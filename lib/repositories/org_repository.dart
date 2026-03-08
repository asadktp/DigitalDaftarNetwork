import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization.dart';
import '../models/org_summary.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class OrgRepository {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Mock data for fallback
  final List<Organization> _mockOrgs = [
    Organization(
      organizationId: 'org1',
      name: 'Darul Uloom (Demo)',
      type: 'madarsa',
      city: 'Lucknow',
      address: 'Address 1',
      latitude: 0,
      longitude: 0,
      adminId: 'admin1',
      status: 'approved',
      subscriptionPlan: 'Basic',
      createdAt: DateTime.now(),
    ),
    Organization(
      organizationId: 'org2',
      name: 'Masjid-e-Nabwi (Demo)',
      type: 'mosque',
      city: 'Mumbai',
      address: 'Address 2',
      latitude: 0,
      longitude: 0,
      adminId: 'admin2',
      status: 'approved',
      subscriptionPlan: 'Basic',
      createdAt: DateTime.now(),
    ),
  ];

  Future<List<Organization>> getOrganizations({
    String? city,
    String? type,
  }) async {
    if (_db == null) {
      debugPrint('Firestore unavailable, returning mock organizations.');
      return _mockOrgs.where((org) {
        bool cityMatch = (city == null || city.isEmpty || org.city == city);
        bool typeMatch = (type == null || type.isEmpty || org.type == type);
        return cityMatch && typeMatch;
      }).toList();
    }
    try {
      Query query = _db!
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
          .map(
              (doc) => Organization.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Firestore Error in getOrganizations, using mock: $e');
      return _mockOrgs.where((org) {
        bool cityMatch = (city == null || city.isEmpty || org.city == city);
        bool typeMatch = (type == null || type.isEmpty || org.type == type);
        return cityMatch && typeMatch;
      }).toList();
    }
  }

  Future<void> createOrganization(Organization org) async {
    if (_db == null) {
      debugPrint('Firestore unavailable, cannot create organization.');
      return;
    }
    await _db!
        .collection('organizations')
        .doc(org.organizationId)
        .set(org.toMap());
  }

  // Location based search logic
  Future<List<Organization>> getNearbyOrganizations(
    Position position,
    double radiusInKm,
  ) async {
    if (_db == null) {
      debugPrint('Firestore unavailable, returning mock nearby organizations.');
      return _mockOrgs.where((org) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          org.latitude,
          org.longitude,
        );
        return (distance / 1000) <= radiusInKm;
      }).toList();
    }
    try {
      final snapshot = await _db!
          .collection('organizations')
          .where('status', isEqualTo: 'approved')
          .get();

      List<Organization> orgs =
          snapshot.docs.map((doc) => Organization.fromMap(doc.data())).toList();

      return orgs.where((org) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          org.latitude,
          org.longitude,
        );
        return (distance / 1000) <= radiusInKm;
      }).toList();
    } catch (e) {
      debugPrint('Firestore Error in getNearbyOrganizations, using mock: $e');
      return _mockOrgs.where((org) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          org.latitude,
          org.longitude,
        );
        return (distance / 1000) <= radiusInKm;
      }).toList();
    }
  }

  Future<Organization?> getOrganization(String orgId) async {
    if (_db == null) {
      debugPrint(
          'Firestore unavailable, returning mock organization for $orgId.');
      return _mockOrgs.firstWhere((o) => o.organizationId == orgId, orElse: () {
        debugPrint(
            'Mock organization with ID $orgId not found, returning first mock.');
        return _mockOrgs.first;
      });
    }
    try {
      final doc = await _db!.collection('organizations').doc(orgId).get();
      if (doc.exists) {
        return Organization.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Firestore Error in getOrganization, returning mock: $e');
      return _mockOrgs.firstWhere((o) => o.organizationId == orgId, orElse: () {
        debugPrint(
            'Mock organization with ID $orgId not found, returning first mock.');
        return _mockOrgs.first;
      });
    }
    return null;
  }

  Future<OrgSummary?> getSummary(String orgId) async {
    if (_db == null) {
      debugPrint('Firestore unavailable, returning mock summary for $orgId.');
      return OrgSummary(
        organizationId: orgId,
        totalDonations: 150000,
        totalExpenses: 80000,
        balance: 70000,
        lastUpdated: DateTime.now(),
      );
    }
    try {
      final doc = await _db!.collection('org_summaries').doc(orgId).get();
      if (doc.exists) {
        return OrgSummary.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Firestore Error in getSummary, returning null: $e');
      return null;
    }
    return null;
  }

  Future<void> updateOrganizationStatus(String orgId, String status) async {}
}
