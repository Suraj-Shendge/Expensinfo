import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import 'expense_card.dart';
import 'lending_card.dart';

class FinanceCardCarousel extends StatefulWidget {
  final double totalExpense;

  const FinanceCardCarousel({
    super.key,
    required this.totalExpense,
  });

  @override
  State<FinanceCardCarousel> createState() => _FinanceCardCarouselState();
}

class _FinanceCardCarouselState extends State<FinanceCardCarousel> {
  final PageController _controller =
      PageController(viewportFraction: 0.88);

  double currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView(
        controller: _controller,
        children: [
          buildAnimatedCard(0, ExpenseCard(totalExpense: widget.totalExpense)),
          buildAnimatedCard(1, const LendingCard()),
        ],
      ),
    );
  }

  Widget buildAnimatedCard(int index, Widget child) {
    double scale = 1.0;

    if (currentPage != index) {
      scale = 0.95;
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: child,
      ),
    );
  }
}
