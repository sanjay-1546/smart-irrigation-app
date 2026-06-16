import 'package:flutter/material.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Admin-only provider backing the user management screen: list/update/
/// delete/register users.
class UserManagementProvider extends ChangeNotifier {
  final UserRepository repository;

  UserManagementProvider({required this.repository});

  List<ManagedUser> users = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      users = await repository.listUsers();
    } catch (e) {
      errorMessage = _cleanMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required String id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
  }) async {
    errorMessage = null;
    try {
      await repository.updateUser(id: id, name: name, email: email, role: role, isActive: isActive);
      await loadUsers();
      return true;
    } catch (e) {
      errorMessage = _cleanMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    errorMessage = null;
    try {
      await repository.deleteUser(id);
      await loadUsers();
      return true;
    } catch (e) {
      errorMessage = _cleanMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    errorMessage = null;
    try {
      await repository.registerUser(name: name, email: email, password: password, role: role);
      await loadUsers();
      return true;
    } catch (e) {
      errorMessage = _cleanMessage(e);
      notifyListeners();
      return false;
    }
  }

  String _cleanMessage(Object e) =>
      e.toString().replaceFirst('ApiException: ', '').replaceFirst('Exception: ', '');
}
