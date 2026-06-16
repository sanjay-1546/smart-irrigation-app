import '../entities/managed_user.dart';
import '../entities/user.dart';

abstract class UserRepository {
  /// Admin only.
  Future<List<ManagedUser>> listUsers();

  /// Admin only.
  Future<void> updateUser({
    required String id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
  });

  /// Admin only. Backend rejects deleting the current admin's own account.
  Future<void> deleteUser(String id);

  /// Current user's own profile.
  Future<User> getProfile();

  /// Current user's own profile (name/email only).
  Future<User> updateProfile({required String name, required String email});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Admin only.
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });
}
