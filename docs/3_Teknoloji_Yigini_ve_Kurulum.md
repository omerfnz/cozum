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

### Mobile (React Native + Expo)
- Çalıştırma:
  - Windows PowerShell: `cd mobile` ve `npm run start`
  - Expo Developer Tools’taki QR’ı Expo Go ile tara (web modu kullanılmaz)
- Ortam değişkeni:
  - `mobile/.env`: `EXPO_PUBLIC_API_BASE_URL=http://localhost:8000/api`
- Ağ katmanı:
  - axios instance (Authorization: Bearer <token>) ve 401 durumunda refresh token ile otomatik yenileme
  - AsyncStorage ile access/refresh token saklama
- Medya:
  - expo-image-picker ile tek fotoğraf seçimi; FormData ile multipart POST
  - Not: Axios boundary’i otomatik belirler; özel bir gereksinim yoksa Content-Type’ı manuel set etmemek önerilir
- Navigasyon:
  - `@react-navigation/native` + `@react-navigation/native-stack`
- Not:
  - Mobil geliştirme hedefi gerçek cihaz (Expo Go). Web sürümü desteklenmiyor.

---

#### Mobile – Google Maps ve Geliştirme Derlemesi (Android)
- Expo Go ile Android’de Google Maps (react-native-maps) API anahtarı native seviyede gömülemediği için harita boş/gri görünebilir. Bu durumda “Development Build” veya EAS Cloud Build kullanılmalıdır.

1) Gerekli bağımlılıklar
```powershell
cd mobile
npm i react-native-maps expo-location expo-image-picker
```

2) Google Maps API anahtarını native’e göm (depolamaya ekleme!)
- app.config.js / app.json içinde Android için aşağıdakini tanımla (anahtarı git’e koyma, EAS secret önerilir):
```jsonc
{
  "expo": {
    "android": {
      "config": {
        "googleMaps": { "apiKey": "<GOOGLE_MAPS_API_KEY>" }
      }
    }
  }
}
```
- Alternatif: AndroidManifest.xml içine `com.google.android.geo.API_KEY` meta-data eklenebilir.

3) Yerel Android geliştirme derlemesi (Windows)
```powershell
# Java ve Android SDK için geçici ortam değişkenleri
$env:JAVA_HOME="C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_SDK_ROOT="$env:LOCALAPPDATA\Android\Sdk"
$env:Path="$env:ANDROID_SDK_ROOT\platform-tools;$env:JAVA_HOME\bin;$env:Path"

# Cihaz bağlantısı
adb version
adb devices  # USB hata ayıklama açık ve RSA izni verildi olmalı

# Native üretim ve yükleme
cd android
.\gradlew installDebug   # veya: .\gradlew assembleDebug && adb install -r .\app\build\outputs\apk\debug\app-debug.apk

# Metro bundler ile çalıştırma
cd ..
npx expo start --dev-client
```

4) EAS Cloud Development Build (alternatif)
```powershell
eas login
cd mobile
eas build:configure
# Google Maps anahtarını gizli olarak ekle
EAS_SECRET="<GOOGLE_MAPS_API_KEY>"
eas secret:create --name GOOGLE_MAPS_API_KEY --value "$EAS_SECRET"
# Development profiliyle derle
eas build -p android --profile development
# İndirip cihaza kurduktan sonra
npx expo start --dev-client
```

5) Sorun giderme
- `npx expo run:android` cihaz bulunamadı: `adb devices` ile kontrol edin, sürücüler ve USB hata ayıklama açık olmalı.
- `adb` tanınmıyor: `ANDROID_SDK_ROOT` ve `Path` içine `platform-tools` ekleyin.
- `JAVA_HOME` eksik: Android Studio JBR yolunu `JAVA_HOME` olarak ayarlayın.
- Harita boş/gri: Expo Go yerine development build kullanın; cihazda Google Play Services güncel olsun.