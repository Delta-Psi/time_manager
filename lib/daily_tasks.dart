import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'database.dart';

class DailyTasks extends StatefulWidget {
    @override
    _DailyTasksState createState() => _DailyTasksState();
}

class _DailyTasksState extends State<DailyTasks> {
    final DatabaseHelper db = DatabaseHelper();

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Expanded(
                    child: FutureBuilder<List<DailyTask>>(
                        future: db.listActiveDailyTasks(),
                        builder: (context, taskList) {
                            if (taskList.connectionState == ConnectionState.done) {
                                if (taskList.data.isEmpty) {
                                    return Align(
                                        alignment: Alignment.topCenter,
                                        child: Text('No active daily tasks'),
                                    );
                                } else {
                                    return ListView.builder(
                                        itemCount: taskList.data.length,
                                        itemBuilder: (BuildContext context, int index) {
                                            var task = taskList.data[index];
                                            return Container(
                                                height: 50,
                                                child: Text(task.name),
                                            );
                                        }
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
