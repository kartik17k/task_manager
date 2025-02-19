import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../models/task.dart';
import '../../service/taskservice.dart';

class EditTaskScreen extends StatefulWidget {
  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late Future<TaskService> _taskServiceFuture;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDueDate;
  late String _selectedPriority;
  late Task _task;
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _taskServiceFuture = TaskService.getInstance();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _task = ModalRoute.of(context)!.settings.arguments as Task;
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    _titleController.text = _task.title;
    _descriptionController.text = _task.description;
    _selectedDueDate = _task.dueDate;
    _selectedPriority = _task.priority;
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final taskService = await _taskServiceFuture;

        final updatedTask = _task.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _selectedDueDate,
          priority: _selectedPriority,
        );

        await taskService.updateTask(updatedTask);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Task')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _isSaving ? null : _saveTask,
          ),
        ],
      ),
      body: FutureBuilder<TaskService>(
        future: _taskServiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: AppStyles.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isSaving,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppStyles.spacingL),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isSaving,
                      maxLines: 3,
                    ),
                    SizedBox(height: AppStyles.spacingL),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: AppStyles.spacingS),
                        Text(
                          'Due Date: ${_selectedDueDate.toString().split(' ')[0]}',
                          style: AppStyles.bodyText1,
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: _isSaving ? null : () => _selectDate(context),
                          child: Text('Change Date'),
                        ),
                      ],
                    ),
                    SizedBox(height: AppStyles.spacingL),
                    Text(
                      'Priority',
                      style: AppStyles.subtitle1,
                    ),
                    SizedBox(height: AppStyles.spacingS),
                    DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ['low', 'medium', 'high'].map((String priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                priority.toUpperCase(),
                                style: TextStyle(
                                  color: _getPriorityColor(priority),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _isSaving ? null : (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriority = newValue;
                          });
                        }
                      },
                    ),
                    SizedBox(height: AppStyles.spacingXL),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveTask,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: _isSaving
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return AppColors.highPriority;
      case 'medium': return AppColors.mediumPriority;
      case 'low': return AppColors.lowPriority;
      default: return AppColors.mediumPriority;
    }
  }
}