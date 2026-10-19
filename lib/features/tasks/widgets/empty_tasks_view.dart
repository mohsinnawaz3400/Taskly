import 'package:flutter/material.dart';

class EmptyTasksView extends StatelessWidget {
  const EmptyTasksView({
    super.key,
    required this.onAddTask,
  });

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 76,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No tasks yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apna pehla task add karein aur aaj ka din productive banayein.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Add your first task'),
            ),
          ],
        ),
      ),
    );
  }
}