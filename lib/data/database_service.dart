import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BorrowLendEntry {
  final int id;
  final String person;
  final double amount;
  final double remaining;
  final String date;
  final int isSettled;

  BorrowLendEntry({
    required this.id,
    required this.person,
    required this.amount,
    required this.remaining,
    required this.date,
    required this.isSettled,
  });
}

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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        category TEXT,
        merchant TEXT,
        date TEXT,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE borrowed (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person TEXT,
        amount REAL,
        remaining REAL,
        date TEXT,
        note TEXT,
        dueDate TEXT,
        isSettled INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE lent (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person TEXT,
        amount REAL,
        remaining REAL,
        date TEXT,
        note TEXT,
        dueDate TEXT,
        isSettled INTEGER
      )
    ''');
  }

  // ===================== INSERT METHODS =====================

  Future<void> insertBorrowed({
    required String person,
    required double amount,
    required String date,
    String note = "",
    String dueDate = "",
  }) async {
    final db = await database;
    await db.insert('borrowed', {
      'person': person,
      'amount': amount,
      'remaining': amount,
      'date': date,
      'note': note,
      'dueDate': dueDate,
      'isSettled': 0,
    });
  }

  Future<void> insertLent({
    required String person,
    required double amount,
    required String date,
    String note = "",
    String dueDate = "",
  }) async {
    final db = await database;
    await db.insert('lent', {
      'person': person,
      'amount': amount,
      'remaining': amount,
      'date': date,
      'note': note,
      'dueDate': dueDate,
      'isSettled': 0,
    });
  }

  // ===================== FETCH OPEN ENTRIES =====================

  Future<List<BorrowLendEntry>> getOpenBorrowedByPerson(String person) async {
    final db = await database;

    final result = await db.query(
      'borrowed',
      where: 'person = ? AND isSettled = 0',
      whereArgs: [person],
      orderBy: 'date ASC', // FIFO
    );

    return result.map((e) => BorrowLendEntry(
      id: e['id'] as int,
      person: e['person'] as String,
      amount: e['amount'] as double,
      remaining: e['remaining'] as double,
      date: e['date'] as String,
      isSettled: e['isSettled'] as int,
    )).toList();
  }

  Future<List<BorrowLendEntry>> getOpenLentByPerson(String person) async {
    final db = await database;

    final result = await db.query(
      'lent',
      where: 'person = ? AND isSettled = 0',
      whereArgs: [person],
      orderBy: 'date ASC', // FIFO
    );

    return result.map((e) => BorrowLendEntry(
      id: e['id'] as int,
      person: e['person'] as String,
      amount: e['amount'] as double,
      remaining: e['remaining'] as double,
      date: e['date'] as String,
      isSettled: e['isSettled'] as int,
    )).toList();
  }

  // ===================== FIFO SETTLEMENT =====================

  Future<void> applyLentSettlementFIFO(String person, double amount) async {
    final db = await database;
    final openEntries = await getOpenLentByPerson(person);

    double remainingAmount = amount;

    for (var entry in openEntries) {
      if (remainingAmount <= 0) break;

      double newRemaining = entry.remaining - remainingAmount;

      if (newRemaining <= 0) {
        await db.update(
          'lent',
          {
            'remaining': 0,
            'isSettled': 1,
          },
          where: 'id = ?',
          whereArgs: [entry.id],
        );
        remainingAmount = -newRemaining;
      } else {
        await db.update(
          'lent',
          {
            'remaining': newRemaining,
          },
          where: 'id = ?',
          whereArgs: [entry.id],
        );
        remainingAmount = 0;
      }
    }
  }

  Future<void> applyBorrowedSettlementFIFO(String person, double amount) async {
    final db = await database;
    final openEntries = await getOpenBorrowedByPerson(person);

    double remainingAmount = amount;

    for (var entry in openEntries) {
      if (remainingAmount <= 0) break;

      double newRemaining = entry.remaining - remainingAmount;

      if (newRemaining <= 0) {
        await db.update(
          'borrowed',
          {
            'remaining': 0,
            'isSettled': 1,
          },
          where: 'id = ?',
          whereArgs: [entry.id],
        );
        remainingAmount = -newRemaining;
      } else {
        await db.update(
          'borrowed',
          {
            'remaining': newRemaining,
          },
          where: 'id = ?',
          whereArgs: [entry.id],
        );
        remainingAmount = 0;
      }
    }
  }
}
