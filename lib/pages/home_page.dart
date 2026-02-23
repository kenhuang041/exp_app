import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyExpensePage extends StatefulWidget {
  const MyExpensePage({super.key});

  @override
  State<MyExpensePage> createState() => _MyExpensePageState();
}

class _MyExpensePageState extends State<MyExpensePage> {

  @override
  Widget build(BuildContext context) {
    var my_color = Provider.of<MyColor>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

          Container(
            width: 360,
            height: 191,
            decoration: BoxDecoration(
              color: my_color.item,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(height: 14,),

          Container(
            width: 360,
            height: 87,
            decoration: BoxDecoration(
              color: my_color.item,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(height: 30,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("詳細資訊", style: TextStyle(fontSize: 14),),
              InkWell(
                onTap: () {

                },
                child: Container(
                  width: 55,
                  height: 25,
                  decoration: BoxDecoration(
                    color: my_color.item,
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Center(child: Text("分類", style: TextStyle(fontSize: 11),)),
                ),
              )
            ],
          ),

          SizedBox(height: 14,),

          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: my_color.item,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text("item0${index}", style: TextStyle(fontSize: 16),),
                        // subtitle: Text("this is the test of subtitle...",style: TextStyle(color: Color(0xFFBBBCBC), fontSize: 12),),
                        visualDensity: VisualDensity(vertical: -4),
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: my_color.grey,
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: Icon(Icons.arrow_upward, size: 16,),
                        ),
                      ),
                    ),
                  );
                }
              )
            )
          )
        ],
      ),
    );
  }
}
