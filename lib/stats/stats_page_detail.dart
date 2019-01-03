import 'package:flutter/material.dart';

import '../data/task.dart';
import '../data/record.dart';
import 'my_chart.dart';

class StatsDetailPage extends StatefulWidget {
  StatsDetailPage(this.task, this.records, {Key key}) : super(key: key);

  final Task task;
  final List<Record> records;

  @override
  createState() => _StatsDetailPageState();
}

class _StatsDetailPageState extends State<StatsDetailPage> with AutomaticKeepAliveClientMixin<StatsDetailPage> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    print("build => ${this.runtimeType.toString()}");
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: MyChart(
              widget.task.title,
              "assets/checkbox-marked-circle-outline.png",
              "${widget.task.currentCount}/${widget.task.totalCount}",
              isLineChart: true,
              dataMap: _parseData(),
            ),
          ),
        ),
        Spacer()
      ],
    );
  }

  Map<String, int> _parseData() {
    var result = <String, int>{};
    int i = 1;
    widget.records.reversed.forEach((record) {
      result[(i++).toString()] = record.toValue;
    });
    return result;
  }
}