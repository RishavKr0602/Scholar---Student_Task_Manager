import 'package:flutter/material.dart';
import '../models/task_model.dart';

class CategoryBadge extends StatelessWidget {
  final TaskCategory category;
  final bool showIcon;
  final double fontSize;

  const CategoryBadge({
    super.key,
    required this.category,
    this.showIcon = true,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final color = category.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(category.icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            category.displayName,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
