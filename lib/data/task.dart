import 'provider/common_field.dart';

final String tableTask = 'task';
final String columnTitle = 'title';
final String columnMessage = 'message';
final String columnTotalCount = 'total_count';
final String columnCurrentCount = 'current_count';
final String columnDeadline = 'deadline';


class Task{
  Task({this.title, this.message, this.totalCount, this.currentCount, this.deadline});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      columnCreated : created,
      columnUpdated : updated,
      columnDeleted : deleted,
      columnTitle: title,
      columnMessage : message,
      columnTotalCount : totalCount,
      columnCurrentCount : currentCount,
      columnDeadline : deadline
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Task.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    created = map[columnCreated];
    updated = map[columnUpdated];
    deleted = map[columnDeleted];
    title = map[columnTitle];
    message = map[columnMessage];
    totalCount = map[columnTotalCount];
    currentCount = map[columnCurrentCount];
    deadline = map[columnDeadline];
  }

  int id;
  int created;
  int updated;
  int deleted;
  String title;
  String message;
  int totalCount;
  int currentCount;
  int deadline;

  @override
  String toString() {
    return 'Task{id: $id, created: $created, updated: $updated, deleted: $deleted, title: $title, message: $message, totalCount: $totalCount, currentCount: $currentCount, deadline: $deadline}';
  }
}