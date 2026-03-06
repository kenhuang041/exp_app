import 'package:exp02/database/expense_provider.dart';
import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';

class MyCalendarPage extends StatefulWidget {
  const MyCalendarPage({super.key});

  @override
  State<MyCalendarPage> createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  List<String> weekName = ["M", "T", "W", "T", "F", "S", "S"];
  List<String> monthName = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月", ];
  DateTime now = DateTime.now();
  DateTime? first_day;

  late int month_day1;
  late int last_month_day;
  final DateTime now_standard = DateTime.now();
  bool isEnd = false, isStart = false;
  final List<List<double>> standard = [
    [50.0, 100.0, 150.0, 200.0],
    [100.0, 200.0, 300.0, 400.0]
  ];

  @override
  void initState() {
    super.initState();
    // Future.microtask(() => context.read<ExpenseProvider>().clearAll());
    updateDate();
    getData();
  }

  void updateDate() {
    month_day1 = DateTime(now.year, now.month, 1).weekday - 1;
    last_month_day = DateTime(now.year, now.month, 0).day;
  }

  void getData() async {
    // if (!mounted) return;
    await Future.microtask(() => context.read<ExpenseProvider>().setFirstDate());
    await Future.microtask(() => context.read<ExpenseProvider>().setAllMonthData());
    await Future.microtask(() => context.read<ExpenseProvider>().setNowMonth());
  }

  double getMonthTotalIncome(expenseData) {
    if(expenseData.monthData.isEmpty) return 0.0;
    var items = expenseData.monthData.firstWhere((x) => (x.$1.year == now.year && x.$1.month == now.month));
    double ret = 0.0;

    for(Day day in items.$2) {
      ret += day.totalIncome;
    }
    return ret;
  }

  double getMonthTotalExpense(expenseData) {
    if(expenseData.monthData.isEmpty) return 0.0;
    var items = expenseData.monthData.firstWhere((x) => (x.$1.year == now.year && x.$1.month == now.month));
    double ret = 0.0;

    for(Day day in items.$2) {
      ret += day.totalExpense;
    }

    return ret;
  }

  (Color, Color) setItemColor(type, count, myColor) {
    Color back = myColor.item;
    Color number = Colors.black87;
    int i=0;

    for(var num in standard[type]) {
      if(count.abs() >= num) {
        back = (type == 0) ? myColor.cal_red[i] : myColor.cal_green[i];
        if(i>=1) number = Colors.white;
      }
      i++;
    }

    return (back, number);
  }

  @override
  Widget build(BuildContext context) {
    var myColor = Provider.of<MyColor>(context);
    var expenseData = Provider.of<ExpenseProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 120),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 45,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Text((now.year != now_standard.year || now.month != now_standard.month) ? "" : now_standard.day.toString(), style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(monthName[now.month - 1], style: TextStyle(color: myColor.hint2, fontSize: 18),),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if(now.month-1 >= expenseData.firstDate.month) {
                              setState(() {
                                now = DateTime(now.year, now.month-1);
                                updateDate();
                              });
                            }
                          },
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: (now.month == expenseData.firstDate.month) ? myColor.cal_grey : myColor.item,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: (now.month == expenseData.firstDate.month) ? Colors.black38 : Colors.black,
                              size: 12,
                            ),
                          ),
                        ),

                        SizedBox(width: 10,),

                        GestureDetector(
                          onTap: () {
                            if(now.month+1 <= now_standard.month) {
                              setState(() {
                                now = DateTime(now.year, now.month+1);
                                updateDate();
                              });
                            }
                          },
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: (now.month == now_standard.month) ? myColor.cal_grey : myColor.item,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: (now.month == now_standard.month) ? Colors.black38 : Colors.black,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                Stack(
                  children: [
                    Container(
                      width: 305,
                      height: 6,
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
                      decoration: BoxDecoration(
                        color: myColor.barGrey,
                        borderRadius: BorderRadius.circular(4)
                      ),
                    ),

                    Container(
                      width: (now.month != now_standard.month) ? 305 : (305/DateTime(now_standard.year, now_standard.month + 1, 0).day) * now_standard.day,
                      height: 6,
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
                      decoration: BoxDecoration(
                          color: myColor.red,
                          borderRadius: BorderRadius.circular(4)
                      ),
                    ),

                    Positioned(
                      top: 20,
                      left: 101.6,
                      child: Container(
                        width: 4,
                        height: 6,
                        color: myColor.barGrey
                      ),
                    ),

                    Positioned(
                      top: 20,
                      left: 203.2,
                      child: Container(
                          width: 4,
                          height: 6,
                          color: myColor.barGrey
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 40,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          weekName[index],
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      );
                    },
                  ),
                ),

                // 日曆部分
                GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: DateTime(now.year, now.month+1, 0).day + month_day1,
                  itemBuilder: (context, index) {
                    double count = 0.0;
                    (Color, Color) tmp = (myColor.item, Colors.black87);

                    if(expenseData.monthData.isNotEmpty && index >= month_day1) {
                      DateTime time = DateTime(now.year, now.month, index+1-month_day1);
                      var month = expenseData.monthData.firstWhere((x) => (x.$1.year == time.year && x.$1.month == time.month));
                      var day = month.$2.firstWhere((x) => (x.date.year == time.year && x.date.month == time.month && x.date.day == time.day));

                      double a = day.totalIncome;
                      double b = day.totalExpense;
                      count = a-b;
                      tmp = setItemColor(((count>0) ? 1 : 0), count, myColor);
                    }

                    return (index < month_day1) ?
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: myColor.cal_grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          (last_month_day + (index+1-month_day1)).toString(),
                          style: TextStyle(
                            color: Colors.black26,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ) :
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tmp.$1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          (index+1-month_day1).toString(),
                          style: TextStyle(
                            color: tmp.$2,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      );
                  }
                ),
              ],
            ),
          ),

          SizedBox(height: 40,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("詳細資訊", style: TextStyle(fontSize: 14),),
              GestureDetector(
                onTap: () {
                  setState(() {
                  });
                },
                child: Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  /*decoration: BoxDecoration(
                    color: myColor.item,
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Icon(Icons.search, size: 14,)*/
                ),
              ),
            ],
          ),

          SizedBox(height: 12,),

          // 列表部分
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: myColor.item,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text("收入", style: TextStyle(fontSize: 16),),
                      trailing: Text(
                        '+NT\$${getMonthTotalIncome(expenseData)}',
                        style: TextStyle(
                            fontSize: 14,
                            color: myColor.text
                        ),
                      ),
                    ),
                  ),

                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: myColor.item,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text("支出", style: TextStyle(fontSize: 16),),
                      trailing: Text(
                        '-NT\$${getMonthTotalExpense(expenseData)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: myColor.text
                        ),
                      ),
                    ),
                  ),
                ],
              )
            )
          )
        ],
      )
    );
  }
}