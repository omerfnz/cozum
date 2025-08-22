# 📦 Veritabanı Şeması (MVP)

Bu şema, MVP kapsamındaki modelleri ve aralarındaki ilişkileri basitçe tanımlar.

### 1. User (Kullanıcı)
Sistemdeki tüm aktörleri (vatandaş, personel) bu model tutar.

* `id` (Primary Key)
* `username` (Kullanıcı Adı)
* `email` (Email, **Benzersiz, Giriş için kullanılır**)
* `password` (Hash'lenmiş şifre)
* `first_name` (Ad)
* `last_name` (Soyad)
* `role` (Rol - Seçenekler: `VATANDAS`, `EKIP`, `OPERATOR`, `ADMIN`)
* `team` (İlişki -> Team, Boş olabilir. Sadece `EKIP` rolündeki kullanıcılar için.)
* `phone` (Telefon Numarası, opsiyonel)
* `address` (Adres, opsiyonel)

### 2. Team (Saha Ekibi)
Belediyenin saha ekiplerini tanımlar.

* `id` (Primary Key)
* `name` (Ekip Adı, Örn: "Fen İşleri A Ekibi")
* `description` (Açıklama, opsiyonel)
* `team_type` (Ekip Tipi - Seçenekler: `EKIP`, `OPERATOR`, `ADMIN`)
* `created_by` (İlişki -> User, Takımı oluşturan kullanıcı)
* `created_by_name` (Serializer alanı - oluşturucunun görünen adı)
* `members` (İlişki -> User, Takım üyeleri)
* `members_count` (Serializer alanı - üye sayısı)
* `created_at` (Oluşturulma Tarihi)
* `is_active` (Aktif mi?)

Not: Takımlar için silme işlemi soft-delete olarak uygulanır (`is_active=false`).

### 3. Category (Kategori)
Vatandaşların bildirim oluştururken seçeceği sorun tipleri.

* `id` (Primary Key)
* `name` (Kategori Adı, Örn: "Yol ve Kaldırım Sorunları")
* `description` (Açıklama, opsiyonel)
* `is_active` (Aktif mi?)
* `created_at` (Oluşturulma Tarihi)

Not: Kategorilerde silme işlemi soft-delete olarak uygulanır (`is_active=false`).

### 4. Report (Bildirim / Görev)
Projenin ana objesi. Vatandaş tarafından oluşturulur, personel tarafından göreve dönüştürülür.

* `id` (Primary Key)
* `title` (Başlık)
* `description` (Açıklama)
* `status` (Durum - Seçenekler: `BEKLEMEDE`, `INCELENIYOR`, `COZULDU`, `REDDEDILDI`)
* `priority` (Öncelik - Seçenekler: `DUSUK`, `ORTA`, `YUKSEK`, `ACIL`)
* `reporter` (İlişki -> User, Bildirimi yapan vatandaş)
* `category` (İlişki -> Category)
* `assigned_team` (İlişki -> Team, Boş olabilir; Operatör tarafından atanır, Saha Ekibi kendi atanmış raporlarını görür)
* `location` (Konum metni, opsiyonel)
* `latitude` (Enlem, opsiyonel)
* `longitude` (Boylam, opsiyonel)
* `created_at` (Oluşturulma Tarihi)
* `updated_at` (Güncellenme Tarihi)

### 5. Media (Medya)
Bildirimlere eklenen fotoğrafları tutar.

* `id` (Primary Key)
* `report` (İlişki -> Report)
* `file` (Dosya Yolu, FileField)
* `file_path` (Dosya Yolu Metni, opsiyonel)
* `file_size` (Dosya Boyutu, opsiyonel)
* `media_type` (Medya Tipi - Seçenekler: `IMAGE`, `VIDEO`)
* `uploaded_at` (Yüklenme Tarihi)

### 6. Comment (Yorum)
Bildirimlerin altına personel tarafından eklenen notlar.

* `id` (Primary Key)
* `report` (İlişki -> Report)
* `user` (İlişki -> User, Yorumu yapan personel)
* `content` (Yorum içeriği)
* `created_at` (Oluşturulma Tarihi)