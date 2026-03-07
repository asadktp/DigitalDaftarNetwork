import '../models/donation.dart';
import 'donation_repository.dart';

class MockDonationRepository extends DonationRepository {
  final List<Donation> _donations = [];

  @override
  Future<void> processDonation(Donation donation) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _donations.add(donation);
  }

  @override
  Future<List<Donation>> getDonationHistory(String orgId) async {
    return _donations.where((d) => d.organizationId == orgId).toList();
  }
}
