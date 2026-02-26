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

  @override
  void initState() {
    super.initState();
    // Future.microtask(() => context.read<ExpenseProvider>().clearAll());
    getData();
  }

  void getData() async {
    await Future.microtask(() => context.read<ExpenseProvider>().setAllMonthData());
    await Future.microtask(() => context.read<ExpenseProvider>().setNowMonth());
  }

  double getMonthTotalIncome(expenseData) {
    double ret = 0.0;
    for(Day day in expenseData.nowMonthData) {
      ret += day.totalIncome;
    }
    return ret;
  }

  double getMonthTotalExpense(expenseData) {
    double ret = 0.0;
    for(Day day in expenseData.nowMonthData) {
      ret += day.totalExpense;
    }

    return ret;
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
                  child: Text(now.day.toString(), style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(monthName[now.month - 1], style: TextStyle(color: myColor.hint2, fontSize: 18),),
                    Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: myColor.item,
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black, size: 12,),
                        ),

                        SizedBox(width: 10,),

                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: myColor.item,
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 12,),
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
                      width: (305/DateTime(now.year, now.month + 1, 0).day) * now.day,
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
                  )
                ),

                GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: 31 + 3,
                  itemBuilder: (context, index) {
                    return (index < 3) ? Container() :
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: myColor.item,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (index+1-3).toString(),
                        style: TextStyle(
                          color: Colors.black87,
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
                  decoration: BoxDecoration(
                    color: myColor.item,
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Icon(Icons.search, size: 14,)
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