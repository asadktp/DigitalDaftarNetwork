class Organization {
  final String organizationId;
  final String name;
  final String type; // madarsa or mosque
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final String adminId;
  final String status; // pending/approved
  final String subscriptionPlan;
  final DateTime? createdAt;

  Organization({
    required this.organizationId,
    required this.name,
    required this.type,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.adminId,
    required this.status,
    required this.subscriptionPlan,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationId': organizationId,
      'name': name,
      'type': type,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'adminId': adminId,
      'status': status,
      'subscriptionPlan': subscriptionPlan,
    };
  }

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
      organizationId: map['organizationId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      city: map['city'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      adminId: map['adminId'] ?? '',
      status: map['status'] ?? 'pending',
      subscriptionPlan: map['subscriptionPlan'] ?? 'Basic',
    );
  }
}
