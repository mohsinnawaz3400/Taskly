import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../repositories/task_repository.dart';

enum TaskFilter { all, pending, completed, overdue }

class TaskController extends ChangeNotifier {
  TaskController(this._repository);

  final TaskRepository _repository;
  final _uuid = const Uuid();

  List<TaskModel> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  String _searchQuery = '';

  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  TaskFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalTasks => _tasks.length;

  int get completedCount =>
      _tasks.where((task) => task.isCompleted).length;

  int get pendingCount =>
      _tasks.where((task) => !task.isCompleted).length;

  double get completionProgress =>
      _tasks.isEmpty ? 0 : completedCount / totalTasks;

  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(_searchQuery) ||
              task.description.toLowerCase().contains(_searchQuery) ||
              task.category.toLowerCase().contains(_searchQuery);

      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
        TaskFilter.overdue => task.isOverdue,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.getAll();
    } catch (error, stackTrace) {
      debugPrint('loadTasks error: $error\n$stackTrace');
      _errorMessage = 'Tasks load nahi ho sakein.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void search(String value) {
    _searchQuery = value.trim().toLowerCase();
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String description = '',
    String category = 'Personal',
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      throw ArgumentError('Task title required hai.');
    }

    final task = TaskModel(
      id: _uuid.v4(),
      title: cleanTitle,
      description: description.trim(),
      category: category,
      priority: priority,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );

    await _repository.insert(task);
    _tasks = [task, ..._tasks];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title required hai.');
    }

    await _repository.update(task);

    _tasks = _tasks
        .map((item) => item.id == task.id ? task : item)
        .toList();

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final updated = _tasks[index].copyWith(
      isCompleted: !_tasks[index].isCompleted,
    );

    await updateTask(updated);
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);

    _tasks = _tasks.where((task) => task.id != id).toList();
    _errorMessage = null;
    notifyListeners();
  }
}