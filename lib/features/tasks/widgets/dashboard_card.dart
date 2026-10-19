import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/task_controller.dart';
import 'dashboard_stat.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = controller.completionProgress;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your productivity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}% completed',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              DashboardStat(
                label: 'Total',
                value: controller.totalTasks,
              ),
              const SizedBox(width: 24),
              DashboardStat(
                label: 'Pending',
                value: controller.pendingCount,
              ),
              const SizedBox(width: 24),
              DashboardStat(
                label: 'Completed',
                value: controller.completedCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}