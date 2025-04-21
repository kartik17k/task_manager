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
  int _selectedIndex = 1;

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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          if (!isSmallScreen) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilters(),
                Expanded(
                  child: _buildTaskList(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isSmallScreen ? _buildBottomNav() : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.task_alt, color: AppColors.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Task Manager',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(1, Icons.task_outlined, 'My Tasks'),
                _buildNavItem(2, Icons.add_circle_outline, 'Add Task'),
                _buildNavItem(3, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sign Out'),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
      onTap: () => _handleNavigation(index),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'My Tasks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
            tooltip: 'Search Tasks',
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Implement notifications
            },
            tooltip: 'Notifications',
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPriority,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                        value: 'all', child: Text('All Priorities')),
                    ...Task.priorities.map((p) => DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(p),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(p.toUpperCase()),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedPriority = value!),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
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

  Widget _buildTaskList() {
    return FutureBuilder<TaskService>(
      future: _taskServiceFuture,
      builder: (context, serviceSnapshot) {
        if (serviceSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (serviceSnapshot.hasError) {
          return Center(child: Text('Error: ${serviceSnapshot.error}'));
        }

        final taskService = serviceSnapshot.data!;

        return StreamBuilder<List<Task>>(
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
              if (_selectedPriority != 'all' &&
                  task.priority != _selectedPriority) return false;
              return true;
            }).toList();

            if (filteredTasks.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) =>
                  _buildTaskCard(taskService, filteredTasks[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(TaskService taskService, Task task) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.pushNamed(
          context,
          '/task-details',
          arguments: task,
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    taskService.updateTask(task.copyWith(isCompleted: value));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPriorityBadge(task.priority),
                  SizedBox(height: 4),
                  Text(
                    'Due ${task.dueDate.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleNavigation,
      destinations: [

        NavigationDestination(
          icon: Icon(Icons.task_outlined),
          label: 'Tasks',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          label: 'Add Task',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add a new task to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
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

  void _handleNavigation(int index) {
    switch (index) {
      case 1: // Tasks
        // Already on tasks screen, no navigation needed
        break;
      case 2: // Add Task
        Navigator.pushNamed(context, '/add-task');
        break;
      case 3: // Profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
    setState(() => _selectedIndex = index);
  }
}
