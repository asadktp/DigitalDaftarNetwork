import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

import '../core/constants.dart';
import '../repositories/mock_auth_repository.dart';
import '../repositories/org_repository.dart';
import '../repositories/mock_org_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AppConstants.useDummyData
      ? MockAuthRepository()
      : AuthRepository();

  AppUser? _user;
  bool _isLoading = false;

  AppUser? get user => _user;
  User? get currentFirebaseUser => FirebaseAuth.instance.currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _repository.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _isLoading = true;
      notifyListeners();
      _user = await _repository.getUserData(firebaseUser.uid);
      if (_user?.role == AppConstants.roleOrgAdmin &&
          _user?.organizationId != null) {
        final orgRepo = AppConstants.useDummyData
            ? MockOrgRepository()
            : OrgRepository();
        final org = await orgRepo.getOrganization(_user!.organizationId!);
        if (org?.status == 'pending') {
          // We can use a property to signal UI to redirect
          _isPendingApproval = true;
        }
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  bool _isPendingApproval = false;
  bool get isPendingApproval => _isPendingApproval;

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<void> updateUserData(AppUser userData) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.saveUserData(userData);
      _user = userData;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
