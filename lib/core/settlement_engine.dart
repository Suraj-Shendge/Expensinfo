import '../data/database_service.dart';

class SettlementSuggestion {
  final String person;
  final double amount;
  final bool isLentSettlement;

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
    required bool isIncoming,
  }) async {
    final db = DatabaseService.instance;

    if (isIncoming) {
      final openLent = await db.getOpenLentByPerson(person);

      double totalRemaining = 0;
      for (var entry in openLent) {
        totalRemaining += (entry['remaining'] as num).toDouble();
      }

      if (totalRemaining > 0) {
        return SettlementSuggestion(
          person: person,
          amount: amount > totalRemaining ? totalRemaining : amount,
          isLentSettlement: true,
        );
      }
    } else {
      final openBorrowed = await db.getOpenBorrowedByPerson(person);

      double totalRemaining = 0;
      for (var entry in openBorrowed) {
        totalRemaining += (entry['remaining'] as num).toDouble();
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
