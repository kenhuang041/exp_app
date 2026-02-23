import 'package:exp02/models/transaction.dart';
import 'package:flutter/material.dart';
import 'db_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Day> _monthData = []; // 每個月份的資料
  List<Day> get monthData => _monthData;

  final DatabaseHelper _helper = DatabaseHelper();

  Future<void> setData(DateTime now) async {
    List<TransactionItem> all = await _helper.getMonth(now);
    List<Day> tmp = [];

    int days = DateTime(now.year, now.month + 1, 0).day; // .day 作用？
    for(int i=1; i<=days; i++) { //
      tmp.add(Day(
        date: DateTime(now.year, now.month, i),
        items: []
      ));
    }

    for(var item in all) {
      int idx = item.dateTime.day - 1;
      tmp[idx].items.add(item);
    }

    _monthData = tmp;
    notifyListeners();
  }

  Future<void> add(TransactionItem item) async {
    await _helper.insert(item);
    await setData(item.dateTime);
  }

  Future<void> remove(TransactionItem item) async {
    await _helper.delete(item.id!);
    await setData(item.dateTime);
  }
}