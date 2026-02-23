// 1. 單筆交易項目 (收入或支出)
class TransactionItem {
  final int? id;
  final String name;          // 項目名稱
  final double amount;        // 金額
  final String type;          // 資金類別: 收入或支出
  final List<String> tags;    // 類別 (Tags)
  final DateTime dateTime;    // 確切時間

  TransactionItem({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.tags,
    required this.dateTime,
  });

  // class 轉 Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'tags': tags,
      'dateTime': dateTime,
    };
  }

  // Map<String, dynamic> 轉 class
  factory TransactionItem.fromMap(Map<String, dynamic> mp) {
    return TransactionItem(
      id: mp['id'],
      name: mp['name'],
      amount: mp['amount'],
      type: mp['type'],
      tags: mp['tags'],
      dateTime: DateTime.parse(mp['dateTime']),
    );
  }
}

class Day {
  final DateTime date;
  List<TransactionItem> items;  // List

  Day({
    required this.date,
    required this.items,
  });

  // 統計收入總和
  double get totalIncome => items
      .where((x) => x.type == "income")
      .fold(0, (sum, item) => sum + item.amount);

  // 統計支出總和
  double get totalExpense => items
      .where((x) => x.type == "expense")
      .fold(0, (sum, item) => sum + item.amount);
}