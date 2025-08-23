# Çözüm Var Backend - Production Deployment Guide

## Dokploy ile Deployment

### Ön Gereksinimler

1. Dokploy kurulu bir sunucu
2. Domain adı (opsiyonel, IP adresi ile de çalışır)
3. SSL sertifikası (production için önerilir)

### Deployment Adımları

#### 1. Proje Hazırlığı

```bash
# .env dosyasını oluşturun
cp .env.example .env

# .env dosyasını düzenleyin
nano .env
```

#### 2. Dokploy Konfigürasyonu

1. Dokploy dashboard'una giriş yapın
2. Yeni bir proje oluşturun: "cozum-var-backend"
3. Git repository'sini bağlayın
4. Build ayarlarını yapılandırın:
   - Build Command: `docker build -t cozum-var-backend .`
   - Start Command: `docker-compose up -d`

#### 3. Environment Variables

Dokploy'da aşağıdaki environment variable'ları ekleyin:

```
DJANGO_SETTINGS_MODULE=cozum_var_backend.settings
SECRET_KEY=your-very-secure-secret-key-here
DEBUG=False
DB_NAME=cozum_var_db
DB_USER=postgres
DB_PASSWORD=your-secure-db-password
DB_HOST=db
DB_PORT=5432
REDIS_URL=redis://redis:6379/1
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=noreply@yourdomain.com
ADMIN_EMAIL=admin@yourdomain.com
SERVER_EMAIL=server@yourdomain.com
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

#### 4. Database Migration

İlk deployment'tan sonra:

```bash
# Container'a bağlanın
docker exec -it cozum-var-backend-backend-1 bash

# Migration'ları çalıştırın
python manage.py migrate

# Superuser oluşturun
python manage.py createsuperuser

# Static dosyaları toplayın (zaten Dockerfile'da yapılıyor)
python manage.py collectstatic --noinput
```

#### 5. SSL Konfigürasyonu (Opsiyonel)

1. SSL sertifikalarını `/ssl` dizinine yerleştirin
2. `nginx.conf` dosyasındaki HTTPS server bloğunu aktif edin
3. Domain adınızı güncelleyin

### Monitoring ve Maintenance

#### Health Check

Uygulama health check endpoint'i: `https://yourdomain.com/api/health/`

#### Log Monitoring

```bash
# Backend logları
docker logs cozum-var-backend-backend-1 -f

# Nginx logları
docker logs cozum-var-backend-nginx-1 -f

# Database logları
docker logs cozum-var-backend-db-1 -f
```

#### Backup

```bash
# Database backup
docker exec cozum-var-backend-db-1 pg_dump -U postgres cozum_var_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Media files backup
tar -czf media_backup_$(date +%Y%m%d_%H%M%S).tar.gz ./media/
```

### Güvenlik Önerileri

1. **Güçlü şifreler kullanın**: Database ve Django secret key için
2. **SSL kullanın**: Production'da mutlaka HTTPS aktif edin
3. **Firewall**: Sadece gerekli portları açın (80, 443)
4. **Regular updates**: Container image'larını düzenli güncelleyin
5. **Backup**: Düzenli database ve media backup'ları alın

### Troubleshooting

#### Common Issues

1. **Database connection error**:
   - DB container'ının çalıştığını kontrol edin
   - Environment variable'ları kontrol edin

2. **Static files not loading**:
   - `collectstatic` komutunu çalıştırın
   - Nginx konfigürasyonunu kontrol edin

3. **CORS errors**:
   - `CORS_ALLOWED_ORIGINS` ayarını kontrol edin
   - Frontend URL'lerini doğru eklediğinizden emin olun

#### Performance Tuning

1. **Gunicorn workers**: CPU core sayısına göre ayarlayın
2. **Database connections**: Connection pooling kullanın
3. **Redis cache**: Cache timeout değerlerini optimize edin
4. **Nginx**: Gzip compression ve caching aktif

### Support

Sorun yaşadığınızda:

1. Logları kontrol edin
2. Health check endpoint'ini test edin
3. Container status'larını kontrol edin: `docker ps`
4. Resource usage'ı kontrol edin: `docker stats`