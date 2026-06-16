import 'dart:math';
import '../../core/services/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final SecureStorageService secureStorage;

  MockAuthRepository({required this.secureStorage});

  static final List<User> _demoUsers = [
    const User(
      id: 'u1',
      name: 'Alice Admin',
      username: 'admin',
      email: 'admin@smartfarm.io',
      role: UserRole.admin,
    ),
    const User(
      id: 'u2',
      name: 'Frank Farmer',
      username: 'farmer',
      email: 'farmer@smartfarm.io',
      role: UserRole.farmer,
    ),
    const User(
      id: 'u3',
      name: 'Tom Technician',
      username: 'technician',
      email: 'technician@smartfarm.io',
      role: UserRole.technician,
    ),
  ];

  @override
  Future<({User user, String token})> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (password.length < 4) {
      throw Exception('Password must be at least 4 characters');
    }
    final match = _demoUsers.firstWhere(
      (u) => u.username.toLowerCase() == username.trim().toLowerCase(),
      orElse: () => throw Exception('Invalid username or password'),
    );
    final token = _generateFakeJwt(match);
    await secureStorage.saveToken(token);
    return (user: match, token: token);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await secureStorage.deleteToken();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  String _generateFakeJwt(User user) {
    final rand = Random();
    final payload = '${user.id}.${user.role.name}.${rand.nextInt(999999)}';
    return 'mock.$payload.signature';
  }
}
