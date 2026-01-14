import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../services/task_firestore_service.dart';
import '../../domain/task.dart';
import '../../domain/task_status.dart';

class CreateTaskPage extends StatefulWidget {
  final Task? task; // null = create, != null = edit

  const CreateTaskPage({
    super.key,
    this.task,
  });

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assigneeController = TextEditingController();

  final TaskFirestoreService _taskService = TaskFirestoreService();

  DateTime? _dueDate;
  bool _isSubmitting = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _assigneeController.text = task.assignee;
      _dueDate = task.dueDate;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isEdit) {
        // ===== UPDATE =====
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          assignee: _assigneeController.text.trim(),
          dueDate: _dueDate!,
        );

        await _taskService.updateTask(updatedTask);
      } else {
        // ===== CREATE =====
        final newTask = Task(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          assignee: _assigneeController.text.trim(),
          dueDate: _dueDate!,
          status: TaskStatus.todo,
        );

        await _taskService.addTask(newTask);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save task failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Task' : 'Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// TITLE
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 16),

              /// DESCRIPTION
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              /// ASSIGNEE
              TextFormField(
                controller: _assigneeController,
                decoration: const InputDecoration(
                  labelText: 'Assignee',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              /// DUE DATE
              _DueDateSelector(
                dueDate: _dueDate,
                onTap: () => _selectDueDate(context),
              ),

              const SizedBox(height: 32),

              /// SUBMIT
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEdit ? 'Save Changes' : 'Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= DUE DATE ================= */

class _DueDateSelector extends StatelessWidget {
  final DateTime? dueDate;
  final VoidCallback onTap;

  const _DueDateSelector({
    required this.dueDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dueDate == null
                  ? 'Select a date'
                  : DateFormat.yMMMd().format(dueDate!),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
