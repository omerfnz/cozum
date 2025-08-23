from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
import os

User = get_user_model()


class Command(BaseCommand):
    help = 'Admin kullanıcısı oluşturur'

    def handle(self, *args, **options):
        admin_email = os.environ.get('ADMIN_EMAIL', 'admin@example.com')
        admin_password = os.environ.get('ADMIN_PASSWORD', 'admin123')
        admin_username = os.environ.get('ADMIN_USERNAME', 'admin')
        
        # Admin kullanıcısı zaten varsa uyarı ver
        if User.objects.filter(email=admin_email).exists():
            self.stdout.write(
                self.style.WARNING(f'Admin kullanıcısı zaten mevcut: {admin_email}')
            )
            return
        
        # Admin kullanıcısı oluştur
        try:
            admin_user = User.objects.create_superuser(
                email=admin_email,
                password=admin_password,
                username=admin_username,
                first_name='Admin',
                last_name='User'
            )
            
            self.stdout.write(
                self.style.SUCCESS(
                    f'Admin kullanıcısı başarıyla oluşturuldu: {admin_email}'
                )
            )
            
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Admin kullanıcısı oluşturulurken hata: {str(e)}')
            )