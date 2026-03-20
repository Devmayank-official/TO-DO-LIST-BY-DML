import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dml_hub/core/widgets/app_empty_widget.dart';
import 'package:dml_hub/core/widgets/app_error_widget.dart';
import 'package:dml_hub/core/widgets/app_loading_widget.dart';
import 'package:dml_hub/features/todo/domain/usecases/project/create_project_usecase.dart';
import 'package:dml_hub/features/todo/presentation/providers/project_providers.dart';
import 'package:dml_hub/features/todo/presentation/screens/todo_shell.dart';

class TodoProjectsPage extends ConsumerWidget {
  const TodoProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return TodoShell(
      title: 'Projects',
      selectedIndex: 2,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectSheet(context, ref),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New Project'),
      ),
      body: projects.when(
        loading: AppLoadingWidget.new,
        error: (error, _) => AppErrorWidget(message: error.toString()),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyWidget(message: 'Create a project to group related work.');
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final project = items[index];
              return ListTile(
                leading: const Icon(Icons.folder_copy_outlined),
                title: Text(project.name),
                subtitle: Text(project.description ?? 'Project ready for tasks'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateProjectSheet(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Project', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Project name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ref.read(projectActionsProvider).createProject(
                          CreateProjectParams(name: controller.text),
                        );
                    if (!context.mounted) {
                      return;
                    }
                    context.pop();
                  },
                  child: const Text('Create project'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
