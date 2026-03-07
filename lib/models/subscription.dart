class Subscription {
  final String organizationId;
  final String plan; // Basic, Premium, Enterprise
  final DateTime startDate;
  final DateTime expiryDate;
  final String status; // active, expired, cancelled

  Subscription({
    required this.organizationId,
    required this.plan,
    required this.startDate,
    required this.expiryDate,
    required this.status,
  });

  bool get isActive => status == 'active' && expiryDate.isAfter(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'organizationId': organizationId,
      'plan': plan,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      organizationId: map['organizationId'] ?? '',
      plan: map['plan'] ?? 'Basic',
      startDate: DateTime.parse(map['startDate']),
      expiryDate: DateTime.parse(map['expiryDate']),
      status: map['status'] ?? 'active',
    );
  }
}
