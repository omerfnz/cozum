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
- [x] Serializer: `MediaSerializer.file` alanı mutlak URL döndürür (Flutter Image.network için)
- [x] Cloudflare R2 Storage entegrasyonu (django-storages ile)
- [x] R2 SSL sorun giderme: Custom domain sorunlarında direct endpoint kullanımı
- [x] Health check endpoint ile R2 bağlantı testi
- [x] R2 API token permissions: Object Read & Write
- [x] URL generation: Custom domain ve direct endpoint arasında otomatik geçiş

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

N) Mobil (Flutter)
1) Kurulum ve Proje Başlatma
   - [x] Flutter SDK ve Android toolchain doğrulandı (flutter doctor)
   - [x] mobile klasörü Flutter ile oluşturuldu (flutter create mobile)
2) Bağımlılıklar
   - [x] dio, flutter_bloc, equatable, get_it, auto_route, flutter_secure_storage, image_picker
   - [x] cached_network_image, geolocator, oktoast, very_good_analysis
   - [x] Dev: build_runner, auto_route_generator, very_good_analysis
3) Mimari ve Navigasyon
   - [x] Clean Architecture iskeleti ve Material3 tema
   - [x] auto_route yapılandırması ve route generator kurulumu
   - [x] get_it container ve service/repository kayıtları (locator.dart)
4) Ağ ve Kimlik Doğrulama
   - [x] dio instance + interceptor (Bearer access token)
   - [x] 401 için refresh token akışı ve otomatik yeniden deneme
   - [x] flutter_secure_storage ile token saklama (TokenStorage)
5) Özellikler (MVP)
   - [x] Auth: Kayıt (Vatandaş) ve giriş ekranları (LoginView, RegisterView)
   - [x] Splash ekranı ve otomatik giriş kontrolü
   - [x] Ana sayfa: Rol bazlı rapor listesi (HomeView)
   - [x] Rapor Oluştur: başlık, açıklama, kategori, 1 fotoğraf, konum (CreateReportView)
   - [x] Rapor Detay: Görüntüleme ve yorum ekleme (ReportDetailView)
   - [x] Profil sayfası: Kullanıcı bilgileri ve çıkış (ProfileView)
   - [x] Ayarlar: Tema değiştirme (SettingsView)
   - [x] Admin paneli: Takım, kullanıcı, kategori yönetimi (AdminTeamsView, AdminUsersView, AdminCategoriesView)
6) Medya
   - [x] image_picker ile fotoğraf seçimi, dio FormData ile yükleme
   - [x] cached_network_image ile görsel önizleme
7) Çevresel Ayarlar
   - [x] API taban adresi: --dart-define=API_BASE_URL=http://localhost:8000/api
   - [x] LAN testi (gerçek cihaz/emülatör): `--dart-define=API_BASE_URL=http://192.168.1.101:8000/api`
   - [x] AppConfig ile ortam değişkeni yönetimi
   - [ ] Android izinleri: INTERNET, CAMERA, READ_MEDIA_IMAGES
8) Çalıştırma
   - [x] flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
9) Harita (opsiyonel)
   - [ ] google_maps_flutter ekleme ve Android API key tanımı
   - [x] geolocator ile konum alma (CreateReportView'da kullanılıyor)

Güncel notlar (Android)
- Gerekli izinler ve API anahtarları git’e eklenmemelidir; yerel/secret yönetimi kullanılmalıdır.

# Adım Adım Task Listesi (Güncel)

Bu dosya MVP’yi hayata geçirmek için gerekli adımların güncel halidir.

## Durum Özeti
- Dokümanlar güncellendi: MVP kapsamı, teknoloji yığını, API listesi.
- Mobil uygulama: Login, Register, Home Feed, Report Create, Report Detail, Yorum ekleme, Harita seçici çalışır durumda.
- DI ve Dio interceptor’lar (Authorization, refresh flow) aktif.
- Router tekilliği: `AppRouter` DI üzerinden tekil örnek olarak kullanılıyor; interceptor yönlendirmeleri aynı örneği kullanır.
- Varsayılan scope (mobil): Rol bazlı olarak otomatik belirlenir (VATANDAS=mine, EKIP=assigned, OPERATOR/ADMIN=all).
- Yorum kısıtı (mobil): VATANDAS sadece kendi raporunda yorum yazabilir.

## Mobil (Flutter) – Eksikler ve Sıradaki Adımlar

### Tamamlanan Özellikler ✅
- Clean Architecture yapısı ve katmanlı mimari
- BLoC/Cubit pattern ile state management
- Auto Route ile navigasyon sistemi
- GetIt ile dependency injection
- JWT tabanlı kimlik doğrulama (login, register, refresh token)
- Rol bazlı ana sayfa (VATANDAS, EKIP, OPERATOR, ADMIN)
- Rapor oluşturma (başlık, açıklama, kategori, fotoğraf, konum)
- Rapor detay görüntüleme ve yorum ekleme
- Admin paneli (takım, kullanıcı, kategori yönetimi)
- Profil sayfası ve tema değiştirme
- Medya yükleme ve önizleme
- Geolocator ile konum alma

### Kritik Eksikler ve Sıradaki Adımlar 🔴
1) **Android İzinleri (Yüksek Öncelik)**
   - android/app/src/main/AndroidManifest.xml'e INTERNET, CAMERA, ACCESS_FINE_LOCATION izinleri
   - iOS için Info.plist kamera ve konum izin metinleri

2) **Harita Entegrasyonu (Orta Öncelik)**
   - google_maps_flutter paketi ekleme
   - Android API key yapılandırması
   - Rapor oluşturmada harita ile konum seçimi
   - Rapor detayında konum gösterimi

3) **Filtreleme ve Arama (Orta Öncelik)**
   - Ana sayfada rapor filtreleme (durum, kategori, tarih)
   - Arama özelliği (başlık, açıklama)
   - Sıralama seçenekleri

4) **Offline Support (Düşük Öncelik)**
   - Hive/SQLite ile yerel veri saklama
   - Ağ bağlantısı olmadığında cached veriler
   - Senkronizasyon mekanizması

### Teknik İyileştirmeler 🔧
1) **Kod Kalitesi**
   - dart analyze ve dart fix --apply çalıştır
   - very_good_analysis kurallarına uyum
   - Test coverage artırma

2) **Performans**
   - ListView.builder optimizasyonları
   - Image caching iyileştirmeleri
   - Memory leak kontrolü

3) **UX İyileştirmeleri**
   - Loading states ve skeleton screens
   - Error handling ve user-friendly mesajlar
   - Pull-to-refresh özelliği
   - Infinite scrolling

### Ortam Yapılandırması 🔧
1) **API Konfigürasyonu**
   - API_BASE_URL'i LAN IP ile ver (örn: http://192.168.1.33:8000/api/)
   - Medya URL kökü: http://192.168.1.33:8000/
   - Prod/Dev/Test ortam ayrımı

2) **Build ve Deploy**
   - AutoRoute codegen: dart run build_runner build --delete-conflicting-outputs
   - APK/AAB build konfigürasyonu
   - Code signing (geliştirici imzaları ayrı tutulur)

## Backend – Kontrol Listesi
- MEDIA_URL mutlak URL üretimi (serializer’da request.build_absolute_uri)
- CORS ve ALLOWED_HOSTS LAN IP dahil güncel
- /api altında auth, reports, categories, comments uçları aktif ve dokümanla uyumlu

## Çalıştırma
- Windows PowerShell:
  - flutter pub get
  - dart run build_runner build --delete-conflicting-outputs
  - flutter run --dart-define=API_BASE_URL=http://192.168.1.33:8000/api/

## Doğrulama
- Fiziksel cihaz ile aynı LAN: evet
- Login/refresh/logout akışı: OK
- Report create (tek görsel) -> listede ve detailde görünüyor: OK
- Yorum ekleme yetkisi: sadece Operatör/Ekip
- Medya URL’leri mutlak ve erişilebilir