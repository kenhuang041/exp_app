/// SQLite 資料庫操作封裝
///
/// 單一資料表 [transactions] 儲存所有收支紀錄，
/// 透過 getDay / getMonth / getAll 等方法依需求查詢。

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:exp02/models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper._internal();

  /// 取得資料庫實例（若尚未建立則執行 _initDatabase）
  Future<Database> get database async {
    if(_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  /// 建立資料庫與 transactions 表（id, name, amount, type, tags, date）
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            amount REAL,
            type TEXT,
            tags TEXT,
            date TEXT
          )
        """);
      },
    );
  }

  /// 新增一筆收支紀錄，回傳插入的 row id
  Future<int> insert(TransactionItem item) async {
    var db = await database;
    return await db.insert('transactions', item.toMap());
  }

  /// 刪除一筆紀錄
  ///
  /// - 若 [item.id] 存在，優先依 id 刪除（最安全）
  /// - 否則退回使用 name+amount+date+type（可能會刪到重複資料）
  /// [!AI] 修正刪除邏輯：避免同名同金額同時間造成「刪錯筆/刪多筆」。
  Future<int> delete(TransactionItem item) async {
    var db = await database;
    if (item.id != null) {
      return await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
    return await db.delete(
        'transactions',
        where: 'name = ? AND amount = ? AND date = ? AND type = ?',
        whereArgs: [item.name, item.amount, item.date.toIso8601String(), item.type]
    );
  }

  /// 清空 transactions 表內所有資料
  Future<void> clear() async {
    var db = await database;
    await db.delete('transactions');
  }

  /// 取得全表最早一筆交易的日期，供日曆起始月使用
  Future<DateTime?> getFirstTransactionDate() async {
    var db = await database;
    List<Map<String, dynamic>> mp = await db.query(
      'transactions',
      orderBy: "date ASC",
      limit: 1,
    );

    if(mp.isNotEmpty) return DateTime.parse(mp.first['date']);
    else return null;
  }

  /// 取得所有交易紀錄（無排序）
  Future<List<TransactionItem>> getAll() async {
    var db = await database;
    List<Map<String, dynamic>> mp = await db.query('transactions',);
    return List.generate(mp.length, (x) => TransactionItem.fromMap(mp[x]));
  }

  /// 取得指定日期當天的所有交易（以 date LIKE 'yyyy-MM-dd%' 查詢）
  Future<List<TransactionItem>> getDay(DateTime day) async {
    var db = await database;
    String str = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    List<Map<String, dynamic>> mp = await db.query(
      'transactions',
      where: "date LIKE ?",
      whereArgs: ['$str%'],
      orderBy: 'date ASC',
    );

    return List.generate(mp.length, (x) => TransactionItem.fromMap(mp[x]));
  }

  /// 取得指定年月的所有交易（以 date LIKE 'yyyy-MM%' 查詢）
  Future<List<TransactionItem>> getMonth(DateTime month) async {
    var db = await database;
    String str = "${month.year}-${month.month.toString().padLeft(2, '0')}";

    List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: "date LIKE ?",
      whereArgs: ['$str%']
    );

    return maps.map((x) => TransactionItem.fromMap(x)).toList();
  }
}