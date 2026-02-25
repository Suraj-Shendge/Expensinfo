import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';

class ExpenseCard extends StatefulWidget {
  final double totalExpense;

  const ExpenseCard({
    super.key,
    required this.totalExpense,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool hideAmount = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFFD6FF00), // Neon yellow style
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row (Title + Eye)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Expenses",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(
                  hideAmount ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    hideAmount = !hideAmount;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Centered Amount
          Center(
            child: AnimatedSwitcher(
              TweenAnimationBuilder<double>(
  tween: Tween<double>(begin: 0, end: widget.totalExpense),
  duration: const Duration(milliseconds: 400),
  builder: (context, value, child) {
    return Center(
      child: Text(
        hideAmount
            ? "INR •••••"
            : "INR ${value.toStringAsFixed(2)}",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  },
),

          const SizedBox(height: 20),

          // Dummy Change Chip (we'll calculate later)
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "+20%",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
