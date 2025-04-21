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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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
          SnackBar(
            content: Text('Error updating task: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Edit Task',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  )
                : Icon(Icons.check),
            onPressed: _isSaving ? null : _saveTask,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: FutureBuilder<TaskService>(
        future: _taskServiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 32,
                      vertical: 24,
                    ),
                    child: Card(
                      elevation: isSmallScreen ? 0 : 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(32),
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
                                  prefixIcon: Icon(Icons.title),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                enabled: !_isSaving,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  hintText: 'Enter task description',
                                  prefixIcon: Icon(Icons.description_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignLabelWithHint: true,
                                ),
                                enabled: !_isSaving,
                                maxLines: 3,
                              ),
                              SizedBox(height: 24),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Task Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    InkWell(
                                      onTap: _isSaving
                                          ? null
                                          : () => _selectDate(context),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              size: 20,
                                              color: AppColors.textSecondary,
                                            ),
                                            SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Due Date',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  _selectedDueDate
                                                      .toString()
                                                      .split(' ')[0],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.chevron_right,
                                              color: AppColors.textSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Priority',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedPriority,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                      items: ['low', 'medium', 'high']
                                          .map((String priority) {
                                        return DropdownMenuItem<String>(
                                          value: priority,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: _getPriorityColor(
                                                      priority),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                priority.toUpperCase(),
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: _isSaving
                                          ? null
                                          : (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _selectedPriority = value;
                                                });
                                              }
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.highPriority;
      case 'medium':
        return AppColors.mediumPriority;
      case 'low':
        return AppColors.lowPriority;
      default:
        return AppColors.mediumPriority;
    }
  }
}
