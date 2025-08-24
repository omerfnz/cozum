import os

from django.conf import settings
from django.core.validators import FileExtensionValidator
from django.db import models
from PIL import Image, UnidentifiedImageError
from datetime import date
from io import BytesIO
from django.core.files.uploadedfile import InMemoryUploadedFile


class Category(models.Model):
    """Bildirim kategorileri modeli"""

    name = models.CharField(max_length=100, verbose_name="Kategori Adı")
    description = models.TextField(blank=True, null=True, verbose_name="Açıklama")
    is_active = models.BooleanField(default=True, verbose_name="Aktif")
    created_at = models.DateTimeField(
        auto_now_add=True, verbose_name="Oluşturulma Tarihi"
    )

    class Meta:
        verbose_name = "Kategori"
        verbose_name_plural = "Kategoriler"

    def __str__(self):
        return self.name


class Report(models.Model):
    """Bildirimler modeli"""

    STATUS_CHOICES = [
        ("BEKLEMEDE", "Beklemede"),
        ("INCELENIYOR", "İnceleniyor"),
        ("COZULDU", "Çözüldü"),
        ("REDDEDILDI", "Reddedildi"),
    ]

    PRIORITY_CHOICES = [
        ("DUSUK", "Düşük"),
        ("ORTA", "Orta"),
        ("YUKSEK", "Yüksek"),
        ("ACIL", "Acil"),
    ]

    title = models.CharField(max_length=200, verbose_name="Başlık")
    description = models.TextField(verbose_name="Açıklama")
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default="BEKLEMEDE", verbose_name="Durum"
    )
    priority = models.CharField(
        max_length=20, choices=PRIORITY_CHOICES, default="ORTA", verbose_name="Öncelik"
    )
    reporter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="reported_issues",
        verbose_name="Bildiren",
    )
    category = models.ForeignKey(
        Category,
        on_delete=models.CASCADE,
        related_name="reports",
        verbose_name="Kategori",
    )
    assigned_team = models.ForeignKey(
        "users.Team",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="assigned_reports",
        verbose_name="Atanan Takım",
    )
    location = models.CharField(
        max_length=500, blank=True, null=True, verbose_name="Konum"
    )
    latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True, verbose_name="Enlem"
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True, verbose_name="Boylam"
    )
    created_at = models.DateTimeField(
        auto_now_add=True, verbose_name="Oluşturulma Tarihi"
    )
    updated_at = models.DateTimeField(auto_now=True, verbose_name="Güncellenme Tarihi")

    class Meta:
        verbose_name = "Bildirim"
        verbose_name_plural = "Bildirimler"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.title} - {self.get_status_display()}"


def report_media_upload_to(instance, filename):
    """Yükleme yolunu yil/ay/gun ve rapor ID bazlı oluşturur."""
    today = date.today()
    report_id = getattr(instance, "report_id", None) or (
        getattr(instance, "report", None).id if getattr(instance, "report", None) else "unassigned"
    )
    return f"reports/{today:%Y/%m/%d}/{report_id}/{filename}"


class Media(models.Model):
    """Bildirim medyaları modeli"""

    MEDIA_TYPE_CHOICES = [
        ("IMAGE", "Resim"),
        ("VIDEO", "Video"),
    ]

    report = models.ForeignKey(
        Report,
        on_delete=models.CASCADE,
        related_name="media_files",
        verbose_name="Bildirim",
    )
    file = models.ImageField(
        upload_to=report_media_upload_to,
        validators=[FileExtensionValidator(["jpg", "jpeg", "png", "webp", "heic", "heif"])],
        verbose_name="Dosya",
    )
    file_path = models.CharField(max_length=500, blank=True, verbose_name="Dosya Yolu")
    file_size = models.PositiveIntegerField(
        null=True, blank=True, verbose_name="Dosya Boyutu (bytes)"
    )
    media_type = models.CharField(
        max_length=10,
        choices=MEDIA_TYPE_CHOICES,
        default="IMAGE",
        verbose_name="Medya Tipi",
    )
    uploaded_at = models.DateTimeField(
        auto_now_add=True, verbose_name="Yüklenme Tarihi"
    )

    class Meta:
        verbose_name = "Medya"
        verbose_name_plural = "Medyalar"

    def save(self, *args, **kwargs):
        """Dosya bilgilerini otomatik doldur ve R2/S3 gibi uzak depolarla uyumlu şekilde görüntüleri optimize et"""
        if self.file:
            # Yeni dosya yüklemelerinde (henüz storage'a yazılmamışken) optimize et
            if not getattr(self.file, "_committed", False) and self.media_type == "IMAGE":
                try:
                    try:
                        self.file.seek(0)
                    except Exception:
                        pass

                    with Image.open(self.file) as img:
                        img_format = (img.format or "").upper()
                        if img_format in ("JPG",):
                            img_format = "JPEG"

                        # Büyük görselleri 1024x1024 içinde tut
                        if img.height > 1024 or img.width > 1024:
                            img.thumbnail((1024, 1024), Image.Resampling.LANCZOS)

                        buffer = BytesIO()
                        save_kwargs = {"optimize": True}
                        if img_format == "JPEG":
                            save_kwargs["quality"] = 85
                        # Geçersiz formatlarda JPEG'e düş
                        final_format = img_format if img_format in ("JPEG", "PNG", "WEBP") else "JPEG"
                        img.save(buffer, format=final_format, **save_kwargs)
                        buffer.seek(0)

                        # İçerik türü belirle
                        content_type = "image/jpeg" if final_format == "JPEG" else f"image/{final_format.lower()}"

                        # Dosya adını koru, uzantıyı formatla eşleştir
                        original_name = getattr(self.file, "name", "upload")
                        root, ext = os.path.splitext(original_name)
                        if final_format == "JPEG" and ext.lower() not in (".jpg", ".jpeg"):
                            new_name = f"{root}.jpg"
                        elif final_format == "PNG" and ext.lower() != ".png":
                            new_name = f"{root}.png"
                        elif final_format == "WEBP" and ext.lower() != ".webp":
                            new_name = f"{root}.webp"
                        else:
                            new_name = original_name

                        new_file = InMemoryUploadedFile(
                            file=buffer,
                            field_name="file",
                            name=new_name,
                            content_type=content_type,
                            size=buffer.getbuffer().nbytes,
                            charset=None,
                        )
                        self.file = new_file
                except (UnidentifiedImageError, OSError):
                    # Geçersiz/bozuk dosya içeriğinde optimizasyonu atla
                    pass
                except Exception:
                    # Beklenmedik durumlarda optimizasyonu atla, yüklemeye engel olma
                    pass

            # Dosya meta bilgileri
            self.file_path = self.file.name
            try:
                self.file_size = self.file.size
            except Exception:
                self.file_size = None

        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.report.title} - {self.get_media_type_display()}"


class Comment(models.Model):
    """Bildirim yorumları modeli"""

    report = models.ForeignKey(
        Report,
        on_delete=models.CASCADE,
        related_name="comments",
        verbose_name="Bildirim",
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="comments",
        verbose_name="Kullanıcı",
    )
    content = models.TextField(verbose_name="İçerik")
    created_at = models.DateTimeField(
        auto_now_add=True, verbose_name="Oluşturulma Tarihi"
    )

    class Meta:
        verbose_name = "Yorum"
        verbose_name_plural = "Yorumlar"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.user.email} - {self.report.title}"
