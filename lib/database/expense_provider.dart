import 'package:exp02/models/transaction.dart';
import 'package:flutter/material.dart';
import 'db_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<(DateTime, List<Day>)> _monthData = []; // 每個月份的資料
  // .first => $1
  // .second => $2
  List<Day> _nowMonthData = [];
  Day? _nowData; // 當天的資料
  double? _totalCost;

  List<(DateTime, List<Day>)> get monthData => _monthData;
  List<Day> get nowMonthData => _nowMonthData;
  Day? get nowData => _nowData;
  double? get totalCost => _totalCost;

  final DatabaseHelper _helper = DatabaseHelper();

  Future<void> setAllMonthData() async {
    DateTime? firstDate = await _helper.getFirstTransactionDate() ?? DateTime.now();
    DateTime nowDate = DateTime.now();
    List<TransactionItem> all = await _helper.getAll();

    _monthData.clear();

    int total = (nowDate.year - firstDate.year) * 12 + (nowDate.month - firstDate.month);

    for(int i=0; i<=total; i++) {
      DateTime nowMonth = DateTime(firstDate.year, firstDate.month + i);
      List<TransactionItem> monthData = await _helper.getMonth(nowMonth);

      int daysInMonth = DateTime(nowMonth.year, nowMonth.month + 1, 0).day;
      List<Day> tmp = List.generate(daysInMonth, (idx) => Day(date: DateTime(nowMonth.year, nowMonth.month, idx+1), items: []));

      for(var transaction in monthData) {
        int dayIndex = transaction.date.day - 1;
        if (dayIndex >= 0 && dayIndex < tmp.length) {
          tmp[dayIndex].items.add(transaction);
        }
      }

      if (tmp.isNotEmpty) {
        var pair = (nowMonth, tmp);
        _monthData.add(pair);
      }
      else print('error of tmp2');
    }

    notifyListeners();
  }

  Future<void> setNowMonth() async {
    try {
      DateTime nowDate = DateTime.now();
      var tmp = _monthData.firstWhere(
        (x) => (x.$1.year == nowDate.year  && x.$1.month == nowDate.month)
      );
      _nowMonthData = tmp.$2;
    } catch (e) {
      print("error of getNowMonth");
      _nowMonthData = [];
    }

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
    if(_nowData == null) {
      _totalCost = 0;
      return;
    }
    double total = _nowData!.totalIncome - _nowData!.totalExpense;
    _totalCost = total;
  }

  Future<void> add(TransactionItem item) async {
    await _helper.insert(item);
    await setDayData(item.date); // 可調整
  }

  Future<void> remove(TransactionItem item) async {
    await _helper.delete(item);
    await setDayData(item.date); // 可調整
  }

  Future<void> clearAll() async {
    await _helper.clear();
    notifyListeners();
  }
}