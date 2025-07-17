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
  final double grossMonthlySalary;
  final String taxSystem;
  final bool? isNonCadre; // Statut salarié non cadre
  final double conventionalBonusMonths; // Nombre de mois de prime conventionnelle
  final DateTime? companyEntryDate; // Date d'entrée dans l'entreprise (pour prime d'ancienneté)
  final double mutualEmployeeCost; // Part salarié de la mutuelle (€/mois)
  final double? mealVoucherValue; // Valeur faciale des titres-restaurant
  final int? mealVouchersPerMonth; // Nombre de titres-restaurant par mois
  
  // Transport fields
  final Map<String, dynamic>? transport;

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
    required this.grossMonthlySalary,
    required this.taxSystem,
    this.isNonCadre,
    required this.conventionalBonusMonths,
    this.companyEntryDate,
    required this.mutualEmployeeCost,
    this.mealVoucherValue,
    this.mealVouchersPerMonth,
    this.transport,
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
    double? grossMonthlySalary,
    String? taxSystem,
    bool? isNonCadre,
    double? conventionalBonusMonths,
    DateTime? companyEntryDate,
    double? mutualEmployeeCost,
    double? mealVoucherValue,
    int? mealVouchersPerMonth,
    Map<String, dynamic>? transport,
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
      grossMonthlySalary: grossMonthlySalary ?? this.grossMonthlySalary,
      taxSystem: taxSystem ?? this.taxSystem,
      isNonCadre: isNonCadre ?? this.isNonCadre,
      conventionalBonusMonths: conventionalBonusMonths ?? this.conventionalBonusMonths,
      companyEntryDate: companyEntryDate ?? this.companyEntryDate,
      mutualEmployeeCost: mutualEmployeeCost ?? this.mutualEmployeeCost,
      mealVoucherValue: mealVoucherValue ?? this.mealVoucherValue,
      mealVouchersPerMonth: mealVouchersPerMonth ?? this.mealVouchersPerMonth,
      transport: transport ?? this.transport,
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
    double? grossMonthlySalary,
    String? taxSystem,
    bool? isNonCadre,
    double? conventionalBonusMonths,
    DateTime? companyEntryDate,
    double? mutualEmployeeCost,
    double? mealVoucherValue,
    int? mealVouchersPerMonth,
    Map<String, dynamic>? transport,
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
      grossMonthlySalary: grossMonthlySalary ?? AppConstants.defaultGrossSalary,
      taxSystem: taxSystem ?? AppConstants.defaultTaxSystem,
      isNonCadre: isNonCadre ?? false,
      conventionalBonusMonths: conventionalBonusMonths ?? 0.0,
      companyEntryDate: companyEntryDate,
      mutualEmployeeCost: mutualEmployeeCost ?? 0.0,
      mealVoucherValue: mealVoucherValue,
      mealVouchersPerMonth: mealVouchersPerMonth,
      transport: transport,
    );
  }
}