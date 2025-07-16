class UserProfile {
  final String id;
  final String lastName;
  final String firstName;
  final String address;
  final String maritalStatus; // Célibataire, Marié(e), Divorcé(e), Veuf(ve)
  final int dependentChildren;
  final String? avatarUrl;
  final String? phone;
  final String? email;
  final DateTime? birthDate;
  final String nationality;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.address,
    required this.maritalStatus,
    required this.dependentChildren,
    this.avatarUrl,
    this.phone,
    this.email,
    this.birthDate,
    required this.nationality,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  UserProfile copyWith({
    String? lastName,
    String? firstName,
    String? address,
    String? maritalStatus,
    int? dependentChildren,
    String? avatarUrl,
    String? phone,
    String? email,
    DateTime? birthDate,
    String? nationality,
  }) {
    return UserProfile(
      id: id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      address: address ?? this.address,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dependentChildren: dependentChildren ?? this.dependentChildren,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      nationality: nationality ?? this.nationality,
      createdAt: createdAt,
    );
  }

  factory UserProfile.create({
    required String lastName,
    required String firstName,
    String? address,
    String? maritalStatus,
    int? dependentChildren,
    String? avatarUrl,
    String? phone,
    String? email,
    DateTime? birthDate,
    String? nationality,
  }) {
    return UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lastName: lastName,
      firstName: firstName,
      address: address ?? '',
      maritalStatus: maritalStatus ?? 'Non renseigné',
      dependentChildren: dependentChildren ?? 0,
      avatarUrl: avatarUrl,
      phone: phone,
      email: email,
      birthDate: birthDate,
      nationality: nationality ?? 'France',
      createdAt: DateTime.now(),
    );
  }
}