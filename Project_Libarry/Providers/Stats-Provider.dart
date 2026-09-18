import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_stats_model.dart';
import '../services/task_service.dart';

class StatsState {
  final TaskStatsModel stats;
  final bool isLoading;
  final String? error;

  StatsState({
    required this.stats,
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    TaskStatsModel? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  final TaskService _taskService = TaskService();

  StatsNotifier() : super(StatsState(stats: TaskStatsModel.empty()));

  Future<void> fetchStats() async {
    try {
      final stats = await _taskService.getStats();
      state = state.copyWith(stats: stats, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier();
});
