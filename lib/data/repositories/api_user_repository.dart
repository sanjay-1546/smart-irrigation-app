import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_client.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Real backend implementation of [UserRepository].
///
/// CONFIRMED from the OpenAPI spec: paths `/users/index.php` (GET/PUT/DELETE,
/// admin only), `/users/profile.php` (GET/PUT), `/users/change_password.php`
/// (POST), `/auth/register.php` (POST, admin only). Response/request body
/// field names are NOT documented beyond the high-level summary.
///
/// GUESSED (parsed defensively, degrade to sensible defaults rather than
/// throwing):
/// - User objects shaped like `{ id, name, email, username?, role,
///   is_active }`, with `active` tried as a fallback key for `is_active`.
/// - List response is in `data` directly, or `data.users`.
/// - `updateUser` PUT body: `{ id, name?, email?, role?, is_active? }`.
/// - `deleteUser` uses DELETE with `?id=` query param (REST-ish index.php
///   convention used elsewhere isn't documented for this resource, so we
///   send both a query param and a body `id` defensively).
/// - `change_password.php` body: `{ current_password, new_password }`
///   (CONFIRMED by task spec). A 401 status means current password is
///   wrong; that message is surfaced as-is from the server.
/// - `register.php` body: `{ name, email, password, role }`, role as the
///   lowercase enum name (e.g. "admin", "farmer", "technician").
class ApiUserRepository implements UserRepository {
  final ApiClient apiClient;

  ApiUserRepository({required this.apiClient});

  @override
  Future<List<ManagedUser>> listUsers() async {
    final data = await apiClient.get(ApiEndpoints.usersList);
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['users'] is List) {
      list = data['users'] as List;
    } else {
      list = const [];
    }
    return list
        .whereType<Map>()
        .map((raw) => _managedUserFromJson(raw.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> updateUser({
    required String id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{'id': id};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (role != null) body['role'] = role.name;
    if (isActive != null) {
      body['is_active'] = isActive;
      body['active'] = isActive;
    }
    await apiClient.put(ApiEndpoints.usersList, body: body);
  }

  @override
  Future<void> deleteUser(String id) async {
    await apiClient.delete(ApiEndpoints.usersList, query: {'id': id}, body: {'id': id});
  }

  @override
  Future<User> getProfile() async {
    final data = await apiClient.get(ApiEndpoints.userProfile);
    if (data is! Map) {
      throw Exception('Failed to load profile.');
    }
    return _userFromJson(data.cast<String, dynamic>());
  }

  @override
  Future<User> updateProfile({required String name, required String email}) async {
    final data = await apiClient.put(
      ApiEndpoints.userProfile,
      body: {'name': name, 'email': email},
    );
    if (data is Map) {
      return _userFromJson(data.cast<String, dynamic>());
    }
    // Some PUT endpoints in this API return no body on success; refetch.
    return getProfile();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.post(
        ApiEndpoints.changePassword,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        throw ApiException('Current password is incorrect.', statusCode: 401);
      }
      rethrow;
    }
  }

  @override
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await apiClient.post(
      ApiEndpoints.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
      },
      requiresAuth: true,
    );
  }

  ManagedUser _managedUserFromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['user_id'])?.toString() ?? '';
    final name = (json['name'] as String?) ?? (json['full_name'] as String?) ?? 'Unknown';
    final email = (json['email'] as String?) ?? '';
    final role = _roleFromJson(json['role']);
    final isActiveRaw = json['is_active'] ?? json['active'];
    final isActive = switch (isActiveRaw) {
      bool b => b,
      int i => i != 0,
      String s => s.toLowerCase() == 'true' || s == '1',
      _ => true,
    };
    return ManagedUser(id: id, name: name, email: email, role: role, isActive: isActive);
  }

  User _userFromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['user_id'])?.toString() ?? '';
    final name = (json['name'] as String?) ?? (json['full_name'] as String?) ?? 'Unknown';
    final email = (json['email'] as String?) ?? '';
    final role = _roleFromJson(json['role']);
    return User(
      id: id,
      name: name,
      username: (json['username'] as String?) ?? email,
      email: email,
      role: role,
    );
  }

  UserRole _roleFromJson(dynamic raw) {
    final roleStr = (raw as String?)?.toLowerCase().trim();
    return switch (roleStr) {
      'admin' => UserRole.admin,
      'technician' => UserRole.technician,
      'farmer' => UserRole.farmer,
      _ => UserRole.farmer,
    };
  }
}
