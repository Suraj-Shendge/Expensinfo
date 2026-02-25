import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../data/database_service.dart';
import '../../../data/models/expense_model.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController merchantController = TextEditingController();

  String selectedCategory = "Fuel";

  final List<Map<String, String>> categories = [
    {"name": "Fuel", "icon": "assets/icons/fuel.png"},
    {"name": "Food", "icon": "assets/icons/food.png"},
    {"name": "Shopping", "icon": "assets/icons/shopping.png"},
    {"name": "Bills", "icon": "assets/icons/bills.png"},
    {"name": "Other", "icon": "assets/icons/other.png"},
  ];

  Future<void> saveExpense() async {
    final double? amount = double.tryParse(amountController.text);

    if (amount == null || merchantController.text.isEmpty) {
      return;
    }

    final expense = Expense(
      amount: amount,
      category: selectedCategory,
      merchant: merchantController.text,
      date: DateTime.now(),
    );

    await DatabaseService.instance.insertExpense(expense);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0E0F13),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Indicator
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Add Expense",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Amount Field
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "₹ 0.00",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 20),

            // Merchant Field
            TextField(
              controller: merchantController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Merchant name",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Category",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Category Selector
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: categories.map((cat) {
                final bool isSelected =
                    selectedCategory == cat["name"];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat["name"]!;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFFD6FF00)
                              : AppColors.card,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFD6FF00)
                                        .withOpacity(0.6),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  )
                                ]
                              : [],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            cat["icon"]!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat["name"]!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6FF00),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: saveExpense,
                child: const Text(
                  "Save Expense",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
