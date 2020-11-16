import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Tasks extends StatefulWidget {
    @override
    _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();
    List<String> _tasks = [];

    void _addTask(task) {
        setState(() {
            _tasks.add(task);
        });
    }

    void _removeTaskAt(index) {
        setState(() {
            _tasks.removeAt(index);
        });
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Form(
                    key: _formKey,
                    child: Column(
                        children: [
                            TextFormField(
                                validator: (value) {
                                    if (value.isEmpty) {
                                        return 'Name required';
                                    }
                                    return null;
                                },
                                decoration: InputDecoration(
                                    labelText: 'Task Name',
                                ),
                                controller: _textController,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                        _addTask(_textController.text);
                                        _textController.clear();
                                    }
                                },
                                child: Text('Add'),
                            ),
                        ],
                    ),
                ),
                Divider(),
                Expanded(
                    child: ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (BuildContext context, int index) {
                            return Container(
                                height: 50,
                                child: Row(
                                    children: [
                                        Expanded(child: Text('${_tasks[index]}')),
                                        ElevatedButton(
                                            onPressed: () {
                                                _removeTaskAt(index);
                                            },
                                            child: Text('Remove'),
                                        ),
                                    ],
                                ),
                            );
                        },
                    ),
                ),
            ],
        );
    }
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Time Manager',
            home: Scaffold(
                appBar: AppBar(
                    title: Text('Time Manager'),
                ),
                body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Tasks(),
                ),
            ),
        );
    }
}
