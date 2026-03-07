import '../models/organization.dart';
import '../models/app_user.dart';
import '../models/donation.dart';
import '../models/expense.dart';
import '../models/org_summary.dart';

class MockData {
  static final List<Organization> organizations = [
    Organization(
      organizationId: 'org1',
      name: 'Madarsa Darul Uloom',
      type: 'madarsa',
      city: 'Lucknow',
      address: 'Old City, Lucknow',
      latitude: 26.8467,
      longitude: 80.9462,
      adminId: 'admin1',
      status: 'approved',
      subscriptionPlan: 'Premium',
      createdAt: DateTime(2024, 1, 15),
    ),
    Organization(
      organizationId: 'org2',
      name: 'Masjid-e-Nabwi (Local)',
      type: 'mosque',
      city: 'Delhi',
      address: 'Jamia Nagar, Delhi',
      latitude: 28.5616,
      longitude: 77.2825,
      adminId: 'admin2',
      status: 'approved',
      subscriptionPlan: 'Basic',
      createdAt: DateTime(2024, 2, 10),
    ),
    Organization(
      organizationId: 'org3',
      name: 'Al-Huda International',
      type: 'madarsa',
      city: 'Mumbai',
      address: 'Andheri West, Mumbai',
      latitude: 19.1136,
      longitude: 72.8697,
      adminId: 'admin3',
      status: 'pending',
      subscriptionPlan: 'Basic',
      createdAt: DateTime(2024, 3, 5),
    ),
    Organization(
      organizationId: 'org4',
      name: 'Masjid Al-Noor',
      type: 'mosque',
      city: 'Lucknow',
      address: 'Hazratganj, Lucknow',
      latitude: 26.8553,
      longitude: 80.9425,
      adminId: 'admin4',
      status: 'approved',
      subscriptionPlan: 'Basic',
      createdAt: DateTime(2024, 3, 20),
    ),
  ];

  static final AppUser dummyDonor = AppUser(
    userId: 'donor1',
    name: 'Asad Mohammed',
    phone: '+919876543210',
    role: 'donor',
    createdAt: DateTime.now(),
  );

  static final AppUser dummyOrgAdmin = AppUser(
    userId: 'admin1',
    name: 'Maulana Zaid',
    phone: '+919999988888',
    role: 'org_admin',
    organizationId: 'org1',
    createdAt: DateTime.now(),
  );

  static final AppUser dummyCollector = AppUser(
    userId: 'coll1',
    name: 'Bilal Ahmed',
    phone: '+918888877777',
    role: 'collector',
    organizationId: 'org1',
    createdAt: DateTime.now(),
  );

  static final List<Donation> donations = [
    Donation(
      donationId: 'don1',
      organizationId: 'org1',
      organizationType: 'madarsa',
      donorId: 'donor1',
      donorName: 'Asad Mohammed',
      donationCategory: 'Zakat',
      amount: 5000.0,
      paymentMethod: 'UPI',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      receiptNumber: 'REC-001',
    ),
    Donation(
      donationId: 'don2',
      organizationId: 'org1',
      organizationType: 'madarsa',
      collectorId: 'coll1',
      donorName: 'Anonymous',
      donationCategory: 'Lillah',
      amount: 200.0,
      paymentMethod: 'Cash',
      isOffline: true,
      timestamp: DateTime.now(),
      receiptNumber: 'REC-002',
    ),
    Donation(
      donationId: 'don3',
      organizationId: 'org1',
      organizationType: 'madarsa',
      donorId: 'donor1',
      donorName: 'Asad Mohammed',
      donationCategory: 'Sadaqah',
      amount: 1000.0,
      paymentMethod: 'UPI',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
      receiptNumber: 'REC-003',
    ),
    Donation(
      donationId: 'don4',
      organizationId: 'org2',
      organizationType: 'mosque',
      donorId: 'donor1',
      donorName: 'Asad Mohammed',
      donationCategory: 'Lillah',
      amount: 500.0,
      paymentMethod: 'UPI',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      receiptNumber: 'REC-004',
    ),
  ];

  static final List<Expense> expenses = [
    Expense(
      expenseId: 'exp1',
      organizationId: 'org1',
      title: 'Electricity Bill',
      category: 'Utilities',
      amount: 1500.0,
      date: DateTime.now().subtract(const Duration(days: 5)),
      addedBy: 'admin1',
    ),
    Expense(
      expenseId: 'exp2',
      organizationId: 'org1',
      title: 'Teacher Salary',
      category: 'Salaries',
      amount: 15000.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      addedBy: 'admin1',
    ),
  ];

  static final OrgSummary summary = OrgSummary(
    organizationId: 'org1',
    totalDonations: 6200.0,
    totalExpenses: 16500.0,
    balance: 3700.0,
    lastUpdated: DateTime.now(),
  );

  // Category-level totals for reports
  static Map<String, double> getCategoryTotals(String orgId) {
    final orgDonations = donations.where((d) => d.organizationId == orgId);
    final Map<String, double> totals = {};
    for (final d in orgDonations) {
      totals[d.donationCategory] = (totals[d.donationCategory] ?? 0) + d.amount;
    }
    return totals;
  }
}
