import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'database.dart';

class DailyTaskEditor extends StatefulWidget {
    @override
    _DailyTaskEditorState createState() => _DailyTaskEditorState();
}

class _DailyTaskEditorState extends State<DailyTaskEditor> {
    final DatabaseHelper db = DatabaseHelper();

    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();

    void _addDailyTask(name) {
        setState(() {
            db.createDailyTask(name);
        });
    }

    void _removeDailyTask(id) {
        setState(() {
            db.removeDailyTask(id);
        });
    }

    void _setDailyTaskActive(id, active) {
        setState(() {
            db.setDailyTaskActive(id, active);
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
                                    labelText: 'Daily task name',
                                ),
                                controller: _textController,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                        _addDailyTask(_textController.text);
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
                    child: FutureBuilder<List<DailyTask>>(
                        future: db.listDailyTasks(),
                        builder: (BuildContext context, AsyncSnapshot<List<DailyTask>> taskList) {
                            if (taskList.connectionState == ConnectionState.done) {
                                if (taskList.data.isEmpty) {
                                    return Align(
                                        alignment: Alignment.topCenter,
                                        child: Text('No daily tasks'),
                                    );
                                } else {
                                    return ListView.builder(
                                        itemCount: taskList.data.length,
                                        itemBuilder: (BuildContext context, int index) {
                                            var task = taskList.data[index];
                                            return Container(
                                                height: 50,
                                                child: Row(
                                                    children: [
                                                        Switch(
                                                            onChanged: (active) {
                                                                _setDailyTaskActive(task.id, active);
                                                            },
                                                            value: task.active,
                                                        ),
                                                        Expanded(child: Text(task.name)),
                                                        IconButton(
                                                            onPressed: () {
                                                                _removeDailyTask(task.id);
                                                            },
                                                            icon: Icon(Icons.highlight_remove),
                                                        ),
                                                    ],
                                                ),
                                            );
                                        },
                                    );
                                }
                            } else {
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
