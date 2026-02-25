import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/database_service.dart';
import '../../data/models/expense_model.dart';

import 'widgets/finance_card_stack.dart';
import 'widgets/category_row.dart';
import 'widgets/add_expense_sheet.dart';

import '../../core/sms_service.dart';
import '../../core/sms_parser.dart';
import '../../core/settlement_engine.dart';

enum RangeType { today, month, custom }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  RangeType selectedRange = RangeType.month;

  DateTime? customStart;
  DateTime? customEnd;

  double totalExpense = 0;
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
    checkSmsForTransactions();
  }

  // ================= SMS CHECK =================

  Future<void> checkSmsForTransactions() async {
    final smsService = SmsService();
    final messages = await smsService.getRecentMessages();

    for (var msg in messages) {
      final parsed = SmsParser.parse(msg.body ?? "");
      if (parsed == null) continue;

      final suggestion = await SettlementEngine.checkSettlement(
        person: parsed.person,
        amount: parsed.amount,
        isIncoming: parsed.isIncoming,
      );

      if (suggestion != null && mounted) {
        showSettlementBottomSheet(suggestion);
        break;
      }
    }
  }

  void showSettlementBottomSheet(SettlementSuggestion suggestion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Settlement Detected",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Apply ₹${suggestion.amount.toStringAsFixed(0)} to ${suggestion.person}?",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6FF00),
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  if (suggestion.isLentSettlement) {
                    await DatabaseService.instance
                        .applyLentSettlementFIFO(
                            suggestion.person, suggestion.amount);
                  } else {
                    await DatabaseService.instance
                        .applyBorrowedSettlementFIFO(
                            suggestion.person, suggestion.amount);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Confirm Settlement"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= LOAD EXPENSES =================

  Future<void> loadExpenses() async {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    if (selectedRange == RangeType.today) {
      start = DateTime(now.year, now.month, now.day);
    } else if (selectedRange == RangeType.month) {
      start = DateTime(now.year, now.month, 1);
    } else {
      start = customStart ?? now;
      end = customEnd ?? now;
    }

    final data =
        await DatabaseService.instance.getExpensesByDateRange(start, end);

    double sum = 0;
    for (var e in data) {
      sum += e.amount;
    }

    setState(() {
      expenses = data;
      totalExpense = sum;
    });
  }

  // ================= UI BELOW (unchanged) =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: buildFAB(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              FinanceCardStack(totalExpense: totalExpense),
              const SizedBox(height: 24),
              const CategoryRow(),
              const SizedBox(height: 24),
              buildRangeSelector(),
              const SizedBox(height: 24),
              buildTransactionHeader(),
              const SizedBox(height: 12),
              buildExpenseList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFAB() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFFD6FF00),
      child: const Icon(Icons.add, color: Colors.black),
      onPressed: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddExpenseSheet(),
        );
        loadExpenses();
      },
    );
  }

  Widget buildRangeSelector() {
    return Container(); // keep your existing implementation
  }

  Widget buildTransactionHeader() {
    return Container(); // keep your existing implementation
  }

  Widget buildExpenseList() {
    return Container(); // keep your existing implementation
  }
}
