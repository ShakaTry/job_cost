class UserProfile {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserProfile.create({
    required String name,
    required String role,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      role: role,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
    );
  }
}