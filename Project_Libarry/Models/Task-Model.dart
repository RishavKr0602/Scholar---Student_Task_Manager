import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum TaskCategory {
  assignment,
  exam,
  project,
  lab,
  personal,
  other;

  static TaskCategory fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ASSIGNMENT':
        return TaskCategory.assignment;
      case 'EXAM':
        return TaskCategory.exam;
      case 'PROJECT':
        return TaskCategory.project;
      case 'LAB':
        return TaskCategory.lab;
      case 'PERSONAL':
        return TaskCategory.personal;
      case 'OTHER':
      default:
        return TaskCategory.other;
    }
  }

  String toApiString() {
    return name.toUpperCase();
  }

  String get displayName {
    switch (this) {
      case TaskCategory.assignment:
        return 'Assignment';
      case TaskCategory.exam:
        return 'Exam';
      case TaskCategory.project:
        return 'Project';
      case TaskCategory.lab:
        return 'Lab Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.assignment:
        return AppColors.categoryAssignment;
      case TaskCategory.exam:
        return AppColors.categoryExam;
      case TaskCategory.project:
        return AppColors.categoryProject;
      case TaskCategory.lab:
        return AppColors.categoryLab;
      case TaskCategory.personal:
        return AppColors.categoryPersonal;
      case TaskCategory.other:
        return AppColors.categoryOther;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.assignment:
        return Icons.menu_book_rounded;
      case TaskCategory.exam:
        return Icons.quiz_rounded;
      case TaskCategory.project:
        return Icons.rocket_launch_rounded;
      case TaskCategory.lab:
        return Icons.science_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
      case TaskCategory.other:
        return Icons.label_outline_rounded;
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high;

  static TaskPriority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'HIGH':
        return TaskPriority.high;
      case 'LOW':
        return TaskPriority.low;
      case 'MEDIUM':
      default:
        return TaskPriority.medium;
    }
  }

  String toApiString() {
    return name.toUpperCase();
  }

  String get displayName {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskPriority.high:
        return AppColors.priorityHighBg;
      case TaskPriority.medium:
        return AppColors.priorityMediumBg;
      case TaskPriority.low:
        return AppColors.priorityLowBg;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool completed;
  final DateTime? completedAt;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.completed = false,
    this.completedAt,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: TaskCategory.fromString(json['category'] as String? ?? 'ASSIGNMENT'),
      priority: TaskPriority.fromString(json['priority'] as String? ?? 'MEDIUM'),
      dueDate: DateTime.parse(json['dueDate'] as String),
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'category': category.toApiString(),
      'priority': priority.toApiString(),
      'dueDate': dueDate.toIso8601String(),
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? completed,
    DateTime? completedAt,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (completed) return false;
    return dueDate.isBefore(DateTime.now());
  }
}
