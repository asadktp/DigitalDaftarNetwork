import '../models/organization.dart';

enum AppFeature {
  basicReporting,
  premiumAnalytics,
  collectorManagement,
  nationalDirectory,
}

class SubscriptionService {
  static bool isFeatureEnabled(Organization org, AppFeature feature) {
    final plan = org.subscriptionPlan.toLowerCase();

    switch (feature) {
      case AppFeature.basicReporting:
        return true; // Available to all plans
      case AppFeature.premiumAnalytics:
        return plan == 'premium' || plan == 'enterprise';
      case AppFeature.collectorManagement:
        return plan == 'premium' || plan == 'enterprise';
      case AppFeature.nationalDirectory:
        return plan == 'enterprise';
    }
  }

  static String getPlanGatingMessage(AppFeature feature) {
    switch (feature) {
      case AppFeature.premiumAnalytics:
        return 'Premium Analytics is available on Premium & Enterprise plans.';
      case AppFeature.collectorManagement:
        return 'Collector Management is available on Premium & Enterprise plans.';
      case AppFeature.nationalDirectory:
        return 'National Directory access is restricted to Enterprise plan.';
      default:
        return 'This feature is not available on your current plan.';
    }
  }
}
