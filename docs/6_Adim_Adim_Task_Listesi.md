# 🧭 Adım Adım Görev Listesi (MVP - Çözüm Var)

Bu liste, mevcut dokümanlara (Manifesto, MVP Kapsamı, Teknoloji Yığını, Veritabanı Şeması, API Endpoint Listesi) dayanarak MVP’yi uçtan uca hayata geçirmek için detaylı adımları içerir. Her adım tamamlandığında işaretleyerek ilerleyin.

Notlar ve İlke/Kısıtlar:
- Tüm geliştirme Windows ortamında yapılacaktır.
- Python projelerinde her zaman önce venv oluşturulup aktive edilecektir.
- JWT tabanlı kimlik doğrulama kullanılacaktır.
- React+Vite+Tailwind ile basit, işlevsel bir arayüz oluşturulacaktır.
- Dokümantasyon ve kararlar docs klasöründe güncel tutulacaktır (MCP uyumlu bağlam yönetimi ve izlenebilirlik).

A) Başlangıç ve Ortam Hazırlığı
1) Depo ve temel dosyalar
   - [x] Git deposu oluştur, .gitignore (venv, __pycache__, media, node_modules) ekle.
   - [x] docs/ güncel; bu dosya proje planının tek kaynağı olarak kullanılacak.
2) Python sanal ortamı (Windows PowerShell)
   - [x] python -m venv venv
   - [x] .\venv\Scripts\Activate.ps1
   - [x] pip install --upgrade pip
3) Gerekli backend paketleri
   - [x] pip install django djangorestframework Pillow django-cors-headers djangorestframework-simplejwt
   - [x] (Gelişim aşamasında) pip install pytest pytest-django black isort flake8

B) Django Projesi ve Uygulamalar
1) Proje ve uygulamalar
   - [x] django-admin startproject cozum_var_backend .
   - [x] python manage.py startapp users
   - [x] python manage.py startapp reports
2) settings.py ilk ayarlar
   - [x] INSTALLED_APPS: rest_framework, corsheaders, users, reports, rest_framework_simplejwt
   - [x] MIDDLEWARE: corsheaders.middleware.CorsMiddleware en üstlere ekle
   - [x] CORS_ALLOWED_ORIGINS: ["http://localhost:5173"]
   - [x] TIME_ZONE, LANGUAGE_CODE (tr), USE_TZ gibi temel ayarlar
   - [x] MEDIA_URL = "/media/", MEDIA_ROOT = BASE_DIR / "media"
   - [x] AUTH_USER_MODEL = "users.User" (özel kullanıcı modeli tanımlanacak)
   - [x] REST_FRAMEWORK + SimpleJWT ayarları (ACCESS_TOKEN_LIFETIME vb.)
3) urls.py
   - [x] /api/ altında users ve reports endpoint’leri
   - [x] DEBUG iken media servisinin eklenmesi

C) Veritabanı Modelleri (Şema ile uyumlu)
1) User (users/models.py)
   - [x] AbstractUser’dan türetilmiş özel model
   - [x] Alanlar: email (benzersiz, login), role (VATANDAS, EKIP, OPERATOR, ADMIN), team (nullable FK), phone, address
   - [x] USERNAME_FIELD = "email", REQUIRED_FIELDS = ["username"]
   - [x] Manager güncelle (create_user/create_superuser)
2) Team (users/models.py veya ayrı)
   - [x] Alanlar: name, description, team_type, created_by (FK User), members (M2M User), created_at, is_active
3) Category (reports/models.py)
   - [x] Alanlar: name, description, is_active, created_at
4) Report (reports/models.py)
   - [x] Alanlar: title, description, status (BEKLEMEDE, INCELENIYOR, COZULDU, REDDEDILDI), priority (DUSUK, ORTA, YUKSEK, ACIL), reporter (FK User), category (FK Category), assigned_team (FK Team, null), location, latitude, longitude, created_at, updated_at
5) Media (reports/models.py)
   - [x] Alanlar: report (FK), file (ImageField), file_path, file_size, media_type (IMAGE/VIDEO), uploaded_at
   - [x] Resim validasyonları (uzantı/boyut) ve Pillow kullanımı
6) Comment (reports/models.py)
   - [x] Alanlar: report (FK), user (FK User), content, created_at
7) Admin kayıtları ve migrasyon
   - [x] admin.py içinde tüm modelleri kaydet
   - [x] python manage.py makemigrations && python manage.py migrate
   - [x] python manage.py createsuperuser

D) Authentication (JWT) ve Yetkilendirme
1) Kayıt endpointi: POST /auth/register/
   - [x] Yalnızca Vatandaş oluşturur (rol=VATANDAS), email benzersiz kontrolü, şifre doğrulama
   - [x] Başarılı kayıtta kullanıcı bilgisi döndürme
2) Giriş endpointi: POST /auth/login/
   - [x] SimpleJWT ile access/refresh token üretimi
3) DRF permission’lar
   - [x] Role bazlı görünürlük: Operatör/Saha Ekibi/Vatandaş
   - [x] Obje seviyesinde: Vatandaş sadece kendi raporlarını görebilir/düzenleyemez

E) Reports API’leri (Şarta uygun davranış)
1) GET /api/reports/
   - [x] Operatör: tüm raporlar
   - [x] Saha Ekibi: assigned_team kendisinin olduğu raporlar
   - [x] Vatandaş: kendi oluşturduğu raporlar
2) POST /api/reports/
   - [x] Yalnızca Vatandaş, 1 adet fotoğraf yükleme (Media ile ilişki), kategori zorunlu
3) GET /api/reports/{id}/
   - [x] Operatör/Saha Ekibi görebilir; Vatandaş yalnızca kendi raporunu görebilir
4) PATCH /api/reports/{id}/
   - [x] Operatör/Saha Ekibi: status ve assigned_team güncelleyebilir (vatandaş güncelleyemez)

F) Categories API
- [x] GET /api/categories/ (giriş yapmış herkes)

G) Comments API
1) GET /api/reports/{id}/comments/
   - [x] Giriş yapmış herkes listeler (Vatandaş dahil)
2) POST /api/reports/{id}/comments/
   - [x] Operatör ve Saha Ekibi ekler (Vatandaş ekleyemez)

H) Medya ve Dosya Yönetimi
- [x] MEDIA_ROOT yapısı ve dosya yolu kuralı
- [x] Maks. boyut/uzantı kontrolleri, hata mesajları
- [x] Geliştirmede dosya servis; üretimde CDN/harici depolama notu
- [x] Yükleme yolu kuralı: `reports/YYYY/MM/DD/<report_id>/<filename>` (upload_to fonksiyonu ile dinamik klasörleme)

Harita ve Konum (Frontend)
- [x] Leaflet ve react-leaflet kuruldu, leaflet.css global import edildi
- [x] Marker ikon yolu problemi: ikon/retina/shadow görselleri import edilip L.Icon.Default.mergeOptions ile düzeltildi, Marker’a defaultIcon atandı
- [x] Konum seçimi: Haritaya tıklayarak marker yerleştirme, Geolocation API ile “Konumumu Kullan”
- [x] Lat/Lng doğruluğu: Backend hane kısıtı için 6 ondalık basamağa yuvarlama (round6)
- [x] FormData: tek dosya yükleme backend’de listeye dönüştürülerek desteklendi
- [x] Hata mesajları: AxiosError detayları toast ile yüzeye çıkarıldı

I) Test ve Kod Kalitesi
1) Testler
   - [x] Modeller: alan/doğrulama ilişkileri
   - [x] Serializer’lar: giriş/çıkış doğruluğu
   - [x] API: auth, reports, categories, comments akışları
   - [x] Yetkiler: rol bazlı görünürlük ve işlemler
2) Kalite araçları
   - [x] black/isort/flake8 konfigürasyonu
   - [x] pre-commit hook’ları

J) Frontend (React + Vite + Tailwind)
1) Kurulum
   - [x] npm create vite@latest frontend -- --template react
   - [x] cd frontend && npm i && npm i -D tailwindcss postcss autoprefixer && npx tailwindcss init -p
   - [x] Tailwind konfigürasyonu (content, base/components/utilities)
2) Ortak
   - [x] .env: VITE_API_BASE_URL=http://localhost:8000/api
   - [x] axios instance + interceptor (Authorization: Bearer <token>)
   - [x] Auth state ve token saklama (localStorage)
3) Layout ve navigasyon
   - [x] ProtectedLayout: giriş yapmış kullanıcılar için ana düzen
   - [x] Sidebar: menü ve navigasyon (daraltılabilir, responsive); Ayarlar menüsü kaldırıldı
   - [x] AppBar: üst çubuk ve kullanıcı bilgileri; kullanıcı menüsünde Profil bağlantısı eklendi
   - [x] Ana router yapısı (App.tsx) ve korumalı rotalar
4) Sayfalar/akışlar
   - [x] Register (Vatandaş)
   - [x] Login
   - [x] Dashboard: İstatistikler, hızlı erişim kartları, dağılım çubuğu
   - [x] Categories: Kategori listeleme, ekleme, düzenleme, arama/filtreleme, aktif/pasif durumu
   - [x] Users: Kullanıcı yönetimi (listeleme, rol değiştirme, takım atama, silme)
   - [x] Teams: Ekip yönetimi (listeleme, ekleme, düzenleme, soft-delete/pasif yapma)
   - [ ] Reports: Rapor yönetimi (gelecek çalışma)
   - [x] Vatandaş: "Bildirim Oluştur" (başlık, açıklama, kategori, 1 fotoğraf, harita ile konum seçimi [adres/lat/lng], konumumu kullan)
   - [ ] Vatandaş: "Bildirimlerim" listesi + detay
   - [ ] Operatör: tüm raporlar listesi, atama (assigned_team), durum değiştirme
   - [ ] Saha Ekibi: atanmış raporlar listesi, durumu COZULDU yapma, yorum ekleme
   - [ ] Yorumlar: rapor detayında listeleme/ekleme (yetkiye göre)
   - [x] Hata/başarı bildirimleri (react-hot-toast), loading durumları

K) Örnek Veri ve Tohumlama
- [ ] Yönetim komutları/fixture: kategori tohumları (Yol, Aydınlatma vb.)
- [ ] Örnek ekip(ler) ve rol bazlı kullanıcılar

L) Çalıştırma ve Doğrulama
- [x] Backend: python manage.py runserver (venv aktif)
- [x] Frontend: npm run dev (http://localhost:5173)
- [ ] En uçtan uca akış: Vatandaş kayıt->giriş->bildirim; Operatör atama/durum; Ekip çözüm/yorum; Görünürlük kontrolleri

M) Güvenlik ve Üretim Notları (MVP Sonrası)
- [ ] PostgreSQL’e geçiş planı, ortam değişkenleri
- [ ] CORS, dosya güvenliği, rate limit, loglama
- [ ] DRF şema + Swagger (drf-spectacular) dokümantasyonu (opsiyonel)

N) Mobil (React Native + Expo)
1) Kurulum ve Proje Başlatma
   - [x] Node 18+ ve Expo CLI kurulumu
   - [x] Mevcut proje: mobile klasörü altında Expo (TypeScript) yapılandırması
   - [x] Android için native prebuild tamamlandı (npx expo prebuild --platform android)
2) Bağımlılıklar
   - [x] axios, @react-navigation/native, @react-navigation/native-stack
   - [x] @react-native-async-storage/async-storage
   - [x] expo-image-picker (fotoğraf), expo-location (konum)
   - [x] react-native-maps (harita) ve izin ayarları
   - [x] react-native-reanimated, react-native-gesture-handler (navigasyon bağımlılıkları)
3) Harita ve Konum (Mobil)
   - [x] MapSelectScreen: MapView’e onError prop’u, yükleniyor overlay’i ve hata overlay’i eklendi
   - [x] Konum alma: Son bilinen konumu anında kullan, ardından 7 sn timeout ile güncel konumu arka planda getir (MapSelect ve CreateReport’ta)
   - [x] "Konumumu bul" ve "Mevcut konumu kullan" akışları hızlandırıldı; UI bloklanmıyor
   - [ ] Development Build ile cihazda Google Map görünürlüğü doğrulanacak (Expo Go yerine)
4) Çevresel Ayarlar
   - [x] mobile/.env: EXPO_PUBLIC_API_BASE_URL yapılandırıldı
   - [x] app.config.js: android.package eklendi (com.anonymous.cozumvarmobile)
   - [ ] Google Maps API key EAS secret olarak tanımlanacak ve native’e gömülecek
5) Çalıştırma
   - [ ] Yerel: JAVA_HOME/ANDROID_SDK/ADB yolları ayarlanıp .\gradlew installDebug ile kurulum
   - [ ] Cloud: EAS development build ile APK üretip cihaza kurulum

Güncel notlar (Android)
- Expo Go’da Google Maps anahtarı native’e gömülemediği için harita boş/gri görünebilir; çözüm dev build (yerel/EAS).
- ADB tanımsız ve JDK eksikliği giderildiğinde yerel kurulum sorunsuz ilerler.