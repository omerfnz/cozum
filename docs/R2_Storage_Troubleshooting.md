# 🔧 Cloudflare R2 Storage Sorun Giderme Rehberi

## Özet
Bu doküman, Cloudflare R2 storage entegrasyonu sırasında yaşanan SSL protokol hataları ve çözüm sürecini detaylandırır.

## Yaşanan Problem

### SSL Protocol Error
```
GET https://pub-bc7868c2204542da94c19ee388e79ab1.r2.dev/reports/2025/08/24/28/image.jpg 
net::ERR_SSL_PROTOCOL_ERROR
```

### Belirtiler
- R2'ye dosya yükleme işlemi başarılı
- Backend'de dosyalar doğru şekilde kaydediliyor
- Frontend'de resimler yüklenmiyor
- Tarayıcı konsolunda SSL protokol hatası

## Kök Sebep Analizi

### Problem
Custom domain'ler (`pub-xxxx.r2.dev`) bazen SSL sertifika konfigürasyonu sorunları yaşayabilir.

### Çözüm Stratejisi
1. **Geçici Fix**: Custom domain'i devre dışı bırak
2. **Direct Endpoint**: Cloudflare'in doğrudan R2 endpoint'ini kullan
3. **Server Restart**: Environment değişkenleri değişikliklerinden sonra
4. **SSL Doğrulama**: Custom domain SSL düzgün çalıştıktan sonra tekrar aktif et

## Adım Adım Çözüm

### 1. Environment Değişkenini Güncelle
```ini
# .env dosyasında
# SSL sorunları nedeniyle custom domain devre dışı
R2_CUSTOM_DOMAIN=
```

### 2. Django Sunucusunu Yeniden Başlat
- Komut satırında `Ctrl+C` ile durdur
- `python manage.py runserver` ile tekrar başlat

### 3. URL Generation'ı Kontrol Et
Sistem otomatik olarak direct endpoint kullanacak:
```
https://bucket-name.account-id.r2.cloudflarestorage.com/path/to/file.jpg
```

### 4. Health Check ile Doğrula
```bash
GET /api/health/
```

Beklenen response:
```json
{
  "storage": {
    "type": "R2",
    "test_url": "https://cozum-media.0454dde75c1f807c88f49035deb5b60a.r2.cloudflarestorage.com/test/dummy.jpg",
    "write_test": "SUCCESS",
    "cleanup": "SUCCESS"
  }
}
```

## Kod Değişiklikleri

### MediaSerializer URL Generation
```python
def get_file(self, obj):
    if getattr(settings, 'USE_R2', False):
        if not url.startswith('https://'):
            # Build URL with custom domain or direct endpoint
            domain = getattr(settings, 'R2_CUSTOM_DOMAIN', '')
            if domain and domain.strip():
                url = f'https://{domain}{url}'
            else:
                # Use direct R2 endpoint
                account_id = getattr(settings, 'R2_ACCOUNT_ID', '')
                bucket_name = getattr(settings, 'R2_BUCKET_NAME', '')
                url = f'https://{bucket_name}.{account_id}.r2.cloudflarestorage.com{url}'
    # ... rest of code ...
```

### Settings.py Güncelleme
```python
# Use direct R2 endpoint for reliable HTTPS instead of custom domain
if R2_CUSTOM_DOMAIN and R2_CUSTOM_DOMAIN.strip():
    MEDIA_URL = f"https://{R2_CUSTOM_DOMAIN}/"
else:
    # Use direct R2 endpoint which has proper SSL certificates
    MEDIA_URL = f"https://{R2_BUCKET_NAME}.{R2_ACCOUNT_ID}.r2.cloudflarestorage.com/"
```

## Başarı Kriterleri

### ✅ Çözüm Tamamlandı
- [ ] SSL hatası ortadan kalktı
- [ ] Resimler frontend'de görüntüleniyor
- [ ] Health check SUCCESS döndürüyor
- [ ] Upload işlemi çalışıyor
- [ ] URL'ler HTTPS ile başlıyor

## Custom Domain Tekrar Aktifleştirme

### Gelecekte Custom Domain Kullanımı
1. **DNS Ayarları**: CNAME kaydını doğru yapılandır
2. **SSL Sertifikası**: Domain için SSL sertifikasını aktif et
3. **Test**: Direct test et custom domain'in çalıştığından emin ol
4. **Environment**: `R2_CUSTOM_DOMAIN=media.yourdomain.com`
5. **Restart**: Django sunucusunu yeniden başlat

### Önerilen Custom Domain
```ini
# Professional görünüm için
R2_CUSTOM_DOMAIN=media.ntek.com.tr
```

## Önleme Stratejileri

### Gelecekteki Projeler İçin
1. **İlk Test**: Her zaman direct endpoint ile başla
2. **SSL Kontrolü**: Custom domain eklemeden önce SSL'i doğrula
3. **Health Check**: Her değişiklikten sonra health endpoint'i kontrol et
4. **Documentation**: SSL sorunlarını dokümante et

## Öğrenilen Dersler

### Teknik
- Direct R2 endpoint her zaman güvenilir SSL'e sahip
- Custom domain'ler ekstra yapılandırma gerektirir
- Environment değişkenleri değişikliklerinden sonra server restart şart

### Süreç
- SSL sorunlarında ilk çözüm: direct endpoint'e geç
- Health check endpoint troubleshooting için kritik
- Serializer'da intelligent URL generation önemli

## Referanslar

### İlgili Dosyalar
- `backend/.env` - Environment variables
- `backend/cozum_var_backend/settings.py` - R2 configuration
- `backend/reports/serializers.py` - URL generation logic
- `backend/cozum_var_backend/health.py` - Health check endpoint

### Cloudflare R2 Docs
- [R2 Custom Domains](https://developers.cloudflare.com/r2/data-access/public-buckets/)
- [R2 SSL Configuration](https://developers.cloudflare.com/ssl/)