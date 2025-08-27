import 'package:equatable/equatable.dart';
import '../../../product/models/report.dart';

abstract class TasksState extends Equatable {
  const TasksState();
  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

class TasksLoading extends TasksState {
  const TasksLoading();
}

class TasksLoaded extends TasksState {
  const TasksLoaded(this.tasks);
  final List<Report> tasks;
  
  @override
  List<Object?> get props => [tasks];
}

class TasksError extends TasksState {
  const TasksError(this.message);
  final String message;
  
  @override
  List<Object?> get props => [message];
}

class TasksTaskDeleted extends TasksState {
  const TasksTaskDeleted();
}

class TasksTaskUpdated extends TasksState {
  const TasksTaskUpdated();
}