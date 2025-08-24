import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/feature/auth/cubit/auth_state.dart';
import 'package:mobile/product/auth/auth_repository.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/report/model/report_models.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  final AuthRepository _repository = di<AuthRepository>();
  final Logger _logger = di<Logger>();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('Giriş denemesi: <$email>');
      await _repository.login(email: email, password: password);
      
      // Kullanıcı bilgilerini al
      final userMap = await _repository.me();
      UserDto? user;
      if (userMap != null) {
        try {
          user = UserDto.fromJson(userMap);
        } catch (e) {
          _logger.w('Kullanıcı bilgisi parse edilemedi: $e');
        }
      }
      
      emit(state.copyWith(isLoading: false, user: user));
      _logger.i('Giriş başarılı');
    } catch (e) {
      final errorMessage = e.toString();
      emit(state.copyWith(isLoading: false, error: errorMessage));
      _logger.e('Giriş hatası: $errorMessage');
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('Kayıt denemesi: email=<$email>, username=<$username>');
      
      await _repository.register(
        email: email,
        username: username,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
      );
      
      // Kayıt başarılı, otomatik giriş yap
      await _repository.login(email: email, password: password);
      
      // Kullanıcı bilgilerini al
      final userMap = await _repository.me();
      UserDto? user;
      if (userMap != null) {
        try {
          user = UserDto.fromJson(userMap);
        } catch (e) {
          _logger.w('Kullanıcı bilgisi parse edilemedi: $e');
        }
      }
      
      emit(state.copyWith(isLoading: false, user: user));
      _logger.i('Kayıt ve giriş başarılı');
    } catch (e) {
      final errorMessage = e.toString();
      emit(state.copyWith(isLoading: false, error: errorMessage));
      _logger.e('Kayıt hatası: $errorMessage');
    }
  }

  Future<void> loadCurrentUser() async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final userMap = await _repository.me();
      UserDto? user;
      if (userMap != null) {
        try {
          user = UserDto.fromJson(userMap);
        } catch (e) {
          _logger.w('Kullanıcı bilgisi parse edilemedi: $e');
        }
      }
      
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      final errorMessage = e.toString();
      emit(state.copyWith(isLoading: false, error: errorMessage));
      _logger.e('Kullanıcı bilgisi yükleme hatası: $errorMessage');
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void logout() {
    emit(const AuthState());
  }
}