# Çözüm Var
## Mahallenizin Nabzını Tutan Sosyal Platform

Slogan: "Vatandaşın Sesi, Belediyenin Hızı"

---

## 1) Özet
Çözüm Var, vatandaşların yaşadıkları çevredeki sorunları hızlıca bildirebildiği, belediye ekiplerinin ise şeffaf ve ölçülebilir şekilde çözüm süreçlerini yönettiği bir sosyal platformdur. Amaç; basit bir şikayet uygulamasından öte, şehir yaşamını birlikte iyileştiren katılımcı bir ekosistem kurmaktır.

---

## 2) Problem ve İçgörü
- Kime, nasıl ve ne zaman iletileceği bilinmeyen sorunlar görünmez kalıyor.
- Süreç şeffaf olmayınca güven ve motivasyon azalıyor.
- Belediyeler için performans takibi ve raporlama zahmetli.

### Çözüm
- Standartlaştırılmış bildirim akışı
- Roller bazlı görev atama ve takip (Vatandaş, Operatör, Ekip, Admin)
- Gerçek zamanlı durum ve öncelik yönetimi
- Şeffaf metrikler ve mahalle bazlı görünürlük

---

## 3) Rollere Göre Deneyim
- Vatandaş: Başlık, açıklama, kategori, konum ve medya ile bildirim oluşturur; süreci takip eder ve yorum yapar.
- Operatör: Bildirimleri inceler, kategorize eder ve doğru sahaya (Team) atar.
- Ekip: Atanan görevleri sahada çözer, durumu ve medyayı günceller.
- Admin: Kullanıcı/rol yönetimi, takım yönetimi. (Genel ayarlar arayüzü MVP sonrası)

---

## 4) Öne Çıkan Özellikler
- Bildirim oluşturma: Başlık, açıklama, kategori, konum (enlem/boylam), medya (görsel)
- Durum ve öncelik takibi: Beklemede, İnceleniyor, Çözüldü; Düşük/Orta/Yüksek
- Yorumlar ve medya yönetimi (görsel optimizasyonu ile)
- Operatör -> Takıma atama akışı
- Takım ve üye yönetimi (aktif/pasif)
- JWT ile kimlik doğrulama, roller bazlı yetkilendirme
- Şeffaf istatistikler ve mahalle karnesi

---

## 5) Demo Akışı (Kısa Senaryo)
1) Vatandaş kayıt olur ve giriş yapar.
2) Konum ve fotoğraf ile yeni rapor oluşturur.
3) Operatör raporu inceleyip ilgili ekibe atar.
4) Ekip sahada müdahale eder, durumu günceller, çözüm fotoğrafı ekler.
5) Vatandaş süreci izler, gerekirse yorum yapar; rapor kapanır.

---

## 6) Başarı Metrikleri (Örnek)
- Genel çözüm oranı
- İlk müdahale süresi ve ortalama çözüm süresi
- Kategori bazında çözüm performansı
- Mahalle karnesi (bölgesel görünürlük)

---

## 7) Mimarî ve Teknoloji
- Backend: Django + Django REST Framework, SimpleJWT ile JWT kimlik doğrulama
- Medya: Pillow ile görsel işleme/optimizasyon, dosya boyutu ve tür bilgisi saklama
- Veri Modeli: Category, Report, Media, Comment, User, Team (roller: VATANDAS, EKIP, OPERATOR, ADMIN)
- Frontend: React + Vite + TypeScript (web arayüzü)
- Veritabanı: Geliştirme için SQLite; üretimde PostgreSQL önerilir

---

## 8) API Kısa Özeti
- Auth: /api/auth/login (JWT), /api/auth/refresh
- Kullanıcılar: /api/users/ (liste, detay, admin aksiyonları)
- Takımlar: /api/teams/ (oluşturma, güncelleme, üyeler)
- Kategoriler: /api/categories/ (liste/oluştur, güncelle/sil – staff/admin)
- Raporlar: /api/reports/ (liste/oluştur), /api/reports/{id}/ (güncelle – yetkiye bağlı)
- Yorumlar: /api/reports/{id}/comments (liste/oluştur)

Not: Tüm uçlar roller ve izinlerle korunur; vatandaş yalnızca kendi bildirimlerini yönetebilir, operatör atama yapar, ekip atanan raporları günceller, admin tam yetkilidir.

---

## 9) Güvenlik ve Uygulama Kalitesi
- JWT tabanlı kimlik doğrulama (SimpleJWT)
- Roller bazlı erişim kontrolleri (RBAC)
- Medya güvenliği ve görsel optimizasyonu
- Test odaklı geliştirme, yüksek kapsam hedefi

---

## 10) Yol Haritası (Öneri)
- v1.0: Çekirdek raporlama, roller, atama, yorum, temel metrikler
- v1.1: Gelişmiş filtreleme/harita, bildirimler, iyileştirilmiş raporlar
- v1.2: Çoklu dil, PWA/mobil iyileştirmeleri, dış sistem entegrasyonları

---

## 11) Sonuç
Çözüm Var; şehir yaşamını iyileştiren, süreçleri şeffaflaştıran ve paydaşları bir araya getiren uçtan uca bir platformdur. Birlikte daha güçlü, birlikte daha güzel şehirler!