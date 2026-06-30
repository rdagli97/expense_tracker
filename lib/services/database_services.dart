import 'package:expense_tracker/models/expense.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServices {
  static Database? _database;

  Future<Database> get getDatabase async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'expense.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      }
    );
  }

  // create: add new expense to table
  Future<int> insertExpense(Expense expense) async {
    final db = await getDatabase;

    return await db.insert('expenses', expense.toMap());
  }

  // read: get all expenses as List
  Future<List<Expense>> getExpenses() async {
    final db = await getDatabase;

    final List<Map<String, dynamic>> maps = await db.query('expenses');

    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await getDatabase;

    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}