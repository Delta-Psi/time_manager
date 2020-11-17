import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dart:async';

import 'database.dart';
import 'notifications.dart';

const DAILY_TASK_DURATION = Duration(hours: 1);
const RESET_HOUR = 6;

class DailyTasks extends StatefulWidget {
    @override
    _DailyTasksState createState() => _DailyTasksState();
}

class _DailyTasksState extends State<DailyTasks> {
    final DatabaseHelper db = DatabaseHelper();

    _DailyTasksState() {
        Timer.periodic(Duration(seconds: 1), _timerCallback);
    }

    String _format(Duration time) {
        final minutes = time.inMinutes.toString().padLeft(2, '0');
        final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
        return '$minutes:$seconds';
    }

    DateTime _cutoffTime() {
        final now = DateTime.now();
        final lastMidnight = DateTime(now.year, now.month, now.day);
        final todayResetHour = DateTime(now.year, now.month, now.day, RESET_HOUR);
        
        if (now.isBefore(todayResetHour)) {
            return todayResetHour.subtract(Duration(days: 1));
        } else {
            return todayResetHour;
        }
    }

    int _currentTaskId;
    String _currentTaskName;
    DateTime _currentTaskFinishes;

    void _timerCallback(timer) {
        if (_currentTaskId != null) {
            final remaining = _currentTaskFinishes.difference(DateTime.now());
            if (remaining.isNegative) {
                NotificationHelper.instance().then((notif) async {
                    await notif.endTask(_currentTaskName);
                });

                setState(() {
                    db.setDailyTaskRemainingTime(_currentTaskId, Duration.zero);

                    _currentTaskId = null;
                    _currentTaskName = null;
                    _currentTaskFinishes = null;
                });
            } else {
                NotificationHelper.instance().then((notif) async {
                    await notif.showTask(_currentTaskName, remaining);
                });

                setState(() {
                    db.setDailyTaskRemainingTime(_currentTaskId, remaining);
                });
            }
        }
    }

    void _startTask(int id, String name, DateTime finishes) {
        setState(() {
            _currentTaskId = id;
            _currentTaskName = name;
            _currentTaskFinishes = finishes;
        });
    }

    void _pauseTask() {
        NotificationHelper.instance().then((notif) async {
            await notif.pauseTask();
        });

        setState(() {
            _currentTaskId = null;
            _currentTaskName = null;
            _currentTaskFinishes = null;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Expanded(
                    child: FutureBuilder<List<DailyTask>>(
                        future: db.listActiveDailyTasks(),
                        builder: (context, taskList) {
                            if (taskList.hasData) {
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
                                                child: Builder(
                                                    builder: (context) {
                                                        var remainingTime = task.remainingTime;
                                                        if (task.lastUpdated == null || task.lastUpdated.isBefore(_cutoffTime())) {
                                                            remainingTime = DAILY_TASK_DURATION;
                                                        }
                                                        //print(remainingTime);

                                                        if (task.id == _currentTaskId) {
                                                            return Row(
                                                                children: [
                                                                    Expanded(child: Text(task.name)),
                                                                    Text(_format(remainingTime)),
                                                                    IconButton(
                                                                        onPressed: () {
                                                                            _pauseTask();
                                                                        },
                                                                        icon: Icon(Icons.pause),
                                                                    ),
                                                                ],
                                                            );
                                                        } else if (remainingTime > Duration.zero) {
                                                            return Row(
                                                                children: [
                                                                    Expanded(child: Text(task.name)),
                                                                    Text(_format(remainingTime)),
                                                                    IconButton(
                                                                        onPressed: () {
                                                                            _startTask(task.id, task.name, DateTime.now().add(remainingTime));
                                                                        },
                                                                        icon: Icon(Icons.play_arrow),
                                                                    ),
                                                                ],
                                                            );
                                                        } else {
                                                            return Row(
                                                                children: [
                                                                    Expanded(child: Text(task.name)),
                                                                    Text(_format(remainingTime)),
                                                                    IconButton(
                                                                        onPressed: () {
                                                                        },
                                                                        icon: Icon(Icons.done),
                                                                    ),
                                                                ],
                                                            );
                                                        }
                                                    },
                                                ),
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
