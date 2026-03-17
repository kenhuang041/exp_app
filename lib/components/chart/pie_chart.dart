import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/color.dart';

class MyPieChart extends StatefulWidget{
  final List<(double, double)> items;
  const MyPieChart({super.key, required this.items});

  @override
  State<MyPieChart> createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800)
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut // Curves.fastOutSlowIn
    );

    total = widget.items.fold(0, (prv,x) => prv + (x.$1).toInt());
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // for(var item in widget.items) print(item);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: PieChartPainter(
            context: context,
            progress: _animation.value,
            items: [
              (widget.items[0], Icons.account_box, Colors.black26),
              (widget.items[1], Icons.account_box, Colors.black54),
              (widget.items[2], Icons.account_box, Colors.black87),
            ],
            total: total
          ),
        );
      }
    );
  }
}


class PieChartPainter extends CustomPainter {
  List<((double, double), IconData, Color)> items;
  BuildContext context;
  double progress;
  double total;

  PieChartPainter({required this.context, required this.progress, required this.items, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    var myColor = Provider.of<MyColor>(context, listen: false);
    var paint = Paint()
        ..color = myColor.barGrey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;

    var center = Offset(size.width/2+70, size.height/2);
    var start = -pi/2;
    var sweep = pi * 6/4;

    for(int i=1; i<=3; i++) {
      var r = 22.0 * i;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        sweep,
        false,
        paint
      );
    }

    for(int i=1; i<=3; i++) {
      var r = 22.0 * i;
      paint.color = items[i-1].$3;
      sweep = (pi * 6/4) * (items[i-1].$1.$2 * progress);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        sweep,
        false,
        paint
      );
    }

    _drawIcon(canvas, Colors.white, Offset(center.dx + 86, center.dy - 38), Icons.emoji_food_beverage);
    _drawIcon(canvas, Colors.white, Offset(center.dx + 86, center.dy + 4), Icons.directions_car_filled);
    _drawIcon(canvas, Colors.white, Offset(center.dx + 86, center.dy + 51), Icons.videogame_asset);

    var pos = Offset(center.dx - 214, center.dy - 65); // 120
    _drawText(canvas, pos, "\$${total}", TextStyle(color: Colors.black26.withOpacity(progress.clamp(0.0, 1.0)), fontSize: 28.0,));
    _drawText(canvas, Offset(pos.dx, pos.dy + 25), "總支出", TextStyle(color: Colors.black26.withOpacity(progress.clamp(0.0, 1.0)), fontSize: 12,));

    pos = Offset(pos.dx + 8, pos.dy + 55);
    _TextItem(canvas, Colors.black87, pos, items[0].$1.$1);
    _TextItem(canvas, Colors.black54, Offset(pos.dx, pos.dy + 23), items[1].$1.$1);
    _TextItem(canvas, Colors.black26, Offset(pos.dx, pos.dy + 46), items[2].$1.$1);
    //_TextItem(canvas, Colors.black54, Offset(pos.dx, pos.dy + 20));
    //_TextItem(canvas, Colors.black26, pos);
  }


  void _TextItem(canvas, color, pos, text) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTRB(pos.dx - 5, pos.dy - 5, pos.dx + 5, pos.dy + 5),
        paint
    );

    _drawText(
      canvas,
      Offset(pos.dx + 16, pos.dy),
      "${text}",
      TextStyle(
        color: Colors.black26.withOpacity(progress.clamp(0.0, 1.0)),
        fontSize: 14,
        // fontWeight: FontWeight.bold
      ),
    );
  }

  void _drawIcon(canvas, color, Offset center, IconData icon) {
    var tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: 13
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start
    );
    tp.layout();

    var pos = Offset(
        center.dx/2 - tp.width,
        center.dy/2 - tp.height
    );

    tp.paint(canvas, pos);
  }

  void _drawText(canvas, center, text, style) {
    var tp = TextPainter(
        text: TextSpan(
          text: text,
          style: style
        ),
        textDirection: TextDirection.ltr
    );
    tp.layout();

    var pos = Offset(
        center.dx,
        center.dy - tp.height/2,
    );

    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate)
    => oldDelegate.progress != progress;
}