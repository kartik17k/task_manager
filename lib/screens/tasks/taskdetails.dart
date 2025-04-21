import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../models/task.dart';
import '../../service/taskservice.dart';

class TaskDetailScreen extends StatefulWidget {
  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<TaskService> _taskServiceFuture;

  @override
  void initState() {
    super.initState();
    _taskServiceFuture = TaskService.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as Task;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              '/edit-task',
              arguments: task,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, task),
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

          final taskService = snapshot.data!;

          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 32),
                    child: Card(
                      elevation: isSmallScreen ? 0 : 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                _buildPriorityBadge(task.priority),
                              ],
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              task.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 24),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    Icons.calendar_today_outlined,
                                    'Due Date',
                                    task.dueDate.toString().split(' ')[0],
                                  ),
                                  SizedBox(height: 16),
                                  _buildInfoRow(
                                    Icons.access_time_outlined,
                                    'Created',
                                    task.createdAt.toString().split(' ')[0],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () async {
                                await taskService.updateTask(
                                  task.copyWith(isCompleted: !task.isCompleted),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: task.isCompleted
                                    ? Colors.grey
                                    : AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    task.isCompleted
                                        ? 'Completed'
                                        : 'Mark as Complete',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(String priority) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        border: Border.all(
          color: _getPriorityColor(priority),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
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

  Future<void> _showDeleteConfirmation(BuildContext context, Task task) async {
    final taskService = await _taskServiceFuture;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete Task',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await taskService.deleteTask(task.id);
      Navigator.pop(context);
    }
  }
}
