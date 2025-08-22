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
  - 401 durumunda refresh token akışı ve otomatik yeniden deneme.
  - Access/refresh token saklama: `flutter_secure_storage` (Android/iOS güvenli depolama)
- Medya:
  - `image_picker` ile tek fotoğraf seçimi; `FormData` ile multipart POST (dio).
- Navigasyon ve Mimarî:
  - `auto_route` ile yönlendirme, `get_it` ile DI, `flutter_bloc`/`equatable` ile state yönetimi.
- Not:
  - MVP’de harita entegrasyonu opsiyoneldir; konum metin alanı yeterlidir. Harita için `google_maps_flutter` eklenerek AndroidManifest’e Google Maps API anahtarı gömülmelidir.

#### Lint ve Analiz (Flutter)
- Lint kural seti: `analysis_options.yaml` içerisinde `package:flutter_lints/flutter.yaml` dahil edilmiştir ve geliştirmeyi hızlandırmak için bazı stil kuralları gevşetilmiştir.
- Kullanılan dev bağımlılıklar: `flutter_lints`, `very_good_analysis` (pubspec altında mevcuttur).
- Kod güncellemeleri:
  - `withOpacity(..)` çağrıları `withValues(alpha: ..)` ile güncellendi (deprecate uyarıları giderildi).
  - Import sırası düzeltildi (directives_ordering).
  - Kayıt sayfasında yalnızca sayısal şifreleri reddeden regex `%5E\d%2B$` → `^\d+$` olarak düzeltildi.
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