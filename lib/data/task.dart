class Task{
  Task({this.title, this.message, this.totalCount, this.currentCount, this.deadLine});

  int id;
  int created;
  int updated;
  int deleted;
  String title;
  String message;
  int totalCount;
  int currentCount;
  int deadLine;

  @override
  String toString() {
    return 'Task{id: $id, created: $created, updated: $updated, deleted: $deleted, title: $title, message: $message, totalCount: $totalCount, currentCount: $currentCount, deadLine: $deadLine}';
  }
}