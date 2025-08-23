# 🚀 Teknoloji Yığını ve Kurulum Rehberi

### Backend
* **Framework:** Django
* **API için:** Django REST Framework (DRF)
* **Kimlik Doğrulama:** djangorestframework-simplejwt (JWT)
* **Veritabanı:** Geliştirme için SQLite, Production için PostgreSQL
* **Medya Yönetimi:** Pillow (Resim işleme kütüphanesi)

### Frontend
* **Kütüphane:** React + Vite
* **Stil:** Tailwind CSS
* **Harita ve Konum:** Leaflet + react-leaflet

### Adım Adım Backend Kurulumu
1.  **Python Sanal Ortamını Oluştur ve Aktif Et (Windows PowerShell):**
    ```powershell
    python -m venv venv
    .\venv\Scripts\Activate.ps1
    ```

2.  **Gerekli Django Paketlerini Yükle:**
    ```powershell
    pip install django djangorestframework Pillow django-cors-headers djangorestframework-simplejwt
    ```

3.  **Django Projesini ve İlk Uygulamayı Oluştur:**
    ```bash
    django-admin startproject cozum_var_backend .
    python manage.py startapp reports
    python manage.py startapp users
    ```

4.  **Önerilen Klasör Yapısı:**
    ```
    cozum_var_backend/
    |-- cozum_var_backend/  # Proje ayarları (settings.py vb.)
    |-- reports/            # Bildirim, kategori, medya, yorum modelleri burada olacak
    |-- users/              # Kullanıcı ve Ekip modelleri burada olacak
    |-- media/              # Yüklenen medya dosyaları
    |-- manage.py
    |-- venv/
    ```

5.  **`settings.py` Dosyasında İlk Ayarlar:**
    * `INSTALLED_APPS` listesine `'rest_framework'`, `'corsheaders'`, `'reports'`, `'users'` uygulamalarını ekle.
    * `CORS_ALLOWED_ORIGINS` ayarını ekleyerek React uygulamasının adresini belirt (örn: `["http://localhost:5173"]`).


### Adım Adım Frontend Kurulumu
1.  Node.js 18+ sürümü önerilir.
2.  Proje kökünde frontend klasörüne geçin ve bağımlılıkları kurun:
    ```powershell
    cd frontend
    npm install
    ```
3.  API adresini tanımlayın (.env dosyası):
    ```ini
    VITE_API_BASE_URL=http://localhost:8000/api
    ```
4.  Leaflet ve react-leaflet bağımlılıklarını kurun (TypeScript için tipler dahil):
    ```powershell
    npm i leaflet react-leaflet
    npm i -D @types/leaflet
    ```
5.  Leaflet CSS'ini global olarak dahil edin (src/main.tsx):
    ```ts
    import 'leaflet/dist/leaflet.css'
    ```
6.  Geliştirme sunucusunu başlatın:
    ```powershell
    npm run dev
    ```
7.  Kod kalitesi ve tip kontrolü (önerilir):
    ```powershell
    npm run lint
    npx tsc --noEmit
    ```

---

### Medya Yükleme Yolu (Django)
- Uygulama, vatandaş tarafından yüklenen medya dosyalarını yıl/ay/gün ve Bildirim ID’sine göre klasörleyen bir yapı kullanır.
- Kural: `media/reports/YYYY/MM/DD/<report_id>/<filename>`
- Teknik uygulama: `reports.models.Media.file` alanında `upload_to` bir fonksiyona atanmıştır (report_media_upload_to). Bu sayede her yüklemede dinamik klasör yolu oluşturulur.
- Not: Bu değişiklik migrasyon gerektirmez; yol kuralları çalışma zamanında uygulanır.

### Mobile (Flutter)
- Çalıştırma:
  - Windows PowerShell: `cd mobile` ve `flutter run`
- Ortam değişkeni:
  - `--dart-define=API_BASE_URL=http://localhost:8000/api` ile taban URL geçilir.
- Ağ katmanı:
  - `dio` ile HTTP istemcisi; Authorization: `Bearer <token>` başlığı için interceptor.
  - 401 durumunda refresh token akışı ve otomatik yeniden deneme; refresh başarısızsa otomatik logout ve `LoginRoute`'a yönlendirme.
  - Access/refresh token saklama: `flutter_secure_storage` (Android/iOS güvenli depolama)
- Medya:
  - `image_picker` ile tek fotoğraf seçimi; `FormData` ile multipart POST (dio).
- Navigasyon ve Mimarî:
  - `auto_route` ile yönlendirme, `get_it` ile DI, `flutter_bloc`/`equatable` ile state yönetimi.
  - Router kullanımı: `AppRouter` tekil örnek olarak DI (get_it) üzerinden sağlanır; interceptor yönlendirmeleriyle aynı router örneği paylaşılır.
- Home Feed Varsayılanları (Mobil):
  - Rol bazlı varsayılan kapsam seçimi: VATANDAS → "mine", EKIP → "assigned", OPERATOR/ADMIN → "all".
  - HomeFeedCubit `fetch(scope)` imzası ile `state.scope` güncellenir ve veri rol bazlı çekilir.
- Not:
  - MVP’de harita entegrasyonu opsiyoneldir; konum metin alanı yeterlidir. Harita için `google_maps_flutter` eklenerek AndroidManifest’e Google Maps API anahtarı gömülmelidir.

#### Lint ve Analiz (Flutter)
- Lint kural seti: `analysis_options.yaml` içerisinde `package:flutter_lints/flutter.yaml` dahil edilmiştir ve geliştirmeyi hızlandırmak için bazı stil kuralları gevşetilmiştir.
- Kullanılan dev bağımlılıklar: `flutter_lints`, `very_good_analysis` (pubspec altında mevcuttur).
- Kod güncellemeleri:
  - `withOpacity(..)` çağrıları `withValues(alpha: ..)` ile güncellendi (deprecate uyarıları giderildi).
  - Import sırası düzeltildi (directives_ordering).
  - Kayıt sayfasında yalnızca sayısal şifreleri reddeden regex `%5E\d%2B$` → `^\d+$` olarak düzeltildi.
  - AutoRoute codegen dosyaları güncellendi (`dart run build_runner build -d`).
- Doğrulama:
  - `flutter analyze` sonucu: No issues found!

---

#### Kurulum Adımları (Windows)
1) Flutter kurulumu doğrula
```powershell
flutter doctor
```

2) Projeyi oluştur (kök dizinde)
```powershell
flutter create mobile
```

3) Bağımlılıkları ekle
```powershell
cd mobile
flutter pub add dio flutter_bloc equatable get_it auto_route flutter_secure_storage image_picker
flutter pub add --dev build_runner auto_route_generator very_good_analysis
```

4) Çalıştırma (API adresi ile)
```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
```

5) Android izinleri (gerekli durumlarda)
- AndroidManifest.xml içine aşağıdaki izinleri ekleyin (hedef API seviyesine göre güncellenebilir):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<!-- Eski cihazlar için: <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" /> -->
```

6) Harita (opsiyonel)
- `google_maps_flutter` ekleyin ve AndroidManifest.xml içine aşağıdaki meta veriyi ekleyin:
```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="@string/google_maps_api_key" />
```
- Anahtarı yerel `local.properties` ya da `res/values/strings.xml` içinde yönetip git’e eklemeyin.

7) Sorun giderme
- `flutter doctor` uyarılarını giderin (Android SDK/JDK, platform-tools, cihaz/emu bağlantısı).
- İzin reddi veya medya seçimi hatalarında Manifest ve runtime izinlerini kontrol edin.
- Ağ çağrısı hatalarında `--dart-define=API_BASE_URL` değerini doğrulayın.

---

# Teknoloji Yığını ve Kurulum

Bu doküman, proje geliştirme ortamının kurulumu ve kullanılan teknolojilerin özetini içerir.

## Backend
- Django, Django REST Framework
- PostgreSQL
- Kimlik doğrulama: JWT (access/refresh)
- Medya: Django Media (MEDIA_URL, MEDIA_ROOT)

## Frontend (Web)
- React (Vite)
- Tailwind CSS
- Leaflet (OpenStreetMap)

## Mobil (Flutter)
- Flutter 3.22+
- Paketler: dio, get_it, auto_route, flutter_bloc, flutter_map, geolocator, image_picker, url_launcher, intl, cached_network_image
- Ortam değişkenleri: API_BASE_URL (örn: http://192.168.1.33:8000/api/)
- Medya URL: http://192.168.1.33:8000/ (MEDIA_URL kökü) — mobil istemci, görsel önizlemelerinde tam URL bekler

### İzinler
- AndroidManifest.xml:
  - INTERNET
  - ACCESS_COARSE_LOCATION, ACCESS_FINE_LOCATION
  - CAMERA, READ_EXTERNAL_STORAGE (Android 13+: READ_MEDIA_IMAGES)
- iOS Info.plist:
  - NSLocationWhenInUseUsageDescription
  - NSCameraUsageDescription
  - NSPhotoLibraryUsageDescription

### Geliştirme ve Çalıştırma
- Windows PowerShell üzerinden:
  - Flutter kurulum kontrolü: flutter doctor
  - Bağımlılıkları indir: flutter pub get
  - Uygulamayı çalıştır: flutter run -d chrome veya cihaz ID
  - Kod üretimi (auto_route): dart run build_runner build --delete-conflicting-outputs

### LAN/IP Notları
- Mobil cihazın, backend ile aynı yerel ağda olduğundan emin olun.
- API_BASE_URL ve medya URL’lerinde cihazdan erişilebilen LAN IP kullanılmalıdır (localhost yerine IP adresi).
- Android Emulator kullanıyorsanız backend’e erişim için özel IP kullanımı: 10.0.2.2 (fiziksel cihazda geçerli değildir).

### Lint ve Analiz
- analysis_options.yaml içinde linter kuralları aktif
- dart fix --apply ve dart analyze ile düzenli kontrol önerilir

- DRF tarafında `MediaSerializer` içerisinde `file` alanı mutlak URL olarak döndürülecek şekilde güncellendi.
- Teknik detay: `request.build_absolute_uri(file.url)` kullanılır; istek bağlamı yoksa `file.url` döner.
- Sonuç: Flutter’da `Image.network` ve webde `<img src>` doğrudan çalışır; `first_media_url` (liste) ve `media_files[].file` (detay) alanları tam URL döndürür.
- Not: Bu değişiklik yalnızca serializer düzeyindedir, migrasyon gerektirmez. Backend’de bu davranışın testleri eklenmeli; prod ortamında `ALLOWED_HOSTS` ve `CSRF_TRUSTED_ORIGINS` LAN/IP yapılandırmalarına dikkat edilmelidir.