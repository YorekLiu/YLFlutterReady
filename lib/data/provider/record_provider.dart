import 'package:sqflite/sqflite.dart';

import 'common_field.dart';
import '../record.dart';

class RecordProvider {

  static final String createTable = '''
          create table $tableRecord ( 
            $columnId integer primary key autoincrement,
            $columnCreated integer not null,
            $columnUpdated integer,
            $columnDeleted integer,
            $columnTaskId integer not null,
            $columnDelta integer not null,
            $columnFromValue integer not null,
            $columnToValue integer not null,
            $columnRemark text)
          ''';

  /// 插入Record
  static Future<int> insert(dynamic dbOrTxn, Record record) async {
    record.created = DateTime.now().millisecondsSinceEpoch;
    return await dbOrTxn.insert(tableRecord, record.toMap());
  }

  /// 根据taskId获取对应的Record
  static Future<List<Record>> getRecordsByTaskId(dynamic dbOrTnx, int taskId) async {
    List<Map> maps = await dbOrTnx.query(tableRecord,
      where: "$columnTaskId = ? and $columnDeleted is null order by $columnCreated desc",
      whereArgs: [taskId]);
    if (maps.length > 0) {
      return maps.map((map) => Record.fromMap(map)).toList();
    }
    return List();
  }

  /// 获取所有的Record，调试时使用
  static Future<List<Record>> getRecords(dynamic dbOrTnx) async {
    List<Map> maps = await dbOrTnx.query(tableRecord,
      where: "$columnDeleted is null");
    if (maps.length > 0) {
      return maps.map((map) => Record.fromMap(map)).toList();
    }
    return List();
  }

  /// 根据recordId获取Record，暂时没有用到
  static Future<Record> getRecord(Database db, int recordId) async {
    List<Map> maps = await db.query(tableRecord,
      where: "$columnId = ? and $columnDeleted is not null",
      whereArgs: [recordId]);
    if (maps.length > 0) {
      return new Record.fromMap(maps.first);
    }
    return null;
  }

  /// 逻辑删除Record，暂时没有用到
  static Future<int> delete(Database db, int recordId) async {
    var values = <String, dynamic> {
      columnDeleted : DateTime.now().millisecondsSinceEpoch,
    };
    return await db.update(tableRecord, values,
      where: "$columnId = ?", whereArgs: [recordId]);
  }

  /// 更新Record，暂时没有用到
  static Future<int> update(Database db, Record record) async {
    record.updated = DateTime.now().millisecondsSinceEpoch;
    return await db.update(tableRecord, record.toMap(),
      where: "$columnId = ?", whereArgs: [record.id]);
  }
}