import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';

class Task {
    final int id;
    final String name;

    Task({this.id, this.name});

    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'name': name,
        };
    }
}

class DatabaseHelper {
    static Database _db;

    Future<Database> get db async {
        if (_db == null) _db = await initDb();
        return _db;
    }

    Future<Database> initDb() async {
        WidgetsFlutterBinding.ensureInitialized();
        return await openDatabase(
            join(await getDatabasesPath(), 'tasks.db'),
            onCreate: (db, version) {
                print('creating database');
                return db.execute(
                    "CREATE TABLE Tasks(name TEXT)",
                );
            },
            version: 2,
        );
    }

    Future<Task> createTask(String name) async {
        var db_ = await db;

        final int id = await db_.insert(
            'Tasks',
            {'name': name},
        );

        return Task(id: id, name: name);
    }

    Future<List<Task>> listTasks() async {
        final Database db_ = await db;

        final List<Map<String, dynamic>> maps = await db_.query(
            'Tasks',
            columns: ['rowid', 'name'],
        );

        return List.generate(maps.length, (i) {
            return Task(id: maps[i]['rowid'], name: maps[i]['name']);
        });
    }

    Future<void> removeTask(int id) async {
        final Database db_ = await db;

        db_.delete('Tasks', where: 'rowid = ?', whereArgs: [id]);
    }
}

void main() {
    runApp(MyApp());
}

class TaskEditor extends StatefulWidget {
    @override
    _TaskEditorState createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
    final DatabaseHelper db = DatabaseHelper();

    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();

    void _addTask(name) {
        setState(() {
            db.createTask(name);
        });
    }

    void _removeTask(id) {
        setState(() {
            db.removeTask(id);
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
                    child: FutureBuilder<List<Task>>(
                        future: db.listTasks(),
                        builder: (BuildContext context, AsyncSnapshot<List<Task>> taskList) {
                            print(taskList);
                            if (taskList.connectionState == ConnectionState.done) {
                                if (taskList.data.isEmpty) {
                                    return Align(
                                        alignment: Alignment.topCenter,
                                        child: Text('No tasks'),
                                    );
                                } else {
                                    return ListView.builder(
                                        itemCount: taskList.data.length,
                                        itemBuilder: (BuildContext context, int index) {
                                            return Container(
                                                height: 50,
                                                child: Row(
                                                    children: [
                                                        Expanded(child: Text('${taskList.data[index].name}')),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                                _removeTask(taskList.data[index].id);
                                                            },
                                                            child: Text('Remove'),
                                                        ),
                                                    ],
                                                ),
                                            );
                                        },
                                    );
                                }
                            } else {
                                print('no data');
                                return Align(
                                    alignment: Alignment.topCenter,
                                    child: CircularProgressIndicator(),
                                );
                            }
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
            home: DefaultTabController(
                length: 3,
                child: Scaffold(
                    appBar: AppBar(
                        backgroundColor: Color(0xFF457285),
                        title: Text('Time Manager'),
                        bottom: TabBar(
                            tabs: [
                                Tab(icon: Icon(Icons.edit)),
                                Tab(icon: Icon(Icons.access_time)),
                                Tab(icon: Icon(Icons.article)),
                            ],
                        ),
                    ),

                    body: TabBarView(
                        children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TaskEditor(),
                            ),
                            Text('fuck'),
                            Text('yeah'),
                        ],
                    ),
                ),
            ),
        );
    }
}
