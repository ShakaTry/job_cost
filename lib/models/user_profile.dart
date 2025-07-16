import '../constants/app_constants.dart';

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

  // Professional situation fields
  final String employmentStatus;
  final String? companyName;
  final String? jobTitle;
  final double workTimePercentage; // Pourcentage de temps de travail (10-100)
  final double weeklyHours; // Heures hebdomadaires
  final double overtimeHours; // Heures supplémentaires par semaine
  final bool overtimeRegular; // true = régulières, false = occasionnelles/estimées
  final double grossMonthlySalary;
  final String taxSystem;

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
    required this.employmentStatus,
    this.companyName,
    this.jobTitle,
    required this.workTimePercentage,
    required this.weeklyHours,
    required this.overtimeHours,
    required this.overtimeRegular,
    required this.grossMonthlySalary,
    required this.taxSystem,
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
    String? employmentStatus,
    String? companyName,
    String? jobTitle,
    double? workTimePercentage,
    double? weeklyHours,
    double? overtimeHours,
    bool? overtimeRegular,
    double? grossMonthlySalary,
    String? taxSystem,
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
      employmentStatus: employmentStatus ?? this.employmentStatus,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      workTimePercentage: workTimePercentage ?? this.workTimePercentage,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      overtimeRegular: overtimeRegular ?? this.overtimeRegular,
      grossMonthlySalary: grossMonthlySalary ?? this.grossMonthlySalary,
      taxSystem: taxSystem ?? this.taxSystem,
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
    String? employmentStatus,
    String? companyName,
    String? jobTitle,
    double? workTimePercentage,
    double? weeklyHours,
    double? overtimeHours,
    bool? overtimeRegular,
    double? grossMonthlySalary,
    String? taxSystem,
  }) {
    return UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lastName: lastName,
      firstName: firstName,
      address: address ?? '',
      maritalStatus: maritalStatus ?? AppConstants.defaultMaritalStatus,
      dependentChildren: dependentChildren ?? AppConstants.defaultDependentChildren,
      avatarUrl: avatarUrl,
      phone: phone,
      email: email,
      birthDate: birthDate,
      nationality: nationality ?? AppConstants.defaultNationality,
      createdAt: DateTime.now(),
      employmentStatus: employmentStatus ?? AppConstants.defaultEmploymentStatus,
      companyName: companyName,
      jobTitle: jobTitle,
      workTimePercentage: workTimePercentage ?? AppConstants.defaultWorkTimePercentage,
      weeklyHours: weeklyHours ?? AppConstants.defaultWeeklyHours,
      overtimeHours: overtimeHours ?? 0.0,
      overtimeRegular: overtimeRegular ?? true,
      grossMonthlySalary: grossMonthlySalary ?? AppConstants.defaultGrossSalary,
      taxSystem: taxSystem ?? AppConstants.defaultTaxSystem,
    );
  }
}