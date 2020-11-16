import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'database.dart';
import 'daily_task_editor.dart';

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
                        actions: [
                            PopupMenuButton(
                                icon: Icon(Icons.menu),
                                itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                        value: 1,
                                        child: Text('Reset database'),
                                    ),
                                ],
                                onSelected: (_) {
                                    db.resetDb();
                                    _dbResetNotifier.value += 1;
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
                            Text('fuck'),
                            Text('yeah'),
                        ],
                    ),
                ),
            ),
        );
    }
}
