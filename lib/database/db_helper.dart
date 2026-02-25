import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:exp02/models/transaction.dart';

// sql結構
// 把所有資料的資料都丟到裡面
// 取資料時再透過 func() 分類取出

class DatabaseHelper {
  // 單例模式
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper._internal();

  // 取得資料庫
  Future<Database> get database async {
    if(_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // 創建資料庫
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

  // 新增資料
  Future<int> insert(TransactionItem item) async {
    var db = await database;
    return await db.insert('transactions', item.toMap());
  }

  // 刪除資料
  Future<int> delete(int id) async {
    var db = await database;
    return await db.delete('transactions',  where: 'id = ?', whereArgs: [id]);
  }

  // 取得特定一天的資料
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

  // 取得特定月份的所有資料
  Future<List<TransactionItem>> getMonth(DateTime month) async {
    var db = await database;
    String str = "${month.year}-${month.month.toString().padLeft(2, '0')}";

    List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: "date LIKE ?",
      whereArgs: ['$str']
    );

    return maps.map((x) => TransactionItem.fromMap(x)).toList();
  }
}