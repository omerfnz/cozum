# ✅ MVP Kapsamı: Çözüm Var

Bu doküman, projenin ilk versiyonunda nelerin yer alacağını ve daha da önemlisi, nelerin yer almayacağını net bir şekilde belirtir. Amacımız, odaklanmış ve hızlı bir başlangıç yapmaktır.

### Kullanıcı Rolleri
1.  **Vatandaş:** Sisteme kayıt olup bildirimde bulunabilen kullanıcı.
2.  **Saha Ekibi:** Kendilerine atanan bildirimleri görüp durumunu güncelleyen belediye personeli.
3.  **Operatör:** Tüm bildirimleri yöneten, ekiplere atama yapan kullanıcı.
4.  **Admin:** Sistemi yöneten (kullanıcı ekleme/çıkarma gibi) yetkili. (Bu rol için temel kullanıcı/ekip yönetimi ekranları uygulamada mevcuttur; ayrıntılı yönetim için Django Admin Paneli kullanılabilir.)

---

### Yapılacaklar ✅
* **Kullanıcı Sistemi:**
    * Vatandaşlar için e-posta/şifre ile kayıt ve giriş.
    * JWT tabanlı kimlik doğrulama (access/refresh token) - mobil ve web uyumlu.
* **Bildirim Oluşturma (Vatandaş):**
    * Başlık, açıklama ve listeden kategori seçimi.
    * Bir adet fotoğraf yükleme (mobilde kamera ile çekim desteklenir).
    * Konum: metin alanı + OpenStreetMap tabanlı harita seçici; opsiyonel enlem/boylam, ters coğrafi kodlama ile adres.
* **Bildirim Yönetimi (Operatör):**
    * Tüm bildirimleri liste halinde görme.
    * Bildirime bir saha ekibi atama.
    * Bildirimin durumunu değiştirme (`BEKLEMEDE`, `INCELENIYOR`, `COZULDU`, `REDDEDILDI`).
* **Görev Yönetimi (Saha Ekibi):**
    * Sadece kendi ekiplerine atanmış bildirimleri görme.
    * Bildirimin durumunu `COZULDU` olarak değiştirme.
    * Çözüme dair bir açıklama (yorum) ekleme.
* **Yorumlar:**
    * Yorumlar herkes tarafından görüntülenir; yorum ekleme yalnızca yetkili personel (Operatör, Saha Ekibi) tarafından yapılabilir.
    * **Mobil özel kısıt:** VATANDAS rolündeki kullanıcılar sadece kendi oluşturdukları raporlarda yorum yazabilir.
* **Rol Bazlı Ana Sayfa Filtreleri (Mobil):**
    * VATANDAS: Varsayılan olarak "mine" (kendi raporları) sekmesi açılır.
    * EKIP: Varsayılan olarak "assigned" (atanmış raporlar) sekmesi açılır.
    * OPERATOR/ADMIN: Varsayılan olarak "all" (tüm raporlar) sekmesi açılır.
* **Otomatik Güvenlik (Mobil):**
    * Refresh token hatası durumunda otomatik çıkış yapma ve giriş sayfasına yönlendirme.
* **Yönetim (Mobil - Admin):**
    * Takım ve Kategori yönetimi için temel CRUD akışları mobil uygulamada sağlandı (TeamsView ve CategoriesView güncel). Rol bazlı yetkilendirme ve soft-delete davranışı uygulanıyor. Görsel doğrulama bir sonraki seansta yapılacak.

---

### ŞİMDİLİK Yapılmayacaklar ❌
* **Emoji / Reaksiyonlar:** Bildirimlere beğeni, emoji gibi tepkiler verilemeyecek.
* **Gelişmiş Dashboard ve İstatistikler:** Detaylı grafikler, raporlar olmayacak.
* **Anlık Bildirimler:** E-posta, SMS veya anlık (push) bildirimler gönderilmeyecek.
* **Harita Entegrasyonu (Web):** Konum seçimi veya bildirimleri haritada gösterme özelliği web frontend için ilk versiyonda yer almayacak; mobil uygulamada basit harita seçici mevcuttur.
* **Gelişmiş Kullanıcı Profilleri:** Kullanıcıların detaylı profil sayfaları olmayacak.
* **Şifre Sıfırlama:** "Şifremi unuttum" özelliği ilk versiyonda yer almayacak.
* **Çoklu Medya Yükleme:** Bildirimlere birden fazla fotoğraf veya video eklenemeyecek.
* **Vatandaş Yorumları:** Genel yorum yetkisi verilmez; vatandaş yalnızca kendi oluşturduğu raporlara yorum ekleyebilir (mobil istemci composer görünürlüğü ile sınırlandırılmıştır).
* Sistem Ayarları / Uygulama Ayarları arayüzü