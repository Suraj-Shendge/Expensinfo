import 'package:flutter/material.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CategoryItem(
            color: Color(0xFF2ECC71),
            imagePath: "assets/icons/fuel.png",
            label: "Fuel",
          ),
          CategoryItem(
            color: Color(0xFF9B59B6),
            imagePath: "assets/icons/food.png",
            label: "Food",
          ),
          CategoryItem(
            color: Color(0xFF3498DB),
            imagePath: "assets/icons/shopping.png",
            label: "Shopping",
          ),
          CategoryItem(
            color: Color(0xFF8D6E63),
            imagePath: "assets/icons/bills.png",
            label: "Bills",
          ),
          CategoryItem(
            color: Color(0xFFE91E63),
            imagePath: "assets/icons/other.png",
            label: "Other",
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Color color;
  final String imagePath;
  final String label;

  const CategoryItem({
    super.key,
    required this.color,
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
