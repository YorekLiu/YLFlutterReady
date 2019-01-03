import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:typed_data';
import 'dart:math' as Math;
import 'dart:ui' as UI;

class MyChart extends StatefulWidget {
  MyChart(this.title, this.assetImageKey, this.total, {this.dataMap, this.isLineChart = false, Key key}) : super(key: key);

  final String title;
  final String assetImageKey;
  final String total;
  final Map<String, int> dataMap;
  final bool isLineChart;

  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  UI.Image image;

  @override
  void initState() {
    super.initState();
    _loadAssetImage();
  }

  _loadAssetImage() async {
    rootBundle.load(widget.assetImageKey).then((byteData) {
      Uint8List list = new Uint8List.view(byteData.buffer);
      UI.instantiateImageCodec(list).then((codec) {
        codec.getNextFrame().then((frameInfo) {
          if (mounted) {
            setState(() {
              image = frameInfo.image;
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MyChartPainter(context, widget.isLineChart, image, widget.title, widget.total, widget.dataMap),
    );
  }
}

class _MyChartPainter extends CustomPainter {
  static final debug = false;
  _MyChartPainter(this.context, this.isLineChart, this.image, this.title, this.total, this.dataMap);

  final BuildContext context;
  final UI.Image image;
  final String title;
  final String total;
  Map<String, int> dataMap;
  final bool isLineChart;

  static final xGap = 12.0;
  static final yGap = 8.0;

  static final padding = 16.0;

  static final iconSize = 24.0;

  static final chartStep = 3;
  static final chartPaddingTop = 16.0;
  static final chartPaddingRight = 8.0;
  static final chartXPaddingBottom = 24.0;
  static final chartXPaddingTop = 24.0;
  static final chartYPaddingLeft = padding;
  static final chartYPaddingRight = padding;

  @override
  void paint(Canvas canvas, Size size) {
    // 包含x、y轴的整个区域
    double chartTop;
    double chartBottom;
    // 只包含图表的区域
    double realChartLeft;
    double realChartRight = size.width - chartYPaddingRight;
    double realChartTop;
    double realChartBottom;
    double realChartBaseLine;
    // x、y轴的区域
    double xyChartLeft = chartYPaddingLeft;
    double xyChartRight = realChartRight;
    double xyChartTop;
    double xyChartBottom;
    // x、y方向每一步的size
    int xStep;
    int yStep;

    var paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.indigo[900]
      ..style = PaintingStyle.fill;

    chartBottom = size.height - yGap * 2;
    xyChartBottom = chartBottom - chartXPaddingBottom;

    // draw background
    paint.color = Colors.indigo[900].withAlpha(99);
    canvas.drawRect(Rect.fromLTWH(xGap * 2, chartBottom, size.width - xGap * 4, yGap * 2), paint);
    canvas.drawRect(Rect.fromLTWH(xGap, chartBottom, size.width - xGap * 2, yGap), paint);
    paint.color = Colors.indigo[900];
    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, chartBottom), paint);

    // draw title
    var titleSpan = TextSpan(
      text: title,
      style: Theme.of(context).textTheme.subhead.copyWith(
        color: Colors.white70,
        fontWeight: FontWeight.w500
      )
    );
    var textPainter = TextPainter(text: titleSpan, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(padding, padding));

    // draw count number
    titleSpan = TextSpan(
      text: total,
      style: Theme.of(context).textTheme.display1.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w400
      )
    );
    var dx = padding + iconSize + padding;
    var dy = padding + textPainter.height + padding;
    textPainter = TextPainter(text: titleSpan, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(dx, dy));

    chartTop = dy + textPainter.height;

    // draw icon
    if (image != null) {
      var oldPaintColor = paint.color;
      paint.color = oldPaintColor.withAlpha(99);
      dx = padding;
      dy = dy + (textPainter.height - iconSize) / 2;
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(dx, dy, iconSize, iconSize),
        paint
      );
      paint.color = oldPaintColor;
    }

    chartTop += chartPaddingTop;
    // draw chart rect (only for debug)
    if (debug) {
      paint
        ..style = PaintingStyle.stroke
        ..color = Colors.red.withAlpha(33)
        ..strokeWidth = 1.0;
      canvas.drawRect(
        Rect.fromLTRB(0.0, chartTop, size.width, chartBottom), paint);
    }

    // find y step
    if (dataMap == null || dataMap.isEmpty) {
      dataMap = {
        "" : 0,
        " " : 0,
        "  " : 0
      };
    }
    var maxValue = dataMap.values.reduce(Math.max);

    var maximum = maxValue ~/ (chartStep - 1);
    var minimum = maxValue ~/ chartStep;
    var yStepValue = (maximum - minimum + 1) ~/ 2 + minimum;
    yStepValue = yStepValue == 0 ? 5 : yStepValue;

    // ready draw chart
    // layout first y
    titleSpan = TextSpan(
      text: maxValue.toString(),
      style: Theme.of(context).textTheme.caption.copyWith(
        color: Colors.white54,
      )
    );
    textPainter = TextPainter(text: titleSpan, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    textPainter.layout();

    realChartLeft = chartYPaddingLeft + textPainter.width + chartYPaddingRight;
    realChartTop = chartTop;
    xyChartTop = realChartTop;
    realChartBaseLine = textPainter.height / 2;

    // draw xyChart rect (only for debug)
    if (debug) {
      paint
        ..style = PaintingStyle.stroke
        ..color = Colors.red.withAlpha(33)
        ..strokeWidth = 1.0;
      canvas.drawRect(
        Rect.fromLTRB(xyChartLeft, xyChartTop, xyChartRight, xyChartBottom),
        paint);
    }

    // find x step
    xStep = (realChartRight - realChartLeft) ~/ dataMap.length;
    // layout last x
    titleSpan = TextSpan(
      text: dataMap.keys.last,
      style: Theme.of(context).textTheme.caption.copyWith(
        color: Colors.white54,
      )
    );
    textPainter = TextPainter(text: titleSpan, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    textPainter.layout();
    dy = chartBottom - chartXPaddingBottom - textPainter.height;
    realChartBottom = dy - chartXPaddingTop;
    realChartBaseLine += realChartBottom;

    // draw real chart rect (only for debug)
    if (debug) {
      paint
        ..style = PaintingStyle.stroke
        ..color = Colors.red.withAlpha(33)
        ..strokeWidth = 1.0;
      canvas.drawRect(Rect.fromLTRB(
        realChartLeft, realChartTop, realChartRight, realChartBottom), paint);
    }

    // draw y axis
    yStep = ((realChartBottom - xyChartTop) ~/ chartStep);
    paint
      ..color = Colors.white12
      ..strokeWidth = 1.0;
    for (var i = 0; i <= chartStep; i++) {
      titleSpan = TextSpan(
        text: (i * yStepValue).toString(),
        style: Theme.of(context).textTheme.caption.copyWith(
          color: Colors.white54,
        )
      );
      textPainter = TextPainter(text: titleSpan, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      textPainter.layout();
      dy = realChartBottom - yStep * i;
      textPainter.paint(canvas, Offset(xyChartLeft, dy));
      
      // draw line
      canvas.drawLine(Offset(realChartLeft, realChartBaseLine - yStep * i), Offset(realChartRight, realChartBaseLine - yStep * i), paint);
    }

    // draw x axis
    int i = 0;
    var lastPoint = Offset(realChartLeft, realChartBaseLine); // when isLineChart is true
    for (var it in dataMap.entries) {
      titleSpan = TextSpan(
        text: it.key,
        style: Theme.of(context).textTheme.caption.copyWith(
          color: Colors.white54,
        )
      );
      textPainter = TextPainter(text: titleSpan, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      textPainter.layout();
      dx = realChartLeft + xStep * i;
      textPainter.paint(canvas, Offset(isLineChart ? dx + xStep - textPainter.width : dx, realChartBottom + chartXPaddingTop));

      // draw column diagram or line chart
      double top = realChartBaseLine - (it.value / yStepValue) * yStep;
      if (isLineChart) {
        paint.color = Colors.indigoAccent[200];
        canvas.drawLine(lastPoint, Offset(dx + xStep, top), paint);
        lastPoint = Offset(dx + xStep, top);
      } else {
        // draw column diagram
        paint.color = i % 2 == 1 ? Colors.indigo[500] : Colors.indigoAccent[200];
        canvas.drawRect(Rect.fromLTRB(dx, top, dx + xStep, realChartBaseLine), paint);
      }
      i++;
    }

    if (!isLineChart) {
      // draw overflow column diagram, just for beauty
      paint.color = paint.color.withAlpha(99);
      Math.Random random = Math.Random();
      // -1 column
      double top = realChartBaseLine - ((random.nextInt(chartStep * yStepValue) + 1) / yStepValue) * yStep;
      canvas.drawRect(Rect.fromLTRB(0.0, top, realChartLeft, realChartBaseLine), paint);
      // n+1 column
      top = realChartBaseLine - ((random.nextInt(chartStep * yStepValue) + 1) / yStepValue) * yStep;
      canvas.drawRect(Rect.fromLTRB(dx + xStep, top, size.width, realChartBaseLine), paint);
    }
  }

  @override
  bool shouldRepaint(_MyChartPainter oldDelegate) =>
    oldDelegate.image != image ||
    oldDelegate.isLineChart != isLineChart ||
    oldDelegate.title != title ||
    oldDelegate.total != total ||
    oldDelegate.dataMap != dataMap;
}