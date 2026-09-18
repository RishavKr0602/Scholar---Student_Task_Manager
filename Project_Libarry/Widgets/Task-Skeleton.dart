import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Animated shimmer skeleton shown while tasks load — a premium alternative to
/// a bare spinner. No external package required.
class TaskListSkeleton extends StatefulWidget {
  final int itemCount;
  const TaskListSkeleton({super.key, this.itemCount = 5});

  @override
  State<TaskListSkeleton> createState() => _TaskListSkeletonState();
}

class _TaskListSkeletonState extends State<TaskListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final block = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final opacity = 0.4 + (_controller.value * 0.5);
            Widget bar(double w, double h) => Opacity(
                  opacity: opacity,
                  child: Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      color: block,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: block,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bar(double.infinity, 14),
                            const SizedBox(height: 8),
                            bar(160, 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [bar(70, 22), const SizedBox(width: 8), bar(60, 22)]),
                      bar(50, 12),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Small inline colored dot — kept here so skeleton + shimmer share a file.
class PulsingDot extends StatelessWidget {
  const PulsingDot({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      );
}
