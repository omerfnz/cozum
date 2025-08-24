part of 'teams_cubit.dart';

/// Takımlar listesi durumu
class TeamsState extends Equatable {
  const TeamsState({
    this.teams = const [],
    this.isLoading = false,
    this.error,
  });

  /// Takımlar listesi
  final List<TeamDto> teams;
  
  /// Yükleme durumu
  final bool isLoading;
  
  /// Hata mesajı
  final String? error;

  /// Başarılı durum kontrolü
  bool get isSuccess => !isLoading && error == null;
  
  /// Boş liste kontrolü
  bool get isEmpty => teams.isEmpty;
  
  /// Hata durumu kontrolü
  bool get hasError => error != null;

  /// State kopyalama metodu
  TeamsState copyWith({
    List<TeamDto>? teams,
    bool? isLoading,
    String? error,
  }) {
    return TeamsState(
      teams: teams ?? this.teams,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [teams, isLoading, error];

  @override
  String toString() {
    return 'TeamsState(teams: ${teams.length}, isLoading: $isLoading, error: $error)';
  }
}