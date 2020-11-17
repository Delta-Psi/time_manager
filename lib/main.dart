import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'database.dart';
import 'notifications.dart';
import 'daily_task_editor.dart';
import 'daily_tasks.dart';

import 'dart:async';

void main() {
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    final DatabaseHelper db = DatabaseHelper();

    final _dbResetNotifier = new ValueNotifier(0);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Time Manager',
            theme: ThemeData(
                primaryColor: Color(0xFF457285),
            ),
            home: DefaultTabController(
                length: 2,
                child: Scaffold(
                    appBar: AppBar(
                        title: Text('Time Manager'),
                        bottom: TabBar(
                            tabs: [
                                Tab(icon: Icon(Icons.edit)),
                                Tab(icon: Icon(Icons.access_time)),
                                //Tab(icon: Icon(Icons.article)),
                            ],
                        ),
                        actions: [
                            PopupMenuButton(
                                icon: Icon(Icons.menu),
                                itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                        value: 1,
                                        child: Text('Reset database'),
                                    ),
                                    PopupMenuItem(
                                        value: 2,
                                        child: Text('Send notification'),
                                    ),
                                ],
                                onSelected: (v) async {
                                    if (v == 1) {
                                        db.resetDb();
                                        _dbResetNotifier.value += 1;
                                    } else if (v == 2) {
                                        var notif = await NotificationHelper.instance();

                                        final duration = Duration(minutes: 1);
                                        await notif.showTask('foo', duration);
                                        var startTime = DateTime.now();
                                        Timer.periodic(
                                            Duration(seconds: 1),
                                            (timer) async {
                                                var elapsed = DateTime.now().difference(startTime);
                                                var remaining = duration - elapsed;
                                                if (remaining.isNegative) {
                                                    timer.cancel();
                                                    await notif.endTask('foo');
                                                } else {
                                                    await notif.showTask('foo', remaining);
                                                }
                                            },
                                        );
                                    }
                                },
                            ),
                        ],
                    ),

                    body: TabBarView(
                        children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: ValueListenableBuilder<int>(
                                    valueListenable: _dbResetNotifier,
                                    builder: (context, value, child) => DailyTaskEditor(),
                                ),
                            ),
                            Padding(
                                padding: EdgeInsets.all(10.0),
                                child: ValueListenableBuilder<int>(
                                    valueListenable: _dbResetNotifier,
                                    builder: (context, value, child) => DailyTasks(),
                                ),
                            ),
                            //Text('yeah'),
                        ],
                    ),
                ),
            ),
        );
    }
}
