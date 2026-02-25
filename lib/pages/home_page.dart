import 'dart:math';

import 'package:exp02/components/list/my_list.dart';
import 'package:exp02/components/list/my_list_group.dart';
import 'package:exp02/database/expense_provider.dart';
import 'package:exp02/models/color.dart';
import 'package:exp02/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';

class MyExpensePage extends StatefulWidget {
  const MyExpensePage({super.key});

  @override
  State<MyExpensePage> createState() => _MyExpensePageState();
}

class _MyExpensePageState extends State<MyExpensePage> {
  bool isSort = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ExpenseProvider>().setDayData(DateTime.now())); // 先讀取資料
    // .microtask ?
    // .read ??
  }

  @override
  Widget build(BuildContext context) {
    var my_color = Provider.of<MyColor>(context);
    var expense_data = Provider.of<ExpenseProvider>(context); // 取得資料

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 自製 appBar 部分
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Center(
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

          // 顯示剩餘資金部分 （最大塊的）
          Container(
            width: 360,
            height: 191,
            decoration: BoxDecoration(
              color: my_color.item,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("剩餘金額", style: TextStyle(color: my_color.text, fontSize: 12),),
                Text("\$${expense_data.totalCost}", style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),)
              ],
            ),
          ),

          SizedBox(height: 14,),

          // 新稱收入及支出部分
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
                  // 新增收入項目
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

                  // 新增支出項目
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

          // 詳細資訊 欄位
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

          // 列表部分
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemCount: (!isSort) ? (expense_data.nowData?.items.length ?? 0) : expense_data.nowData!.getAllTags.length, // null則資料數為0
                itemBuilder: (context, index) {
                  final item = expense_data.nowData!.items[index];

                  if(!isSort) {
                    return MyListItemPage(item: item);
                  }
                  else {
                    return MyListGroupPage(tagName: expense_data.nowData!.getAllTags[index], today: expense_data.nowData!);
                  }
                }
              )
            )
          )
        ],
      ),
    );
  }
}
