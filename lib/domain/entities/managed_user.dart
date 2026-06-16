import 'user.dart';

/// Lightweight entity used only by the admin user-management screen.
///
/// Keeps the core [User] entity's shape unchanged (it's used app-wide for
/// the logged-in user) while still letting admins see/manage `isActive`.
class ManagedUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  const ManagedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  ManagedUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
  }) {
    return ManagedUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
