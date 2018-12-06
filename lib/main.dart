import 'package:flutter/material.dart';

import 'stats/stats.dart';
import 'task/task_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Ready?',
      theme: new ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto'
      ),
      home: MainPage(),
    );
  }
}

class NavigationIconView {
  NavigationIconView({
    Widget icon,
    String title,
    Widget tabView,
    TickerProvider vsync,
  }) : _title = title,
      _tabView = tabView,
      item = BottomNavigationBarItem(
        icon: icon,
        title: Text(title),
      ),
      controller = AnimationController(
        duration: kThemeAnimationDuration,
        vsync: vsync,
      ) {
    _animation = controller.drive(CurveTween(
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    ));
  }

  final String _title;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  final Widget _tabView;
  Animation<double> _animation;

  FadeTransition transition(BuildContext context) {

    return FadeTransition(
      key: Key(_title),
      opacity: _animation,
      child: SlideTransition(
        position: _animation.drive(
          Tween<Offset>(
            begin: const Offset(0.0, 0.02), // Slightly down.
            end: Offset.zero,
          ),
        ),
        child: _tabView
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  static const String routeName = '/';

  @override
  createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<NavigationIconView> _navigationViews;

  @override
  void initState() {
    super.initState();

    _navigationViews = <NavigationIconView>[
      NavigationIconView(
        icon: const Icon(Icons.timer_off),
        title: "Ready",
        tabView: TaskListPage(),
        vsync: this,
      ),
      NavigationIconView(
        icon: const Icon(Icons.timeline),
        title: "Stats",
        tabView: StatsPage(),
        vsync: this,
      ),
    ];

    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  @override
  void dispose() {
    for (NavigationIconView view in _navigationViews)
      view.controller.dispose();
    super.dispose();
  }

  Widget _buildTransitionsStack() {
    final List<FadeTransition> transitions = <FadeTransition>[];

    for (NavigationIconView view in _navigationViews)
      transitions.add(view.transition(context));

    // We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.opacity;
      final Animation<double> bAnimation = b.opacity;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;

      return aValue.compareTo(bValue);
    });

    return Stack(children: transitions);
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar botNavBar = BottomNavigationBar(
      items: _navigationViews
        .map<BottomNavigationBarItem>((NavigationIconView navigationView) => navigationView.item)
        .toList(),
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
        });

        // fix a bug that the current tab view can't interact with anything
        Future.delayed(kThemeAnimationDuration, () => setState(() {}));
      },
    );

    return Scaffold(
      body: Center(
        child: _buildTransitionsStack()
      ),
      bottomNavigationBar: Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white
      ),
      child: botNavBar,
    ),
    );
  }
}