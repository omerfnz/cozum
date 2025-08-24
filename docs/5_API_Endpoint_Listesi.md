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

POST /api/auth/login/
- İzin: AllowAny
- Gövde (JSON): {"email":"...","password":"..."}
- Yanıt: {"access":"<jwt>","refresh":"<jwt>"}
- Not: Access token claim’lerinde email, role, username bulunur.

POST /api/auth/refresh/
- Gövde (JSON): {"refresh":"<jwt>"}
- Yanıt: {"access":"<jwt>"}

GET /api/auth/me/
- İzin: IsAuthenticated
- Yanıt: Giriş yapan kullanıcının detayları

PATCH /api/auth/me/update/
- İzin: IsAuthenticated
- Gövde (JSON): {"username":"...","first_name":"...","last_name":"...","phone":"...","address":"..."}
- Yanıt: Güncellenen kullanıcı

PATCH /api/auth/password/change/
- İzin: IsAuthenticated
- Gövde (JSON): {"old_password":"...","new_password":"...","new_password_confirm":"..."}
- Yanıt: {"detail":"Şifreniz başarıyla güncellendi."}

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

## 4) Takımlar
- Listeleme herkes (IsAuthenticated); oluşturma/düzenleme/silme sadece staff/admin.

GET /api/teams/
- Not: list aksiyonunda sadece aktif (is_active=true) takımlar döner.

GET /api/teams/{id}/
POST /api/teams/        (staff)
PUT/PATCH /api/teams/{id}/ (staff)
DELETE /api/teams/{id}/ (staff; soft delete → is_active=false)

## 5) Kategoriler
- Liste herkes (IsAuthenticated); oluşturma/düzenleme/silme sadece staff/admin. Silme soft-delete (is_active=false) olarak uygulanır.

GET /api/categories/
- Not: Sadece aktif kategoriler döner (is_active=true).

POST /api/categories/       (staff)
GET /api/categories/{id}/
PUT/PATCH /api/categories/{id}/ (staff)
DELETE /api/categories/{id}/    (staff; soft delete)

## 6) Bildirimler (Reports)
GET /api/reports/?scope=all|mine|assigned
- İzin: IsAuthenticated
- Davranış: scope parametresi opsiyoneldir. Sağlanmazsa rol bazlı varsayılan uygulanır:
  - VATANDAS → sadece kendi raporları
  - EKIP → kendi takımına atanmış raporlar
  - OPERATOR veya staff → tüm raporlar
- Yanıt: ReportListSerializer dizisi. Alanlar: id, title, status, priority, reporter, category, assigned_team, location, created_at, updated_at, media_count, comment_count, first_media_url

GET /api/reports/{id}/
- Yanıt: ReportDetailSerializer (description, latitude/longitude float, media_files[], comments[] dâhil)

POST /api/reports/
- İçerik tipi: multipart/form-data
- Alanlar: title (str), description (str), category (int, kategori id’si), location (str, ops.), latitude (float, ops.), longitude (float, ops.)
- Dosyalar: En az 1 görsel zorunlu. Aşağıdaki anahtarların herhangi biriyle yüklenebilir: media_files (çoklu), media_files[] (çoklu), files (çoklu) veya file (tekli).
- Desteklenen uzantılar: jpg, jpeg, png, webp, heic, heif
- Not: Birden fazla görsel gönderimi desteklenir.

PATCH /api/reports/{id}/  (PUT de desteklenir)
- Alanlar: status (BEKLEMEDE|INCELENIYOR|COZULDU|REDDEDILDI), priority (DUSUK|ORTA|YUKSEK|ACIL), assigned_team (int, team id)
- Yetki:
  - VATANDAS: güncelleme yetkisi yok
  - EKIP: sadece kendi takımına atanmış raporları güncelleyebilir
  - OPERATOR/staff: tüm raporları güncelleyebilir

## 7) Yorumlar
GET /api/reports/{id}/comments/
- Belirtilen raporun yorumları (en yeni ilk)

POST /api/reports/{id}/comments/
- Gövde (JSON): {"content":"..."}
- Yetki: VATANDAS sadece kendi oluşturduğu raporlara yorum ekleyebilir

GET /api/comments/{id}/
PATCH /api/comments/{id}/
DELETE /api/comments/{id}/
- Yetki: Yorum sahibi düzenleyip silebilir; ayrıca OPERATOR/staff düzenleyip silebilir

---
Hata Kodları (özet)
- 400 Bad Request: Doğrulama hataları (örn. zorunlu alan eksik, geçersiz kategori, dosya türü)
- 401 Unauthorized: JWT eksik/Geçersiz
- 403 Forbidden: Yetki yok (rol kuralları, sahiplik vb.)
- 404 Not Found: Kaynak bulunamadı veya yanlış/eksik slash