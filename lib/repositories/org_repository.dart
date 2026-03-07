import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization.dart';
import '../models/org_summary.dart';
import 'package:geolocator/geolocator.dart';

class OrgRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<List<Organization>> getOrganizations({
    String? city,
    String? type,
  }) async {
    Query query = _db
        .collection('organizations')
        .where('status', isEqualTo: 'approved');

    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Organization.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> createOrganization(Organization org) async {
    await _db
        .collection('organizations')
        .doc(org.organizationId)
        .set(org.toMap());
  }

  // Location based search logic
  Future<List<Organization>> getNearbyOrganizations(
    Position position,
    double radiusInKm,
  ) async {
    final snapshot = await _db
        .collection('organizations')
        .where('status', isEqualTo: 'approved')
        .get();

    List<Organization> orgs = snapshot.docs
        .map((doc) => Organization.fromMap(doc.data()))
        .toList();

    return orgs.where((org) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        org.latitude,
        org.longitude,
      );
      return (distance / 1000) <= radiusInKm;
    }).toList();
  }

  Future<Organization?> getOrganization(String orgId) async {
    final doc = await _db.collection('organizations').doc(orgId).get();
    if (doc.exists) {
      return Organization.fromMap(doc.data()!);
    }
    return null;
  }

  Future<OrgSummary?> getSummary(String orgId) async {
    final doc = await _db.collection('org_summaries').doc(orgId).get();
    if (doc.exists) {
      return OrgSummary.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateOrganizationStatus(String orgId, String status) async {
    await _db.collection('organizations').doc(orgId).update({'status': status});
  }
}
