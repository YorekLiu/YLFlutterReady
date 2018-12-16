import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../provider/task_provider.dart';
import '../provider/record_provider.dart';

class DBManager {
  static final DBManager _instance = DBManager._internal();

  static Database _db;

  factory DBManager() => _instance;

  DBManager._internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'ready.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.transaction((txn) async {
      await txn.execute(TaskProvider.createTable);
      await txn.execute(RecordProvider.createTable);
    });
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}