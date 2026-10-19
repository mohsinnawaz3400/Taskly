import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading.dart';
import '../../settings/controllers/theme_controller.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/empty_tasks_view.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

class TaskHomeScreen extends StatelessWidget {
  const TaskHomeScreen({super.key});

  Future<void> _openForm(
      BuildContext context, {
        TaskModel? task,
      }) async
  {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditTaskScreen(task: task),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      TaskModel task,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" delete karna hai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<TaskController>().deleteTask(task.id);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task delete nahi ho saka. Dobara try karein.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TaskFlow',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Plan your day, one task at a time.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Consumer<ThemeController>(
            builder: (context, controller, child) {
              return IconButton(
                tooltip: 'Toggle theme',
                onPressed: () {
                  controller.toggleTheme(!controller.isDarkMode);
                },
                icon: Icon(
                  controller.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: SafeArea(
        child: Consumer<TaskController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const AppLoading();
            }

            if (controller.errorMessage != null &&
                controller.totalTasks == 0) {
              return AppErrorView(
                message: controller.errorMessage!,
                onRetry: controller.loadTasks,
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadTasks,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                children: [
                  DashboardCard(controller: controller),
                  const SizedBox(height: 24),
                  Text(
                    'Your tasks',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: controller.search,
                    decoration: const InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TaskFilter.values.map((filter) {
                        final selected = controller.filter == filter;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_filterLabel(filter)),
                            selected: selected,
                            onSelected: (_) => controller.setFilter(filter),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (controller.filteredTasks.isEmpty)
                    EmptyTasksView(
                      onAddTask: () => _openForm(context),
                    )
                  else
                    ...controller.filteredTasks.map(
                          (task) => TaskCard(
                        task: task,
                        onToggle: () async {
                          try {
                            await controller.toggleTask(task.id);
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task update nahi hua.'),
                              ),
                            );
                          }
                        },
                        onEdit: () => _openForm(context, task: task),
                        onDelete: () => _confirmDelete(context, task),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _filterLabel(TaskFilter filter) {
    return switch (filter) {
      TaskFilter.all => 'All',
      TaskFilter.pending => 'Pending',
      TaskFilter.completed => 'Completed',
      TaskFilter.overdue => 'Overdue',
    };
  }
}



