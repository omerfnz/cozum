from django.contrib import admin

from .models import Category, Comment, Media, Report


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("name", "is_active", "created_at")
    list_filter = ("is_active", "created_at")
    search_fields = ("name", "description")


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = (
        "title",
        "status",
        "priority",
        "reporter",
        "category",
        "assigned_team",
        "created_at",
    )
    list_filter = ("status", "priority", "category", "assigned_team", "created_at")
    search_fields = ("title", "description", "location")
    raw_id_fields = ("reporter",)


@admin.register(Media)
class MediaAdmin(admin.ModelAdmin):
    list_display = ("report", "media_type", "file_path", "file_size", "uploaded_at")
    list_filter = ("media_type", "uploaded_at")
    search_fields = ("file_path",)


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ("report", "user", "created_at")
    list_filter = ("created_at",)
    search_fields = ("content",)
