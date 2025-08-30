# 🏗️ Flutter Mimari Şablonu - Geliştirme Anayasası

## 🤖 AI ASİSTANLARI İÇİN KRİTİK TALİMATLAR

> **⚠️ ZORUNLU**: Bu belge Flutter uygulamaları geliştirmek için **MUTLAK** kurallar içerir. Her kural tam olarak takip edilmelidir. Sapma uyumsuz kodla sonuçlanacaktır.

### 📌 Hızlı Referans
- **Şablon Versiyonu**: v2.0
- **Flutter SDK**: >=3.22.0 <4.0.0
- **Mimari**: MVVM + Clean Architecture
- **State Management**: BLoC/Cubit Pattern
- **Test Kapsamı**: Minimum %80
- **Proje Durumu**: ✅ TAMAMLANDI - MVP özellikleri aktif

## İçindekiler

1. [Temel İlkeler](#temel-ilkeler)
2. [Proje Kimliği](#proje-kimliği)
3. [Sistem Mimarisi](#sistem-mimarisi)
4. [Teknoloji Yığını](#teknoloji-yığını)
5. [Klasör Organizasyonu](#klasör-organizasyonu)
6. [Bağımlılıklar](#bağımlılıklar)
7. [Modül Sistemi](#modül-sistemi)
8. [State Management](#state-management)
9. [Navigasyon ve Yönlendirme](#navigasyon-ve-yönlendirme)
10. [Yerelleştirme](#yerelleştirme)
11. [Tema Sistemi](#tema-sistemi)
12. [Ağ Katmanı](#ağ-katmanı)
13. [Test Stratejisi](#test-stratejisi)
14. [Performans ve En İyi Uygulamalar](#performans-ve-en-iyi-uygulamalar)
15. [Yasaklı Uygulamalar](#yasaklı-uygulamalar)
16. [Hızlı Başlangıç Şablonu](#hızlı-başlangıç-şablonu)

---

## Temel İlkeler

### ZORUNLU Geliştirme Kuralları

1. **Clean Architecture**: Katı katman ayrımı (Presentation → Business → Data → Service)
2. **Modüler Tasarım**: Her özellik net sınırlarla ayrı modüllerde
3. **BLoC Pattern**: State management için Cubit, doğrudan UI-business bağlantısı yok
4. **Responsive Tasarım**: Tüm UI bileşenleri cihazlar arası responsive olmalı
5. **Type Safety**: Katı null safety, final sınıflar, değişmez durumlar
6. **Test-Driven**: Minimum %80 test kapsamı, kapsamlı test stratejisi

---

## Proje Kimliği

### ZORUNLU pubspec.yaml Yapısı

```yaml
name: cozum_mobile
description: Vatandaş Bildirim Sistemi - Flutter Mobil Uygulaması
version: 1.0.0+1
environment:
  sdk: ">=3.22.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  
  # Temel Mimari
  equatable: ^2.0.5
  get_it: ^8.0.2
  flutter_bloc: ^8.1.6
  
  # Ağ ve Veri
  dio: ^5.7.0
  
  # UI ve Navigasyon
  auto_route: ^9.2.2
  google_fonts: ^6.2.1
  
  # Güvenlik ve Depolama
  flutter_secure_storage: ^9.2.2
  
  # UI Bileşenleri
  shimmer: ^3.0.0
  image_picker: ^1.1.2
  
  # Yardımcı Araçlar
  logger: ^2.4.0
  
  # Splash Screen
  flutter_native_splash: ^2.4.1
```

---

## Sistem Mimarisi

### ZORUNLU Katman Yapısı

```
┌─────────────────────────────────────┐
│        Presentation Layer           │ ← Views, Widgets (Sadece UI)
│         (lib/feature/*/view)        │
├─────────────────────────────────────┤
│         Business Layer              │ ← BLoC/Cubit Logic
│      (lib/feature/*/view_model)     │
├─────────────────────────────────────┤
│           Data Layer                │ ← Models, Repository
│    (lib/feature/*/model+service)    │
├─────────────────────────────────────┤
│         Service Layer               │ ← Network, Cache, API
│       (lib/product/service)         │
└─────────────────────────────────────┘
```

### ZORUNLU Bağımlılık Akışı

- **Presentation** → **Business** → **Data** → **Service**
- **HİÇBİR** ters bağımlılığa izin verilmez
- Dependency injection için **GetIt**
- **Interface-based** servis sözleşmeleri

---

## Teknoloji Yığını

### ZORUNLU Temel Teknolojiler

- **Flutter**: 3.22.0+ (En son kararlı)
- **Dart**: 3.4.0+ (Null safety etkin)
- **State Management**: flutter_bloc (Cubit pattern)
- **Dependency Injection**: get_it
- **Navigation**: auto_route v9
- **Network**: dio
- **Security**: flutter_secure_storage
- **Architecture**: MVVM Pattern
- **Testing**: flutter_test, bloc_test
- **Code Quality**: flutter_lints

---

## Klasör Organizasyonu

### ZORUNLU Kök Yapısı

```
proje_adi/
├── lib/
│   ├── main.dart                    ← Uygulama giriş noktası
│   ├── development/                 ← Geliştirme konfigürasyonları
│   ├── feature/                     ← Özellik modülleri
│   └── product/                     ← Paylaşılan bileşenler
├── module/                          ← Bağımsız modüller
│   ├── core/                        ← Temel işlevsellik
│   ├── common/                      ← Paylaşılan bileşenler
│   ├── gen/                         ← Oluşturulan varlıklar
│   └── widgets/                     ← UI bileşenleri
├── asset/translations/              ← Yerelleştirme dosyaları
├── script/                          ← Build scriptleri
└── test/                            ← Test dosyaları
```

### ZORUNLU Özellik Yapısı

```
feature/[ozellik_adi]/
├── view/
│   ├── [ozellik_adi]_view.dart     ← Ana UI bileşeni
│   └── mixin/                       ← View mixinleri
├── view_model/
│   ├── [ozellik_adi]_cubit.dart    ← State management
│   └── [ozellik_adi]_state.dart    ← State tanımı
├── service/
│   └── [ozellik_adi]_service.dart  ← Veri erişim katmanı
└── model/
    └── [ozellik_adi]_model.dart    ← Veri modelleri
```

---

## Bağımlılıklar

### ZORUNLU Ana Bağımlılıklar

```yaml
dependencies:
  # Temel Mimari
  equatable: ^2.0.5              # Değer karşılaştırması
  get_it: ^8.0.2                 # Dependency injection
  flutter_bloc: ^8.1.6           # State management
  
  # Ağ ve Veri
  dio: ^5.7.0                    # HTTP client
  
  # UI ve Navigasyon
  auto_route: ^9.2.2             # Declarative routing
  google_fonts: ^6.2.1           # Tipografi
  
  # Güvenlik ve Depolama
  flutter_secure_storage: ^9.2.2 # Güvenli token depolama
  
  # UI Bileşenleri
  shimmer: ^3.0.0                # Loading animasyonları
  image_picker: ^1.1.2           # Medya seçimi
  
  # Yardımcı Araçlar
  logger: ^2.4.0                 # Gelişmiş loglama
  flutter_native_splash: ^2.4.1  # Splash screen
```

### ZORUNLU Geliştirme Bağımlılıkları

```yaml
dev_dependencies:
  very_good_analysis: ^6.0.0     # Kod analizi
  auto_route_generator: ^9.0.0   # Route oluşturma
  build_runner: ^2.4.6           # Kod oluşturma
  flutter_launcher_icons: ^0.14.1 # Uygulama ikonları
  device_preview: ^1.1.0         # Cihaz önizlemesi
  mockito: ^5.4.2                # Mock nesneler
  bloc_test: ^9.1.4              # BLoC testi
  patrol: ^3.11.1                # Entegrasyon testi
```

---

## Modül Sistemi

### ZORUNLU Modül Yapısı

#### Core Modülü
```yaml
# module/core/pubspec.yaml
dependencies:
  hive: ^4.0.0-dev.2             # Yerel depolama
  isar_flutter_libs: ^4.0.0-dev.13 # NoSQL veritabanı
  path_provider: ^2.1.0          # Dosya sistemi erişimi
```

#### Common Modülü
```yaml
# module/common/pubspec.yaml
dependencies:
  cached_network_image: ^3.3.0   # Optimize edilmiş resim yükleme
```

#### Gen Modülü
```yaml
# module/gen/pubspec.yaml
dependencies:
  json_annotation: ^4.8.1        # JSON serileştirme
  flutter_svg: ^2.0.7            # SVG desteği
  lottie: ^2.6.0                 # Animasyon desteği
  envied: ^0.3.0+3               # Ortam değişkenleri
```

#### Widgets Modülü
```yaml
# module/widgets/pubspec.yaml
dependencies:
  responsive_framework: ^1.1.1   # Responsive tasarım
  shimmer: ^3.0.0               # Enhanced shimmer bileşenleri
```

---

## State Management

### ZORUNLU BLoC Implementasyonu

#### State Sınıfı Deseni
```dart
final class HomeState extends Equatable {
  const HomeState({
    this.isLoading = false,
    this.data = const [],
    this.error,
  });

  final bool isLoading;
  final List<HomeModel> data;
  final String? error;

  HomeState copyWith({
    bool? isLoading,
    List<HomeModel>? data,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, data, error];
}
```

#### Cubit Sınıfı Deseni
```dart
final class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._service) : super(const HomeState());

  final IHomeService _service;

  Future<void> fetchData() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await _service.getData();
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
```

### ZORUNLU Global State

```dart
// Uygulama geneli state için ProductViewModel
final class ProductViewModel extends Cubit<ProductState> {
  ProductViewModel() : super(const ProductState());

  void changeTheme(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  void changeLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }
}
```

---

## Navigasyon ve Yönlendirme

### ZORUNLU Auto Route Kurulumu

```dart
@AutoRouterConfig()
final class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      initial: true,
    ),
    AutoRoute(
      page: ProfileRoute.page,
      path: '/profile',
    ),
  ];
}

// Route Sayfa Tanımı
@RoutePage()
final class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<HomeCubit>(),
      child: const _HomeViewBody(),
    );
  }
}
```

### ZORUNLU Navigasyon Kullanımı

```dart
// Navigasyon metodları
context.router.push(const ProfileRoute());
context.router.replace(const HomeRoute());
context.router.pop();
```

---

## Yerelleştirme

### ZORUNLU Easy Localization Kurulumu

```dart
// main.dart
Future<void> main() async {
  await ApplicationInitialize().make();
  runApp(ProductLocalization(
    child: const StateInitialize(child: _MyApp()),
  ));
}

// ProductLocalization wrapper
final class ProductLocalization extends StatelessWidget {
  const ProductLocalization({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('tr', 'TR')],
      path: 'asset/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: child,
    );
  }
}
```

### ZORUNLU Çeviri Yapısı

```json
// asset/translations/tr.json
{
  "home": {
    "title": "Ana Sayfa",
    "welcome": "Hoş geldin {}!"
  },
  "general": {
    "button": {
      "save": "Kaydet",
      "cancel": "İptal"
    }
  }
}
```

---

## Tema Sistemi

### ZORUNLU Tema Implementasyonu

```dart
final class CustomLightTheme {
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.light,
    ),
    fontFamily: GoogleFonts.roboto().fontFamily,
  );
}

final class CustomDarkTheme {
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.dark,
    ),
    fontFamily: GoogleFonts.roboto().fontFamily,
  );
}
```

---

## Ağ Katmanı

### ZORUNLU Vexana Implementasyonu

```dart
final class NetworkManager extends NetworkManager<EmptyModel> {
  NetworkManager.base() : super(
    options: BaseOptions(
      baseUrl: AppEnvironment.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );
}

// Servis Interface
abstract class IHomeService {
  Future<List<HomeModel>> getData();
}

// Servis Implementasyonu
final class HomeService implements IHomeService {
  HomeService(this._networkManager);
  final INetworkManager _networkManager;

  @override
  Future<List<HomeModel>> getData() async {
    final response = await _networkManager.send<HomeModel, ErrorModel>(
      '/data',
      type: RequestType.GET,
      parseModel: HomeModel(),
      errorModel: ErrorModel(),
    );
    return response?.data ?? [];
  }
}
```

---

## Test Stratejisi

### ZORUNLU Test Türleri

1. **Unit Tests**: İş mantığı, servisler, modeller
2. **Widget Tests**: UI bileşenleri, kullanıcı etkileşimleri
3. **BLoC Tests**: State management, state geçişleri
4. **Integration Tests**: Uçtan uca kullanıcı akışları

### ZORUNLU Test Yapısı

```dart
void main() {
  group('HomeCubit Testleri', () {
    late HomeCubit cubit;
    late MockHomeService mockService;

    setUp(() {
      mockService = MockHomeService();
      cubit = HomeCubit(mockService);
    });

    blocTest<HomeCubit, HomeState>(
      'fetchData başarılı olduğunda loading sonra data emit eder',
      build: () => cubit,
      act: (cubit) => cubit.fetchData(),
      expect: () => [
        const HomeState(isLoading: true),
        const HomeState(isLoading: false, data: mockData),
      ],
    );
  });
}
```

---

## Performans ve En İyi Uygulamalar

### ZORUNLU Kod Standartları

```dart
// Sınıf Yapısı
final class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.tr('home.title'))),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(HomeState state) {
    if (state.isLoading) return const CircularProgressIndicator();
    if (state.error != null) return Text('Hata: ${state.error}');
    return ListView.builder(
      itemCount: state.data.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(state.data[index].title),
      ),
    );
  }
}
```

### ZORUNLU Performans Kuralları

- Tüm widget'lar için **const constructors**
- Değişmezlik için **final classes**
- Seçici yeniden yapılandırma için **BlocBuilder**
- Büyük listeler için **ListView.builder**
- Ağ resimleri için **Image caching**
- Ağır işlemler için **Lazy loading**
- Merkezi **Enhanced shimmer** yönetimi
- Loading state'leri için **Shimmer optimization**

---

## Yasaklı Uygulamalar

### ASLA YAPMAYIN

- ❌ Gerekçe olmadan **StatefulWidget**
- ❌ **Const olmayan** widget constructor'ları
- ❌ UI bileşenlerinde **İş mantığı**
- ❌ UI'dan **Doğrudan servis** erişimi
- ❌ UI'da **Hardcoded string'ler**
- ❌ GetIt dışında **Global değişkenler** veya singleton'lar
- ❌ Katmanlar arası **Döngüsel bağımlılıklar**
- ❌ **Karışık state management** çözümleri
- ❌ Yeni özellikler için **Test atlama**
- ❌ Analiz uyarılarını **Görmezden gelme**
- ❌ Enhanced shimmer yerine **Manuel shimmer** implementasyonu
- ❌ Loading state'lerde **Shimmer kullanmama**

---

## Hızlı Başlangıç Şablonu

### ZORUNLU Kurulum Komutları

```bash
# 1. Proje oluştur
flutter create proje_adi
cd proje_adi

# 2. Klasör yapısını kur
mkdir -p lib/{development,feature,product/{cache,init,navigation,service,state,utility,widget}}
mkdir -p module/{core,common,gen,widgets}
mkdir -p asset/translations
mkdir -p script

# 3. Bağımlılıkları yükle
flutter pub get

# 4. Modülleri kur
cd module/core && flutter pub get && cd ../..
cd module/common && flutter pub get && cd ../..
cd module/gen && flutter pub get && cd ../..
cd module/widgets && flutter pub get && cd ../..

# 5. Kod oluştur
flutter packages pub run build_runner build --delete-conflicting-outputs

# 6. Testleri çalıştır
flutter test

# 7. Uygulamayı çalıştır
flutter run
```

### ZORUNLU İlk Dosyalar

#### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'product/init/application_initialize.dart';
import 'product/init/product_localization.dart';
import 'product/init/state_initialize.dart';

Future<void> main() async {
  await ApplicationInitialize().make();
  runApp(ProductLocalization(
    child: const StateInitialize(child: _MyApp()),
  ));
}

final class _MyApp extends StatelessWidget {
  const _MyApp();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter().config(),
      theme: CustomLightTheme().themeData,
      darkTheme: CustomDarkTheme().themeData,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
```

#### Ortam Değişkenleri
```dart
// .env
API_BASE_URL=https://api.example.com
API_KEY=your_api_key_here
```

Bu anayasa, clean architecture ilkelerini takip eden, kapsamlı test ve modern geliştirme uygulamaları ile ölçeklenebilir, sürdürülebilir ve yüksek kaliteli Flutter uygulamaları sağlar.