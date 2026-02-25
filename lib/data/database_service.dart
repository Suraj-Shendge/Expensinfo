import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/expense_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expensinfo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchant TEXT,
        category TEXT,
        amount REAL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE lent (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person TEXT,
        amount REAL,
        remaining REAL,
        date TEXT,
        isSettled INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE borrowed (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person TEXT,
        amount REAL,
        remaining REAL,
        date TEXT,
        isSettled INTEGER
      )
    ''');
  }

  // ================= EXPENSES =================

  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    final db = await instance.database;

    final result = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );

    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // ================= LENT =================

  Future<List<Map<String, dynamic>>> getOpenLentByPerson(
      String person) async {
    final db = await instance.database;

    return await db.query(
      'lent',
      where: 'person = ? AND isSettled = 0',
      whereArgs: [person],
      orderBy: 'date ASC',
    );
  }

  Future<void> applyLentSettlementFIFO(
      String person, double amount) async {
    final db = await instance.database;

    final entries = await getOpenLentByPerson(person);

    double remainingAmount = amount;

    for (var entry in entries) {
      if (remainingAmount <= 0) break;

      double entryRemaining = entry['remaining'];

      if (remainingAmount >= entryRemaining) {
        await db.update(
          'lent',
          {'remaining': 0, 'isSettled': 1},
          where: 'id = ?',
          whereArgs: [entry['id']],
        );
        remainingAmount -= entryRemaining;
      } else {
        await db.update(
          'lent',
          {'remaining': entryRemaining - remainingAmount},
          where: 'id = ?',
          whereArgs: [entry['id']],
        );
        remainingAmount = 0;
      }
    }
  }

  // ================= BORROWED =================

  Future<List<Map<String, dynamic>>> getOpenBorrowedByPerson(
      String person) async {
    final db = await instance.database;

    return await db.query(
      'borrowed',
      where: 'person = ? AND isSettled = 0',
      whereArgs: [person],
      orderBy: 'date ASC',
    );
  }

  Future<void> applyBorrowedSettlementFIFO(
      String person, double amount) async {
    final db = await instance.database;

    final entries = await getOpenBorrowedByPerson(person);

    double remainingAmount = amount;

    for (var entry in entries) {
      if (remainingAmount <= 0) break;

      double entryRemaining = entry['remaining'];

      if (remainingAmount >= entryRemaining) {
        await db.update(
          'borrowed',
          {'remaining': 0, 'isSettled': 1},
          where: 'id = ?',
          whereArgs: [entry['id']],
        );
        remainingAmount -= entryRemaining;
      } else {
        await db.update(
          'borrowed',
          {'remaining': entryRemaining - remainingAmount},
          where: 'id = ?',
          whereArgs: [entry['id']],
        );
        remainingAmount = 0;
      }
    }
  }
}
