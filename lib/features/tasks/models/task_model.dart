enum TaskPriority { low, medium, high }

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'Personal',
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;

  bool get isOverdue =>
      !isCompleted &&
          dueDate != null &&
          dueDate!.isBefore(DateTime.now());

  TaskModel copyWith({
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.name,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, Object?> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Personal',
      priority: TaskPriority.values.firstWhere(
            (value) => value.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      dueDate: map['due_date'] == null
          ? null
          : DateTime.parse(map['due_date'] as String),
    );
  }
}