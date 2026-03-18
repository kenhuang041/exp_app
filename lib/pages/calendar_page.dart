/// 日曆頁：月曆格顯示每日淨額色塊、切換月份、當月收入／支出總計

import 'package:exp02/database/expense_provider.dart';
import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../components/list/my_list_group.dart';
import '../models/transaction.dart';

class MyCalendarPage extends StatefulWidget {
  const MyCalendarPage({super.key});

  @override
  State<MyCalendarPage> createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  List<String> weekName = ["M", "T", "W", "T", "F", "S", "S"];
  List<String> monthName = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月", ];
  /// 目前顯示的月份（使用者可切換）
  DateTime now = DateTime.now();
  // DateTime nowIndex = DateTime.now();

  /// 當月 1 號是星期幾（0=周一 … 6=周日），用於月曆前導空格
  late int month_day1;
  /// 上個月天數，用於月曆前導格顯示上月日期
  late int last_month_day;
  /// 系統當前日期，用於「今天」與月份切換上限
  final DateTime now_standard = DateTime.now();
  /// 日曆格色階門檻： [0]=支出色階, [1]=收入色階，每格四個門檻
  final List<List<double>> standard = [
    [50.0, 100.0, 150.0, 200.0],
    [100.0, 200.0, 300.0, 400.0]
  ];

  @override
  void initState() {
    super.initState();
    updateDate();
    getData();
  }

  /// 依當前 [now] 更新 month_day1、last_month_day
  void updateDate() {
    month_day1 = DateTime(now.year, now.month, 1).weekday - 1;
    last_month_day = DateTime(now.year, now.month, 0).day;
  }

  /// 載入最早日期、全月份資料、並設定當前月份資料
  void getData() async {
    // [!AI] 避免重複重載：若已有 monthData 快取，就不再整批重建（搭配 IndexedStack 效果更好）
    final provider = context.read<ExpenseProvider>();
    await Future.microtask(() => provider.setFirstDate());
    if (provider.monthData.isEmpty) {
      await Future.microtask(() => provider.setAllMonthData());
    }
    await Future.microtask(() => provider.setNowMonth());
  }

  /// 目前顯示月份的收入總和
  double getMonthTotalIncome(expenseData) {
    if(expenseData.monthData.isEmpty) return 0.0;
    final items = expenseData.monthData[DateTime(now.year, now.month)] ?? [];
    double ret = 0.0;

    for(Day day in items) {
      ret += day.totalIncome;
    }
    return ret;
  }

  /// 目前顯示月份的支出總和
  double getMonthTotalExpense(expenseData) {
    if(expenseData.monthData.isEmpty) return 0.0;

    final items = expenseData.monthData[DateTime(now.year, now.month)] ?? [];
    double ret = 0.0;

    for(Day day in items) {
      ret += day.totalExpense;
    }

    return ret;
  }

  /// 依金額區間回傳日曆格背景色與文字色（type: 0=支出, 1=收入）
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
    final tags = expenseData.monthData[DateTime(now.year, now.month)]?[now.day-1].getAllTags;

    // [!AI] 預先取出當月 day 列表，避免在 Grid itemBuilder 內重複 firstWhere 搜尋
    final currentMonthDays = expenseData.monthData.isEmpty
        ? const <Day>[]
        : expenseData.monthData[DateTime(now.year, now.month)] ?? [];

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
                        GestureDetector(
                          onTap: () async {
                            // [!AI] 修正月份邊界判斷：原本只比 month，跨年份時會錯
                            final canGoPrev = (now.year > expenseData.firstDate.year) ||
                                (now.year == expenseData.firstDate.year && now.month > expenseData.firstDate.month);
                            if (canGoPrev) {
                              setState(() {
                                now = DateTime(now.year, now.month-1);
                                if(now.month == DateTime.now().month) now = DateTime(now.year, now.month, DateTime.now().day);
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
                            // [!AI] 修正月份上限判斷：需同時考慮 year/month
                            final canGoNext = (now.year < now_standard.year) ||
                                (now.year == now_standard.year && now.month < now_standard.month);
                            if (canGoNext) {
                              setState(() {
                                now = DateTime(now.year, now.month+1);
                                if(now.month == DateTime.now().month) now = DateTime(now.year, now.month, DateTime.now().day);
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
                          weekName[index], // 星期標題列
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

                    if(currentMonthDays.isNotEmpty && index >= month_day1) {
                      DateTime time = DateTime(now.year, now.month, index+1-month_day1);
                      // [!AI] 防止找不到日期時 firstWhere 拋錯：改用索引直接取當月 days
                      final dayIndex = time.day - 1;
                      final day = (dayIndex >= 0 && dayIndex < currentMonthDays.length)
                          ? currentMonthDays[dayIndex]
                          : null;

                      if (day != null) {
                        final a = day.totalIncome;
                        final b = day.totalExpense;
                        count = a - b;
                        tmp = setItemColor(((count > 0) ? 1 : 0), count, myColor);
                      }
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
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            now = DateTime(now.year, now.month, (index+1-month_day1));
                          });

                          var tmp = expenseData.monthData[DateTime(now.year, 3)]![12];
                        },
                        child: Container(
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

          // 當月收入／支出總計兩列
          /*
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
          ) */

          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: (expenseData.monthData[DateTime(now.year, now.month)]?[now.day-1] == null)
                ? Container()
                : AnimationLimiter(
                    // key: ValueKey(isSort),
                    child: (expenseData.monthData[DateTime(now.year, now.month)]?[now.day-1].items.length == 0)
                      ? Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 60),
                          child: Text("暫無資料", style: TextStyle(color: Colors.grey, fontSize: 12,)),
                      )
                      : ListView.builder(
                          // key: ValueKey("list_$isSort"),
                          physics: const ClampingScrollPhysics(),
                          itemCount: tags!.length ?? 0, // null則資料數為0
                          itemBuilder: (context, index) {
                            final nowDay = expenseData.monthData[DateTime(now.year, now.month)]?[now.day-1];
                            final tagName = tags[index];

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: MyListGroupPage(tagName: tagName, today: nowDay!)
                                )
                              )
                            );
                        }
                    ),
                  )
              )
          )
        ],
      )
    );
  }
}