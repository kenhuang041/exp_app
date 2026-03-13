/// 首頁：當日剩餘金額、新增收入/支出入口、當日明細列表（可切換依分類分組）

import 'package:exp02/components/list/my_list.dart';
import 'package:exp02/components/list/my_list_group.dart';
import 'package:exp02/database/expense_provider.dart';
import 'package:exp02/models/color.dart';
import 'package:exp02/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart';

class MyExpensePage extends StatefulWidget {
  const MyExpensePage({super.key});

  @override
  State<MyExpensePage> createState() => _MyExpensePageState();
}

class _MyExpensePageState extends State<MyExpensePage> {
  /// 是否依標籤分組顯示（true=分組，false=單一列表）
  bool isSort = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ExpenseProvider>().setDayData(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    var my_color = Provider.of<MyColor>(context);
    var expense_data = Provider.of<ExpenseProvider>(context);
    // [!AI] 防呆：nowData 尚未載入時不要強制解參考，避免 build 階段直接閃退。
    final tags = expense_data.nowData?.getAllTags ?? const <String>[];


    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 頂部標題列（左：返回＋「記帳」、右：設定圖示）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        print(await getDatabasesPath());
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: my_color.item,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black, size: 16,),
                      ),
                    ),
                  ),
                  SizedBox(width: 12,),
                  Text("記帳",style: TextStyle(fontSize: 14)),
                ],
              ),

              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: my_color.item,
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Icon(Icons.settings, color: Colors.black, size: 20,),
              ),
            ],
          ),

          SizedBox(height: 10,),

          // 當日剩餘金額卡片（收入－支出）
          Container(
            width: 360,
            height: 191,
            decoration: BoxDecoration(
              color: my_color.item,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedOpacity(
              opacity: (expense_data.nowData == null) ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("剩餘金額", style: TextStyle(color: my_color.text, fontSize: 12),),
                  Text(
                    (expense_data.nowData == null) ? "" : "\$${expense_data.totalCost}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(height: 14,),

          // 新增收入／支出按鈕區
          Container(
            width: 360,
            height: 87,
            decoration: BoxDecoration(
              color: my_color.item,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 14, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 新增收入：開啟 BottomSheet 輸入
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)
                        ),
                        backgroundColor: my_color.grey,
                        scrollControlDisabledMaxHeightRatio: 0.88,
                        builder: (context) {
                          return MyAddItemPage(isIncome: true,);
                        }
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: my_color.item_grey,
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: Icon(Icons.arrow_upward, color: Colors.black, size: 20,),
                        ),
                        SizedBox(height: 2,),
                        Text("收入", style: TextStyle(fontSize: 12, color: my_color.text,)),
                      ],
                    ),
                  ),

                  SizedBox(width: 20,),

                  // 新增支出：開啟 BottomSheet 輸入
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                        ),
                        backgroundColor: my_color.grey,
                        scrollControlDisabledMaxHeightRatio: 0.88,
                        builder: (context) {
                          return MyAddItemPage(isIncome: false,);
                        }
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: my_color.item_grey,
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: Icon(Icons.arrow_downward, color: Colors.black, size: 20,),
                        ),
                        SizedBox(height: 2,),
                        Text("支出", style: TextStyle(fontSize: 12, color: my_color.text,)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30,),

          // 「詳細資訊」標題與「分類」切換鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("詳細資訊", style: TextStyle(fontSize: 14),),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSort = !isSort;
                  });
                },
                child: Container(
                  width: 55,
                  height: 25,
                  decoration: BoxDecoration(
                    color: isSort ? Color(0xBBCACACA) : my_color.item,
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Center(child: Text("分類", style: TextStyle(fontSize: 11),)),
                ),
              ),
            ],
          ),

          SizedBox(height: 14,),

          // 當日明細列表（依 isSort 顯示單一列表或依 tag 分組）
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: (expense_data.nowData == null)
                ? Container()
                : AnimationLimiter(
                    key: ValueKey(isSort),
                    child: ListView.builder(
                      key: ValueKey("list_$isSort"),
                      itemCount: (!isSort) ? (expense_data.nowData?.items.length ?? 0) : tags.length, // null則資料數為0

                      itemBuilder: (context, index) {
                        final item = (!isSort) ? expense_data.nowData!.items[index] : null;
                        final tagName = isSort ? tags[index] : null;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: (!isSort)
                                ? MyListItemPage(item: item!)
                                : MyListGroupPage(tagName: tagName!, today: expense_data.nowData!)
                          )
                          )
                        );
                      }
                    ),
                 )
            )
          )
        ],
      ),
    );
  }
}
