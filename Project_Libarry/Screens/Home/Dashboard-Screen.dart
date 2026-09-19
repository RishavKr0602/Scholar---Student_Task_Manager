import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/page_transitions.dart';
import '../../core/utils/task_feedback.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/animated_entrance.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/task_card.dart';
import '../tasks/create_task_screen.dart';
import '../tasks/task_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _sectionFade;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _sectionFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _staggerController.forward();

    Future.microtask(() {
      ref.read(statsProvider.notifier).fetchStats();
      ref.read(taskProvider.notifier).fetchTasks();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final statsState = ref.watch(statsProvider);
    final taskState = ref.watch(taskProvider);

    final userName = authState.user?.name.split(' ').first ?? 'Student';
    final stats = statsState.stats;
    final now = DateTime.now();

    // Filter today's and upcoming tasks for dashboard
    final todayTasks = taskState.tasks.where((t) {
      return !t.completed &&
          t.dueDate.year == now.year &&
          t.dueDate.month == now.month &&
          t.dueDate.day == now.day;
    }).toList();

    final upcomingTasks = taskState.tasks.where((t) {
      final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
      return !t.completed && t.dueDate.isAfter(startOfTomorrow);
    }).take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(statsProvider.notifier).fetchStats(),
              ref.read(taskProvider.notifier).fetchTasks(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Greeting & Date
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $userName 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(now),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add quick task button
                    IconButton.filled(
                      onPressed: () {
                        context.pushSmooth(const CreateTaskScreen());
                      },
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                  ),
                ),
                const SizedBox(height: 20),

                // Productivity Progress Card
                FadeTransition(
                  opacity: _cardFade,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4F46E5), // Indigo 600
                        Color(0xFF6366F1), // Indigo 500
                        Color(0xFF8B5CF6), // Violet 500
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ACADEMIC PRODUCTIVITY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${stats.completionRate}% Completed',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.insights_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: stats.total > 0 ? (stats.completed / stats.total) : 0.0,
                          ),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        stats.total == 0
                            ? 'Welcome! Add your first assignment or exam to start tracking.'
                            : stats.completionRate >= 80
                                ? 'Outstanding! You are crushing your academic goals this semester 🚀'
                                : "You're ${stats.weeklyRate}% through your tasks this week. Keep the momentum going!",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4 Stat Cards Grid
                FadeTransition(
                  opacity: _cardFade,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.18,
                  children: [
                    StatCard(
                      title: 'Total Tasks',
                      value: '${stats.total}',
                      icon: Icons.assignment_outlined,
                      color: AppColors.primary,
                      subtitle: 'All items',
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                    StatCard(
                      title: 'Pending',
                      value: '${stats.pending}',
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                      subtitle: 'In progress',
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                    StatCard(
                      title: 'Completed',
                      value: '${stats.completed}',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      subtitle: 'Accomplished',
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                    StatCard(
                      title: 'Overdue',
                      value: '${stats.overdue}',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                      subtitle: stats.overdue > 0 ? 'Needs attention' : 'All clear',
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                  ],
                ),
                  ),
                ),
                const SizedBox(height: 28),

                // Today's Tasks Section
                FadeTransition(
                  opacity: _sectionFade,
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Today's Tasks",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${todayTasks.length}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateTab?.call(1),
                      child: Text(
                        'View All',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                ),
                const SizedBox(height: 12),

                if (todayTasks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.sentiment_satisfied_alt_rounded,
                            size: 32, color: AppColors.success),
                        const SizedBox(height: 8),
                        Text(
                          'No tasks due today!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enjoy your free time or prepare for upcoming deadlines.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...todayTasks.asMap().entries.map((entry) {
                    final task = entry.value;
                    return AnimatedEntrance(
                      index: entry.key,
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
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // Upcoming Deadlines Section
                if (upcomingTasks.isNotEmpty) ...[
                  Text(
                    'Upcoming Deadlines',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...upcomingTasks.asMap().entries.map((entry) {
                    final task = entry.value;
                    return AnimatedEntrance(
                      index: entry.key,
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
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
