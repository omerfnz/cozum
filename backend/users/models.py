from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models


class UserManager(BaseUserManager):
    """Özel kullanıcı manager'ı"""

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email adresi zorunludur")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("role", "ADMIN")

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser is_staff=True olmalı.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser is_superuser=True olmalı.")

        return self.create_user(email, password, **extra_fields)


class User(AbstractUser):
    """Özel kullanıcı modeli"""

    ROLE_CHOICES = [
        ("VATANDAS", "Vatandaş"),
        ("EKIP", "Saha Ekibi"),
        ("OPERATOR", "Operatör"),
        ("ADMIN", "Admin"),
    ]

    email = models.EmailField(unique=True, verbose_name="Email")
    role = models.CharField(
        max_length=20, choices=ROLE_CHOICES, default="VATANDAS", verbose_name="Rol"
    )
    team = models.ForeignKey(
        "Team",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="team_members",
        verbose_name="Takım",
    )
    phone = models.CharField(
        max_length=20, blank=True, null=True, verbose_name="Telefon"
    )
    address = models.TextField(blank=True, null=True, verbose_name="Adres")

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    objects = UserManager()

    class Meta:
        verbose_name = "Kullanıcı"
        verbose_name_plural = "Kullanıcılar"

    def __str__(self):
        return f"{self.email} ({self.get_role_display()})"


class Team(models.Model):
    """Saha ekipleri modeli"""

    TEAM_TYPE_CHOICES = [
        ("EKIP", "Saha Ekibi"),
        ("OPERATOR", "Operatör Takımı"),
        ("ADMIN", "Admin Takımı"),
    ]

    name = models.CharField(max_length=100, verbose_name="Takım Adı")
    description = models.TextField(blank=True, null=True, verbose_name="Açıklama")
    team_type = models.CharField(
        max_length=20,
        choices=TEAM_TYPE_CHOICES,
        default="EKIP",
        verbose_name="Takım Tipi",
    )
    created_by = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="created_teams",
        verbose_name="Oluşturan",
    )
    members = models.ManyToManyField(
        User, related_name="teams", blank=True, verbose_name="Üyeler"
    )
    created_at = models.DateTimeField(
        auto_now_add=True, verbose_name="Oluşturulma Tarihi"
    )
    is_active = models.BooleanField(default=True, verbose_name="Aktif")

    class Meta:
        verbose_name = "Takım"
        verbose_name_plural = "Takımlar"

    def __str__(self):
        return f"{self.name} ({self.get_team_type_display()})"
    
    @property
    def member_count(self):
        """Takımdaki üye sayısını döndürür"""
        return self.team_members.count()
    
    @property
    def created_by_name(self):
        """Takımı oluşturan kişinin adını döndürür"""
        if self.created_by:
            return self.created_by.get_full_name() or self.created_by.username
        return "Bilinmeyen Kullanıcı"
