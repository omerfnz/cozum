# 🏛️ Proje Manifestosu: Çözüm Var

### Proje Sloganı
> Vatandaşın Sesi, Belediyenin Hızı.

### Asansör Pitch (Kısa Tanıtım)
"Çözüm Var", vatandaşların şehirdeki sorunları (bozuk yol, patlak lamba vb.) kolayca fotoğraflı ve konumlu olarak bildirebildiği, belediye ekiplerinin de bu bildirimleri anında göreve dönüştürerek organize bir şekilde çözüme kavuşturduğu bir dijital köprüdür.

### Hangi Problemi Çözüyoruz?
* **Vatandaş İçin:** Sorunları belediyeye iletmek için karmaşık ve yavaş süreçlerle uğraşmak, bildiriminin akıbetini takip edememek.
* **Belediye İçin:** Gelen bildirimleri organize edememek, doğru ekibe hızlıca yönlendirememek, hangi sorunun çözüldüğünü takip etmekte zorlanmak ve yapılan işleri raporlayamamak.

### MVP (İlk Versiyon) Odağımız Nedir?
İlk ve tek amacımız, şu temel döngüyü kusursuz bir şekilde çalıştırmaktır:
1.  **BİLDİR:** Vatandaş, bir sorunu kategorisi ve fotoğrafıyla birlikte sisteme kaydeder.
2.  **ATA:** Belediye operatörü, gelen bildirimi ilgili saha ekibine atar.
3.  **ÇÖZ:** Saha ekibi, görevi tamamlar ve sonucunu sisteme işler.

### MVP İçin Başarı Kriteri
İlk 100 vatandaş bildiriminin sistem üzerinden başarılı bir şekilde alınıp ilgili ekiplere atanarak çözüme kavuşturulması.

### Bugüne Kadar Neler Yaptık? (Özet)
- Backend: Kullanıcı, Takım, Kategori, Bildirim, Medya ve Yorum modelleri tamamlandı. JWT tabanlı kimlik doğrulama ve rol bazlı yetkilendirme hayatta. Tüm API uç noktaları aktif.
- Frontend: React+Vite+Tailwind yapılandırıldı. Giriş/Kayıt sayfaları, korumalı rotalar ve router yapısı tamam. Users ve Teams yönetim ekranları devrede (listeleme, arama, ekip oluşturma/düzenleme, soft-delete; kullanıcı rol ve takım ataması). API entegrasyonu, token yönetimi, toast bildirimleri ve lint/typecheck temiz. Profil sayfası eklendi. Sidebar’dan 'Ayarlar' menüsü kaldırıldı.

### Sıradaki Adımlar
- Vatandaş akışları: Bildirim oluşturma ve “Bildirimlerim” sayfası.
- Operatör akışları: Tüm raporlar, ekip atama ve durum güncelleme.
- Saha ekibi akışları: Atanan raporlar, durum/yorum güncellemeleri.