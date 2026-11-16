import 'admin_role.dart';

class Admin {
  final String id;
  final String username;
  final AdminRole role;

  const Admin({
    required this.id,
    required this.username,
    required this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Admin &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          role == other.role;

  @override
  int get hashCode => Object.hash(id, username, role);
}
