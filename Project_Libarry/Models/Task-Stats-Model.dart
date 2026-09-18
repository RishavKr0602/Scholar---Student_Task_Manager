class CategoryCount {
  final String category;
  final int count;

  CategoryCount({required this.category, required this.count});

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
      category: json['category'] as String,
      count: json['count'] as int? ?? 0,
    );
  }
}

class PriorityCount {
  final String priority;
  final int count;

  PriorityCount({required this.priority, required this.count});

  factory PriorityCount.fromJson(Map<String, dynamic> json) {
    return PriorityCount(
      priority: json['priority'] as String,
      count: json['count'] as int? ?? 0,
    );
  }
}

class TaskStatsModel {
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final int dueToday;
  final int completionRate;
  final int weeklyRate;
  final int completedThisWeek;
  final List<CategoryCount> categories;
  final List<PriorityCount> priorities;

  TaskStatsModel({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.dueToday,
    required this.completionRate,
    required this.weeklyRate,
    required this.completedThisWeek,
    required this.categories,
    required this.priorities,
  });

  factory TaskStatsModel.empty() {
    return TaskStatsModel(
      total: 0,
      completed: 0,
      pending: 0,
      overdue: 0,
      dueToday: 0,
      completionRate: 0,
      weeklyRate: 0,
      completedThisWeek: 0,
      categories: [],
      priorities: [],
    );
  }

  factory TaskStatsModel.fromJson(Map<String, dynamic> json) {
    return TaskStatsModel(
      total: json['total'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      overdue: json['overdue'] as int? ?? 0,
      dueToday: json['dueToday'] as int? ?? 0,
      completionRate: json['completionRate'] as int? ?? 0,
      weeklyRate: json['weeklyRate'] as int? ?? 0,
      completedThisWeek: json['completedThisWeek'] as int? ?? 0,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      priorities: (json['priorities'] as List<dynamic>? ?? [])
          .map((e) => PriorityCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
