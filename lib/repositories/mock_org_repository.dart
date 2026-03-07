import 'package:geolocator/geolocator.dart';
import '../models/organization.dart';
import '../models/org_summary.dart';
import '../core/mock_data.dart';
import 'org_repository.dart';

class MockOrgRepository extends OrgRepository {
  @override
  Future<List<Organization>> getOrganizations({
    String? city,
    String? type,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    return MockData.organizations;
  }

  @override
  Future<OrgSummary?> getSummary(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.summary;
  }

  @override
  Future<Organization?> getOrganization(String orgId) async {
    try {
      return MockData.organizations.firstWhere(
        (o) => o.organizationId == orgId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createOrganization(Organization org) async {
    MockData.organizations.add(org);
  }

  @override
  Future<void> updateOrganizationStatus(String orgId, String status) async {
    final idx = MockData.organizations.indexWhere(
      (o) => o.organizationId == orgId,
    );
    if (idx != -1) {
      final org = MockData.organizations[idx];
      MockData.organizations[idx] = Organization(
        organizationId: org.organizationId,
        name: org.name,
        type: org.type,
        city: org.city,
        address: org.address,
        latitude: org.latitude,
        longitude: org.longitude,
        adminId: org.adminId,
        status: status,
        subscriptionPlan: org.subscriptionPlan,
      );
    }
  }

  @override
  Future<List<Organization>> getNearbyOrganizations(
    Position position,
    double radiusInKm,
  ) async {
    return MockData.organizations.where((o) => o.status == 'approved').toList();
  }
}
