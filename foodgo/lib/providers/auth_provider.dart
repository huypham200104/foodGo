import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodgo/models/user_model.dart';
import 'package:foodgo/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Handle auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      // Set interim user immediately so isLoggedIn becomes true without waiting
      _currentUser = UserModel.fromFirebaseUser(firebaseUser);
      notifyListeners();

      // Then merge with Firestore data when available
      try {
        final mergedUser = await UserService.getCurrentUser();
        if (mergedUser != null) {
          _currentUser = mergedUser;
          notifyListeners();
        }
      } catch (_) {
        // Keep interim user on failure
      }
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _currentUser = await UserService.getCurrentUser();
        notifyListeners();
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with email and password
  Future<UserModel?> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);
        
        // Create user profile
        final newUser = UserModel.fromFirebaseUser(credential.user!);
        await UserService.createUserProfile(newUser);
        
        _currentUser = newUser;
        notifyListeners();
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  /// Logout (alias cho signOut để tương thích)
  Future<void> logout() async {
    await signOut();
  }

  /// Update user profile
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await UserService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  /// Update user info in memory and optionally in database
  void updateUserInfo(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  /// Update user info and save to database
  Future<void> updateUserInfoAndSave(UserModel updatedUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      await UserService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Update user info and save error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      _currentUser = await UserService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Refresh user error: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();

      await UserService.deleteUserAccount();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }
}
