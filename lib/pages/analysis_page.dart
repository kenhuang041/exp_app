/// 統計頁：預留頁面，尚未實作圖表或統計摘要（目前為佔位內容）
import 'dart:math';

import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAnalysisPage extends StatefulWidget {
  const MyAnalysisPage({super.key});

  @override
  State<MyAnalysisPage> createState() => _MyAnalysisPageState();
}

class _MyAnalysisPageState extends State<MyAnalysisPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isWeek = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800)
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var myColor = Provider.of<MyColor>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 頂部標題列（左：返回＋「記帳」、右：設定圖示）
          Stack(
            alignment: Alignment.center,
            children: [
              Text("每週結算",style: TextStyle(fontSize: 14, color: Colors.grey)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: myColor.item,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Icon(Icons.refresh, color: Colors.black, size: 20,),
                ),
              ),
            ],
          ),

          SizedBox(
            width: 360,
            height: 240,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                    painter: ChartPainter(
                      context: context,
                      progress: _animation.value,
                      value: 92,
                    )
                );
              },
            ),
          ),

          // 當日剩餘金額卡片（收入－支出）
          Container(
            width: 360,
            height: 280,
            decoration: BoxDecoration(
              color: myColor.item, // myColor.any_item,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: AlignmentDirectional.topCenter,
            padding: const EdgeInsets.only(top: 15, left: 0, right: 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isWeek = !isWeek;
                });
              },
              child: Container(
                width: 310,
                height: 35,
                decoration: BoxDecoration(
                  color: myColor.cal_grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      left: isWeek ? 4.0 : 156.0, // 根據狀態改變 left
                      child: Container(
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                          color: myColor.item,
                          borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 57),
                          child: Text("Week", style: TextStyle(color: (isWeek) ? Colors.black87 : Colors.grey),),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 55),
                          child: Text("Month", style: TextStyle(color: (!isWeek) ? Colors.black87 : Colors.grey),),
                        ),
                      ],
                    ),
                  ],
                )
              ),
            ),
          ),

          SizedBox(height: 12,),

          /* Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 166,
                height: 87,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5), // myColor.any_item,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Container(
                width: 166,
                height: 87,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5), // myColor.any_item,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ) */
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  double progress;
  double value;
  BuildContext context;
  ChartPainter({required this.context, required this.progress, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    var myColor = Provider.of<MyColor>(context, listen: false);
    var paint = Paint()
        ..color = myColor.barGrey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;

    var center = Offset(size.width/2, size.height/2 + 40.0);
    double r = 110.0;
    double start = pi;
    double sweep = pi * (value * progress / 100);

    canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, pi, false, paint);
    paint.color = Colors.blueAccent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, sweep, false, paint);

    _drawText(canvas, Offset(center.dx, center.dy - 40), Colors.black87.withOpacity((progress - 0.2).clamp(0.0, 1.0)), "${value.toInt()}%");
  }

  void _drawText(canvas, center, color, text) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 32),
      ),
      textDirection: TextDirection.ltr
    );
    textPainter.layout();

    var offset = Offset(
      center.dx - textPainter.width/2,
      center.dy - textPainter.height/2,
    );

   textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate)
    => oldDelegate.progress != progress;
}
