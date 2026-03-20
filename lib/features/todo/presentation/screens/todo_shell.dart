import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dml_hub/core/constants/app_routes.dart';
import 'package:dml_hub/features/todo/presentation/widgets/add_task_sheet.dart';

class TodoShell extends StatelessWidget {
  const TodoShell({
    required this.title,
    required this.selectedIndex,
    required this.body,
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final int selectedIndex;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.todoSettings),
            icon: const Icon(Icons.tune_outlined),
          ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton ??
          FloatingActionButton.extended(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (context) => const AddTaskSheet(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.todoToday);
              break;
            case 1:
              context.go(AppRoutes.todoTasks);
              break;
            case 2:
              context.go(AppRoutes.todoProjects);
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), label: 'Projects'),
        ],
      ),
    );
  }
}
