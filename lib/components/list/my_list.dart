import 'package:exp02/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/expense_provider.dart';
import '../../models/color.dart';

class MyListItemPage extends StatefulWidget {
  final TransactionItem item;
  const MyListItemPage({super.key, required this.item});

  @override
  State<MyListItemPage> createState() => _MyListItemPageState();
}

class _MyListItemPageState extends State<MyListItemPage> {
  @override
  Widget build(BuildContext context) {
    var my_color = Provider.of<MyColor>(context);
    var expense_data = Provider.of<ExpenseProvider>(context); // 取得資料

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(widget.item.id.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (d) {
          expense_data.remove(widget.item);
        },
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: my_color.item,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(widget.item.name, style: TextStyle(fontSize: 16),),
            visualDensity: VisualDensity(vertical: -4),
            leading: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: my_color.grey,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: Icon((widget.item.type == "income" ? Icons.arrow_upward : Icons.arrow_downward), size: 16,),
            ),
            trailing: Text(
              (widget.item.type == "expense") ? '-NT\$${widget.item.amount}' : '+NT\$${widget.item.amount}',
              style: TextStyle(
                  fontSize: 14,
                  color: my_color.text
              ),
            ),
          ),
        ),
      ),
    );
  }
}
