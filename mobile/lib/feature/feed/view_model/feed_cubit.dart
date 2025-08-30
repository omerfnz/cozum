import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/service/auth/auth_service.dart' as auth;
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit() : super(const FeedInitial());

  final _net = GetIt.I<INetworkService>();
  final _auth = GetIt.I<auth.IAuthService>();

  List<Report> _allReports = [];
  int _visibleCount = 0;
  static const int _pageSize = 8;
  auth.User? _currentUser;

  Future<void> loadUserAndFetch() async {
    final userRes = await _auth.getCurrentUser();
    if (userRes.isSuccess && userRes.data != null) {
      _currentUser = userRes.data;
    }
    await fetchReports();
  }

  Future<void> fetchReports() async {
    emit(const FeedLoading());
    
    final res = await _net.request<List<Report>>(
      path: ApiEndpoints.reports,
      type: RequestType.get,
      parser: (json) {
        final list = (json as List<dynamic>)
            .map((e) => Report.fromJson(e as Map<String, dynamic>))
            .toList();
        // En yeni ilk
        list.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        return list;
      },
    );

    if (res.isSuccess && res.data != null) {
      _allReports = res.data!;
      _visibleCount = min(_pageSize, _allReports.length);
      emit(FeedLoaded(_allReports.take(_visibleCount).toList(), _visibleCount < _allReports.length));
    } else {
      emit(FeedError(res.error ?? 'Akış yüklenemedi'));
    }
  }

  void loadMore() {
    if (_visibleCount >= _allReports.length) return;
    if (state is! FeedLoaded) return;
    
    emit(const FeedLoadingMore());
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _visibleCount = min(_visibleCount + _pageSize, _allReports.length);
      emit(FeedLoaded(_allReports.take(_visibleCount).toList(), _visibleCount < _allReports.length));
    });
  }

  void loadMoreReports() {
    loadMore();
  }

  bool canDeleteReport(Report report) {
    if (_currentUser == null) return false;
    final user = _currentUser!;
    
    // OPERATOR ve ADMIN tüm bildirimleri silebilir
    if (user.role == 'OPERATOR' || user.role == 'ADMIN') return true;
    
    // VATANDAS sadece kendi bildirilerini silebilir
    if (user.role == 'VATANDAS' && report.reporter.id == user.id) return true;
    
    // EKIP silme yetkisi yok
    return false;
  }

  Future<void> deleteReport(Report report) async {
    final id = report.id;
    if (id == null) {
      emit(const FeedError('Bildirim ID bulunamadı'));
      return;
    }

    final res = await _net.request(
      path: ApiEndpoints.reportById(id),
      type: RequestType.delete,
    );

    if (res.isSuccess) {
      _allReports.removeWhere((r) => r.id == id);
      _visibleCount = min(_visibleCount, _allReports.length);
      emit(FeedLoaded(_allReports.take(_visibleCount).toList(), _visibleCount < _allReports.length));
      emit(const FeedReportDeleted());
    } else {
      emit(FeedError('Bildirim silinirken hata oluştu: ${res.error}'));
    }
  }

  auth.User? get currentUser => _currentUser;
}