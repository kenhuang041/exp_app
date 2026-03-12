/// 單筆交易項目（收入或支出），對應 DB 一筆紀錄
class TransactionItem {
  final int? id;
  final String name;
  final double amount;
  /// 資金類別：'income' 或 'expense'
  final String type;
  /// 分類標籤（目前為單一字串，如「薪水」「交通」）
  final String tags;
  final DateTime date;

  TransactionItem({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.tags,
    required this.date,
  });

  /// 轉成 sqflite insert/update 用的 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'tags': tags, // 轉成SQL能識別的 String
      'date': date.toIso8601String(),
    };
  }

  /// 從 DB 查詢結果的 Map 建立實例
  factory TransactionItem.fromMap(Map<String, dynamic> mp) {
    return TransactionItem(
      id: mp['id'],
      name: mp['name'],
      amount: mp['amount'],
      type: mp['type'],
      tags: mp['tags'],
      date: DateTime.parse(mp['date']),
    );
  }
}

/// 單日彙總：該日期的所有交易列表，以及收入／支出合計的 getter
class Day {
  final DateTime date;
  List<TransactionItem> items;

  Day({
    required this.date,
    required this.items,
  });

  /// 當日所有 type == 'income' 的金額總和
  double get totalIncome => items
      .where((x) => x.type == "income")
      .fold(0, (sum, item) => sum + item.amount);

  /// 當日所有 type == 'expense' 的金額總和
  double get totalExpense => items
      .where((x) => x.type == "expense")
      .fold(0, (sum, item) => sum + item.amount);

  /// 篩選出 tags 等於 [tag] 的交易列表
  List<TransactionItem> tagsOfItems(String tag) => items
      .where((x) => x.tags == tag)
      .toList();

  /// 當日所有不重複的 tags（收入類先、支出類後）
  List<String> get getAllTags {
    final sortedItems = List<TransactionItem>.from(items);
    sortedItems.sort((a,b) {
      if(a.type == b.type) return 0;
      return a.type == "income" ? -1 : 1;
    });

    final st = <String>{};
    for(var tmp in sortedItems) st.add(tmp.tags);
    return st.toList();
  }
}