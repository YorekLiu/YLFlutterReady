import 'package:flutter/material.dart';

import '../data/task.dart';
import '../utils.dart' as Utils;

class TaskListPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("build => ${this.runtimeType.toString()}");

    final body = ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return TaskListItem(index);
        }
      );

    return Scaffold(
      appBar: AppBar(
        title: Text('Ready'),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: "添加Task",
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {

  TaskListItem(this._index, {Key key}) : super(key: key);

  final int _index;
  Task task;

  @override
  Widget build(BuildContext context) {
    task = Task(
      title: "Hello World $_index",
      message: "Flutter AAA",
      totalCount: 100,
      currentCount: 33,
      deadLine: DateTime(
        2019,
        6,
        1,
      ).millisecondsSinceEpoch
    );
    task.created = DateTime(
      2018,
      10,
      1,
    ).millisecondsSinceEpoch;
    task.updated = DateTime(
      2018,
      11,
      1,
    ).millisecondsSinceEpoch;

    return Card(
      margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
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
                            Utils.duration(DateTime.fromMillisecondsSinceEpoch(task.deadLine)),
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
                    ) : Text(''),
                  ],
                ),
              ),
              LinearProgressIndicator(
                value: task.currentCount / task.totalCount,
              ),
            ],
          ),
        ),
      )
    );
  }
}