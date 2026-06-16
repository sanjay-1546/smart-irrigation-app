import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_client.dart';
import '../../core/services/farm_context.dart';
import '../../core/services/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Real backend implementation of [AuthRepository].
///
/// CONFIRMED from the OpenAPI spec: login request body is
/// `{ "email": string, "password": string }` and the global error envelope
/// is `{ "success": false, "message": string, "errors": [] }`.
///
/// GUESSED (response schemas are undocumented beyond "JWT issued"/"OK"):
/// - success envelope mirrors the error one: `{ success: true, message, data }`.
/// - login `data` contains `token` (fallback: top-level `token`/`jwt`) and a
///   `user` object.
/// - `/auth/me.php` returns the user directly in `data` (or the whole body).
/// - User field names: `id`, `name`, `email`, `role` (case-insensitive,
///   mapped to [UserRole], default [UserRole.farmer] if unrecognized).
/// - `/farms/index.php` returns a list (in `data` or `data.farms`) of farm
///   objects with `id` (fallback `farm_id`).
class ApiAuthRepository implements AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;
  final FarmContext farmContext;

  ApiAuthRepository({
    required this.apiClient,
    required this.secureStorage,
    required this.farmContext,
  });

  @override
  Future<({User user, String token})> login(String username, String password) async {
    final data = await apiClient.post(
      ApiEndpoints.login,
      body: {'email': username, 'password': password},
      requiresAuth: false,
    );

    if (data is! Map) {
      throw Exception('Unexpected response from server during login.');
    }
    final map = data.cast<String, dynamic>();

    final token = (map['token'] ?? map['jwt'] ?? map['access_token']) as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Login succeeded but no auth token was returned by the server.');
    }
    await secureStorage.saveToken(token);

    User user;
    final userJson = map['user'];
    if (userJson is Map) {
      user = _userFromJson(userJson.cast<String, dynamic>());
    } else {
      // Fall back to /auth/me.php to populate the user entity.
      user = await _fetchMe();
    }

    await _refreshActiveFarm();

    return (user: user, token: token);
  }

  Future<User> _fetchMe() async {
    final data = await apiClient.get(ApiEndpoints.me);
    if (data is! Map) {
      throw Exception('Failed to load the current user profile.');
    }
    return _userFromJson(data.cast<String, dynamic>());
  }

  User _userFromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['user_id'])?.toString() ?? '';
    final name = (json['name'] as String?) ?? (json['full_name'] as String?) ?? 'Unknown';
    final email = (json['email'] as String?) ?? '';
    final roleStr = (json['role'] as String?)?.toLowerCase().trim();
    final role = switch (roleStr) {
      'admin' => UserRole.admin,
      'technician' => UserRole.technician,
      'farmer' => UserRole.farmer,
      _ => UserRole.farmer,
    };
    return User(
      id: id,
      name: name,
      username: (json['username'] as String?) ?? email,
      email: email,
      role: role,
    );
  }

  Future<void> _refreshActiveFarm() async {
    try {
      final data = await apiClient.get(ApiEndpoints.farms);
      List<dynamic> farms;
      if (data is List) {
        farms = data;
      } else if (data is Map && data['farms'] is List) {
        farms = data['farms'] as List;
      } else {
        farms = const [];
      }
      if (farms.isEmpty) {
        await farmContext.setFarmId(null);
        return;
      }
      final first = farms.first;
      if (first is Map) {
        final id = (first['id'] ?? first['farm_id'])?.toString();
        await farmContext.setFarmId(id);
      }
    } catch (_) {
      // Non-critical: leave whatever farmId was previously persisted.
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout, body: const {});
    } catch (_) {
      // Don't block logout UX on server-side invalidation failing.
    }
    await secureStorage.deleteToken();
    await farmContext.clear();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    // No password-reset endpoint exists in the real API; this stays
    // unsupported server-side. Surface a clear failure to the caller.
    throw Exception('Password reset is not available on this server yet.');
  }
}
