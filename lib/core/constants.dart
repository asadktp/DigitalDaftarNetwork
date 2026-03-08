import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Digital Daftar Network';

  // Roles
  static const String roleDonor = 'donor';
  static const String roleOrgAdmin = 'org_admin';
  static const String roleCollector = 'collector';
  static const String roleSuperAdmin = 'super_admin';

  // Org Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Organization Types
  static const String orgTypeMadarsa = 'madarsa';
  static const String orgTypeMosque = 'mosque';

  // Donation Categories
  static const String catZakat = 'Zakat';
  static const String catSadaqah = 'Sadaqah';
  static const String catLillah = 'Lillah';
  static const String catImdad = 'Imdad';
  static const String catGeneral = 'General Donation';

  // Donation categories per org type
  static const List<String> madarsaCategories = [
    catZakat,
    catSadaqah,
    catLillah,
    catImdad,
    catGeneral,
  ];
  static const List<String> mosqueDonationCategories = [
    catLillah,
    catImdad,
    catGeneral,
  ];

  static List<String> getCategoriesForOrgType(String orgType) {
    return orgType == orgTypeMadarsa
        ? madarsaCategories
        : mosqueDonationCategories;
  }

  // Subscription Plans
  static const String planBasic = 'Basic';
  static const String planPremium = 'Premium';
  static const String planEnterprise = 'Enterprise';

  // Colors (Premium Emerald & Gold)
  static const Color primaryGreen = Color(0xFF006837);
  static const Color secondaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Mock Data Flag
  static const bool useDummyData = false;
}
