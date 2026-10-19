import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/settings/controllers/theme_controller.dart';
import 'features/tasks/controllers/task_controller.dart';
import 'features/tasks/repositories/task_repository.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  final taskRepository = TaskRepository(databaseService);

  final themeController = ThemeController();
  await themeController.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(
          value: themeController,
        ),
        ChangeNotifierProvider<TaskController>(
          create: (_) => TaskController(taskRepository)..loadTasks(),
        ),
      ],
      child: const TodoApp(),
    ),
  );
}