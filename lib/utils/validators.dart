import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

class Validators {
  // Regex patterns
  static final RegExp _phoneRegex = RegExp(r'^(?:\+33|0)[1-9](?:[0-9]{8})$');
  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  // Name validation
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      if (fieldName == AppStrings.lastName) {
        return AppStrings.enterLastName;
      } else if (fieldName == AppStrings.firstName) {
        return AppStrings.enterFirstName;
      }
      return 'Veuillez entrer $fieldName';
    }
    if (value.length < AppConstants.minNameLength) {
      return '$fieldName ${AppStrings.nameMinLength}';
    }
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterAddress;
    }
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      // Remove all spaces and special characters except +
      String cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
      // Check French format (10 digits or international)
      if (!_phoneRegex.hasMatch(cleaned)) {
        return AppStrings.invalidPhoneFormat;
      }
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!_emailRegex.hasMatch(value)) {
        return AppStrings.invalidEmailFormat;
      }
    }
    return null;
  }

  // Clean phone number for storage
  static String cleanPhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[^\d+]'), '');
  }

  // Check if phone is valid (for save operations)
  static bool isPhoneValid(String value) {
    if (value.isEmpty) return true; // Empty is valid
    String cleaned = cleanPhoneNumber(value);
    return _phoneRegex.hasMatch(cleaned);
  }

  // Check if email is valid (for save operations)
  static bool isEmailValid(String value) {
    if (value.isEmpty) return true; // Empty is valid
    return _emailRegex.hasMatch(value);
  }
}