# 🚀 Teknoloji Yığını ve Kurulum Rehberi (Güncel)

Bu doküman, mevcut backend (Django) uygulamasına ve projedeki diğer bileşenlere göre güncellenmiştir. Aşağıdaki adımlar Windows ortamı içindir ve Python sanal ortamı (venv) kullanılmasını zorunlu kılar.

## Backend
- Framework: Django 4.2.23
- API: Django REST Framework (DRF)
- Kimlik Doğrulama: JWT (djangorestframework-simplejwt)
- Veritabanı: PostgreSQL (geliştirme ve üretim)
- Medya İşleme: Pillow
- Dosya Depolama: Opsiyonel Cloudflare R2 (S3-compatible) — django-storages üzerinden
- CORS: django-cors-headers

## Frontend (Web)
- React + Vite
- Tailwind CSS
- Harita: Leaflet + react-leaflet

## Mobil (Flutter)
- Flutter 3.22+
- Önerilen paketler: dio, get_it, auto_route, flutter_bloc, image_picker, geolocator, url_launcher, intl

---

## Adım Adım Backend Kurulumu (Windows)
1) Python Sanal Ortamını Oluştur ve Aktif Et (PowerShell)
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
# Gerekirse (script çalıştırma izni yoksa): Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

2) Bağımlılıkları Yükle
```powershell
pip install -r requirements.txt
```

3) Ortam Değişkenlerini Yapılandır (.env)
- Kök dizindeki .env.example dosyasını .env olarak kopyalayın ve değerleri düzenleyin:
  - SECRET_KEY, DEBUG
  - ALLOWED_HOSTS (örn: localhost,127.0.0.1,192.168.1.10)
  - CORS_ALLOWED_ORIGINS (örn: http://localhost:5173)
  - DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT
  - USE_R2, R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET_NAME, R2_CUSTOM_DOMAIN (opsiyonel)

```powershell
Copy-Item .env.example .env
```

4) Veritabanı Migrasyonları ve Yönetici Kullanıcı
```powershell
python manage.py migrate
python manage.py createsuperuser
```

5) Geliştirme Sunucusunu Başlat
```powershell
python manage.py runserver 0.0.0.0:8000
```

6) Sağlık Kontrolü
- Tarayıcıdan veya bir HTTP istemcisinden GET /api/health/ çağırın:
  - R2 kapalıysa yerel medya ayarlarını,
  - R2 etkinse R2 bağlantı/URL yapılandırmasını, yazma/temizleme test sonuçlarını döner.

---

## Docker ile Çalıştırma (Opsiyonel)
- Proje kökünde aşağıdaki komutu çalıştırın:
```powershell
docker compose up --build -d
```
- docker-compose, PostgreSQL ve Django’yu birlikte ayağa kaldırmak için yapılandırılmıştır. İlk kurulumda migrate/createsuperuser adımlarını konteyner içinde çalıştırmanız gerekebilir.

---

## Önemli Ayarlar (settings.py ile uyumlu)
- APPEND_SLASH=False: Tüm API yolları sondaki eğik çizgi ile çağrılmalıdır (ör. /api/reports/). Slashesiz çağrılar 404 dönebilir.
- DRF Varsayılan İzin: IsAuthenticated. Sadece register ve login uçları AllowAny.
- JWT Süreleri: ACCESS_TOKEN 60 dk, REFRESH_TOKEN 7 gün.
- CORS: Geliştirmede CORS_ALLOW_ALL_ORIGINS=True; üretimde CORS_ALLOWED_ORIGINS ortam değişkeni ile alan kısıtlayın.
- Proxy Arkası HTTPS: USE_X_FORWARDED_HOST=True ve SECURE_PROXY_SSL_HEADER tanımlıdır.
- Medya/R2:
  - Varsayılan: MEDIA_URL=/media/, MEDIA_ROOT=<proje_kökü>/media
  - USE_R2=True ise S3 Storage kullanılır. R2_CUSTOM_DOMAIN doluysa MEDIA_URL=https://<custom_domain>/, boşsa https://<bucket>.<account>.r2.cloudflarestorage.com/

---

## Cloudflare R2 Konfigürasyonu (Opsiyonel)
### Ortam Değişkenleri (.env)
```ini
USE_R2=True
R2_ACCOUNT_ID=your_account_id
R2_ACCESS_KEY_ID=your_access_key
R2_SECRET_ACCESS_KEY=your_secret_key
R2_BUCKET_NAME=your_bucket
# Opsiyonel: media.example.com veya pub-xxxxxxx.r2.dev
R2_CUSTOM_DOMAIN=
```

### SSL ve URL Seçimi
- Custom domain SSL sorun çıkarıyorsa R2_CUSTOM_DOMAIN boş bırakın; Django otomatik olarak güvenilir doğrudan R2 endpoint’ini (bucket.account.r2.cloudflarestorage.com) kullanır.

### Sağlık Kontrolü ile Doğrulama
- GET /api/health/ çağrısı; R2 yapılandırması, örnek URL üretimi, yazma/temizleme test sonuçlarını döndürür.

### Medya URL Üretimi
- Serializer’lar (özellikle Media/Report) mutlak URL üretir. İstek bağlamı varsa request.build_absolute_uri(file.url) kullanılır; aksi halde file.url döner.

---

## Medya Yükleme Yolu
- Yükleme kuralı: reports/YYYY/MM/DD/<report_id>/<filename>
- Desteklenen uzantılar: jpg, jpeg, png, webp, heic, heif
- Görsel optimizasyonu: Büyük görseller 1024x1024’e kadar küçültülür; JPEG kalite 85; PNG/WEBP optimize edilir.

---

## Test ve Kod Kalitesi
- Testler (pytest):
```powershell
pytest -q
```
- Lint (flake8):
```powershell
flake8
```
- Otomatik format (black) ve import düzeni (isort):
```powershell
black .
isort .
```

---

## Frontend Kurulumu (özet)
1) Node.js 18+
2) İlgili frontend klasöründe:
```powershell
npm install
npm run dev
```
3) .env (örnek):
```ini
VITE_API_BASE_URL=http://localhost:8000/api
```
4) Leaflet bağımlılıkları:
```powershell
npm i leaflet react-leaflet
npm i -D @types/leaflet
```

## Mobil (Flutter) Notları (özet)
- Çalıştırma:
```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
```
- Ağ katmanı: Authorization: Bearer <access>
- Varsayılan feed kapsamı (rol bazlı): VATANDAS→mine, EKIP→assigned, OPERATOR/ADMIN→all
- Medya: multipart/form-data ile görsel yükleme desteklenir.

- AutoRoute v9 notu:
  - MaterialApp.router bağlama: `routerConfig: appRouter.config()`
  - Kod üretimi: `dart run build_runner build --delete-conflicting-outputs`

- Native Splash (flutter_native_splash):
  1) Geliştirme bağımlılığı ekleyin (pubspec.yaml dev_dependencies): `flutter_native_splash: ^2.4.0`
  2) pubspec.yaml altında konfigürasyon ekleyin:
```yaml
flutter_native_splash:
  color: "#1976D2"
  color_dark: "#0D47A1"
  android_12:
    color: "#1976D2"
    color_dark: "#0D47A1"
```
  3) PowerShell'de oluşturun:
```powershell
flutter pub get
dart run flutter_native_splash:create
```
  4) Doğrulama: Uygulamayı başlatın, native splash ardından AutoRoute Guard akışı (SplashView → LoginView/HomeView) çalışmalıdır.

### Android - MIUI Cihazlarda İlk Açılış ANR Çözümü
- Bazı MIUI cihazlarda ilk açılışta Profile Installer tetiklenmesi ANR'a sebep olabilir.
- Çözüm: Profile Installer'ı devre dışı bırakın.
  1) AndroidManifest'e tools namespace ekleyin (manifest etiketi): `xmlns:tools="http://schemas.android.com/tools"`
  2) application etiketine aşağıdaki meta-data'yı ekleyin:
```xml
<meta-data
    android:name="androidx.profileinstaller.ProfileInstaller"
    android:value="false" />
```
  3) PowerShell'de temizleyip bağımlılıkları yenileyin:
```powershell
flutter clean
flutter pub get
```
  4) Doğrulama: Uygulamayı cihazdan kaldırıp yeniden yükleyin ve ilk açılışta ANR olmadığını doğrulayın.
- Not: PowerShell'de komutları && ile zincirlemeyin; ayrı ayrı çalıştırın.