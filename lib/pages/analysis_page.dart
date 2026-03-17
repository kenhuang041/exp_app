/// 統計頁：預留頁面，尚未實作圖表或統計摘要（目前為佔位內容）
import 'dart:math';

import 'package:exp02/components/chart/bar_chart.dart';
import 'package:exp02/components/chart/pie_chart.dart';
import 'package:exp02/components/type_view.dart';
import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/expense_provider.dart';
import '../models/transaction.dart';
import 'package:collection/collection.dart';

class MyAnalysisPage extends StatefulWidget {
  const MyAnalysisPage({super.key});

  @override
  State<MyAnalysisPage> createState() => _MyAnalysisPageState();
}

class _MyAnalysisPageState extends State<MyAnalysisPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Map<String,int> mp = {"交通": 2, "娛樂": 1, "伙食": 0};
  List<(double, String, IconData)> week_items = [
    (0.0, "伙食", Icons.emoji_food_beverage),
    (0.0, "娛樂", Icons.videogame_asset),
    (0.0, "交通", Icons.directions_car_filled),
  ];
  List<(double, double)> pieData = [];
  List<Day?> items = [];

  double totalWeek = 0.0;
  double tg = 1500.0;
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
      curve: Curves.fastOutSlowIn
    );

    _controller.forward();

    getData();
  }

  void getData() async {
    final provider = context.read<ExpenseProvider>();

    await Future.microtask(() => provider.setFirstDate());
    if (provider.monthData.isEmpty) await Future.microtask(() => provider.setAllMonthData());
    if(provider.nowMonthData.isEmpty) await Future.microtask(() => provider.setNowMonth());

    getNowWeekData();
    setPieChartData();
  }

  void getNowWeekData() async {
    var expenseData = Provider.of<ExpenseProvider>(context, listen: false);
    items.clear();

    if(expenseData.nowMonthData.isNotEmpty) {
      DateTime now = DateTime.now();
      DateTime tmp = now.subtract(Duration(days: now.weekday - 1));

      for(int i=0; i<7; i++) {
        Day? tmpDay = expenseData.nowMonthData.firstWhereOrNull(
              (x) => x.date.year == tmp.year &&
              x.date.month == tmp.month &&
              x.date.day == tmp.day,
        );

        items.add(tmpDay);
        totalWeek += (tmpDay == null) ? 0.0 : tmpDay.totalExpense;
        tmp = tmp.add(const Duration(days: 1));
      }

      setState(() {});
      return;
    }

    setState(() { items = []; });
  }

  /// 目前顯示月份的支出總和
  double getMonthTotalExpense(expenseData, now) {
    if(expenseData.monthData.isEmpty) return 0.0;

    final items = expenseData.monthData[DateTime(now.year, now.month)] ?? [];
    double ret = 0.0;

    for(Day day in items) {
      ret += day.totalExpense;
    }

    return ret;
  }

  void setPieChartData() async {
    var expenseData = Provider.of<ExpenseProvider>(context, listen: false);
    pieData = [(0.0, 0.0), (0.0, 0.0), (0.0, 0.0)];

    if(expenseData.nowMonthData.isNotEmpty) {
      var tags = ["娛樂", "交通", "伙食"];
      var idx=0;

      for(var tag in tags) {
        for(var day in expenseData.nowMonthData) {
          for(var item in day.items) {
            if(tag == item.tags) {
              pieData[idx] = (pieData[idx].$1 + item.amount, 0.0);
              var tmp = week_items[mp[item.tags] ?? 0];
              week_items[mp[item.tags] ?? 0] = (
                tmp.$1 + item.amount,
                tmp.$2,
                tmp.$3,
              );
            }
          }
        }
        idx++;
        if(idx>=3) break;
      }

      var t = getMonthTotalExpense(expenseData, DateTime.now());
      for(int i=0; i<3; i++) {
        pieData[i] = (pieData[i].$1, pieData[i].$1 / t);
      }

      setState(() {});
      return;
    }

    setState(() { pieData = []; });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var expenseData = Provider.of<ExpenseProvider>(context);
    var myColor = Provider.of<MyColor>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 90),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 頂部標題列（左：返回＋「記帳」、右：設定圖示）
              Stack(
                alignment: Alignment.center,
                children: [
                  Text("每週結算",style: TextStyle(fontSize: 14, color: Colors.black54)),
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
                height: 200,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (BuildContext context, Widget? child) {
                    return CustomPaint(
                        painter: ChartPainter(
                          context: context,
                          progress: _animation.value,
                          value: totalWeek / tg,
                          total: totalWeek,
                        )
                    );
                  },
                ),
              ),

              /*
              Container(
                padding: const EdgeInsets.only(top: 10, bottom: 15),
                alignment: Alignment.centerLeft,
                child: Text("  詳細資訊")
              ),
              */
              SizedBox(height: 24,),

              Container(
                width: 360,
                height: 280,
                decoration: BoxDecoration(
                  color: myColor.item, // myColor.any_item,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: AlignmentDirectional.topCenter,
                padding: const EdgeInsets.only(top: 15, left: 0, right: 0),
                child: Column(
                  children: [
                    GestureDetector(
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
                                  padding: const EdgeInsets.only(left: 62),
                                  child: Text("本週", style: TextStyle(color: (isWeek) ? Colors.black87 : Colors.grey),),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 62),
                                  child: Text("本月", style: TextStyle(color: (!isWeek) ? Colors.black87 : Colors.grey),),
                                ),
                              ],
                            ),
                          ],
                        )
                      ),
                    ),

                    // 圖表部分
                    Container(
                      margin: const EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
                      height: 160,
                      // color: Colors.yellow,
                      child: (isWeek) ? MyBarChart(items: items,) : MyPieChart(items: pieData,)
                    )
                  ],
                ),
              ),

              SizedBox(height: 16,),


              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 166,
                    height: 87,
                    decoration: BoxDecoration(
                      color: myColor.item, // myColor.any_item,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Container(
                    width: 166,
                    height: 87,
                    decoration: BoxDecoration(
                      color: myColor.item, // myColor.any_item,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ) */
            ],
          ),
        ),

        Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 20),
          child: MyTypePage(totalWeek: totalWeek, items: week_items,)
        ),
      ],
    );
  }
}

class ChartPainter extends CustomPainter {
  double progress;
  double value;
  double total;
  BuildContext context;
  ChartPainter({required this.context, required this.progress, required this.value, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    var myColor = Provider.of<MyColor>(context, listen: false);
    var paint = Paint()
        ..color = myColor.barGrey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;

    var center = Offset(size.width/2, size.height/2 + 60.0);
    double r = 110.0;
    double start = pi;
    double sweep = pi * (value * progress);

    canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, pi, false, paint);
    paint.color = Colors.blueAccent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, sweep, false, paint);

    _drawText(
      canvas,
      Offset(center.dx, center.dy - 40),
      "${(value * 100).toInt()}%",
      TextStyle(color: Colors.black87.withOpacity((progress - 0.2).clamp(0.0, 1.0)), fontSize: 32, fontWeight: FontWeight.bold),
    );

    _drawText(
      canvas,
      Offset(center.dx, center.dy),
      "目前共花費 ${total.toInt()} 元",
      TextStyle(color: Colors.black12.withOpacity((progress - 0.2).clamp(0.0, 1.0)), fontSize: 14),
    );
  }

  void _drawText(canvas, center, text, style) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style
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
