import os

from django.conf import settings
from django.core.validators import FileExtensionValidator
from django.db import models
from PIL import Image, UnidentifiedImageError
from datetime import date


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
        validators=[FileExtensionValidator(["jpg", "jpeg", "png"])],
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
        """Dosya bilgilerini otomatik doldur"""
        if self.file:
            self.file_path = self.file.name
            self.file_size = self.file.size

        super().save(*args, **kwargs)

        # Resim boyutunu optimize et
        if self.file and self.media_type == "IMAGE":
            img_path = self.file.path
            if os.path.exists(img_path):
                try:
                    with Image.open(img_path) as img:
                        if img.height > 1024 or img.width > 1024:
                            img.thumbnail((1024, 1024), Image.Resampling.LANCZOS)
                            img.save(img_path, optimize=True, quality=85)
                except (UnidentifiedImageError, OSError):
                    # Geçersiz/bozuk dosya içeriğinde optimizasyonu atla
                    pass

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
