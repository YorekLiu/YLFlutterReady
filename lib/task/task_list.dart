import 'package:flutter/material.dart';

import '../data/task.dart';
import '../data/db/dbmanager.dart';
import '../data/provider/task_provider.dart';
import '../utils.dart' as Utils;
import 'add/task_add_detail.dart';

typedef ShowDetailListener = void Function(BuildContext context, Task task);
typedef RefreshListener = void Function();

class TaskListPage extends StatefulWidget {

  @override
  createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {

  Future<List<Task>> getTasks() async {
    var db = await DBManager().db;
    return await TaskProvider.getTasks(db);
  }

  _navigateDetailOrAdd(BuildContext context, Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailOrAddForm(task: task),
      )
    );

    if (result == true) {
      _refresh();
    }
  }

  _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("build => ${this.runtimeType.toString()}");

    final Widget body = FutureBuilder(
      future: getTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()),);
        } else if (snapshot.data == null || snapshot.data.isEmpty) {
          return Center(child: Text("Are you Ready?"),);
        } else {
          return _buildList(snapshot.data);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('Ready'),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateDetailOrAdd(context, null),
        tooltip: "添加Task",
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskListItem(task, _navigateDetailOrAdd, _refresh);
      },
    );
  }
}

class TaskListItem extends StatelessWidget {

  static int _itemId = 0;
  static int get itemId => _itemId++;

  TaskListItem(this.task, this.navigateListener, this.refreshListener, {Key key})
    : super(key: key);

  final ShowDetailListener navigateListener;
  final RefreshListener refreshListener;
  final Task task;

  _inc(BuildContext context, Task item) async {
    if (item.currentCount == item.totalCount) {
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('已经完成Task了😀'),
        )
      );
    } else {
      item.currentCount++;
      var db = await DBManager().db;
      await TaskProvider.update(db, item, item.currentCount - 1);
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('打卡${item.title}😀'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              _dec(item);
              refreshListener();
            }
          ),
        )
      );
    }
    refreshListener();
  }

  _dec(Task item) async {
    item.currentCount--;
    var db = await DBManager().db;
    await TaskProvider.update(db, item, item.currentCount + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: Key(itemId.toString()),
        resizeDuration: Duration(milliseconds: 1),
        onDismissed: (direction) {
          _inc(context, task);
        },
        background: Container(
          color: Colors.greenAccent[700],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(16.0),
                child: Icon(Icons.add_circle, color: Colors.white,),
              ),
              Container(
                margin: const EdgeInsets.all(16.0),
                child: Icon(Icons.add_circle, color: Colors.white,),
              ),
            ],
          ),
        ),
        child: InkWell(
          onTap: () => navigateListener(context, task),
          child: Container(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.headline,
                      ),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(right: 4.0),
                              child: Icon(
                                Icons.timer_off,
                                size: 12.0,
                                color: Theme.of(context).textTheme.caption.color,
                              ),
                            ),
                            Text(
                              Utils.duration(DateTime.fromMillisecondsSinceEpoch(task.deadline)),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        task.message,
                        style: Theme.of(context).textTheme.body1,
                      ),
                      task.updated != null ?
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(right: 4.0),
                                child: Icon(
                                  Icons.done,
                                  size: 12.0,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              Text(
                                Utils.duration(DateTime.fromMillisecondsSinceEpoch(task.updated)),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          )
                        ) :
                        Text('')
                      ,
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: task.currentCount / task.totalCount,
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}