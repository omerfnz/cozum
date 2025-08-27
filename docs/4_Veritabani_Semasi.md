# 📦 Veritabanı Şeması (Güncel)

Bu şema, aktif backend modellerini ve ilişkilerini özetler.

### 1. User (Özel Kullanıcı)
- Giriş alanı: email (USERNAME_FIELD=email, benzersiz)
- Zorunlu ek alan: username
- Alanlar: id, email, username, first_name, last_name, password (hash), role [VATANDAS|EKIP|OPERATOR|ADMIN], team (FK→Team, null olabilir), phone, address, is_staff, is_superuser, date_joined, last_login
- Manager: UserManager (create_user / create_superuser)

### 2. Team (Saha Ekibi)
- Alanlar: id, name, description, team_type [EKIP|OPERATOR|ADMIN], created_by (FK→User), members (M2M→User), created_at, is_active
- Özellikler: member_count (hesaplanan), created_by_name (hesaplanan)
- Silme: Soft delete (is_active=false)

### 3. Category (Kategori)
- Alanlar: id, name, description, is_active, created_at
- Silme: Soft delete (is_active=false)

### 4. Report (Bildirim)
- Alanlar: id, title, description, status [BEKLEMEDE|INCELENIYOR|COZULDU|REDDEDILDI], priority [DUSUK|ORTA|YUKSEK|ACIL], reporter (FK→User), category (FK→Category), assigned_team (FK→Team, null), location (str, opsiyonel), latitude (decimal, opsiyonel), longitude (decimal, opsiyonel), created_at, updated_at
- Sıralama: created_at desc (en yeni ilk)

### 5. Media (Medya)
- Alanlar: id, report (FK→Report), file (ImageField), file_path (str), file_size (int), media_type [IMAGE|VIDEO], uploaded_at
- Yükleme yolu: reports/YYYY/MM/DD/<report_id>/<filename>
- Desteklenen uzantılar: jpg, jpeg, png, webp, heic, heif
- Görsel optimizasyonu: Büyük görseller 1024x1024 üzerine küçültülür; JPEG kalite 85; PNG/WEBP optimize. Hatalı/bozuk içerikte optimizasyon atlanır.
- Depolama hataları için anlamlı doğrulama mesajları üretir (örn. R2 yetkilendirme).

### 6. Comment (Yorum)
- Alanlar: id, report (FK→Report), user (FK→User), content, created_at
- Sıralama: created_at desc (en yeni ilk)

### Notlar
- **Varsayılan izinler:** DRF global olarak IsAuthenticated. Register/login uçları AllowAny.
- **Medya URL'leri:** Mutlak URL. R2 etkinse https://<bucket>.<account>.r2.cloudflarestorage.com veya tanımlı custom domain kullanılır.
- **API Endpoint Kuralı:** APPEND_SLASH=False: Tüm endpoint'ler sondaki / ile eşleşir.
- **Durum:** Tüm modeller aktif ve çalışır durumda. Backend tamamen tamamlandı.