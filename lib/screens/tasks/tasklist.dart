import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../service/authservice.dart';
import '../../service/taskservice.dart';
import '../../constants/styles.dart';
import '../../constants/colors.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<TaskService> _taskServiceFuture;
  String _selectedPriority = 'all';
  bool _showCompleted = true;

  void logout(BuildContext context) {
    final authService = AuthService();
    Navigator.pushNamed(context, '/login');
    authService.logout();
  }

  @override
  void initState() {
    super.initState();
    _taskServiceFuture = TaskService.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<TaskService>(
        future: _taskServiceFuture,
        builder: (context, serviceSnapshot) {
          if (serviceSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (serviceSnapshot.hasError) {
            return Center(child: Text('Error: ${serviceSnapshot.error}'));
          }

          final taskService = serviceSnapshot.data!;

          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: StreamBuilder<List<Task>>(
                  stream: taskService.getTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final tasks = snapshot.data ?? [];
                    final filteredTasks = tasks.where((task) {
                      if (!_showCompleted && task.isCompleted) return false;
                      if (_selectedPriority != 'all' && task.priority != _selectedPriority) return false;
                      return true;
                    }).toList();

                    if (filteredTasks.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) => _buildTaskCard(taskService, filteredTasks[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-task'),
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey),
          SizedBox(height: AppStyles.spacingM),
          Text(
            'No tasks found',
            style: AppStyles.subtitle1.copyWith(color: Colors.grey),
          ),
          SizedBox(height: AppStyles.spacingS),
          Text(
            'Add a new task to get started',
            style: AppStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedPriority,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                ...Task.priorities.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.toUpperCase()),
                )),
              ],
              onChanged: (value) => setState(() => _selectedPriority = value!),
            ),
          ),
          SizedBox(width: AppStyles.spacingM),
          Row(
            children: [
              Text('Show Completed'),
              Switch(
                value: _showCompleted,
                onChanged: (value) => setState(() => _showCompleted = value),
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskService taskService, Task task) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            taskService.updateTask(task.copyWith(isCompleted: value));
          },
          activeColor: AppColors.primaryColor,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Due: ${task.dueDate.toString().split(' ')[0]}',
                  style: AppStyles.caption,
                ),
              ],
            ),
          ],
        ),
        trailing: _buildPriorityBadge(task.priority),
        onTap: () => Navigator.pushNamed(
          context,
          '/task-detail',
          arguments: task,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: 12),
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