import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation.dart';

class DonationRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<void> processDonation(Donation donation) async {
    await _db
        .collection('donations')
        .doc(donation.donationId)
        .set(donation.toMap());

    final summaryRef = _db
        .collection('org_summaries')
        .doc(donation.organizationId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(summaryRef);
      if (!snapshot.exists) {
        transaction.set(summaryRef, {
          'totalDonations': donation.amount,
          'totalExpenses': 0.0,
          'balance': donation.amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        double currentTotal =
            (snapshot.data()?['totalDonations'] as num?)?.toDouble() ?? 0.0;
        double currentBalance =
            (snapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

        transaction.update(summaryRef, {
          'totalDonations': currentTotal + donation.amount,
          'balance': currentBalance + donation.amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<List<Donation>> getDonationHistory(String orgId) async {
    final snapshot = await _db
        .collection('donations')
        .where('organizationId', isEqualTo: orgId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Donation.fromMap(doc.data())).toList();
  }
}
