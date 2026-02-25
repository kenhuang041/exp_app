// 1. 單筆交易項目 (收入或支出)
class TransactionItem {
  final int? id;
  final String name;          // 項目名稱
  final double amount;        // 金額
  final String type;          // 資金類別: 收入或支出
  final String tags;    // 類別 (Tags)
  final DateTime date;    // 確切時間

  TransactionItem({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.tags,
    required this.date,
  });

  // class 轉 Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'tags': tags, // 轉成SQL能識別的 String
      'date': date.toIso8601String(), // 和上述同理
    };
  }

  // Map<String, dynamic> 轉 class
  factory TransactionItem.fromMap(Map<String, dynamic> mp) {
    return TransactionItem(
      id: mp['id'],
      name: mp['name'],
      amount: mp['amount'],
      type: mp['type'],
      tags: mp['tags'], // String to List
      date: DateTime.parse(mp['date']), // to DateTime
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

  // 取得特定 tag 的所有 item
  List<TransactionItem> tagsOfItems(String tag) => items
      .where((x) => x.tags == tag)
      .toList();
  
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