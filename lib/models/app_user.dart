class AppUser {
  final String userId;
  final String name;
  final String phone;
  final String role;
  String? organizationId;
  final DateTime createdAt;

  AppUser({
    required this.userId,
    required this.name,
    required this.phone,
    required this.role,
    this.organizationId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'role': role,
      'organizationId': organizationId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'donor',
      organizationId: map['organizationId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
