import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final TaskModel? task;

  @override
  State<AddEditTaskScreen> createState() =>
      _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String _category = 'Personal';
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _isSaving = false;

  static const _categories = [
    'Personal',
    'Work',
    'Study',
    'Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    _titleController = TextEditingController(
      text: task?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    if (task != null) {
      _category = _categories.contains(task.category)
          ? task.category
          : 'Other';
      _priority = task.priority;
      _dueDate = task.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (selected != null && mounted) {
      setState(() {
        _dueDate = selected;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final controller = context.read<TaskController>();

      if (widget.task == null) {
        await controller.addTask(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
        );
      } else {
        final updated = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
        );

        await controller.updateTask(updated);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task save nahi hua: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Create Task'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Task title',
                hint: 'e.g. Complete Flutter project',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title required hai.';
                  }
                  if (value.trim().length > 120) {
                    return 'Title 120 characters se chhota rakhein.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Task ki details...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                ),
                items: TaskPriority.values
                    .map(
                      (priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name.toUpperCase()),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickDueDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _dueDate == null
                      ? 'Select due date'
                      : 'Due: ${_dueDate!.year}-'
                      '${_dueDate!.month.toString().padLeft(2, '0')}-'
                      '${_dueDate!.day.toString().padLeft(2, '0')}',
                ),
              ),
              if (_dueDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _dueDate = null),
                    child: const Text('Remove due date'),
                  ),
                ),
              const SizedBox(height: 24),
              AppButton(
                text: isEditing ? 'Save changes' : 'Create task',
                icon: isEditing ? Icons.check : Icons.add,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveTask,
              ),
            ],
          ),
        ),
      ),
    );
  }
}