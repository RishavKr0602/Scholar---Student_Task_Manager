import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../core/network/api_exceptions.dart';
import 'stats_provider.dart';

class TaskFilterState {
  final String status;
  final TaskCategory? category;
  final TaskPriority? priority;
  final String search;
  final String sortBy;
  final String sortOrder;

  TaskFilterState({
    this.status = 'all',
    this.category,
    this.priority,
    this.search = '',
    this.sortBy = 'dueDate',
    this.sortOrder = 'asc',
  });

  TaskFilterState copyWith({
    String? status,
    TaskCategory? category,
    TaskPriority? priority,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool clearCategory = false,
    bool clearPriority = false,
  }) {
    return TaskFilterState(
      status: status ?? this.status,
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class TaskListState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;
  final TaskFilterState filters;

  TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    required this.filters,
  });

  TaskListState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? error,
    TaskFilterState? filters,
    bool clearError = false,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filters: filters ?? this.filters,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskListState> {
  final TaskService _taskService = TaskService();
  final Ref _ref;

  TaskNotifier(this._ref) : super(TaskListState(filters: TaskFilterState()));

  Future<void> fetchTasks({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final tasks = await _taskService.getTasks(
        status: state.filters.status,
        category: state.filters.category?.toApiString(),
        priority: state.filters.priority?.toApiString(),
        search: state.filters.search,
        sortBy: state.filters.sortBy,
        sortOrder: state.filters.sortOrder,
      );

      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      final message = e is ApiException ? e.message : 'Error loading tasks: $e';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  void setStatusFilter(String status) {
    state = state.copyWith(filters: state.filters.copyWith(status: status));
    fetchTasks();
  }

  void setCategoryFilter(TaskCategory? category) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        category: category,
        clearCategory: category == null,
      ),
    );
    fetchTasks();
  }

  void setPriorityFilter(TaskPriority? priority) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        priority: priority,
        clearPriority: priority == null,
      ),
    );
    fetchTasks();
  }

  void setSearchQuery(String search) {
    state = state.copyWith(filters: state.filters.copyWith(search: search));
    fetchTasks(showLoading: false);
  }

  void setSorting(String sortBy, String sortOrder) {
    state = state.copyWith(
      filters: state.filters.copyWith(sortBy: sortBy, sortOrder: sortOrder),
    );
    fetchTasks();
  }

  void clearFilters() {
    state = state.copyWith(
      filters: TaskFilterState(),
    );
    fetchTasks();
  }

  // Toggle completion with optimistic UI update
  Future<bool> toggleComplete(String taskId) async {
    final originalTasks = state.tasks;
    final index = state.tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return false;

    final targetTask = state.tasks[index];
    final updatedTask = targetTask.copyWith(
      completed: !targetTask.completed,
      completedAt: !targetTask.completed ? DateTime.now() : null,
    );

    // Optimistically update list
    final newTasks = List<TaskModel>.from(state.tasks);
    newTasks[index] = updatedTask;
    state = state.copyWith(tasks: newTasks);

    try {
      final result = await _taskService.toggleComplete(taskId);
      // Replace with server truth
      final confirmedTasks = List<TaskModel>.from(state.tasks);
      confirmedTasks[index] = result;
      state = state.copyWith(tasks: confirmedTasks);

      // Refresh stats
      _ref.read(statsProvider.notifier).fetchStats();
      return true;
    } catch (e) {
      // Rollback
      state = state.copyWith(tasks: originalTasks);
      return false;
    }
  }

  Future<bool> createTask({
    required String title,
    String? description,
    required TaskCategory category,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    try {
      final created = await _taskService.createTask(
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
      );

      state = state.copyWith(tasks: [created, ...state.tasks]);
      _ref.read(statsProvider.notifier).fetchStats();
      return true;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Error creating task: $e';
      state = state.copyWith(error: message);
      return false;
    }
  }

  Future<bool> updateTask({
    required String id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? completed,
  }) async {
    try {
      final updated = await _taskService.updateTask(
        id: id,
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
        completed: completed,
      );

      final index = state.tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final newTasks = List<TaskModel>.from(state.tasks);
        newTasks[index] = updated;
        state = state.copyWith(tasks: newTasks);
      }

      _ref.read(statsProvider.notifier).fetchStats();
      return true;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Error updating task: $e';
      state = state.copyWith(error: message);
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    final originalTasks = state.tasks;
    state = state.copyWith(tasks: state.tasks.where((t) => t.id != taskId).toList());

    try {
      await _taskService.deleteTask(taskId);
      _ref.read(statsProvider.notifier).fetchStats();
      return true;
    } catch (e) {
      state = state.copyWith(tasks: originalTasks);
      return false;
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskListState>((ref) {
  return TaskNotifier(ref);
});
