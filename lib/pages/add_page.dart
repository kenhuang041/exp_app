import 'package:exp02/database/expense_provider.dart';
import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';

class MyAddItemPage extends StatefulWidget {
  final bool isIncome;
  const MyAddItemPage({super.key, required this.isIncome});

  @override
  State<MyAddItemPage> createState() => _MyAddItemPageState();
}

class _MyAddItemPageState extends State<MyAddItemPage> {
  final TextEditingController name_controller = TextEditingController();
  final TextEditingController amount_controller = TextEditingController();
  final List<String> incomeTags = ['薪水', '獎金', '生活費'];
  final List<String> expenseTags = ['娛樂', '交通', '伙食', '點心'];
  late String tags;

  Widget selectMenu(var my_color) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return (widget.isIncome) ?
          incomeTags.map((x) {
            return PopupMenuItem(
              value: x,
              child: Text(x),
            );
          }).toList() :
          expenseTags.map((x) {
            return PopupMenuItem(
              value: x,
              child: Text(x),
            );
          }).toList();
      },

      color: Colors.white,
      padding: EdgeInsets.zero,
      offset: const Offset(170, 50),
      icon: Icon(Icons.arrow_drop_down_outlined, color: my_color.hint,),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (value) {
        setState(() {
          tags = value.toString();
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    tags = (widget.isIncome) ? incomeTags[0] : expenseTags[0];
  }

  @override
  Widget build(BuildContext context) {
    var my_color = Provider.of<MyColor>(context);
    var expense_data = Provider.of<ExpenseProvider>(context);
    String type = (widget.isIncome) ? "收入" : "支出";

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 16,),
                ),
              ),

              Text("新增${type}",style: TextStyle(fontSize: 16)),

              GestureDetector(
                onTap: () {
                  if(name_controller.text.isNotEmpty && amount_controller.text.isNotEmpty) {
                    final testItem = TransactionItem(
                      name: name_controller.text,
                      amount: double.parse(amount_controller.text.toString()),
                      type: (widget.isIncome) ? "income" : "expense",
                      tags: tags,
                      date: DateTime.now(),
                    );

                    context.read<ExpenseProvider>().add(testItem);
                  }

                  Navigator.pop(context);
                },
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: my_color.item,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Icon(Icons.check, color: Colors.black, size: 20,),
                ),
              ),
            ],
          ),

          SizedBox(height: 16,),

          // 輸入名稱和價格
          Container(
            height: 100,
            width: 370,
            decoration: BoxDecoration(
              color: my_color.item,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.only(left: 17, right: 17, top: 3),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: name_controller,
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                        hintText: "名稱",
                        hintStyle: TextStyle(color: my_color.hint, fontSize: 16),
                        border: InputBorder.none
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 360,
                    height: 1,
                    color: my_color.hint,
                  ),
                ),

                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: amount_controller,
                    cursorColor: Colors.black54,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                        hintText: "價格",
                        hintStyle: TextStyle(color: my_color.hint, fontSize: 16),
                        border: InputBorder.none
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16,),

          Container(
            height: 45,
            width: 370,
            decoration: BoxDecoration(
              color: my_color.item,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.only(left: 17, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("標籤", style: TextStyle(color: Colors.black87, fontSize: 16),),
                Row(
                  children: [
                    Text(tags, style: TextStyle(color: my_color.hint),),
                    Container(
                      width: 26,
                      height: 26,
                      child: selectMenu(my_color)
                    ),
                  ],
                )
              ],
            ),
          ),

          SizedBox(height: 16,),

          Container(
            height: 45,
            width: 370,
            decoration: BoxDecoration(
              color: my_color.item,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.only(left: 17, right: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("時間", style: TextStyle(color: Colors.black87, fontSize: 16),),
                Text(DateTime.now().toString().substring(0,16), style: TextStyle(color: Colors.black87, fontSize: 16),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
