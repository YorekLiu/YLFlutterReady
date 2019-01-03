import 'package:flutter/material.dart';

import '../data/db/dbmanager.dart';
import '../data/task.dart';
import '../data/record.dart';
import '../data/provider/task_provider.dart';
import 'stats_page_detail.dart';
import 'stats_page_overview.dart';

class StatsPage extends StatefulWidget {
  @override
  createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with TickerProviderStateMixin {

  TabController _tc;
  List<Widget> tabs = [];

  TabController _makeNewTabController() => TabController(
    vsync: this,
    length: tabs.length,
    initialIndex: 0,
  );

  @override
  Widget build(BuildContext context) {
    print("build => ${this.runtimeType.toString()}");
    return FutureBuilder(
      future: getTaskRecordsMap(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text(snapshot.error.toString()),);
        else
          return _build(snapshot.data);
      }
    );
  }

  _build(Map<Task, List<Record>> map) {
    tabs = [Tab(text: "Overview")];
    if (map != null) {
      tabs.addAll(map.keys.map((task) => Tab(text: task.title)));
    }
    _tc = _makeNewTabController();

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text('Stats'),
        elevation: 1.0,
        backgroundColor: Theme.of(context).canvasColor,
        textTheme: Theme.of(context).textTheme,
        bottom: TabBar(
          controller: _tc,
          isScrollable: true,
          labelColor: Colors.black87,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Colors.indigo,
          unselectedLabelColor: Colors.black38,
          tabs: tabs
        ),
      ),
      body: TabBarView(
        controller: _tc,
        children: _buildTabBarView(tabs.length, map),
      ),
    );
  }

  _buildTabBarView(int length, Map<Task, List<Record>> map) {
    List<Widget> widgets = [];
    if (length > 0) {
      widgets.add(StatsOverviewPage(map));
    }
    if (map == null) {
      return widgets;
    }

    for (var iterator in map.entries) {
      widgets.add(StatsDetailPage(iterator.key, iterator.value,));
    }

    return widgets;
  }

  Future<Map<Task, List<Record>>> getTaskRecordsMap() async {
    var db = await DBManager().db;
    return await TaskProvider.getTaskRecordsMap(db);
  }
}