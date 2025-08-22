from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import Team, User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    """Özel kullanıcı admin paneli"""

    list_display = (
        "email",
        "username",
        "first_name",
        "last_name",
        "role",
        "team",
        "is_active",
    )
    list_filter = ("role", "is_active", "is_staff", "team")
    search_fields = ("email", "username", "first_name", "last_name")
    ordering = ("email",)

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        (
            "Kişisel Bilgiler",
            {"fields": ("first_name", "last_name", "username", "phone", "address")},
        ),
        ("Rol ve Takım", {"fields": ("role", "team")}),
        (
            "İzinler",
            {
                "fields": (
                    "is_active",
                    "is_staff",
                    "is_superuser",
                    "groups",
                    "user_permissions",
                )
            },
        ),
        ("Önemli Tarihler", {"fields": ("last_login", "date_joined")}),
    )

    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("email", "username", "password1", "password2", "role"),
            },
        ),
    )


@admin.register(Team)
class TeamAdmin(admin.ModelAdmin):
    """Takım admin paneli"""

    list_display = ("name", "team_type", "created_by", "is_active", "created_at")
    list_filter = ("team_type", "is_active", "created_at")
    search_fields = ("name", "description")
    ordering = ("name",)

    fieldsets = (
        (None, {"fields": ("name", "description", "team_type", "is_active")}),
        ("İlişkiler", {"fields": ("created_by", "members")}),
    )

    filter_horizontal = ("members",)
