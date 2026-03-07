class Collector {
  final String collectorId;
  final String organizationId;
  final String name;
  final String phone;
  final String status; // active, inactive

  Collector({
    required this.collectorId,
    required this.organizationId,
    required this.name,
    required this.phone,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'collectorId': collectorId,
      'organizationId': organizationId,
      'name': name,
      'phone': phone,
      'status': status,
    };
  }

  factory Collector.fromMap(Map<String, dynamic> map) {
    return Collector(
      collectorId: map['collectorId'] ?? '',
      organizationId: map['organizationId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] ?? 'active',
    );
  }
}
