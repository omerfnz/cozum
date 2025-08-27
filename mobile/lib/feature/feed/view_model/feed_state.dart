import 'package:equatable/equatable.dart';
import '../../../product/models/report.dart';

abstract class FeedState extends Equatable {
  const FeedState();
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  const FeedLoaded(this.reports, this.hasMore);
  final List<Report> reports;
  final bool hasMore;
  
  List<Report> get visibleReports => reports;
  bool get hasMoreToLoad => hasMore;
  
  @override
  List<Object?> get props => [reports, hasMore];
}

class FeedLoadingMore extends FeedState {
  const FeedLoadingMore();
}

class FeedError extends FeedState {
  const FeedError(this.message);
  final String message;
  
  @override
  List<Object?> get props => [message];
}

class FeedReportDeleted extends FeedState {
  const FeedReportDeleted();
}