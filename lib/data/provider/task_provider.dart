import 'package:sqflite/sqflite.dart';

import 'common_field.dart';
import 'record_provider.dart';
import '../task.dart';
import '../record.dart';

class TaskProvider {

  static final String createTable = '''
          create table $tableTask ( 
            $columnId integer primary key autoincrement,
            $columnCreated integer not null,
            $columnUpdated integer,
            $columnDeleted integer,
            $columnTitle text not null,
            $columnMessage text,
            $columnTotalCount integer not null,
            $columnCurrentCount integer not null,
            $columnDeadline integer not null)
          ''';

  /// 新建Task，顺便插入Record
  static Future<int> insert(Database db, Task task) async {
    // 记录Task的创建时间
    task.created = DateTime.now().millisecondsSinceEpoch;

    int taskId;
    await db.transaction((txn) async {
      taskId = await txn.insert(tableTask, task.toMap());
      // 创建Record并插入
      Record record = Record(
        taskId: taskId,
        delta: 0,
        fromValue: task.currentCount,
        toValue: task.currentCount,
      );
      await RecordProvider.insert(txn, record);
    });

    return taskId;
  }

  /// 获取所有Task
  static Future<List<Task>> getTasks(dynamic dbOrTnx) async {
    List<Map> maps = await dbOrTnx.query(tableTask,
      where: "$columnDeleted is null");
    if (maps.length > 0) {
      return maps.map((map) => Task.fromMap(map)).toList();
    }
    return List();
  }

  /// 获取所有Task，以及每条Task的所有Record
  static Future<Map<Task, List<Record>>> getTaskRecordsMap(Database db) async {
    Map<Task, List<Record>> result = Map();

    await db.transaction((txn) async {
      // 获取所有Task
      await TaskProvider.getTasks(txn).then((tasks) {
        // 对每条Task，获取对应的Record
        tasks.forEach((task) async {
          await RecordProvider.getRecordsByTaskId(txn, task.id).then((records) {
            // 保存到Map中
            result[task] = records;
          });
        });
      });
    });

    return result;
  }

  /// 更新Task，顺便插入Record
  static Future<int> update(Database db, Task task, int oldValue) async {
    task.updated = DateTime.now().millisecondsSinceEpoch;

    int taskId;
    await db.transaction((txn) async {
      // 创建Record并插入
      Record record = Record(
        taskId: task.id,
        delta: task.currentCount - oldValue,
        fromValue: oldValue,
        toValue: task.currentCount,
      );
      await RecordProvider.insert(txn, record);

      taskId = await txn.update(tableTask, task.toMap(),
        where: "$columnId = ?", whereArgs: [task.id]);
    });
    return taskId;
  }

  /// 根据taskId查找Task，暂时没有用到
  static Future<Task> getTask(Database db, int taskId) async {
    List<Map> maps = await db.query(tableTask,
      where: "$columnId = ? and $columnDeleted is not null",
      whereArgs: [taskId]);
    if (maps.length > 0) {
      return new Task.fromMap(maps.first);
    }
    return null;
  }

  /// 逻辑删除Task，暂时没有用到
  static Future<int> delete(Database db, int taskId) async {
    var values = <String, dynamic> {
      columnDeleted : DateTime.now().millisecondsSinceEpoch,
    };
    return await db.update(tableTask, values,
      where: "$columnId = ?", whereArgs: [taskId]);
  }
}