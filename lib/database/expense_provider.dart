import 'package:exp02/models/transaction.dart';
import 'package:flutter/material.dart';
import 'db_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Day> _monthData = []; // 每個月份的資料
  Day? _nowData; // 當天的資料
  double? _totalCost;

  List<Day> get monthData => _monthData;
  Day? get nowData => _nowData;
  double? get totalCost => _totalCost;

  final DatabaseHelper _helper = DatabaseHelper();

  Future<void> setMonthData(DateTime now) async {
    List<TransactionItem> all = await _helper.getMonth(now);
    List<Day> tmp = [];

    int days = DateTime(now.year, now.month + 1, 0).day; // .day 作用？
    for(int i=1; i<=days; i++) { // 要改成第一次 啟動的月份 到 現在的月份
      tmp.add(Day(
        date: DateTime(now.year, now.month, i),
        items: []
      ));
    }

    for(var item in all) { // 把這個月的資料都丟進去
      int idx = item.date.day - 1;
      tmp[idx].items.add(item);
    }

    _monthData = tmp;
    notifyListeners();
  }

  // 取得當天資料
  Future<void> setDayData(DateTime now) async { // now 格式: 2026-03-20
    DateTime dayTime = DateTime(now.year, now.month, now.day);
    List<TransactionItem> item = await _helper.getDay(dayTime);

    _nowData = Day(date: now, items: item);
    countTotalCost();

    notifyListeners();
  }

  // 計算當天總和
  Future<void> countTotalCost() async {
    double total = _nowData!.totalIncome - _nowData!.totalExpense;
    _totalCost = total;
  }

  Future<void> add(TransactionItem item) async {
    await _helper.insert(item);
    await setDayData(item.date); // 可調整
  }

  Future<void> remove(TransactionItem item) async {
    await _helper.delete(item.id!);
    await setDayData(item.date); // 可調整
  }
}