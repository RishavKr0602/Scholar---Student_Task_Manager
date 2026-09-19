import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_haptics.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/utils/page_transitions.dart';
import '../../core/utils/task_feedback.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/priority_badge.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends ConsumerWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to current state of this task
    final taskList = ref.watch(taskProvider).tasks;
    final currentTask = taskList.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Task',
            onPressed: () {
              context.pushSmooth(EditTaskScreen(task: currentTask));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Task',
            onPressed: () => _confirmDelete(context, ref, currentTask),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Priority Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CategoryBadge(category: currentTask.category, fontSize: 13),
                  PriorityBadge(priority: currentTask.priority, fontSize: 13),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                currentTask.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  decoration: currentTask.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 16),

              // Due Date Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: currentTask.isOverdue
                      ? AppColors.error.withOpacity(0.08)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: currentTask.isOverdue
                        ? AppColors.error.withOpacity(0.3)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: currentTask.isOverdue
                            ? AppColors.error.withOpacity(0.15)
                            : AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        currentTask.isOverdue
                            ? Icons.warning_amber_rounded
                            : Icons.calendar_today_rounded,
                        color: currentTask.isOverdue ? AppColors.error : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTask.completed
                                ? 'Status: Completed'
                                : currentTask.isOverdue
                                    ? 'Status: Overdue'
                                    : 'Status: Pending',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: currentTask.completed
                                  ? AppColors.success
                                  : currentTask.isOverdue
                                      ? AppColors.error
                                      : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateHelpers.formatDueDate(currentTask.dueDate),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description section
              Text(
                'Description',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  currentTask.description != null && currentTask.description!.trim().isNotEmpty
                      ? currentTask.description!
                      : 'No additional details or notes provided for this task.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.6,
                    color: currentTask.description != null && currentTask.description!.trim().isNotEmpty
                        ? (isDark ? Colors.white70 : const Color(0xFF334155))
                        : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    fontStyle: currentTask.description != null && currentTask.description!.trim().isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Mark complete button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final wasPending = !currentTask.completed;
                    ref.read(taskProvider.notifier).toggleComplete(currentTask.id);
                    if (wasPending) {
                      showTaskCompletedFeedback(context, currentTask.title);
                    } else {
                      AppHaptics.light();
                    }
                  },
                  icon: Icon(
                    currentTask.completed
                        ? Icons.remove_done_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 20,
                  ),
                  label: Text(
                    currentTask.completed ? 'Mark as Incomplete' : 'Mark as Completed',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentTask.completed
                        ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                        : AppColors.primary,
                    foregroundColor: currentTask.completed
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(taskProvider.notifier).deleteTask(task.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
