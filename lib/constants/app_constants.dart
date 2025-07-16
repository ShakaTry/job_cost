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
}