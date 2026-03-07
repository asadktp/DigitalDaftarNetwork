class OrgSummary {
  final String organizationId;
  final double totalDonations;
  final double totalExpenses;
  final double balance;
  final DateTime lastUpdated;

  OrgSummary({
    required this.organizationId,
    required this.totalDonations,
    required this.totalExpenses,
    required this.balance,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationId': organizationId,
      'totalDonations': totalDonations,
      'totalExpenses': totalExpenses,
      'balance': balance,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory OrgSummary.fromMap(Map<String, dynamic> map) {
    return OrgSummary(
      organizationId: map['organizationId'] ?? '',
      totalDonations: (map['totalDonations'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (map['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as dynamic).toDate()
          : DateTime.now(),
    );
  }
}
