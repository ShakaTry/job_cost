class AppConstants {
  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 32.0;

  // Border radius
  static const double defaultRadius = 8.0;
  static const double cardRadius = 12.0;

  // Default values
  static const String defaultNationality = 'France';
  static const String defaultMaritalStatus = 'Non renseigné';
  static const int defaultDependentChildren = 0;

  // Profile limits
  static const int maxFreeProfiles = 3;

  // Avatar sizes
  static const double smallAvatarRadius = 30.0;
  static const double mediumAvatarRadius = 50.0;
  static const double largeAvatarRadius = 60.0;

  // Font sizes
  static const double smallAvatarFontSize = 24.0;
  static const double mediumAvatarFontSize = 36.0;
  static const double largeAvatarFontSize = 48.0;

  // Form validation
  static const int minNameLength = 2;

  // Lists
  static const List<String> maritalStatusOptions = [
    'Célibataire',
    'Marié(e)',
    'Divorcé(e)',
    'Veuf(ve)',
    'Pacsé(e)',
    'Union libre',
  ];

  static const List<String> nationalityOptions = [
    'France',
    'Belgique',
    'Suisse',
    'Luxembourg',
    'Canada',
    'États-Unis',
    'Royaume-Uni',
    'Allemagne',
    'Espagne',
    'Italie',
    'Portugal',
    'Pays-Bas',
    'Maroc',
    'Algérie',
    'Tunisie',
    'Sénégal',
    'Côte d\'Ivoire',
    'Cameroun',
    'Madagascar',
    'Chine',
    'Japon',
    'Inde',
    'Brésil',
    'Argentine',
    'Mexique',
    'Autre',
  ];

  // Professional situation
  static const List<String> employmentStatusOptions = [
    'Salarié(e) CDI',
  ];

  static const List<String> workTimeOptions = [
    'Temps plein',
    'Temps partiel 90%',
    'Temps partiel 80%',
    'Temps partiel 70%',
    'Temps partiel 60%',
    'Temps partiel 50%',
    'Mi-temps',
    'Temps partiel 30%',
    'Temps partiel 20%',
    'Autre',
  ];

  static const List<String> taxSystemOptions = [
    'Prélèvement à la source',
    'Acomptes provisionnels',
    'Micro-entrepreneur',
  ];

  // Default professional values
  static const String defaultEmploymentStatus = 'Salarié(e) CDI';
  static const double defaultWorkTimePercentage = 100.0; // 100% temps plein
  static const double defaultWeeklyHours = 35.0; // 35h par semaine
  static const String defaultTaxSystem = 'Prélèvement à la source';
  static const double defaultGrossSalary = 0.0;
  static const double defaultMutualEmployeeCost = 0.0; // Part salarié mutuelle
  
  // Meal vouchers constants
  static const double maxMealVoucherExemption = 7.18; // 2024
  static const double defaultMealVoucherValue = 9.0; // Valeur moyenne
  static const int defaultMealVouchersPerMonth = 19; // Moyenne mensuelle
  static const double defaultEmployerMealVoucherRate = 0.6; // 60%
  
  // Transport
  static const List<String> transportModes = [
    'Véhicule personnel',
  ];
  
  // Fuel types
  static const List<String> fuelTypes = [
    'Essence',
    'Diesel',
    'Hybride',
    'Électrique',
    'GPL',
  ];
  
  // Childcare types
  static const List<String> childcareTypes = [
    'Assistant(e) maternel(le)',
    'Crèche',
    'Garde à domicile',
    'Périscolaire',
    'Centre de loisirs',
    'Autre',
  ];
}