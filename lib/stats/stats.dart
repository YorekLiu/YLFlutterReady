import 'package:flutter/material.dart';
import 'dart:math';

class StatsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("build => ${this.runtimeType.toString()}");
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text('Stats'),
        elevation: 1.0,
        backgroundColor: Theme.of(context).canvasColor,
        textTheme: Theme.of(context).textTheme,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Placeholder for code tab ${Random().nextInt(100000)}'),
            Icon(Icons.code)
          ],
        ),
      ),
    );
  }
}