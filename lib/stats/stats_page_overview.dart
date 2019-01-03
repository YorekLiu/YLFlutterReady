import 'package:flutter/material.dart';

import '../utils.dart' as Utils;
import '../data/task.dart';
import '../data/record.dart';
import 'my_chart.dart';

class StatsOverviewPage extends StatefulWidget {

  StatsOverviewPage(this.map, {Key key}) : super(key: key);

  final Map<Task, List<Record>> map;

  @override
  createState() => _StatsOverviewPageState();
}

class _StatsOverviewPageState extends State<StatsOverviewPage> with AutomaticKeepAliveClientMixin<StatsOverviewPage> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    print("build => ${this.runtimeType.toString()}");
    Map<String, int> dataMap = {};
    int total = 0;
    // 计算每个Task在7天之内完成的情况
    if (widget.map != null && widget.map.isNotEmpty) {
      for (var iterator in widget.map.entries) {
        // 第一个Record肯定是创建记录
        if (iterator.value.length >= 1) {
          int count = 0;
          iterator.value.forEach((record) {
            var duration = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(record.created));
            if (duration.inDays <= 7) {
              count += record.delta;
            }
          });
          dataMap[iterator.key.title] = count;
          total += count;
        } else {
          dataMap[iterator.key.title] = 0;
        }
      }
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            [_buildChart("Overview (Weekly)", total.toString(), dataMap: dataMap)],
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true
          ),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
            mainAxisSpacing: 0.0,
            crossAxisSpacing: 0.0,
            childAspectRatio: 2.0
          ),
          delegate: SliverChildBuilderDelegate(
              (context, index) {
              return _buildListItem(
                context,
                widget.map.keys.elementAt(index),
                widget.map.values.elementAt(index),
                dataMap.values.elementAt(index)
              );
            },
            childCount: dataMap.length
          ),
        )
      ],
    );
  }

  _buildListItem(BuildContext context, Task task, List<Record> records, int count) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
          width: 0.5
        )
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    "${task.currentCount}",
                    style: Theme.of(context).textTheme.headline.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(4.0, 0.0, 8.0, 0.0),
                    child: Text(
                      "/ ${task.totalCount}",
                      style: Theme.of(context).textTheme.caption.copyWith(
                        color: Colors.black54,
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.caption.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                      Icon(Icons.format_quote, color: Colors.black54, size: 12.0,)
                    ],
                  ),
                  Text(
                    "remaining: ${Utils.duration(DateTime.fromMillisecondsSinceEpoch(task.deadline))}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption.copyWith(
                      color: Colors.black54,
                    )
                  ),
                  Text(
                    "last: ${Utils.duration(DateTime.fromMillisecondsSinceEpoch(task.created))}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption.copyWith(
                      color: Colors.black54,
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildChart(String title, String total, {Map<String, int> dataMap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12))
      ),
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.1,
        child: MyChart(
          title,
          "assets/checkbox-marked-circle-outline.png",
          total,
          dataMap: dataMap,
        ),
      ),
    );
  }
}