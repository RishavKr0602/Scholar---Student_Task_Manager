import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/page_transitions.dart';
import '../../core/utils/task_feedback.dart';
import '../../providers/task_provider.dart';
import '../../widgets/animated_entrance.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_skeleton.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _statusTabs = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Today', 'value': 'today'},
    {'label': 'Upcoming', 'value': 'upcoming'},
    {'label': 'Overdue', 'value': 'overdue'},
    {'label': 'Completed', 'value': 'completed'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskState = ref.watch(taskProvider);
    final activeStatus = taskState.filters.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded),
                if (taskState.filters.category != null || taskState.filters.priority != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filters & Sorting',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const FilterBottomSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(taskProvider.notifier).setSearchQuery(val);
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search tasks by title or keyword...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(taskProvider.notifier).setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            // Horizontal Status Filter Chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _statusTabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tab = _statusTabs[index];
                  final isSelected = activeStatus == tab['value'];

                  return ChoiceChip(
                    label: Text(tab['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(taskProvider.notifier).setStatusFilter(tab['value']!);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Task List View
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(taskProvider.notifier).fetchTasks();
                },
                child: taskState.isLoading
                    ? const TaskListSkeleton()
                    : taskState.tasks.isEmpty
                        ? EmptyStateView(
                            icon: Icons.task_alt_rounded,
                            title: 'No tasks found',
                            message: _searchController.text.isNotEmpty
                                ? 'No tasks matched "${_searchController.text}". Try a different search term.'
                                : 'You have no tasks in this view. Tap + to add an academic assignment.',
                            buttonText: 'Add Task',
                            onButtonPressed: () {
                              context.pushSmooth(const CreateTaskScreen());
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: taskState.tasks.length,
                            itemBuilder: (context, index) {
                              final task = taskState.tasks[index];
                              return AnimatedEntrance(
                                index: index,
                                child: TaskCard(
                                  task: task,
                                  onToggleComplete: (_) {
                                    final wasPending = !task.completed;
                                    ref.read(taskProvider.notifier).toggleComplete(task.id);
                                    if (wasPending) {
                                      showTaskCompletedFeedback(context, task.title);
                                    }
                                  },
                                  onTap: () {
                                    context.pushSmooth(TaskDetailScreen(task: task));
                                  },
                                  onDelete: () {
                                    ref.read(taskProvider.notifier).deleteTask(task.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Deleted "${task.title}"'),
                                        behavior: SnackBarBehavior.floating,
                                        action: SnackBarAction(
                                          label: 'Dismiss',
                                          onPressed: () {},
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
