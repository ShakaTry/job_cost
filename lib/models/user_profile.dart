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
  final String? companyAddress;
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
  
  // Transport fields
  final Map<String, dynamic>? transport;

  // Professional expenses fields
  final double? mealExpenses; // Frais de repas mensuels (hors titres)
  final double? mealAllowance; // Indemnité repas employeur
  final double? mealTicketValue; // Valeur des titres-restaurant
  final int? mealTicketsPerMonth; // Nombre de titres-restaurant par mois
  final String? childcareType; // Type de garde d'enfants
  final double? childcareCost; // Coût mensuel de la garde
  final double? childcareAids; // Aides reçues (CAF, employeur)
  final double? workDaysPerWeek; // Jours travaillés par semaine
  final double? remoteDaysPerWeek; // Jours de télétravail par semaine
  final double? remoteAllowance; // Forfait télétravail employeur
  final double? remoteExpenses; // Frais réels télétravail
  final double? remoteEquipment; // Équipement télétravail (amortissement)
  final double? workClothing; // Vêtements de travail
  final double? professionalEquipment; // Matériel professionnel
  final double? trainingCost; // Formation non remboursée
  final double? unionFees; // Cotisations syndicales

  // Fiscal parameters fields
  final String? fiscalRegime; // Régime fiscal (réel ou forfaitaire)
  final double? withholdingRate; // Taux de prélèvement à la source
  final double? fiscalParts; // Nombre de parts fiscales
  final String? mileageScaleCategory; // Catégorie barème kilométrique (3-4CV, 5CV, etc.)
  final double? deductibleCSG; // CSG déductible (pourcentage personnalisé si différent du standard)
  final double? additionalDeductions; // Autres déductions fiscales mensuelles

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
    this.companyAddress,
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
    this.transport,
    this.mealExpenses,
    this.mealAllowance,
    this.mealTicketValue,
    this.mealTicketsPerMonth,
    this.childcareType,
    this.childcareCost,
    this.childcareAids,
    this.workDaysPerWeek,
    this.remoteDaysPerWeek,
    this.remoteAllowance,
    this.remoteExpenses,
    this.remoteEquipment,
    this.workClothing,
    this.professionalEquipment,
    this.trainingCost,
    this.unionFees,
    this.fiscalRegime,
    this.withholdingRate,
    this.fiscalParts,
    this.mileageScaleCategory,
    this.deductibleCSG,
    this.additionalDeductions,
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
    String? companyAddress,
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
    Map<String, dynamic>? transport,
    double? mealExpenses,
    double? mealAllowance,
    double? mealTicketValue,
    int? mealTicketsPerMonth,
    String? childcareType,
    double? childcareCost,
    double? childcareAids,
    double? workDaysPerWeek,
    double? remoteDaysPerWeek,
    double? remoteAllowance,
    double? remoteExpenses,
    double? remoteEquipment,
    double? workClothing,
    double? professionalEquipment,
    double? trainingCost,
    double? unionFees,
    String? fiscalRegime,
    double? withholdingRate,
    double? fiscalParts,
    String? mileageScaleCategory,
    double? deductibleCSG,
    double? additionalDeductions,
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
      companyAddress: companyAddress ?? this.companyAddress,
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
      transport: transport ?? this.transport,
      mealExpenses: mealExpenses ?? this.mealExpenses,
      mealAllowance: mealAllowance ?? this.mealAllowance,
      mealTicketValue: mealTicketValue ?? this.mealTicketValue,
      mealTicketsPerMonth: mealTicketsPerMonth ?? this.mealTicketsPerMonth,
      childcareType: childcareType ?? this.childcareType,
      childcareCost: childcareCost ?? this.childcareCost,
      childcareAids: childcareAids ?? this.childcareAids,
      workDaysPerWeek: workDaysPerWeek ?? this.workDaysPerWeek,
      remoteDaysPerWeek: remoteDaysPerWeek ?? this.remoteDaysPerWeek,
      remoteAllowance: remoteAllowance ?? this.remoteAllowance,
      remoteExpenses: remoteExpenses ?? this.remoteExpenses,
      remoteEquipment: remoteEquipment ?? this.remoteEquipment,
      workClothing: workClothing ?? this.workClothing,
      professionalEquipment: professionalEquipment ?? this.professionalEquipment,
      trainingCost: trainingCost ?? this.trainingCost,
      unionFees: unionFees ?? this.unionFees,
      fiscalRegime: fiscalRegime ?? this.fiscalRegime,
      withholdingRate: withholdingRate ?? this.withholdingRate,
      fiscalParts: fiscalParts ?? this.fiscalParts,
      mileageScaleCategory: mileageScaleCategory ?? this.mileageScaleCategory,
      deductibleCSG: deductibleCSG ?? this.deductibleCSG,
      additionalDeductions: additionalDeductions ?? this.additionalDeductions,
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
    String? companyAddress,
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
    Map<String, dynamic>? transport,
    double? mealExpenses,
    double? mealAllowance,
    double? mealTicketValue,
    int? mealTicketsPerMonth,
    String? childcareType,
    double? childcareCost,
    double? childcareAids,
    double? workDaysPerWeek,
    double? remoteDaysPerWeek,
    double? remoteAllowance,
    double? remoteExpenses,
    double? remoteEquipment,
    double? workClothing,
    double? professionalEquipment,
    double? trainingCost,
    double? unionFees,
    String? fiscalRegime,
    double? withholdingRate,
    double? fiscalParts,
    String? mileageScaleCategory,
    double? deductibleCSG,
    double? additionalDeductions,
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
      companyAddress: companyAddress,
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
      transport: transport,
      mealExpenses: mealExpenses,
      mealAllowance: mealAllowance,
      mealTicketValue: mealTicketValue,
      mealTicketsPerMonth: mealTicketsPerMonth,
      childcareType: childcareType,
      childcareCost: childcareCost,
      childcareAids: childcareAids,
      workDaysPerWeek: workDaysPerWeek,
      remoteDaysPerWeek: remoteDaysPerWeek,
      remoteAllowance: remoteAllowance,
      remoteExpenses: remoteExpenses,
      remoteEquipment: remoteEquipment,
      workClothing: workClothing,
      professionalEquipment: professionalEquipment,
      trainingCost: trainingCost,
      unionFees: unionFees,
      fiscalRegime: fiscalRegime,
      withholdingRate: withholdingRate,
      fiscalParts: fiscalParts,
      mileageScaleCategory: mileageScaleCategory,
      deductibleCSG: deductibleCSG,
      additionalDeductions: additionalDeductions,
    );
  }
}