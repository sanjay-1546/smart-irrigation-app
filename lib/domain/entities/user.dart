enum UserRole { admin, farmer, technician }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.technician:
        return 'Technician';
    }
  }
}

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
  });
}
