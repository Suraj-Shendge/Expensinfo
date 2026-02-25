import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'expense_card.dart';
import 'lending_card.dart';

class FinanceCardStack extends StatefulWidget {
  final double totalExpense;

  const FinanceCardStack({super.key, required this.totalExpense});

  @override
  State<FinanceCardStack> createState() => _FinanceCardStackState();
}

class _FinanceCardStackState extends State<FinanceCardStack>
    with SingleTickerProviderStateMixin {
  double dragX = 0;
  double dragY = 0;

  int activeIndex = 0;

  late AnimationController controller;
  late Animation<double> animation;

  final List<String> cards = ["expense", "lending"];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void resetPosition() {
    animation = Tween<double>(begin: dragX, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          dragX = animation.value;
          dragY = 0;
        });
      });

    controller.forward(from: 0);
  }

  void completeSwipe() {
    HapticFeedback.mediumImpact();

    setState(() {
      activeIndex = (activeIndex + 1) % cards.length;
      dragX = 0;
      dragY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double rotation = dragX / screenWidth * 0.2;
    double dragProgress = (dragX.abs() / screenWidth).clamp(0, 1);

    double backScale = 0.94 + dragProgress * 0.06;
    double backTop = 20 - dragProgress * 20;

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 🔥 BACK CARD
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: backTop,
            child: Transform.scale(
              scale: backScale,
              child: Opacity(
                opacity: 0.85,
                child: SizedBox(
                  width: screenWidth - 32,
                  child: activeIndex == 0
                      ? const LendingCard()
                      : ExpenseCard(totalExpense: widget.totalExpense),
                ),
              ),
            ),
          ),

          // 🔥 FRONT CARD
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                dragX += details.delta.dx;
                dragY += details.delta.dy * 0.15;
              });
            },
            onPanEnd: (details) {
              if (dragX.abs() > 120) {
                completeSwipe();
              } else {
                resetPosition();
              }
            },
            child: Transform.translate(
              offset: Offset(dragX, dragY),
              child: Transform.rotate(
                angle: rotation,
                child: SizedBox(
                  width: screenWidth - 32,
                  child: activeIndex == 0
                      ? ExpenseCard(totalExpense: widget.totalExpense)
                      : const LendingCard(),
                ),
              ),
            ),
          ),

          // 🔥 PAGE INDICATOR
          buildIndicator(),
        ],
      ),
    );
  }

  Widget buildIndicator() {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(cards.length, (index) {
          bool isActive = index == activeIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isActive ? 24 : 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFD6FF00)
                  : Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }
}
