import 'package:flutter/material.dart';
import '../../core/services/farm_context.dart';
import '../../core/services/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  final SecureStorageService secureStorage;
  final FarmContext? farmContext;
  final UserRepository? userRepository;

  AuthProvider({
    required this.repository,
    required this.secureStorage,
    this.farmContext,
    this.userRepository,
  });

  AuthStatus status = AuthStatus.unknown;
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  // Profile / change-password state (kept on AuthProvider since it already
  // owns `currentUser`).
  bool isProfileSaving = false;
  String? profileErrorMessage;
  bool isChangingPassword = false;
  String? passwordErrorMessage;

  Future<bool> updateProfile({required String name, required String email}) async {
    final repo = userRepository;
    if (repo == null) return false;
    isProfileSaving = true;
    profileErrorMessage = null;
    notifyListeners();
    try {
      currentUser = await repo.updateProfile(name: name, email: email);
      isProfileSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      profileErrorMessage = _cleanMessage(e);
      isProfileSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final repo = userRepository;
    if (repo == null) return false;
    isChangingPassword = true;
    passwordErrorMessage = null;
    notifyListeners();
    try {
      await repo.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      isChangingPassword = false;
      notifyListeners();
      return true;
    } catch (e) {
      passwordErrorMessage = _cleanMessage(e);
      isChangingPassword = false;
      notifyListeners();
      return false;
    }
  }

  String _cleanMessage(Object e) =>
      e.toString().replaceFirst('ApiException: ', '').replaceFirst('Exception: ', '');

  Future<void> bootstrap() async {
    final token = await secureStorage.readToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
    } else {
      await farmContext?.loadPersisted();
      status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await repository.login(username, password);
      currentUser = result.user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '').replaceFirst('Exception: ', '');
      isLoading = false;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      await repository.requestPasswordReset(email);
      return true;
    } catch (_) {
      return false;
    }
  }
}
