import 'dart:math';

class ParsedTransaction {
  final String person;
  final double amount;
  final bool isIncoming; // true = received, false = paid

  ParsedTransaction({
    required this.person,
    required this.amount,
    required this.isIncoming,
  });
}

class SmsParser {
  static ParsedTransaction? parse(String message) {
    final lower = message.toLowerCase();

    // Detect transaction keywords
    final isIncoming = lower.contains("credited") ||
        lower.contains("received") ||
        lower.contains("credit");

    final isOutgoing = lower.contains("debited") ||
        lower.contains("sent") ||
        lower.contains("paid") ||
        lower.contains("debit");

    if (!isIncoming && !isOutgoing) return null;

    // Extract amount
    final amountRegex = RegExp(r'₹\s?(\d+(?:\.\d+)?)');
    final amountMatch = amountRegex.firstMatch(message);

    if (amountMatch == null) return null;

    final amount = double.tryParse(amountMatch.group(1) ?? "0");
    if (amount == null || amount <= 0) return null;

    // Extract person (basic heuristic)
    final personRegex =
        RegExp(r'(from|to)\s([A-Za-z0-9@.\-_ ]+)', caseSensitive: false);

    final personMatch = personRegex.firstMatch(message);
    if (personMatch == null) return null;

    String person = personMatch.group(2) ?? "Unknown";

    // Clean person string
    person = person.split(" ").first;

    return ParsedTransaction(
      person: person.trim(),
      amount: amount,
      isIncoming: isIncoming,
    );
  }
}
