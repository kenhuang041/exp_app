/// 支出／收入狀態管理（Provider）
///
/// 負責：當日資料、當月資料、全月份快取、總額計算，以及與 [DatabaseHelper] 的 CRUD 同步。

import 'package:exp02/models/transaction.dart';
import 'package:flutter/material.dart';
import 'db_helper.dart';

class ExpenseProvider with ChangeNotifier {
  /// 每個月份的資料：(該月 DateTime, 該月每日 [Day] 列表)，$1=月份、$2=日列表
  List<(DateTime, List<Day>)> _monthData = [];
  /// 目前顯示月份的每日資料（用於日曆頁）
  List<Day> _nowMonthData = [];
  /// 資料庫中最早一筆交易的日期，用於日曆可選範圍
  DateTime _firstDate = DateTime.now();
  /// 當前選定日期的當日收支資料（首頁用）
  Day? _nowData;
  /// 當日淨額（收入－支出）
  double? _totalCost;

  List<(DateTime, List<Day>)> get monthData => _monthData;
  List<Day> get nowMonthData => _nowMonthData;
  Day? get nowData => _nowData;
  double? get totalCost => _totalCost;
  DateTime get firstDate => _firstDate;

  final DatabaseHelper _helper = DatabaseHelper();

  /// 從資料庫載入從 _firstDate 到當月為止的每個月份資料，填入 _monthData
  Future<void> setAllMonthData() async {
    DateTime nowDate = DateTime.now();
    List<TransactionItem> all = await _helper.getAll();

    _monthData.clear();

    int total = (nowDate.year - _firstDate.year) * 12 + (nowDate.month - _firstDate.month);

    for(int i=0; i<=total; i++) {
      DateTime nowMonth = DateTime(_firstDate.year, _firstDate.month + i);
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

  /// 將 _nowMonthData 設為當前系統日期所在月份的日列表（從 _monthData 取出）
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

  /// 從 DB 取得第一筆交易日期，更新 _firstDate
  Future<void> setFirstDate() async {
    _firstDate = await _helper.getFirstTransactionDate() ?? DateTime.now();
  }

  /// 取得指定日期的當日交易並寫入 _nowData，同時呼叫 countTotalCost 更新 _totalCost
  Future<void> setDayData(DateTime now) async {
    DateTime dayTime = DateTime(now.year, now.month, now.day);
    List<TransactionItem> item = await _helper.getDay(dayTime);

    _nowData = Day(date: now, items: item);
    countTotalCost();

    notifyListeners();
  }

  /// 依 _nowData 計算當日淨額（收入－支出）並寫入 _totalCost
  Future<void> countTotalCost() async {
    if(_nowData == null) {
      _totalCost = 0;
      return;
    }
    double total = _nowData!.totalIncome - _nowData!.totalExpense;
    _totalCost = total;
  }

  /// 新增一筆交易並刷新當日資料
  Future<void> add(TransactionItem item) async {
    await _helper.insert(item);
    await setDayData(item.date);
  }

  /// 刪除一筆交易並刷新當日資料
  Future<void> remove(TransactionItem item) async {
    await _helper.delete(item);
    await setDayData(item.date);
  }

  /// 清空資料庫所有交易並通知監聽者
  Future<void> clearAll() async {
    await _helper.clear();
    notifyListeners();
  }
}