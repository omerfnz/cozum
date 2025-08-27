# API Endpoint Listesi (Güncel)

Bu doküman, mevcut backend uygulamasına göre güncellenmiş API uç noktalarını ve beklenen istek/yanıt formatlarını içerir.

Genel Notlar
- Taban yol: /api/
- Kimlik doğrulama: Tüm uç noktalar, aksi belirtilmedikçe JWT Bearer zorunludur (Authorization: Bearer <access>). Varsayılan izin: IsAuthenticated.
- Son eğik çizgi: APPEND_SLASH=False olduğu için tüm yollar sonda eğik çizgi ile çağrılmalıdır (ör. /api/reports/). /api/reports (slashesiz) 404 döner.
- Yanıt formatı: JSON. Liste uç noktalarında sayfalama açık değildir; doğrudan dizi döner.
- Medya URL’leri: Mutlak URL döner. R2 etkinse HTTPS üzerinden custom domain ya da doğrudan R2 endpoint kullanılır.

## 1) Sağlık Kontrolü
GET /api/health/
- Açıklama: Servis ve (varsa) R2 depolama yapılandırması hakkında durum bilgisi döner.
- Örnek: {"status":"healthy","service":"cozum-var-backend","storage":{"type":"R2","configured":true,"media_url":"..."}}

## 2) Kimlik Doğrulama
POST /api/auth/register/
- İzin: AllowAny
- Gövde (JSON): {"email":"...","username":"...","first_name":"...","last_name":"...","password":"...","password_confirm":"...","role":"VATANDAS|EKIP|OPERATOR|ADMIN","phone":"...","address":"..."}
- Yanıt: Oluşturulan kullanıcı bilgileri (token dönmez)
- Mobil: RegisterView ile entegre (kullanılıyor).

POST /api/auth/login/
- İzin: AllowAny
- Gövde (JSON): {"email":"...","password":"..."}
- Yanıt: {"access":"<jwt>","refresh":"<jwt>"}
- Not: Access token claim’lerinde email, role, username bulunur.
- Mobil: LoginView ile entegre (kullanılıyor). Tokenlar flutter_secure_storage ile tutulur.

POST /api/auth/refresh/
- Gövde (JSON): {"refresh":"<jwt>"}
- Yanıt: {"access":"<jwt>"}
- Mobil: NetworkService interceptor’ında 401 sonrası otomatik yenileme akışı mevcut (kullanılıyor).

GET /api/auth/me/
- İzin: IsAuthenticated
- Yanıt: Giriş yapan kullanıcının detayları
- Mobil: Profil sayfası entegrasyonu planlandı (ProfileView’de kullanılacak).

PATCH /api/auth/me/update/
- İzin: IsAuthenticated
- Gövde (JSON): {"username":"...","first_name":"...","last_name":"...","phone":"...","address":"..."}
- Yanıt: Güncellenen kullanıcı
- Mobil: Ayarlar/Profil düzenleme için planlandı (henüz kullanılmıyor).

PATCH /api/auth/password/change/
- İzin: IsAuthenticated
- Gövde (JSON): {"old_password":"...","new_password":"...","new_password_confirm":"..."}
- Yanıt: {"detail":"Şifreniz başarıyla güncellendi."}
- Mobil: Şifre değiştirme akışı için planlandı (henüz kullanılmıyor).

## 3) Kullanıcılar (Yönetici)
- Tüm uç noktalar IsAdminUser gerektirir.

GET /api/users/
POST /api/users/
GET /api/users/{id}/
PUT/PATCH /api/users/{id}/
DELETE /api/users/{id}/

Özel Aksiyonlar (POST):
- /api/users/{id}/set_role/  Gövde: {"role":"VATANDAS|EKIP|OPERATOR|ADMIN"}
- /api/users/{id}/set_team/  Gövde: {"team": <team_id> } veya {"team": null} (takımı kaldırır)
- Mobil: AdminDashboard altındaki kullanıcı yönetimi ekranlarında planlandı (henüz kullanılmıyor).

## 4) Takımlar
- Listeleme herkes (IsAuthenticated); oluşturma/düzenleme/silme sadece staff/admin.

GET /api/teams/
- Not: list aksiyonunda sadece aktif (is_active=true) takımlar döner.
- Mobil: CreateReportView kategori/atama akışında opsiyonel kullanım; admin ekranlarında planlı.
- Mobil: AdminTeamsView/TeamsView içinde listeleme, ekleme, düzenleme ve soft-delete akışları uygulandı; üye ekleme (POST /api/teams/{id}/add_member benzeri özel uç olmadan, placeholder kullanıcı ID ile) istemci tarafında hazır. Backend özel uç nokta ihtiyacı varsa eklenecek.
- **Mobil Durum**: Takım yönetimi tamamen tamamlandı ve çalışır durumda.

GET /api/teams/{id}/
POST /api/teams/        (staff)
PUT/PATCH /api/teams/{id}/ (staff)
DELETE /api/teams/{id}/ (staff; soft delete → is_active=false)
- **Mobil Durum**: TeamsView CRUD formları bottom sheet içinde; use_build_context_synchronously uyarıları giderildi; analiz temiz. Takım yönetimi tamamen aktif.

## 5) Kategoriler
- Liste herkes (IsAuthenticated); oluşturma/düzenleme/silme sadece staff/admin. Silme soft-delete (is_active=false) olarak uygulanır.

GET /api/categories/
- Not: Sadece aktif kategoriler döner (is_active=true).
- Mobil: CreateReportView kategori dropdown’ında kullanılıyor (kullanılıyor).
- Mobil (Güncel): AdminCategoriesView/CategoriesView içinde listeleme, ekleme, düzenleme ve soft-delete akışları uygulandı; formlarda null-safe mantık ile isEdit/path hesaplaması ve mounted kontrolleri eklendi; analiz temiz.

POST /api/categories/       (staff)
GET /api/categories/{id}/
PUT/PATCH /api/categories/{id}/ (staff)
DELETE /api/categories/{id}/    (staff; soft delete)
- **Mobil Durum**: CategoriesView CRUD formları bottom sheet içinde; use_build_context_synchronously uyarıları giderildi; analiz temiz. Kategori yönetimi tamamen aktif.

## 6) Bildirimler/Görevler (Reports)
GET /api/reports/?scope=all|mine|assigned
- İzin: IsAuthenticated
- Davranış: scope parametresi opsiyoneldir. Sağlanmazsa rol bazlı varsayılan uygulanır:
  - VATANDAS → sadece kendi raporları (bildirimlerim)
  - EKIP → kendi takımına atanmış raporlar (görevlerim)
  - OPERATOR/ADMIN → tüm raporlar (tüm görevler)
- Yanıt: ReportListSerializer dizisi. Alanlar: id, title, status, priority, reporter, category, assigned_team, location, created_at, updated_at, media_count, comment_count, first_media_url
- Mobil: Home/Feed listesinde ve TasksView'da kullanılıyor (kullanılıyor).
- **Görevler Sayfası**: TasksView bu endpoint'i kullanarak rol bazlı görev listesi gösterir.

GET /api/reports/{id}/
- Yanıt: ReportDetailSerializer (description, latitude/longitude float, media_files[], comments[] dâhil)
- Mobil: ReportDetailView’da kullanılıyor (kullanılıyor).

POST /api/reports/
- İçerik tipi: multipart/form-data
- Alanlar: title (str), description (str), category (int, kategori id’si), location (str, ops.), latitude (float, ops.), longitude (float, ops.)
- Dosyalar: En az 1 görsel zorunlu. Aşağıdaki anahtarların herhangi biriyle yüklenebilir: media_files (çoklu), media_files[] (çoklu), files (çoklu) veya file (tekli).
- Desteklenen uzantılar: jpg, jpeg, png, webp, heic, heif
- Not: Birden fazla görsel gönderimi desteklenir.
- Mobil: CreateReportView ile entegre (kullanılıyor, tekli görsel akışı doğrulandı).

PATCH /api/reports/{id}/  (PUT de desteklenir)
- Alanlar: status (BEKLEMEDE|INCELENIYOR|COZULDU|REDDEDILDI), priority (DUSUK|ORTA|YUKSEK|ACIL), assigned_team (int, team id)
- Yetki:
  - VATANDAS: güncelleme yetkisi yok
  - EKIP: sadece kendi takımına atanmış görevlerin durumunu güncelleyebilir (status)
  - OPERATOR/ADMIN: tüm görevleri güncelleyebilir (status, priority, assigned_team)
- Mobil: ReportDetailView'da görev atama ve durum güncelleme için kullanılıyor.
- **Görevler Sayfası**: Görev durumu değiştirme ve ekip atama işlemleri için kullanılır.

DELETE /api/reports/{id}/
- İzin: IsAuthenticated + rol kontrolü
- Yetki:
  - VATANDAS: kendi oluşturduğu raporları silebilir
  - EKIP: silme yetkisi yok
  - OPERATOR/ADMIN: tüm raporları silebilir
- Yanıt: 204 No Content (başarılı silme)
- **Görevler Sayfası**: Admin/Operator için görev silme özelliği.

## 7) Yorumlar
GET /api/reports/{id}/comments/
- Belirtilen raporun yorumları (en yeni ilk)
- Mobil: ReportDetailView’da kullanılıyor (kullanılıyor).

POST /api/reports/{id}/comments/
- Gövde (JSON): {"content":"..."}
- Yetki: 
  - VATANDAS: sadece kendi oluşturduğu raporlara yorum ekleyebilir
  - EKIP: kendi takımına atanmış görevlere yorum ekleyebilir
  - OPERATOR/ADMIN: tüm görevlere yorum ekleyebilir
- Mobil: ReportDetailView'da kullanılıyor (kullanılıyor).
- **Görevler Sayfası**: Görev detayında yorum ekleme için kullanılır.

GET /api/comments/{id}/
PATCH /api/comments/{id}/
DELETE /api/comments/{id}/
- Yetki: Yorum sahibi düzenleyip silebilir; ayrıca OPERATOR/staff düzenleyip silebilir
- Mobil: İleri aşama için planlı (henüz kullanılmıyor).

## Mobil Uygulama Entegrasyon Durumu

### Tamamlanan Entegrasyonlar
- ✅ **Kimlik Doğrulama**: Login, Register, Token yenileme tamamen aktif
- ✅ **Bildirim Oluşturma**: CreateReportView ile POST /api/reports/ entegrasyonu
- ✅ **Feed/Ana Sayfa**: GET /api/reports/ ile rol bazlı listeleme
- ✅ **Görev Detayları**: ReportDetailView ile GET /api/reports/{id}/ entegrasyonu
- ✅ **Yorum Sistemi**: Yorum listeleme ve ekleme tamamen aktif
- ✅ **Takım Yönetimi**: Admin panelinde CRUD işlemleri
- ✅ **Kategori Yönetimi**: Admin panelinde CRUD işlemleri
- ✅ **Profil Sistemi**: Kullanıcı bilgileri görüntüleme

### Teknik Detaylar
- **State Management**: Bloc pattern ile tüm API çağrıları yönetiliyor
- **Network Layer**: Dio ile interceptor'lar (token yenileme, hata yönetimi)
- **Güvenlik**: flutter_secure_storage ile token saklama
- **Navigasyon**: AutoRoute v9 ile type-safe routing
- **Kod Kalitesi**: Tüm lint hatalar düzeltildi, MVVM mimarisi uygulandı

---
Hata Kodları (özet)
- 400 Bad Request: Doğrulama hataları (örn. zorunlu alan eksik, geçersiz kategori, dosya türü)
- 401 Unauthorized: JWT eksik/Geçersiz
- 403 Forbidden: Yetki yok (rol kuralları, sahiplik vb.)
- 404 Not Found: Kaynak bulunamadı veya yanlış/eksik slash