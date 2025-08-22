import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/product/report/model/report_models.dart';
import 'package:mobile/product/report/report_repository.dart';

class HomeFeedState extends Equatable {
  const HomeFeedState({
    required this.items,
    required this.isLoading,
    this.error,
    required this.scope,
    this.isRefreshing = false,
    this.nextUrl,
    this.isLoadingMore = false,
  });

  final List<ReportListItem> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String scope; // 'all' | 'mine' | 'assigned'
  final String? nextUrl;
  final bool isLoadingMore;

  HomeFeedState copyWith({
    List<ReportListItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? scope,
    String? nextUrl,
    bool? isLoadingMore,
  }) {
    return HomeFeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      scope: scope ?? this.scope,
      nextUrl: nextUrl ?? this.nextUrl,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, isRefreshing, error, scope, nextUrl, isLoadingMore];
}

class HomeFeedCubit extends Cubit<HomeFeedState> {
  HomeFeedCubit(this._repository)
      : super(const HomeFeedState(items: [], isLoading: false, scope: 'all'));

  final ReportRepository _repository;

  Future<void> fetch({String? scope}) async {
    final newScope = scope ?? state.scope;
    emit(state.copyWith(isLoading: state.items.isEmpty, isRefreshing: state.items.isNotEmpty, error: null, scope: newScope));
    try {
      final page = await _repository.fetchPage(scope: newScope);
      emit(state.copyWith(items: page.items, nextUrl: page.nextUrl, isLoading: false, isRefreshing: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, isRefreshing: false, error: e.toString()));
    }
  }

  Future<void> refresh() => fetch();

  Future<void> changeScope(String scope) async {
    if (scope == state.scope) return;
    emit(state.copyWith(scope: scope));
    await fetch(scope: scope);
  }

  Future<void> fetchNext() async {
    final next = state.nextUrl;
    if (next == null || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true, error: null));
    try {
      final page = await _repository.fetchPage(pageUrl: next);
      final merged = List<ReportListItem>.from(state.items)..addAll(page.items);
      emit(state.copyWith(items: merged, nextUrl: page.nextUrl, isLoadingMore: false));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }
}