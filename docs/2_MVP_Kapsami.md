# ✅ MVP Kapsamı: Çözüm Var

Bu doküman, projenin ilk versiyonunda nelerin yer alacağını ve daha da önemlisi, nelerin *yer almayacağını* net bir şekilde belirtir. Amacımız, odaklanmış ve hızlı bir başlangıç yapmaktır.

### Kullanıcı Rolleri
1.  **Vatandaş:** Sisteme kayıt olup bildirimde bulunabilen kullanıcı.
2.  **Saha Ekibi:** Kendilerine atanan bildirimleri görüp durumunu güncelleyen belediye personeli.
3.  **Operatör:** Tüm bildirimleri yöneten, ekiplere atama yapan kullanıcı.
4.  **Admin:** Sistemi yöneten (kullanıcı ekleme/çıkarma gibi) yetkili. (Bu rol için temel kullanıcı/ekip yönetimi ekranları uygulamada mevcuttur; ayrıntılı yönetim için Django Admin Paneli kullanılabilir.)

---

### Yapılacaklar ✅
* **Kullanıcı Sistemi:**
    * Vatandaşlar için e-posta/şifre ile kayıt ve giriş.
* **Bildirim Oluşturma (Vatandaş):**
    * Başlık, açıklama ve listeden kategori seçimi.
    * **Bir adet** fotoğraf yükleme.
    * (Konum bilgisi şimdilik manuel girilecek veya bir sonraki aşamaya bırakılacak).
* **Bildirim Yönetimi (Operatör):**
    * Tüm bildirimleri liste halinde görme.
    * Bildirime bir saha ekibi atama.
    * Bildirimin durumunu değiştirme (`BEKLEMEDE`, `INCELENIYOR`, `COZULDU`, `REDDEDILDI`).
* **Görev Yönetimi (Saha Ekibi):**
    * Sadece kendi ekiplerine atanmış bildirimleri görme.
    * Bildirimin durumunu `COZULDU` olarak değiştirme.
    * Çözüme dair bir açıklama (yorum) ekleme.
* **Yorumlar:**
    * Bir bildirimin altına sadece yetkili personel (Operatör, Saha Ekibi) tarafından yorum eklenebilecek.

---

### ŞİMDİLİK Yapılmayacaklar ❌
* **Emoji / Reaksiyonlar:** Bildirimlere beğeni, emoji gibi tepkiler verilemeyecek.
* **Gelişmiş Dashboard ve İstatistikler:** Detaylı grafikler, raporlar olmayacak.
* **Anlık Bildirimler:** E-posta, SMS veya anlık (push) bildirimler gönderilmeyecek.
* **Harita Entegrasyonu:** Konum seçimi veya bildirimleri haritada gösterme özelliği olmayacak.
* **Gelişmiş Kullanıcı Profilleri:** Kullanıcıların detaylı profil sayfaları olmayacak.
* **Şifre Sıfırlama:** "Şifremi unuttum" özelliği ilk versiyonda yer almayacak.
* **Çoklu Medya Yükleme:** Bildirimlere birden fazla fotoğraf veya video eklenemeyecek.
* **Vatandaş Yorumları:** İlk aşamada vatandaşlar bildirimlere yorum yapamayacak. Bu, süreci basit tutmak içindir.
* Sistem Ayarları / Uygulama Ayarları arayüzü