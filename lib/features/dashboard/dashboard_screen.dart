import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/database_service.dart';
import '../../data/models/expense_model.dart';

import 'widgets/finance_card_stack.dart';
import 'widgets/category_row.dart';
import 'widgets/add_expense_sheet.dart';

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
  }

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

  Future<void> pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.emerald,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      customStart = range.start;
      customEnd = range.end;
      selectedRange = RangeType.custom;
      loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFD6FF00),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD6FF00).withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(35),
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddExpenseSheet(),
              );

              loadExpenses();
            },
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
        ),
      ),

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

  Widget buildRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          rangeButton("Today", RangeType.today),
          rangeButton("This Month", RangeType.month),
          rangeButton("Custom", RangeType.custom),
        ],
      ),
    );
  }

  Widget rangeButton(String label, RangeType type) {
    final isSelected = selectedRange == type;

    return GestureDetector(
      onTap: () {
        if (type == RangeType.custom) {
          pickCustomRange();
        } else {
          setState(() {
            selectedRange = type;
          });
          loadExpenses();
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.emerald),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget buildTransactionHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Transactions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "See All",
            style: TextStyle(
              color: AppColors.emerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpenseList() {
    if (expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            "No transactions yet",
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final e = expenses[index];

        return Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD6FF00),
                ),
                child: const Icon(
                  Icons.receipt,
                  color: Colors.black,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.merchant,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.category,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "₹ ${e.amount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
