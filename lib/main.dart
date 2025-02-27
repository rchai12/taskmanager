import 'package:flutter/material.dart';

void main() => runApp(TaskManagerApp());

class Task {
  String _title;
  String _description;
  bool _status;

  Task({required String title, required String description, bool status = false})
      : _title = title,
        _description = description,
        _status = status;

  String get title => _title;
  String get description => _description;
  bool get status => _status;

  void setTitle(String title) => _title = title;
  void setDescription(String description) => _description = description;
  void toggleStatus() => _status = !_status;
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  final List<Task> _tasks = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);


    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _titleController.text, description: _descriptionController.text));
        _titleController.clear();
        _descriptionController.clear();
      });
      Navigator.of(context).pop();
    }
  }

  void _editTask(int index) {
    _titleController.text = _tasks[index].title;
    _descriptionController.text = _tasks[index].description;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Task Description'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _tasks[index].setTitle(_titleController.text);
                      _tasks[index].setDescription(_descriptionController.text);
                    });
                    _titleController.clear();
                    _descriptionController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index].toggleStatus();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showAddTaskMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Task Description'),
                ),
                ElevatedButton(onPressed: _addTask, child: Text('Add Task')),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ongoingTasks = _tasks.where((task) => !task.status).toList();
    final completedTasks = _tasks.where((task) => task.status).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: ongoingTasks.length,
            itemBuilder: (context, index) {
              final task = ongoingTasks[index];
              return ListTile(
                onTap: () => _editTask(_tasks.indexOf(task)),
                leading: IconButton(
                  icon: Icon(task.status ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                  onPressed: () => _toggleTaskStatus(_tasks.indexOf(task)),
                ),
                title: Text(task.title),
              );
            },
          ),
          ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return ListTile(
                onTap: () => _editTask(_tasks.indexOf(task)),
                leading: Icon(Icons.radio_button_checked),
                title: Text(task.title, style: TextStyle(decoration: TextDecoration.lineThrough)),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddTaskMenu,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
