import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';

class DailyTask {
    int id;
    String name;
    bool active;

    DailyTask({this.id, this.name, this.active});

    static fromMap(map) {
        return DailyTask(
            id: map['rowid'],
            name: map['name'],
            active: map['active'] == 1,
        );
    }
}

class DatabaseHelper {
    static Database _db;

    Future<Database> _getDb() async {
        if (_db == null) _db = await _initDb();
        return _db;
    }

    Future<String> _dbPath() async {
        return join(await getDatabasesPath(), 'time_manager.db');
    }

    Future<Database> _initDb() async {
        print('opening database');
        return await openDatabase(
            await _dbPath(),
            onCreate: (db, version) {
                print('creating database');
                return db.execute(
                    "CREATE TABLE DailyTasks(name TEXT, active INTEGER DEFAULT 1)",
                );
            },
            version: 2,
        );
    }

    Future<void> resetDb() async {
        print('resetting database');
        _db.close();
        _db = null;
        var file = File(await _dbPath());
        if (await file.exists()) {
            await file.delete();
        }
    }

    Future<DailyTask> createDailyTask(String name) async {
        final db = await _getDb();

        final int id = await db.insert(
            'DailyTasks',
            {'name': name},
        );

        return DailyTask(id: id, name: name);
    }

    Future<List<DailyTask>> listDailyTasks() async {
        final db = await _getDb();

        final List<Map<String, dynamic>> maps = await db.query(
            'DailyTasks',
            columns: ['rowid', 'name', 'active'],
        );

        return List.generate(maps.length, (i) {
            return DailyTask.fromMap(maps[i]);
        });
    }
    Future<List<DailyTask>> listActiveDailyTasks() async {
        final db = await _getDb();

        final List<Map<String, dynamic>> maps = await db.query(
            'DailyTasks',
            columns: ['rowid', 'name', 'active'],
            where: 'active = 1',
        );


        return List.generate(maps.length, (i) {
            return DailyTask.fromMap(maps[i]);
        });
    }


    Future<void> setDailyTaskActive(id, bool active) async {
        final db = await _getDb();

        await db.update(
            'DailyTasks',
            {'active': active},
            where: 'rowid = ?',
            whereArgs: [id],
        );
    }

    Future<void> removeDailyTask(int id) async {
        final db = await _getDb();

        db.delete('DailyTasks', where: 'rowid = ?', whereArgs: [id]);
    }
}

