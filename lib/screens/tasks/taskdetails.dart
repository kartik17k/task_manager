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

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              '/edit-task',
              arguments: task,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, task),
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

          final taskService = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: AppStyles.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: AppStyles.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: AppStyles.headline2,
                                ),
                              ),
                              _buildPriorityBadge(task.priority),
                            ],
                          ),
                          SizedBox(height: AppStyles.spacingL),
                          Text(
                            'Description',
                            style: AppStyles.subtitle1.copyWith(color: Colors.grey[600]),
                          ),
                          SizedBox(height: AppStyles.spacingS),
                          Text(
                            task.description,
                            style: AppStyles.bodyText1,
                          ),
                          SizedBox(height: AppStyles.spacingL),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Due Date',
                            task.dueDate.toString().split(' ')[0],
                          ),
                          SizedBox(height: AppStyles.spacingM),
                          _buildInfoRow(
                            Icons.access_time,
                            'Created',
                            task.createdAt.toString().split(' ')[0],
                          ),
                          SizedBox(height: AppStyles.spacingL),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    task.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                                  ),
                                  label: Text(
                                    task.isCompleted ? 'Completed' : 'Mark as Complete',
                                  ),
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(width: AppStyles.spacingS),
        Text(
          '$label: ',
          style: AppStyles.bodyText1.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: AppStyles.bodyText1,
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(String priority) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: Colors.white),
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

  Future<void> _showDeleteConfirmation(BuildContext context, Task task) async {
    final taskService = await _taskServiceFuture;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result ?? false) {
      await taskService.deleteTask(task.id);
      Navigator.pop(context);
    }
  }
}