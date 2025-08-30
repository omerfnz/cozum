import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/service/auth/auth_service.dart' as auth;
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(const TasksInitial());

  final _net = GetIt.I<INetworkService>();
  final _auth = GetIt.I<auth.IAuthService>();

  auth.User? _currentUser;

  Future<void> loadUserAndFetch() async {
    try {
      final userRes = await _auth.getCurrentUser();
      if (userRes.isSuccess && userRes.data != null) {
        _currentUser = userRes.data;
      }
    } catch (_) {
      // Kullanıcı bilgisi yüklenemedi, devam et
    }
    await fetchTasks();
  }

  Future<void> fetchTasks() async {
    emit(const TasksLoading());

    final res = await _net.request<List<Report>>(
      path: ApiEndpoints.reports,
      type: RequestType.get,
      queryParameters: await _getDefaultFilters(),
      parser: (json) {
        if (json is List) {
          return json.map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
        }
        if (json is Map && json['results'] is List) {
          return (json['results'] as List)
              .map((e) => Report.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Report>[];
      },
    );

    if (res.isSuccess) {
      emit(TasksLoaded(res.data ?? []));
    } else {
      emit(TasksError(res.error ?? 'Görevler yüklenemedi'));
    }
  }

  Future<Map<String, dynamic>> _getDefaultFilters() async {
    try {
      final authService = GetIt.I<auth.IAuthService>();
      final meRes = await authService.getCurrentUser();
      final user = meRes.data;
      final String? role = user?.role;

      final Map<String, dynamic> q = {
        'tasks_only': 'true', // Görev sayfası için sadece atanmış bildirimleri getir
      };

      // Rol bazlı scope parametresi
      switch (role) {
        case 'VATANDAS':
          q['scope'] = 'mine';
          break;
        case 'EKIP':
          q['scope'] = 'assigned';
          break;
        case 'OPERATOR':
        case 'ADMIN':
          q['scope'] = 'all';
          break;
        default:
          q['scope'] = 'mine'; // Güvenlik için varsayılan
      }

      return q;
    } catch (_) {
      return {
        'scope': 'mine', // Hata durumunda güvenli varsayılan
        'tasks_only': 'true',
      };
    }
  }

  bool canDeleteTask(Report report) {
    final role = _currentUser?.role;
    // OPERATOR/ADMIN tüm görevleri silebilir
    if (role == 'OPERATOR' || role == 'ADMIN') {
      return true;
    }
    // VATANDAS sadece kendi raporlarını silebilir
    if (role == 'VATANDAS' && report.reporter.id == _currentUser?.id) {
      return true;
    }
    return false;
  }

  bool canManageTask(Report report) {
    final role = _currentUser?.role;
    // OPERATOR/ADMIN tüm görevleri yönetebilir
    if (role == 'OPERATOR' || role == 'ADMIN') {
      return true;
    }
    // EKIP sadece kendi takımına atananları yönetebilir
    if (role == 'EKIP' && report.assignedTeam?.id == _currentUser?.team?['id']) {
      return true;
    }
    return false;
  }

  Future<void> deleteTask(Report report) async {
    final id = report.id;
    if (id == null) {
      emit(const TasksError('Görev ID bulunamadı'));
      return;
    }

    final res = await _net.request(
      path: ApiEndpoints.reportById(id),
      type: RequestType.delete,
    );

    if (res.isSuccess) {
      emit(const TasksTaskDeleted());
      await fetchTasks(); // Listeyi yenile
    } else {
      emit(TasksError(res.error ?? 'Görev silinemedi'));
    }
  }

  Future<void> updateTaskStatus(Report report, ReportStatus newStatus) async {
    final id = report.id;
    if (id == null) {
      emit(const TasksError('Görev ID bulunamadı'));
      return;
    }

    final res = await _net.request(
      path: ApiEndpoints.reportById(id),
      type: RequestType.patch,
      data: {'status': newStatus.name},
    );

    if (res.isSuccess) {
      emit(const TasksTaskUpdated());
      await fetchTasks(); // Listeyi yenile
    } else {
      emit(TasksError(res.error ?? 'Görev güncellenemedi'));
    }
  }

  Future<void> deleteReport(Report report) async {
    final id = report.id;
    if (id == null) {
      emit(const TasksError('Bildirim ID bulunamadı'));
      return;
    }

    final res = await _net.request(
      path: ApiEndpoints.reportById(id),
      type: RequestType.delete,
    );

    if (res.isSuccess) {
      // TasksState, TasksLoaded(reports) şeklinde; rapor listesini güncellemek için mevcut state'i kontrol et
      if (state is TasksLoaded) {
        final current = (state as TasksLoaded).tasks;
        final updated = current.where((r) => r.id != id).toList();
        emit(TasksLoaded(updated));
      }
      // Ayrı bir "TasksReportDeleted" sınıfı tanımlı değil; silme sonrası genel başarı durumu olarak TasksTaskDeleted yayınlıyoruz
      emit(const TasksTaskDeleted());
    } else {
      emit(TasksError('Bildirim silinirken hata oluştu: ${res.error}'));
    }
  }

  auth.User? get currentUser => _currentUser;
}