# 📡 API Endpoint Listesi (MVP)

Bu liste, React frontend'in ihtiyaç duyacağı temel API endpoint'lerini içerir. Tüm endpoint'ler `/api/` altında olacaktır.

### Auth (Kimlik Doğrulama)
* `POST /auth/register/`
* `POST /auth/login/`
* `POST /auth/refresh/`
* `GET /auth/me/`

### Users (Kullanıcılar)
* `GET /users/`
  * Açıklama: Kullanıcıları listeler (Admin)
* `GET /users/{id}/`
  * Açıklama: Kullanıcı detayı (Admin)
* `PATCH /users/{id}/`
  * Açıklama: Kullanıcı bilgilerini günceller (role, team, phone, address vb.) (Admin)
* `DELETE /users/{id}/`
  * Açıklama: Kullanıcıyı siler (Admin)
* `POST /users/{id}/set_role/`
  * Açıklama: Kullanıcının rolünü ayarlar (VATANDAS | OPERATOR | EKIP | ADMIN) (Admin)
* `POST /users/{id}/set_team/`
  * Açıklama: Kullanıcıyı takıma atar veya çıkarır (Admin)

### Teams (Ekipler)
* `GET /teams/`
    * Açıklama: Aktif ekipleri listeler.
    * Yetki: Giriş yapmış herkes
* `POST /teams/`
    * Açıklama: Yeni bir ekip oluşturur.
    * Yetki: Yalnızca staff/admin
* `PATCH /teams/{id}/`
    * Açıklama: Ekip bilgisini günceller (name, description, team_type, members, is_active).
    * Yetki: Yalnızca staff/admin
* `DELETE /teams/{id}/`
    * Açıklama: Ekibi pasif hale getirir (soft delete: is_active=false).
    * Yetki: Yalnızca staff/admin

### Reports (Bildirimler)
* `GET /reports/`
    * Açıklama: Kullanıcının rolüne göre bildirimleri listeler. (Operatör hepsini görür, Saha Ekibi sadece kendi ekibine atananları görür, Vatandaş sadece kendi raporlarını görür).
    * Yetki: Operatör, Saha Ekibi, Vatandaş
    * Yanıt notu: Liste öğelerinde ilk medya dosyasının URL'si `first_media_url` alanı ile sağlanır (kart/grid görünümünde kapak görseli olarak kullanılır).
* `POST /reports/`
    * Açıklama: Giriş yapmış bir `Vatandaş` tarafından yeni bir bildirim ve bağlı medyası oluşturulur.
    * Yetki: Vatandaş
    * İstek (multipart/form-data): title, description, category, location (opsiyonel), latitude (opsiyonel, 6 ondalık basamak), longitude (opsiyonel, 6 ondalık basamak), media_files (1+ dosya). Tek dosya gönderimi desteklenir.
    * Notlar: latitude/longitude toplam hane kısıtı nedeniyle 6 ondalığa yuvarlanmalıdır; frontend bu yuvarlamayı uygular.
* `GET /reports/{id}/`
    * Açıklama: Tek bir bildirimin detaylarını getirir.
    * Yetki: Operatör, Saha Ekibi, (Vatandaş sadece kendi bildirimini görebilir)
* `PATCH /reports/{id}/`
    * Açıklama: Bir bildirimin durumunu (`status`) veya atandığı ekibi (`assigned_team`) günceller.
    * Yetki: Operatör, Saha Ekibi

### Categories (Kategoriler)
* `GET /categories/`
    * Açıklama: Bildirim oluşturma formunda kullanılmak üzere tüm kategorileri listeler.
    * Yetki: Giriş yapmış herkes
* `POST /categories/`
    * Açıklama: Yeni kategori oluşturur.
    * Yetki: Yalnızca staff/operatör
* `PATCH /categories/{id}/`
    * Açıklama: Kategori bilgisini günceller (name, description, is_active).
    * Yetki: Yalnızca staff/operatör
* `DELETE /categories/{id}/`
    * Açıklama: Kategoriyi pasif hale getirir.
    * Yetki: Yalnızca staff/operatör

### Comments (Yorumlar)
* `GET /reports/{id}/comments/`
    * Açıklama: Bir bildirime ait yorumları listeler.
    * Yetki: Operatör, Saha Ekibi
* `POST /reports/{id}/comments/`
    * Açıklama: Bir bildirime yeni bir yorum ekler.
    * Yetki: Operatör, Saha Ekibi