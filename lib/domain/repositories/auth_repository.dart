import '../entities/user.dart';

abstract class AuthRepository {
  Future<({User user, String token})> login(String username, String password);
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
}
