# API Endpoint Listesi (MVP)

Bu doküman, mobil uygulama ile uyumlu çalışan temel endpoint’leri ve örnek istek/yanıtları içerir.

## Auth
- POST /api/auth/login/
  - Body (JSON): {"email":"user@example.com","password":"secret"}
  - Response: {"access":"<jwt>","refresh":"<jwt>"}
- POST /api/auth/register/
  - Body (JSON): {"email":"user@example.com","username":"user1","password":"P@ssw0rd","password_confirm":"P@ssw0rd","role":"VATANDAS"}
- GET /api/auth/me/ (Bearer)
  - Response: kullanıcı profili
- POST /api/auth/refresh/
  - Body (JSON): {"refresh":"<jwt>"}
- POST /api/auth/logout/ (Bearer)

## Health Check
- GET /api/health/
  - Response: Sistem durumu ve R2 storage konfigürasyon bilgileri
  - Örnek response: {"status":"healthy","storage":{"type":"R2","write_test":"SUCCESS","cleanup":"SUCCESS"}}
  - Kullanım: R2 storage bağlantısını test etmek ve konfigürasyon sorunlarını tespit etmek için

## Reports
- GET /api/reports/?scope=all|assigned|mine
  - Query: scope parametresi opsiyoneldir, default: all
  - Response: sayfalı liste {"count": N, "next": url|null, "results": [ReportListItem]}
  - Mobil istemci davranışı: Varsayılan scope kullanıcı rolüne göre seçilir (VATANDAS=mine, EKIP=assigned, OPERATOR/ADMIN=all) ve ilk yüklemede bu parametre ile çağrılır.
- GET /api/reports/{id}/ (Bearer)
  - Response: ReportDetail + media, comments alanları
- POST /api/reports/ (Bearer, multipart/form-data)
  - Fields: title, description, category_id, location_text (opsiyonel), latitude (opsiyonel), longitude (opsiyonel)
  - Files: media_files (tek veya çoklu); MVP’de tek görsel

## Categories
- GET /api/categories/
  - Response: [CategoryDto]

## Comments
- POST /api/reports/{id}/comments/ (Bearer)
  - Body (JSON): {"text":"..."}
  - Response: CommentDto

### Notlar
- Tüm yanıtlar JSON formatındadır.
- Mobilde Dio tabanı: baseUrl=API_BASE_URL; Authorization: Bearer <access> header’ı Interceptor ile eklenir; 401’de refresh akışı otomatik tetiklenir.
- Medya URL’leri DRF tarafından mutlak URL olarak döndürülmelidir.