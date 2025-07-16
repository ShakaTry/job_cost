class UserProfile {
  final String id;
  final String lastName;
  final String firstName;
  final String address;
  final String maritalStatus; // Célibataire, Marié(e), Divorcé(e), Veuf(ve)
  final int dependentChildren;
  final String? avatarUrl;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.address,
    required this.maritalStatus,
    required this.dependentChildren,
    this.avatarUrl,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.create({
    required String lastName,
    required String firstName,
    String? address,
    String? maritalStatus,
    int? dependentChildren,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lastName: lastName,
      firstName: firstName,
      address: address ?? '',
      maritalStatus: maritalStatus ?? 'Non renseigné',
      dependentChildren: dependentChildren ?? 0,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
    );
  }
}