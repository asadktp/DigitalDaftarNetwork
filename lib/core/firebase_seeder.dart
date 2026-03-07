import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// FirebaseSeeder — Digital Daftar Network
/// Sirf development/testing ke liye. Production mein use mat karna!
class FirebaseSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collection Names ───────────────────────────────────────────────────────
  static const String _users = 'users';
  static const String _organizations = 'organizations';
  static const String _donations = 'donations';
  static const String _expenses = 'expenses';
  static const String _collectors = 'collectors';
  static const String _subscriptions = 'subscriptions';
  static const String _orgSummaries = 'org_summaries';

  // ─── Org IDs (test ke liye) ─────────────────────────────────────────────────
  static const String _madarsaId = 'org_madarsa_001';
  static const String _mosqueId = 'org_mosque_001';

  // ─── Timestamps ─────────────────────────────────────────────────────────────
  static Timestamp get _now => Timestamp.now();
  static Timestamp get _thirtyDaysAgo =>
      Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30)));
  static Timestamp get _oneYearLater =>
      Timestamp.fromDate(DateTime.now().add(const Duration(days: 365)));

  // ════════════════════════════════════════════════════════════════════════════
  //  SEED ALL
  // ════════════════════════════════════════════════════════════════════════════

  /// Saari collections ko ek saath seed karo
  static Future<void> seedAll() async {
    debugPrint(
      '🚀 [Seeder] Digital Daftar Network — Full DB seed shuru ho raha hai...',
    );
    await seedUsers();
    await seedOrganizations();
    await seedCollectors();
    await seedSubscriptions();
    await seedDonations();
    await seedExpenses();
    await seedOrgSummaries();
    debugPrint('🎉 [Seeder] Saari collections successfully seed ho gayi!');
    _printSummary();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  1. USERS
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> seedUsers() async {
    debugPrint('\n📁 [Seeder] users collection seed ho raha hai...');

    final List<Map<String, dynamic>> users = [
      // Super Admin
      {
        'userId': 'test_super_admin_001',
        'name': 'Abdullah Khan',
        'phone': '+919876543210',
        'role': 'super_admin',
        'organizationId': null,
        'createdAt': _now,
        'status': 'active',
      },
      // Org Admins
      {
        'userId': 'test_org_admin_001',
        'name': 'Maulana Rashid Ahmed',
        'phone': '+919865432109',
        'role': 'org_admin',
        'organizationId': _madarsaId,
        'createdAt': _now,
        'status': 'active',
      },
      {
        'userId': 'test_org_admin_002',
        'name': 'Hafiz Ibrahim Siddiqui',
        'phone': '+919854321098',
        'role': 'org_admin',
        'organizationId': _mosqueId,
        'createdAt': _now,
        'status': 'active',
      },
      // Collectors
      {
        'userId': 'test_collector_user_001',
        'name': 'Usman Ali',
        'phone': '+919843210987',
        'role': 'collector',
        'organizationId': _madarsaId,
        'createdAt': _now,
        'status': 'active',
      },
      {
        'userId': 'test_collector_user_002',
        'name': 'Salman Qureshi',
        'phone': '+919832109876',
        'role': 'collector',
        'organizationId': _mosqueId,
        'createdAt': _now,
        'status': 'active',
      },
      // Donors
      {
        'userId': 'test_donor_001',
        'name': 'Ahmed Hassan',
        'phone': '+919821098765',
        'role': 'donor',
        'organizationId': null,
        'createdAt': _now,
        'status': 'active',
      },
      {
        'userId': 'test_donor_002',
        'name': 'Farida Begum',
        'phone': '+919810987654',
        'role': 'donor',
        'organizationId': null,
        'createdAt': _now,
        'status': 'active',
      },
      {
        'userId': 'test_donor_003',
        'name': 'Yusuf Merchant',
        'phone': '+919899887766',
        'role': 'donor',
        'organizationId': null,
        'createdAt': _now,
        'status': 'active',
      },
      // Pending
      {
        'userId': 'test_pending_001',
        'name': 'Zaid Ansari',
        'phone': '+919809876543',
        'role': 'org_admin',
        'organizationId': 'org_pending_001',
        'createdAt': _now,
        'status': 'active',
      },
      // Blocked
      {
        'userId': 'test_blocked_001',
        'name': 'Imran Shaikh (Blocked)',
        'phone': '+919700000000',
        'role': 'donor',
        'organizationId': null,
        'createdAt': _now,
        'status': 'blocked',
      },
    ];

    await _batchWrite(_users, users, (u) => u['userId']);
    debugPrint('   ✅ ${users.length} users created');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  2. ORGANIZATIONS
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> seedOrganizations() async {
    debugPrint('\n📁 [Seeder] organizations collection seed ho raha hai...');

    final List<Map<String, dynamic>> orgs = [
      // Madarsa
      {
        'organizationId': _madarsaId,
        'name': 'Darul Uloom Rashidiya',
        'type': 'madarsa',
        'city': 'Mumbai',
        'address': 'Near Jama Masjid, Bhendi Bazaar, Mumbai - 400003',
        'latitude': 18.9543,
        'longitude': 72.8351,
        'adminId': 'test_org_admin_001',
        'status': 'approved',
        'subscriptionPlan': 'premium',
        'createdAt': _thirtyDaysAgo,
      },
      // Mosque
      {
        'organizationId': _mosqueId,
        'name': 'Masjid-e-Ibrahim',
        'type': 'mosque',
        'city': 'Delhi',
        'address': 'Okhla Phase 1, New Delhi - 110020',
        'latitude': 28.5510,
        'longitude': 77.2700,
        'adminId': 'test_org_admin_002',
        'status': 'approved',
        'subscriptionPlan': 'basic',
        'createdAt': _thirtyDaysAgo,
      },
      // Pending org
      {
        'organizationId': 'org_pending_001',
        'name': 'Noor ul Islam Madarsa',
        'type': 'madarsa',
        'city': 'Hyderabad',
        'address': 'Old City, Hyderabad - 500002',
        'latitude': 17.3616,
        'longitude': 78.4737,
        'adminId': 'test_pending_001',
        'status': 'pending',
        'subscriptionPlan': 'basic',
        'createdAt': _now,
      },
    ];

    await _batchWrite(_organizations, orgs, (o) => o['organizationId']);
    debugPrint('   ✅ ${orgs.length} organizations created');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  3. COLLECTORS
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> seedCollectors() async {
    debugPrint('\n📁 [Seeder] collectors collection seed ho raha hai...');

    final List<Map<String, dynamic>> collectors = [
      {
        'collectorId': 'test_collector_001',
        'organizationId': _madarsaId,
        'name': 'Usman Ali',
        'phone': '+919843210987',
        'status': 'active',
        'createdAt': _thirtyDaysAgo,
      },
      {
        'collectorId': 'test_collector_002',
        'organizationId': _madarsaId,
        'name': 'Bilal Shaikh',
        'phone': '+919777888999',
        'status': 'active',
        'createdAt': _thirtyDaysAgo,
      },
      {
        'collectorId': 'test_collector_003',
        'organizationId': _mosqueId,
        'name': 'Salman Qureshi',
        'phone': '+919832109876',
        'status': 'active',
        'createdAt': _thirtyDaysAgo,
      },
      {
        'collectorId': 'test_collector_004',
        'organizationId': _mosqueId,
        'name': 'Farhan Malik (Inactive)',
        'phone': '+919600000001',
        'status': 'inactive',
        'createdAt': _thirtyDaysAgo,
      },
    ];

    await _batchWrite(_collectors, collectors, (c) => c['collectorId']);
    debugPrint('   ✅ ${collectors.length} collectors created');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  4. SUBSCRIPTIONS
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> seedSubscriptions() async {
    debugPrint('\n📁 [Seeder] subscriptions collection seed ho raha hai...');

    final List<Map<String, dynamic>> subs = [
      {
        'organizationId': _madarsaId,
        'plan': 'premium',
        'startDate': _thirtyDaysAgo,
        'expiryDate': _oneYearLater,
        'status': 'active',
      },
      {
        'organizationId': _mosqueId,
        'plan': 'basic',
        'startDate': _thirtyDaysAgo,
        'expiryDate': _oneYearLater,
        'status': 'active',
      },
    ];

    // subscriptions mein organizationId hi document ID hai
    await _batchWrite(_subscriptions, subs, (s) => s['organizationId']);
    debugPrint('   ✅ ${subs.length} subscriptions created');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  5. DONATIONS
  //  RULE: Mosque — sirf Lillah, Imdad, General
  //        Madarsa — Zakat, Sadaqah, Lillah, Imdad, General
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> seedDonations() async {
    debugPrint('\n📁 [Seeder] donations collection seed ho raha hai...');

    final List<Map<String, dynamic>> donations = [
      // ── Madarsa Donations ──────────────────────────────────────────────────
      {
        'donationId': 'don_001',
        'organizationId': _madarsaId,
        'organizationType': 'madarsa',
        'donorId': 'test_donor_001',
        'collectorId': 'test_collector_001',
        'donationCategory': 'Zakat',
        'amount': 5000.0,
        'paymentMethod': 'cash',
        'receiptNumber': 'DDN-M-2026-0001',
        'createdAt': _thirtyDaysAgo,
      },
      {
        'donationId': 'don_002',
        'organizationId': _madarsaId,
        'organizationType': 'madarsa',
        'donorId': 'test_donor_002',
        'collectorId': 'test_collector_001',
        'donationCategory': 'Sadaqah',
        'amount': 2000.0,
        'paymentMethod': 'upi',
        'receiptNumber': 'DDN-M-2026-0002',
        'createdAt': _thirtyDaysAgo,
      },
      {
        'donationId': 'don_003',
        'organizationId': _madarsaId,
        'organizationType': 'madarsa',
        'donorId': 'test_donor_003',
        'collectorId': null,
        'donationCategory': 'Lillah',
        'amount': 1500.0,
        'paymentMethod': 'bank',
        'receiptNumber': 'DDN-M-2026-0003',
        'createdAt': _now,
      },
      {
        'donationId': 'don_004',
        'organizationId': _madarsaId,
        'organizationType': 'madarsa',
        'donorId': 'test_donor_001',
        'collectorId': 'test_collector_002',
        'donationCategory': 'Imdad',
        'amount': 3000.0,
        'paymentMethod': 'cash',
        'receiptNumber': 'DDN-M-2026-0004',
        'createdAt': _now,
      },
      // ── Mosque Donations (NO Zakat/Sadaqah) ───────────────────────────────
      {
        'donationId': 'don_005',
        'organizationId': _mosqueId,
        'organizationType': 'mosque',
        'donorId': 'test_donor_001',
        'collectorId': 'test_collector_003',
        'donationCategory': 'Lillah',
        'amount': 1000.0,
        'paymentMethod': 'cash',
        'receiptNumber': 'DDN-MS-2026-0001',
        'createdAt': _thirtyDaysAgo,
      },
      {
        'donationId': 'don_006',
        'organizationId': _mosqueId,
        'organizationType': 'mosque',
        'donorId': 'test_donor_002',
        'collectorId': null,
        'donationCategory': 'General Donation',
        'amount': 500.0,
        'paymentMethod': 'upi',
        'receiptNumber': 'DDN-MS-2026-0002',
        'createdAt': _now,
      },
      {
        'donationId': 'don_007',
        'organizationId': _mosqueId,
        'organizationType': 'mosque',
        'donorId': 'test_donor_003',
        'collectorId': 'test_collector_003',
        'donationCategory': 'Imdad',
        'amount': 2500.0,
        'paymentMethod': 'bank',
        'receiptNumber': 'DDN-MS-2026-0003',
        'createdAt': _now,
      },
    ];

    await _batchWrite(_donations, donations, (d) => d['donationId']);
    debugPrint('   ✅ ${donations.length} donations created');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  6. EXPENSES
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> seedExpenses() async {
    debugPrint('\n📁 [Seeder] expenses collection seed ho raha hai...');

    final List<Map<String, dynamic>> expenses = [
      // Madarsa
      {
        'expenseId': 'exp_001',
        'organizationId': _madarsaId,
        'title': 'Teachers Salary — February',
        'category': 'Salary',
        'amount': 45000.0,
        'description': '5 teachers ka February month ka salary',
        'createdAt': _thirtyDaysAgo,
        'addedBy': 'test_org_admin_001',
      },
      {
        'expenseId': 'exp_002',
        'organizationId': _madarsaId,
        'title': 'Books & Stationery',
        'category': 'Education',
        'amount': 8000.0,
        'description': 'New semester ke liye books kharidi',
        'createdAt': _thirtyDaysAgo,
        'addedBy': 'test_org_admin_001',
      },
      {
        'expenseId': 'exp_003',
        'organizationId': _madarsaId,
        'title': 'Collector Travel Expense — Usman',
        'category': 'Travel',
        'amount': 1200.0,
        'description': 'Auto aur rickshaw ka kiraya — donation collection',
        'createdAt': _now,
        'addedBy': 'test_collector_user_001',
      },
      // Mosque
      {
        'expenseId': 'exp_004',
        'organizationId': _mosqueId,
        'title': 'Electricity Bill — February',
        'category': 'Utilities',
        'amount': 3500.0,
        'description': 'February ka bijli ka bill',
        'createdAt': _thirtyDaysAgo,
        'addedBy': 'test_org_admin_002',
      },
      {
        'expenseId': 'exp_005',
        'organizationId': _mosqueId,
        'title': 'Cleaning & Maintenance',
        'category': 'Maintenance',
        'amount': 2000.0,
        'description': 'Masjid saaf karne ka kharcha',
        'createdAt': _now,
        'addedBy': 'test_org_admin_002',
      },
    ];

    await _batchWrite(_expenses, expenses, (e) => e['expenseId']);
    debugPrint('   ✅ ${expenses.length} expenses created');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  7. ORG_SUMMARIES
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> seedOrgSummaries() async {
    debugPrint('\n📁 [Seeder] org_summaries collection seed ho raha hai...');

    final List<Map<String, dynamic>> summaries = [
      {
        'organizationId': _madarsaId,
        // Donations: 5000+2000+1500+3000 = 11500
        'totalDonations': 11500.0,
        // Expenses: 45000+8000+1200 = 54200
        'totalExpenses': 54200.0,
        'balance': 11500.0 - 54200.0, // -42700
        'lastUpdated': _now,
      },
      {
        'organizationId': _mosqueId,
        // Donations: 1000+500+2500 = 4000
        'totalDonations': 4000.0,
        // Expenses: 3500+2000 = 5500
        'totalExpenses': 5500.0,
        'balance': 4000.0 - 5500.0, // -1500
        'lastUpdated': _now,
      },
    ];

    await _batchWrite(_orgSummaries, summaries, (s) => s['organizationId']);
    debugPrint('   ✅ ${summaries.length} org_summaries created');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  CLEAR (Cleanup — sirf test_ prefixed docs delete karta hai)
  // ════════════════════════════════════════════════════════════════════════════

  /// Sirf 'test_' se shuru hone wale user documents delete karo
  static Future<void> clearTestUsers() async {
    debugPrint('🗑️ [Seeder] Test users delete ho rahe hain...');
    final snap = await _db.collection(_users).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      if (doc.id.startsWith('test_')) batch.delete(doc.reference);
    }
    await batch.commit();
    debugPrint('✅ Test users delete ho gaye!');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> _batchWrite(
    String collection,
    List<Map<String, dynamic>> docs,
    String Function(Map<String, dynamic>) docId,
  ) async {
    // Firestore batch limit 500 hai — chunked batches
    const chunkSize = 400;
    for (int i = 0; i < docs.length; i += chunkSize) {
      final chunk = docs.sublist(i, (i + chunkSize).clamp(0, docs.length));
      final batch = _db.batch();
      for (final doc in chunk) {
        final ref = _db.collection(collection).doc(docId(doc));
        batch.set(ref, doc, SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  static void _printSummary() {
    debugPrint('\n════════════════════════════════════════');
    debugPrint('  📊 SEED SUMMARY — Digital Daftar Network');
    debugPrint('════════════════════════════════════════');
    debugPrint('  ✅ users          — 10 documents');
    debugPrint('  ✅ organizations  —  3 documents');
    debugPrint('  ✅ collectors     —  4 documents');
    debugPrint('  ✅ subscriptions  —  2 documents');
    debugPrint('  ✅ donations      —  7 documents');
    debugPrint('  ✅ expenses       —  5 documents');
    debugPrint('  ✅ org_summaries  —  2 documents');
    debugPrint('════════════════════════════════════════');
    debugPrint('  ⚠️  Ab constants.dart mein runSeederOnStart = false karo!');
    debugPrint('════════════════════════════════════════\n');
  }
}
