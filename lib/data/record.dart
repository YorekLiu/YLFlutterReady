import 'provider/common_field.dart';

final String tableRecord = 'record';
final String columnTaskId = 'task_id';
final String columnDelta = 'delta';
final String columnFromValue = 'from_value';
final String columnToValue = 'to_value';
final String columnRemark = 'remark';


class Record{
  Record({this.taskId, this.delta, this.fromValue, this.toValue, this.remark});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      columnCreated : created,
      columnUpdated : updated,
      columnDeleted : deleted,
      columnTaskId: taskId,
      columnDelta : delta,
      columnFromValue : fromValue,
      columnToValue : toValue,
      columnRemark : remark
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Record.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    created = map[columnCreated];
    updated = map[columnUpdated];
    deleted = map[columnDeleted];
    taskId = map[columnTaskId];
    delta = map[columnDelta];
    fromValue = map[columnFromValue];
    toValue = map[columnToValue];
    remark = map[columnRemark];
  }

  int id;
  int created;
  int updated;
  int deleted;
  int taskId;
  int delta;
  int fromValue;
  int toValue;
  String remark;

  @override
  String toString() {
    return 'Record{id: $id, created: $created, updated: $updated, deleted: $deleted, taskId: $taskId, delta: $delta, fromValue: $fromValue, toValue: $toValue, remark: $remark}';
  }
}