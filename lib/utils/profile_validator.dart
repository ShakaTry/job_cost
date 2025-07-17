import '../models/user_profile.dart';
import '../utils/validators.dart';
import '../constants/app_strings.dart';

enum ValidationStatus {
  valid,
  error,
  incomplete,
}

class ProfileValidator {
  // Validation des informations personnelles
  static bool hasPersonalInfoErrors(UserProfile profile) {
    return Validators.validateName(profile.lastName, AppStrings.lastName) != null ||
           Validators.validateName(profile.firstName, AppStrings.firstName) != null ||
           Validators.validateAddress(profile.address) != null ||
           Validators.validatePhone(profile.phone ?? '') != null ||
           Validators.validateEmail(profile.email ?? '') != null;
  }

  static bool isPersonalInfoComplete(UserProfile profile) {
    return profile.lastName.isNotEmpty && 
           profile.firstName.isNotEmpty &&
           profile.birthDate != null &&
           profile.address.isNotEmpty;
  }

  // Validation de la situation professionnelle
  static bool hasProfessionalSituationErrors(UserProfile profile) {
    // Pas d'erreurs spécifiques pour le moment (principalement des champs optionnels)
    return false;
  }

  static bool isProfessionalSituationComplete(UserProfile profile) {
    return profile.companyName != null && 
           profile.companyName!.isNotEmpty &&
           profile.jobTitle != null && 
           profile.jobTitle!.isNotEmpty &&
           profile.grossMonthlySalary > 0;
  }

  // Validation du transport
  static bool hasTransportErrors(UserProfile profile) {
    // Pas d'erreurs spécifiques pour le moment
    return false;
  }

  static bool isTransportComplete(UserProfile profile) {
    return profile.transport != null &&
           profile.transport!['vehicleType'] != null &&
           profile.transport!['fuelType'] != null &&
           profile.transport!['distanceToWork'] != null &&
           (profile.transport!['distanceToWork'] as double?) != null &&
           (profile.transport!['distanceToWork'] as double) > 0;
  }

  // Validation des frais professionnels
  static bool hasProfessionalExpensesErrors(UserProfile profile) {
    // Validation des champs numériques s'ils sont renseignés
    return (profile.mealExpenses != null && profile.mealExpenses! < 0) ||
           (profile.childcareCost != null && profile.childcareCost! < 0) ||
           (profile.workDaysPerWeek != null && (profile.workDaysPerWeek! < 0 || profile.workDaysPerWeek! > 7)) ||
           (profile.remoteDaysPerWeek != null && (profile.remoteDaysPerWeek! < 0 || profile.remoteDaysPerWeek! > 7));
  }

  static bool isProfessionalExpensesComplete(UserProfile profile) {
    return profile.workDaysPerWeek != null && profile.workDaysPerWeek! > 0;
  }

  // Validation des paramètres fiscaux
  static bool hasFiscalParametersErrors(UserProfile profile) {
    // Pas d'erreurs spécifiques pour le moment
    return false;
  }

  static bool isFiscalParametersComplete(UserProfile profile) {
    return profile.fiscalRegime != null && profile.fiscalRegime!.isNotEmpty;
  }

  // Déterminer le statut de validation d'une section
  static ValidationStatus getSectionValidationStatus(bool hasErrors, bool isComplete) {
    if (hasErrors) return ValidationStatus.error;
    if (isComplete) return ValidationStatus.valid;
    return ValidationStatus.incomplete;
  }

  // Évaluation globale du profil
  static ValidationStatus getOverallProfileStatus(UserProfile profile) {
    List<ValidationStatus> sectionStatuses = [
      getSectionValidationStatus(hasPersonalInfoErrors(profile), isPersonalInfoComplete(profile)),
      getSectionValidationStatus(hasProfessionalSituationErrors(profile), isProfessionalSituationComplete(profile)),
      getSectionValidationStatus(hasTransportErrors(profile), isTransportComplete(profile)),
      getSectionValidationStatus(hasProfessionalExpensesErrors(profile), isProfessionalExpensesComplete(profile)),
      getSectionValidationStatus(hasFiscalParametersErrors(profile), isFiscalParametersComplete(profile)),
    ];

    // Si au moins une section a des erreurs
    if (sectionStatuses.any((status) => status == ValidationStatus.error)) {
      return ValidationStatus.error;
    }

    // Si toutes les sections sont valides
    if (sectionStatuses.every((status) => status == ValidationStatus.valid)) {
      return ValidationStatus.valid;
    }

    // Sinon, profil incomplet
    return ValidationStatus.incomplete;
  }

  // Compter les sections complétées
  static int getCompletedSectionsCount(UserProfile profile) {
    List<bool> completions = [
      isPersonalInfoComplete(profile) && !hasPersonalInfoErrors(profile),
      isProfessionalSituationComplete(profile) && !hasProfessionalSituationErrors(profile),
      isTransportComplete(profile) && !hasTransportErrors(profile),
      isProfessionalExpensesComplete(profile) && !hasProfessionalExpensesErrors(profile),
      isFiscalParametersComplete(profile) && !hasFiscalParametersErrors(profile),
    ];

    return completions.where((completed) => completed).length;
  }

  static const int totalSectionsCount = 5;
}