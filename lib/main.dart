import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'core/firebase_seeder.dart';

// Auth screens
import 'screens/auth/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/auth/pending_approval_screen.dart';

// Donor screens
import 'screens/donor/donor_dashboard_screen.dart';
import 'screens/donor/org_directory_screen.dart';
import 'screens/donor/donation_flow_screen.dart';
import 'screens/donor/donation_history_screen.dart';

// Admin screens
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/collector_management_screen.dart';
import 'screens/admin/reports_screen.dart';

// Collector screens
import 'screens/collector/collector_dashboard_screen.dart';
import 'screens/collector/collector_intake_screen.dart';
import 'screens/collector/daily_report_screen.dart';

// Super Admin
import 'screens/super_admin/super_admin_dashboard.dart';

// Shared
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!AppConstants.useDummyData) {
    try {
      await Firebase.initializeApp();
      // 🌱 DEV ONLY: Firestore mein test data seed karo
      // Seed ho jane ke baad runSeederOnStart = false karo!
      if (AppConstants.runSeederOnStart) {
        await FirebaseSeeder.seedAll();
      }
    } catch (e) {
      // Web par Firebase initialize nahi ho pa raha — dummy mode pe fallback
      debugPrint('⚠️ Firebase init failed: $e');
      debugPrint(
        '💡 Tip: Android/iOS device use karo Firebase testing ke liye',
      );
    }
  }
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: const DigitalDaftarApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ── Auth Flow ─────────────────────────────────────────────
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) =>
          RegistrationScreen(initialRole: state.uri.queryParameters['role']),
    ),
    GoRoute(
      path: '/pending',
      builder: (context, state) => const PendingApprovalScreen(),
    ),

    // ── Donor Flow ─────────────────────────────────────────────
    GoRoute(
        path: '/donor',
        builder: (context, state) => const DonorDashboardScreen()),
    GoRoute(
        path: '/orgs', builder: (context, state) => const OrgDirectoryScreen()),
    GoRoute(
        path: '/donate',
        builder: (context, state) => const DonationFlowScreen()),
    GoRoute(
      path: '/donor/history',
      builder: (context, state) => const DonationHistoryScreen(),
    ),

    // ── Admin Flow ─────────────────────────────────────────────
    GoRoute(
      path: '/admin/:orgId',
      builder: (context, state) =>
          AdminDashboard(orgId: state.pathParameters['orgId']!),
      routes: [
        GoRoute(
          path: 'collectors',
          builder: (context, state) =>
              CollectorManagementScreen(orgId: state.pathParameters['orgId']!),
        ),
        GoRoute(
          path: 'reports',
          builder: (context, state) =>
              ReportsScreen(orgId: state.pathParameters['orgId']!),
        ),
      ],
    ),

    // ── Collector Flow ─────────────────────────────────────────
    GoRoute(
      path: '/collector/:orgId',
      builder: (context, state) =>
          CollectorDashboardScreen(orgId: state.pathParameters['orgId']!),
    ),
    GoRoute(
      path: '/collector/intake/:orgId',
      builder: (context, state) =>
          CollectorIntakeScreen(orgId: state.pathParameters['orgId']!),
    ),
    GoRoute(
      path: '/collector/report/:orgId',
      builder: (context, state) =>
          DailyReportScreen(orgId: state.pathParameters['orgId']!),
    ),

    // ── Super Admin ─────────────────────────────────────────────
    GoRoute(
      path: '/super-admin',
      builder: (context, state) => const SuperAdminDashboard(),
    ),

    // ── Shared ─────────────────────────────────────────────────
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsScreen()),

    // ── Fallback ───────────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
  ],
);

class DigitalDaftarApp extends StatelessWidget {
  const DigitalDaftarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
