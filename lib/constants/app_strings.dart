class AppStrings {
  // App title
  static const String appTitle = 'Job Cost';

  // Screen titles
  static const String selectProfileTitle = 'Choisissez votre profil';
  static const String personalInfoTitle = 'Informations personnelles';
  static const String newProfileTitle = 'Nouveau profil';

  // Buttons
  static const String addNewProfile = 'Ajouter un nouveau profil';
  static const String cancel = 'Annuler';
  static const String create = 'Créer';
  static const String ok = 'OK';
  static const String delete = 'Supprimer';
  static const String stayAndCorrect = 'Rester et corriger';
  static const String exitWithoutSaving = 'Quitter sans sauvegarder';
  static const String deleteProfile = 'Supprimer ce profil';

  // Form labels
  static const String lastName = 'Nom';
  static const String firstName = 'Prénom';
  static const String address = 'Adresse complète';
  static const String phone = 'Téléphone';
  static const String email = 'Email';
  static const String birthDate = 'Date de naissance';
  static const String nationality = 'Nationalité';
  static const String maritalStatus = 'État civil';
  static const String dependentChildren = 'Nombre d\'enfants à charge';

  // Form hints
  static const String lastNameHint = 'Ex: Dupont';
  static const String firstNameHint = 'Ex: Jean';
  static const String addressHint = 'Ex: 123 rue de la Paix, 75001 Paris';
  static const String phoneHint = 'Ex: 06 12 34 56 78';
  static const String emailHint = 'Ex: jean.dupont@email.com';
  static const String selectDateHint = 'Sélectionner une date';

  // Validation messages
  static const String enterLastName = 'Veuillez entrer votre nom';
  static const String enterFirstName = 'Veuillez entrer votre prénom';
  static const String enterAddress = 'Veuillez entrer votre adresse';
  static const String nameMinLength = 'doit contenir au moins 2 caractères';
  static const String invalidPhoneFormat = 'Format invalide (ex: 06 12 34 56 78)';
  static const String invalidEmailFormat = 'Format email invalide';

  // Section headers
  static const String identitySection = 'Identité';
  static const String contactSection = 'Coordonnées';
  static const String familySection = 'Situation familiale';

  // Info messages
  static const String currentSituation = 'Votre situation actuelle';
  static const String socialTaxInfo = 'Ces informations sont essentielles pour calculer vos charges sociales et fiscales';
  static const String profilePhotoInfo = 'Cette fonctionnalité sera bientôt disponible.';

  // Dialog messages
  static const String invalidDataTitle = 'Données invalides';
  static const String invalidDataMessage = 'Certaines informations ne sont pas valides.\n\nVoulez-vous quitter sans sauvegarder les modifications ?';
  static const String deleteProfileTitle = 'Supprimer le profil';
  static const String deleteProfileMessage = 'Voulez-vous vraiment supprimer le profil de';
  static const String profilePhotoTitle = 'Photo de profil';

  // Profile detail sections
  static const String personalInfoSectionTitle = 'Informations personnelles';
  static const String personalInfoSectionSubtitle = 'Nom, adresse, situation familiale';
  static const String professionalSituationTitle = 'Situation professionnelle actuelle';
  static const String professionalSituationSubtitle = 'Emploi actuel, statut, régime fiscal';
  static const String transportTitle = 'Transport & Déplacements';
  static const String transportSubtitle = 'Mode de transport, distance domicile-travail';
  static const String professionalExpensesTitle = 'Frais professionnels';
  static const String professionalExpensesSubtitle = 'Repas, garde d\'enfants, équipements';
  static const String fiscalParametersTitle = 'Paramètres fiscaux';
  static const String fiscalParametersSubtitle = 'Régime fiscal, taux de prélèvement';

  // Other
  static const String notSpecified = 'Non renseigné';
  static const String notSpecifiedDate = 'Non renseignée';
  static const String none = 'Aucun';
  static const String yearsOld = 'ans';

  // Professional situation screen
  static const String professionalSituationScreenTitle = 'Situation professionnelle';
  static const String currentEmploymentSection = 'Emploi actuel';
  static const String salarySection = 'Salaire et revenus';
  static const String taxSection = 'Régime fiscal';
  static const String employmentStatus = 'Statut professionnel';
  static const String companyName = 'Nom de l\'entreprise';
  static const String jobTitle = 'Intitulé du poste';
  static const String workTime = 'Temps de travail';
  static const String grossMonthlySalary = 'Salaire brut mensuel';
  static const String grossHourlyRate = 'Taux horaire brut';
  static const String grossAnnualSalary = 'Salaire brut annuel';
  static const String netMonthlySalary = 'Salaire net mensuel estimé';
  static const String taxSystem = 'Mode d\'imposition';
  static const String companyNameHint = 'Ex: Société ABC';
  static const String jobTitleHint = 'Ex: Développeur web';
  static const String salaryHint = 'En euros';
  static const String hourlyRateHint = 'En euros';
  static const String or = 'OU';
  static const String hoursPerWeek = 'heures/semaine';
  static const String professionalInfoMessage = 'Ces informations serviront de base pour le calcul de votre salaire réel net.';
  static const String salaryInfoMessage = 'Indiquez votre salaire brut mensuel ou votre taux horaire. Les deux champs se calculent automatiquement selon votre temps de travail.';
  static const String monthlyAmount = 'par mois';
  static const String annualAmount = 'par an';
  static const String euroSymbol = '€';
  
  // Overtime section
  static const String overtimeSection = 'Heures supplémentaires';
  static const String overtimeHours = 'Heures supplémentaires par semaine';
  static const String overtimeHoursHint = 'Ex: 4';
  static const String overtimeInfo = 'En France, les heures au-delà de 35h/semaine sont majorées : +25% de la 36e à la 43e heure, +50% au-delà.';
  static const String overtimeMonthlyAmount = 'Montant mensuel des heures supp.';
  static const String overtimeRate25 = 'Heures à 25%';
  static const String overtimeRate50 = 'Heures à 50%';
  static const String hoursPerMonth = 'h/mois';
  static const String overtimeTaxExemption = 'Exonération fiscale (max 5000€/an)';
  static const String regularOvertime = 'Heures supplémentaires régulières';
  static const String regularOvertimeHelper = 'Ces heures sont effectuées chaque semaine';
  static const String occasionalOvertimeHelper = 'Estimation ponctuelle (impact sur la précision du calcul)';
  
  // Errors
  static const String errorTitle = 'Erreur';
  static const String errorGeneric = 'Une erreur est survenue. Veuillez réessayer.';
}