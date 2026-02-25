import '../data/database_service.dart';

class SettlementSuggestion {
  final String person;
  final double amount;
  final bool isLentSettlement; // true = settling lent, false = settling borrowed

  SettlementSuggestion({
    required this.person,
    required this.amount,
    required this.isLentSettlement,
  });
}

class SettlementEngine {
  static Future<SettlementSuggestion?> checkSettlement({
    required String person,
    required double amount,
    required bool isIncoming, // true = received money, false = paid
  }) async {
    final db = DatabaseService.instance;

    if (isIncoming) {
      // Received money → check Lent
      final openLent = await db.getOpenLentByPerson(person);
      double totalRemaining = 0;

      for (var entry in openLent) {
        totalRemaining += entry.remaining;
      }

      if (totalRemaining > 0) {
        return SettlementSuggestion(
          person: person,
          amount: amount > totalRemaining ? totalRemaining : amount,
          isLentSettlement: true,
        );
      }
    } else {
      // Paid money → check Borrowed
      final openBorrowed = await db.getOpenBorrowedByPerson(person);
      double totalRemaining = 0;

      for (var entry in openBorrowed) {
        totalRemaining += entry.remaining;
      }

      if (totalRemaining > 0) {
        return SettlementSuggestion(
          person: person,
          amount: amount > totalRemaining ? totalRemaining : amount,
          isLentSettlement: false,
        );
      }
    }

    return null;
  }
}
