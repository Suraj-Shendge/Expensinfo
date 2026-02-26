import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'data/database_service.dart';
import 'data/models/expense_model.dart';

const MethodChannel _channel = MethodChannel("background_channel");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Background notification action handler
  _channel.setMethodCallHandler((call) async {
    if (call.method == "insertExpense") {
      final data = Map<String, dynamic>.from(call.arguments);

      await DatabaseService.instance.insertExpense(
        Expense(
          amount: (data["amount"] as num).toDouble(),
          merchant: data["merchant"] ?? "",
          category: data["category"] ?? "Other",
          date: DateTime.now(),
        ),
      );
    }
  });

  runApp(const ExpensinfoApp());
}

class ExpensinfoApp extends StatelessWidget {
  const ExpensinfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
