import 'dart:math';

import 'package:exp02/models/color.dart';
import 'package:exp02/models/transaction.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class MyBarChart extends StatefulWidget {
  final List<Day?> items;
  const MyBarChart({super.key, required this.items});

  @override
  State<MyBarChart> createState() => _MyBarChartState();
}

class _MyBarChartState extends State<MyBarChart> {
  final List<String> weekName = ["M", "T", "W", "T", "F", "S", "S"];
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 140), () { //
      if (mounted) setState(() => _startAnimation = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColor = Provider.of<MyColor>(context);
    List<Day?> _items;

    if (widget.items.isEmpty) {
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      _items = List.generate(7, (index) {
        return Day(
          date: startOfWeek.add(Duration(days: index)),
          items: [], // 空的交易列表
        );
      });
    } else {
      // 3. 如果不為空，複製一份出來，方便後續補全 null
      _items = List.from(widget.items);
    }

    double average = widget.items.fold(0.0, (sum, item) => sum + (item?.totalExpense ?? 0.0));
    double mx = 500.0, spec = 100.0, mod=0;

    DateTime begin = _items[0]?.date ?? DateTime.now();

    for(int i=0; i<_items.length; i++) {
      if(_items[i] == null) _items[i] = Day(date: begin.add(Duration(days: i)), items: []);
      var day = _items[i];

      mx = max(mx, (day == null) ? 0.0 : day.totalExpense);
      if(day!.items.isNotEmpty) mod = max(1, mod+1);
    }
    mx = (mx>500 ? (mx>1000 ? 2000 : 1000) : 500);
    spec = (mx>500 ? (mx>1000 ? 400 : 200) : 100);
    // debugPrint('Build triggered by: ${context.widget.runtimeType}');

    return BarChart(
      key: ValueKey(_items.length),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.bounceOut,

      BarChartData(
        maxY: mx,
        groupsSpace: 20,
        // 設定圖表範圍與格線
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _buildTitles(spec), // 設定座標軸標籤
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            (mod!=0) ? HorizontalLine(
              y: average / mod,
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              // dashArray: [6,6]
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (line) => 'avg',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              )
            ) : HorizontalLine(y: 1, color: Colors.transparent)
          ]
        ),

        // bar
        barGroups: _items.mapIndexed((idx,x) =>
            _makeGroupData(idx, (x == null) ? 10 : x.totalExpense, myColor, _startAnimation)
        ).toList(),

        // 互動效果（觸碰提示）
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
          ),
        ),
      ),
    );
  }

  // 封裝每組柱狀數據的工具函式
  BarChartGroupData _makeGroupData(int x, double y, myColor, start) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: start ? y : 0,
          color: myColor.barGrey2,
          width: 18, // 柱子寬度
          borderRadius: BorderRadius.circular(15), // 圓角
        ),
      ],
    );
  }

  // 設定座標軸文字
  FlTitlesData _buildTitles(spec) {
    return FlTitlesData(
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: spec, // 改用你計算出的動態間距
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                value.toInt().toString(),
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }
        )
      ),

      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(weekName[value.toInt()], style: const TextStyle(fontSize: 12)),
            );
          },
        ),
      ),
    );
  }
}