import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation.dart';
import 'package:flutter/foundation.dart';

class DonationRepository {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Mock data for fallback
  final List<Donation> _mockDonations = [
    Donation(
      donationId: 'd1',
      organizationId: 'org1',
      amount: 1000,
      donationCategory: 'Zakat',
      timestamp: DateTime.now(),
      isOffline: true,
      receiptNumber: 'REC-001',
    ),
    Donation(
      donationId: 'd2',
      organizationId: 'org1',
      amount: 500,
      donationCategory: 'Sadaqah',
      timestamp: DateTime.now(),
      isOffline: true,
      receiptNumber: 'REC-002',
    ),
  ];

  Future<void> processDonation(Donation donation) async {
    if (_db == null) return;
    await _db!
        .collection('donations')
        .doc(donation.donationId)
        .set(donation.toMap());
  }

  Future<List<Donation>> getDonationHistory(String orgId) async {
    if (_db == null) {
      debugPrint('Firestore unavailable, returning mock donation history.');
      return _mockDonations;
    }
    try {
      final snapshot = await _db!
          .collection('donations')
          .where('organizationId', isEqualTo: orgId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Donation.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Firestore Error in getDonationHistory: $e');
      return _mockDonations;
    }
  }
}
