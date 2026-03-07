class Donation {
  final String donationId;
  final String organizationId;
  final String organizationType; // madarsa or mosque
  final String? donorId;
  final String? collectorId;
  final String? donorName;
  final String donationCategory; // Zakat, Sadaqah, Lillah, Imdad, General
  final String status;
  final bool isOffline;
  final String paymentMethod;
  final DateTime timestamp;
  final String receiptNumber;
  final double amount;

  Donation({
    required this.donationId,
    required this.organizationId,
    this.organizationType = 'madarsa',
    this.donorId,
    this.collectorId,
    this.donorName,
    required this.donationCategory,
    this.status = 'completed',
    this.isOffline = false,
    required this.amount,
    this.paymentMethod = 'online',
    required this.timestamp,
    required this.receiptNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'donationId': donationId,
      'organizationId': organizationId,
      'organizationType': organizationType,
      'donorId': donorId,
      'collectorId': collectorId,
      'donorName': donorName,
      'donationCategory': donationCategory,
      'status': status,
      'isOffline': isOffline,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
      'receiptNumber': receiptNumber,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      donationId: map['donationId'] ?? '',
      organizationId: map['organizationId'] ?? '',
      organizationType: map['organizationType'] ?? 'madarsa',
      donorId: map['donorId'],
      collectorId: map['collectorId'],
      donorName: map['donorName'],
      donationCategory: map['donationCategory'] ?? 'General Donation',
      status: map['status'] ?? 'completed',
      isOffline: map['isOffline'] ?? false,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'online',
      timestamp: DateTime.parse(map['timestamp'] ?? map['date']),
      receiptNumber: map['receiptNumber'] ?? '',
    );
  }
}
