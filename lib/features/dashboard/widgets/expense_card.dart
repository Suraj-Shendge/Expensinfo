import 'package:flutter/material.dart';

class ExpenseCard extends StatefulWidget {
  final double totalExpense;

  const ExpenseCard({super.key, required this.totalExpense});

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
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD6FF00),
            Color(0xFFA8E600),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Expenses",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          /// Animated Amount
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.totalExpense),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Text(
                hideAmount
                    ? "₹ •••••"
                    : "₹ ${value.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          const Spacer(),

          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {
                setState(() {
                  hideAmount = !hideAmount;
                });
              },
              icon: Icon(
                hideAmount ? Icons.visibility_off : Icons.visibility,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
