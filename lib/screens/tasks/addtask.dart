import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../models/task.dart';
import '../../service/taskservice.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late Future<TaskService> _taskServiceFuture;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _selectedDueDate;
  String _selectedPriority = 'medium';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _taskServiceFuture = TaskService.getInstance();
    _selectedDueDate = DateTime.now().add(Duration(days: 1));
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

  Future<void> _createTask() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final taskService = await _taskServiceFuture;

        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID generation
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _selectedDueDate,
          priority: _selectedPriority,
          isCompleted: false,
          createdAt: DateTime.now(),
          userId: '',
        );

        await taskService.createTask(newTask);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating task: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _isSubmitting ? null : _createTask,
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
                        hintText: 'Enter task title',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isSubmitting,
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
                        hintText: 'Enter task description',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isSubmitting,
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
                          onPressed: _isSubmitting ? null : () => _selectDate(context),
                          child: Text('Select Date'),
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
                                style: AppStyles.bodyText1,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _isSubmitting ? null : (String? newValue) {
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
                        onPressed: _isSubmitting ? null : _createTask,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: _isSubmitting
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            'Create Task',
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