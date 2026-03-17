import 'dart:math';

import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/expense_provider.dart';

class MyTypePage extends StatefulWidget {
  double totalWeek;
  List<(double, String, IconData)> items;
  MyTypePage({super.key, required this.totalWeek, required this.items});

  @override
  State<MyTypePage> createState() => _MyTypePageState();
}

class _MyTypePageState extends State<MyTypePage> with SingleTickerProviderStateMixin{
  late AnimationController _controller2;
  late PageController _controller;
  late Animation<double> _animation;
  // late List<(double, String, IconData)> items;

  // final items = [(200.0, "伙食", Icons.emoji_food_beverage), (200.0, "交通", Icons.directions_car_filled),];
  double current = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0, viewportFraction: 0.9)..addListener(() {
      setState(() {
        current = _controller.page!;
      });
    });
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller2,
      curve: Curves.fastOutSlowIn,
    );

    _controller2.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColor = Provider.of<MyColor>(context, listen: false);
    double total = 0.0;
    for(var item in widget.items) total += item.$1;

    return PageView.builder(
      controller: _controller,
      itemCount: widget.items.length,
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      onPageChanged: (idx) {
        _controller2.reset();
        _controller2.forward();
      },
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return TypeItem(index, index - current, item, myColor, total);
      }
    );
  }

  Widget TypeItem(int index, double pos, item, myColor, total) {
    double scale = max(0.8, 1 - pos.abs() * 0.2);
    double opacity = max(0, 1 - pos.abs() * 1);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(scale),
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: myColor.item, // myColor.any_item,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
              child: AnimatedOpacity(
                opacity: (total == 0 ? 0 : 1),
                duration: Duration(milliseconds: 600),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.$3, color: Colors.black54,),
                            SizedBox(width: 8,),
                            Text(
                              "${item.$2}",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2,),

                        Text(
                          "目前共花費 ${item.$1} 元\n百分比: ${((item.$1 / (total == 0 ? 1 : total)) * 100).toInt()}%",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 20,),

                    SizedBox(
                      width: 160,
                      height: 80,
                      // color: Colors.yellow,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: PieChartPainter(
                              context: context,
                              progress: _animation.value,
                              total: total,
                              item: item,
                            ),
                          );
                        }
                      ),
                    )
                  ],
                ),
              ),
            )
          ),
        ),
      ),
    );
  }
}


class PieChartPainter extends CustomPainter {
  BuildContext context;
  double progress;
  double total;
  (double, String, IconData) item;

  PieChartPainter({
    required this.context,
    required this.progress,
    required this.total,
    required this.item
  });

  @override
  void paint(Canvas canvas, Size size) {
    var myColor = Provider.of<MyColor>(context, listen: false);
    var paint = Paint()
      ..color = myColor.barGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    var center = Offset(size.width/2, size.height/2);
    var start = -pi/2;
    var sweep = pi * 2 * item.$1/total * progress;

    var r = 23.0;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        2 * pi,
        false,
        paint
    );

    paint.color = Colors.black54;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        sweep,
        false,
        paint
    );

    paint.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTRB(center.dx + 46, center.dy - 16, center.dx + 54, center.dy - 8),
        paint
    );

    paint.color = myColor.barGrey;
    canvas.drawRect(
      Rect.fromLTRB(center.dx + 46, center.dy + 11, center.dx + 54, center.dy + 3),
      paint
    );

    _drawIcon(
      canvas,
      Colors.black26.withOpacity(progress.clamp(0.0, 1.0)),
      Offset(310, 58),
      item.$3,
    );

    _drawIcon(
      canvas,
      Colors.black26.withOpacity(progress.clamp(0.0, 1.0)),
      Offset(310, 98),
      Icons.wallet,
    );
  }

  void _drawIcon(canvas, color, center, IconData icon) {
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
        textDirection: TextDirection.ltr
    );
    tp.layout();

    var pos = Offset(
        center.dx/2 - tp.width,
        center.dy/2 - tp.height
    );

    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate)
  => oldDelegate.progress != progress;
}

/*
class BarChartPainter extends CustomPainter {
  BuildContext context;
  double progress;

  BarChartPainter({required this.context, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    var myColor = Provider.of<MyColor>(context, listen: false);
    var paint = Paint()
      ..color = myColor.barGrey2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    var center = Offset(size.width/2-60, size.height/2-5);
    canvas.drawLine(center, Offset(center.dx + 110 * progress, center.dy), paint);

    paint.color = Colors.black26;
    canvas.drawLine(Offset(center.dx, center.dy + 15), Offset(center.dx + 60 * progress, center.dy + 15), paint);

  }

  void _drawText(canvas, center, text) {
    var tp = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
              color: Colors.black26,
              fontSize: 12,
            )
        ),
        textDirection: TextDirection.ltr
    );
    tp.layout();

    var pos = Offset(
        center.dx/2 - tp.width,
        center.dy/2 - tp.height
    );

    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate)
  => oldDelegate.progress != progress;
}
*/