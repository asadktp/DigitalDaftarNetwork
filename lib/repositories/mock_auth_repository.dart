import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../core/mock_data.dart';
import 'auth_repository.dart';

class MockAuthRepository extends AuthRepository {
  @override
  Stream<User?> get authStateChanges => Stream.value(null); // Keep as logged out for UI test

  @override
  Future<AppUser?> getUserData(String uid) async {
    return MockData.dummyDonor;
  }

  @override
  Future<void> saveUserData(AppUser user) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onFailed,
  }) async {
    onCodeSent("mock_verification_id");
  }

  @override
  Future<UserCredential> signInWithCode(
    String verificationId,
    String smsCode,
  ) async {
    // In actual app, we'd sign in. Here just return a fake credential if needed.
    throw UnimplementedError("Mock Sign In not fully implemented");
  }
}
