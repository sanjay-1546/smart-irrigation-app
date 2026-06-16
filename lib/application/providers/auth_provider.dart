import 'package:flutter/material.dart';
import '../../core/services/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  final SecureStorageService secureStorage;

  AuthProvider({required this.repository, required this.secureStorage});

  AuthStatus status = AuthStatus.unknown;
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  Future<void> bootstrap() async {
    final token = await secureStorage.readToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
    } else {
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
      errorMessage = e.toString().replaceFirst('Exception: ', '');
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
