class SessionStatusEntity {
  final bool isAuthenticated;
  final String? username;
  final String? role;

  const SessionStatusEntity({
    required this.isAuthenticated,
    this.username,
    this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusEntity &&
          runtimeType == other.runtimeType &&
          isAuthenticated == other.isAuthenticated &&
          username == other.username &&
          role == other.role;

  @override
  int get hashCode => Object.hash(isAuthenticated, username, role);
}
