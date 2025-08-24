from django.apps import AppConfig


class ReportsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "reports"

    def ready(self):
        # HEIC/HEIF desteği: pillow-heif opsiyonel, varsa opener kaydını yap
        try:
            import pillow_heif  # type: ignore

            pillow_heif.register_heif_opener()
        except Exception:
            # Bağımlılık yoksa veya kayıt sırasında hata olursa sessiz geç
            pass
