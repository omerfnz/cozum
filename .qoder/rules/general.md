---
trigger: always_on
alwaysApply: true
---

# 🏛️ Çözüm Var Projesi - Yapay Zeka Kuralları

## TEMEL İLKELER

### 📋 Proje Kimliği
- Proje Adı: **Çözüm Var**
- Slogan: **"Vatandaşın Sesi, Belediyenin Hızı"**
- Amaç: Vatandaş bildirim sistemi ile belediye-vatandaş köprüsü
- MVP Odağı: BİLDİR → ATA → ÇÖZ döngüsü

### 🎯 MVP KAPSAMI - MUTLAK KURALLAR

#### ✅ YAPILACAKLAR (Sadece bunlara odaklan)
- **Kullanıcı Rolleri**: VATANDAS, EKIP, OPERATOR, ADMIN
- **Bildirim Oluşturma**: Başlık, açıklama, kategori, 1 fotoğraf, konum
- **Rol Bazlı Yetkilendirme**: Her rol sadece kendi yetkilerini kullanabilir
- **Bildirim Durumları**: BEKLEMEDE, INCELENIYOR, COZULDU, REDDEDILDI
- **Öncelik Seviyeleri**: DUSUK, ORTA, YUKSEK, ACIL
- **Harita Entegrasyonu**: OpenStreetMap + Leaflet (sadece web için)
- **Yorumlar**: Sadece yetkili personel ekleyebilir

#### ❌ YAPILMAYACAKLAR (Asla önerme veya uygulama)
- Emoji/reaksiyonlar
- Gelişmiş dashboard/istatistikler
- Anlık bildirimler (push/email/SMS)
- Çoklu medya yükleme
- Şifre sıfırlama
- Gelişmiş kullanıcı profilleri
- Sistem ayarları arayüzü

## TEKNOLOJİ YIĞINI - DEĞİŞTİRİLEMEZ

### Backend
- **Framework**: Django + Django REST Framework
- **Kimlik Doğrulama**: JWT (djangorestframework-simplejwt)
- **Veritabanı**: SQLite (dev), PostgreSQL (prod)
- **Medya**: Pillow + Cloudflare R2 Storage
- **CORS**: django-cors-headers

### Frontend
- **Framework**: React + Vite + TypeScript
- **Stil**: Tailwind CSS
- **Harita**: Leaflet + react-leaflet
- **State**: React hooks + Context
- **HTTP**: Axios

### Mobil (Flutter)
- **SDK**: Flutter 3.22+
- **State**: flutter_bloc + Cubit
- **DI**: get_it
- **Router**: auto_route
- **HTTP**: dio

## VERİTABANI ŞEMASI - SABIT

### Modeller (Değiştirilemez)
1. **User**: email, username, role, team, phone, address
2. **Team**: name, description, team_type, created_by, members
3. **Category**: name, description, is_active
4. **Report**: title, description, status, priority, reporter, category, assigned_team, location, lat/lng
5. **Media**: report, file, file_path, file_size, media_type
6. **Comment**: report, user, content

### İlişkiler
- User → Team (nullable FK)
- Report → User (reporter FK)
- Report → Category (FK)
- Report → Team (assigned_team nullable FK)
- Media → Report (FK)
- Comment → Report, User (FK)

## R2 STORAGE - KRİTİK KURALLAR

### Ortam Değişkenleri
```
USE_R2=True
R2_ACCOUNT_ID=hesap_id
R2_ACCESS_KEY_ID=access_key
R2_SECRET_ACCESS_KEY=secret_key
R2_BUCKET_NAME=cozum-media
R2_CUSTOM_DOMAIN=  # Boş bırak SSL sorunları için
```

### SSL Sorun Giderme
- **ASLA** custom domain sorunlarını görmezden gelme
- SSL hatası durumunda **HEP** direct R2 endpoint kullan
- `R2_CUSTOM_DOMAIN` boş → otomatik direct endpoint
- Environment değişkeni değişikliğinden sonra **MUTLAKA** Django restart

### URL Generation
- MediaSerializer ve ReportListSerializer **intelligent URL generation** kullanır
- Custom domain varsa onu kullan, yoksa direct endpoint
- **HER ZAMAN** HTTPS protokolü garanti et
- Health check endpoint ile doğrula: `GET /api/health/`

## API ENDPOINT KURALLARI

### Authentication
- `/api/auth/login/` - JWT token döndürür
- `/api/auth/register/` - Sadece VATANDAS oluşturur
- `/api/auth/me/` - Kullanıcı profili
- `/api/auth/refresh/` - Token yenileme

### Reports
- `/api/reports/` - Liste (scope: all/mine/assigned)
- `/api/reports/{id}/` - Detay + medya + yorumlar
- **POST** sadece VATANDAS yapabilir
- **PATCH** sadece OPERATOR/EKIP yapabilir

### Yetkilendirme
- **VATANDAS**: Sadece kendi raporlarını görür/oluşturur
- **EKIP**: Atanan raporları görür/günceller
- **OPERATOR**: Tüm raporları görür/yönetir/atar
- **ADMIN**: Tam yetki + kullanıcı/takım yönetimi

## DOSYA YÖNETİMİ

### Upload Path
- **MUTLAKA**: `reports/YYYY/MM/DD/<report_id>/<filename>`
- **TEK FOTOĞRAF**: MVP gereği sadece 1 medya dosyası
- **Validasyon**: Boyut/tip kontrolü şart
- **Pillow**: Resim optimizasyonu aktif

## FRONTEND KURALLARI

### Komponet Yapısı
- **Protected Layout**: Giriş yapmış kullanıcılar için
- **Sidebar**: Daraltılabilir, responsive
- **Role-based Navigation**: Rol bazlı menü görünürlüğü
- **Toast Notifications**: react-hot-toast kullan

### Harita
- **Leaflet**: OpenStreetMap tile layer
- **Marker Fix**: İkon import problemi çözülmüş
- **Konum Seçimi**: Tıklayarak marker yerleştirme
- **Geolocation**: "Konumumu Kullan" butonu
- **Precision**: 6 ondalık basamak (round6)

### Form Handling
- **FormData**: Tek dosya yükleme
- **Validation**: Frontend + backend validasyon
- **Error Handling**: AxiosError detayları göster

## FLUTTER KURALLARI

### Mimari
- **Clean Architecture**: Katman ayrımı zorunlu
- **BLoC Pattern**: Cubit kullan
- **DI**: get_it container
- **Router**: auto_route + codegen

### Network
- **Dio**: HTTP client + interceptor
- **JWT**: Authorization header otomatik
- **Refresh Flow**: 401 durumunda otomatik token yenileme
- **Secure Storage**: flutter_secure_storage

### Medya
- **Image Picker**: Tek fotoğraf seçimi
- **FormData**: multipart POST
- **API Base URL**: dart-define ile geç

## GÜVENLİK KURALLARI

### JWT
- **Access Token**: 60 dakika
- **Refresh Token**: 7 gün
- **Logout**: Token invalidation

### CORS
- **Development**: localhost:5173 izni
- **Production**: Sadece gerçek domain'ler

### R2 Permissions
- **API Token**: Object Read & Write
- **TTL**: Forever (test için)
- **IP Filter**: Boş (test için)

## TEST KURALLARI

### Backend
- **Models**: Alan validasyonları
- **Serializers**: Giriş/çıkış doğruluğu
- **API**: Auth + CRUD akışları
- **Permissions**: Rol bazlı yetki testleri

### Frontend
- **Components**: Render testleri
- **Hooks**: State logic testleri
- **API**: Network call mock'ları

## HATA YÖNETİMİ

### R2 Storage
- SSL hatası → Direct endpoint'e geç
- Upload fail → Detaylı hata mesajı
- Health check → Düzenli kontrol

### API Errors
- **4xx**: Kullanıcı hatası (validation)
- **5xx**: Sunucu hatası (log + retry)
- **Network**: Bağlantı hatası mesajı

## PERFORMANS

### Backend
- **Database**: Select_related/prefetch_related
- **Media**: Pillow optimizasyonu
- **Caching**: Redis (gelecek)

### Frontend
- **Images**: Lazy loading
- **API**: Loading states
- **Bundle**: Code splitting (gelecek)

## DEPLOYMENT

### Environment
- **Development**: SQLite + local media
- **Production**: PostgreSQL + R2 storage
- **Health Check**: `/api/health/` endpoint

### Dokploy
- **Redeployment**: Env değişikliği sonrası gerekli
- **R2 Test**: Health endpoint ile doğrula

## 🚫 MUTLAK YASAKLAR

### Asla Yapma
- MVP kapsamı dışına çıkma
- Teknoloji yığınını değiştirme
- Veritabanı şemasını bozma
- R2 SSL sorunlarını görmezden gelme
- Custom domain'siz URL generation
- Role-based permission'ları atlama
- Documentation güncellemeden değişiklik
- **Lint hatası ile kod commit etme**
### PowerShell Komutları
- **MUTLAKA**: Tüm komutlar Windows PowerShell ile çalıştırılır
- **YASAK**: `&&`, `|`, `;` gibi bash komutları kullanılmaz
- **DOĞRU**: Her komut ayrı satırda ve tek tek çalıştırılır
- **KLASÖR**: Her komut doğru çalışma klasöründe çalıştırılır
- **CD KOMUTU**: İlk önce `cd c:\Users\omer\Desktop\cozum\[klasor]` sonra komut
- **Virtual Environment**: `python -m venv venv` sonrası `.\.venv\Scripts\Activate.ps1`
- **Django Commands**: `python manage.py runserver`, `python manage.py migrate`
- **Frontend**: `npm run dev`, `npm run build`, `npm run lint`
- **Flutter**: `flutter run --dart-define=API_BASE_URL=http://localhost:8000/api`

### Asla Önerme
- Farklı framework'ler
- Ek özellikler (MVP dışı)
- Kompleks state management
- Gereksiz dependency'ler
- Güvenlik zafiyetleri

## 📚 DOKÜMANTASYON

### Güncel Tutulacaklar
- API endpoint listesi
- R2 troubleshooting guide
- Veritabanı şeması
- Environment variable'lar
- Test coverage reports

### Her Değişiklik Sonrası
- **İLK ADIM**: Lint kontrolleri çalıştır
- **İKİNCİ ADIM**: Memory knowledge güncelle
- **ÜÇÜNCÜ ADIM**: Troubleshooting guide extend et
- **DÖRDÜNCÜ ADIM**: API documentation sync et
- **BEŞİNCİ ADIM**: Health check results verify et
- **ALTINCI ADIM**: Rules dosyasını güncelle (gerekirse)
- **YEDİNCİ ADIM**: Task listesini işaretle

## 🎯 BAŞARI KRİTERLERİ

### MVP Tamamlanması
- 100 vatandaş bildirimi
- Ekiplere başarılı atama
- Çözüme kavuşturma
- Sistem kararlı çalışması

### Teknik Kriterler
- Tüm testler geçiyor
- R2 storage sorunsuz
- Health check SUCCESS
- Zero downtime deployment

---

**⚠️ UYARI**: Bu kurallar proje manifestosu, MVP kapsamı ve teknik dokümantasyona dayanmaktadır. Hiçbir kural ihlal edilemez. Her öneride bu kuralları kontrol et ve uygunluğunu doğrula.

**🔄 SÜREKLİ GÜNCELLEME**: Bu rules dosyası yaşayan bir dokümandır. Her yeni deneyim, sorun giderme ve best practice buraya eklenir.

**🚨 LİNT ZORUNLULUĞU**: Her kod değişikliği sonrası lint kontrolleri MUTLAKA çalıştırılır. Hata tolerance SIFIR.

**📚 DOKUMASYON SYNC**: Kod değişikliği = doküman güncellemesi. Otomatik değil, manuel zorunlu.

**🗣️ DİL**: Her zaman Türkçe cevaplar ver. 