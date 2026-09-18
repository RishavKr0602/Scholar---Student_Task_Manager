import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskState = ref.watch(taskProvider);
    final filters = taskState.filters;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort Tasks',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(taskProvider.notifier).clearFilters();
                  Navigator.pop(context);
                },
                child: Text(
                  'Reset All',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category section
          Text(
            'CATEGORY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All Categories'),
                selected: filters.category == null,
                onSelected: (_) => ref.read(taskProvider.notifier).setCategoryFilter(null),
              ),
              ...TaskCategory.values.map(
                (cat) => FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 14, color: cat.color),
                      const SizedBox(width: 4),
                      Text(cat.displayName),
                    ],
                  ),
                  selected: filters.category == cat,
                  onSelected: (_) => ref.read(taskProvider.notifier).setCategoryFilter(cat),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Priority section
          Text(
            'PRIORITY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All Priorities'),
                selected: filters.priority == null,
                onSelected: (_) => ref.read(taskProvider.notifier).setPriorityFilter(null),
              ),
              ...TaskPriority.values.map(
                (pri) => FilterChip(
                  label: Text(pri.displayName),
                  selected: filters.priority == pri,
                  onSelected: (_) => ref.read(taskProvider.notifier).setPriorityFilter(pri),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort by
          Text(
            'SORT BY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Due Date'),
                selected: filters.sortBy == 'dueDate',
                onSelected: (_) => ref.read(taskProvider.notifier).setSorting('dueDate', filters.sortOrder),
              ),
              ChoiceChip(
                label: const Text('Priority'),
                selected: filters.sortBy == 'priority',
                onSelected: (_) => ref.read(taskProvider.notifier).setSorting('priority', filters.sortOrder),
              ),
              ChoiceChip(
                label: const Text('Title'),
                selected: filters.sortBy == 'title',
                onSelected: (_) => ref.read(taskProvider.notifier).setSorting('title', filters.sortOrder),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
