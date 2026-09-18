import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/widgets/category_badge.dart';
import 'package:taskflow/widgets/priority_badge.dart';
import 'package:taskflow/widgets/stat_card.dart';

void main() {
  testWidgets('CategoryBadge renders category name and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryBadge(category: TaskCategory.assignment),
        ),
      ),
    );

    expect(find.text('Assignment'), findsOneWidget);
  });

  testWidgets('PriorityBadge renders priority correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PriorityBadge(priority: TaskPriority.high),
        ),
      ),
    );

    expect(find.text('High'), findsOneWidget);
  });

  testWidgets('StatCard displays title and value', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatCard(
            title: 'Total Tasks',
            value: '12',
            icon: Icons.assignment_outlined,
            color: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.text('Total Tasks'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
}
