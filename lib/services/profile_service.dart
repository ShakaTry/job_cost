import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileService {
  static const String _profilesKey = 'user_profiles';
  static final ProfileService _instance = ProfileService._internal();
  
  factory ProfileService() => _instance;
  ProfileService._internal();
  
  Future<List<UserProfile>> loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList(_profilesKey) ?? [];
      
      return profilesJson.map((json) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        return _profileFromJson(data);
      }).toList();
    } catch (e) {
      // Log error silently in production
      return [];
    }
  }
  
  Future<bool> saveProfiles(List<UserProfile> profiles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = profiles.map((profile) {
        return jsonEncode(_profileToJson(profile));
      }).toList();
      
      return await prefs.setStringList(_profilesKey, profilesJson);
    } catch (e) {
      // Log error silently in production
      return false;
    }
  }
  
  Future<bool> updateProfile(UserProfile profile) async {
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    
    if (index != -1) {
      profiles[index] = profile;
      return await saveProfiles(profiles);
    }
    
    return false;
  }
  
  Map<String, dynamic> _profileToJson(UserProfile profile) {
    return {
      'id': profile.id,
      'lastName': profile.lastName,
      'firstName': profile.firstName,
      'address': profile.address,
      'maritalStatus': profile.maritalStatus,
      'dependentChildren': profile.dependentChildren,
      'avatarUrl': profile.avatarUrl,
      'phone': profile.phone,
      'email': profile.email,
      'birthDate': profile.birthDate?.toIso8601String(),
      'nationality': profile.nationality,
      'createdAt': profile.createdAt.toIso8601String(),
      'employmentStatus': profile.employmentStatus,
      'companyName': profile.companyName,
      'companyAddress': profile.companyAddress,
      'jobTitle': profile.jobTitle,
      'workTimePercentage': profile.workTimePercentage,
      'weeklyHours': profile.weeklyHours,
      'overtimeHours': profile.overtimeHours,
      'grossMonthlySalary': profile.grossMonthlySalary,
      'taxSystem': profile.taxSystem,
      'isNonCadre': profile.isNonCadre,
      'conventionalBonusMonths': profile.conventionalBonusMonths,
      'companyEntryDate': profile.companyEntryDate?.toIso8601String(),
      'mutualEmployeeCost': profile.mutualEmployeeCost,
      'transport': profile.transport,
      'mealExpenses': profile.mealExpenses,
      'mealAllowance': profile.mealAllowance,
      'mealTicketValue': profile.mealTicketValue,
      'mealTicketsPerMonth': profile.mealTicketsPerMonth,
      'childcareType': profile.childcareType,
      'childcareCost': profile.childcareCost,
      'childcareAids': profile.childcareAids,
      'workDaysPerWeek': profile.workDaysPerWeek,
      'remoteDaysPerWeek': profile.remoteDaysPerWeek,
      'remoteAllowance': profile.remoteAllowance,
      'remoteExpenses': profile.remoteExpenses,
      'remoteEquipment': profile.remoteEquipment,
      'workClothing': profile.workClothing,
      'professionalEquipment': profile.professionalEquipment,
      'trainingCost': profile.trainingCost,
      'unionFees': profile.unionFees,
      'fiscalRegime': profile.fiscalRegime,
      'withholdingRate': profile.withholdingRate,
      'fiscalParts': profile.fiscalParts,
      'deductibleCSG': profile.deductibleCSG,
      'additionalDeductions': profile.additionalDeductions,
    };
  }
  
  UserProfile _profileFromJson(Map<String, dynamic> json) {
    // Migration des anciennes données workTime vers workTimePercentage/weeklyHours
    double workTimePercentage = 100.0;
    double weeklyHours = 35.0;
    
    // Si les nouvelles données existent, les utiliser
    if (json['workTimePercentage'] != null && json['weeklyHours'] != null) {
      workTimePercentage = (json['workTimePercentage'] as num).toDouble();
      weeklyHours = (json['weeklyHours'] as num).toDouble();
    } else if (json['workTime'] != null) {
      // Migration depuis l'ancien format workTime
      final oldWorkTime = json['workTime'] as String;
      switch (oldWorkTime) {
        case 'Temps plein':
          workTimePercentage = 100.0;
          weeklyHours = 35.0;
          break;
        case 'Temps partiel 90%':
          workTimePercentage = 90.0;
          weeklyHours = 31.5;
          break;
        case 'Temps partiel 80%':
          workTimePercentage = 80.0;
          weeklyHours = 28.0;
          break;
        case 'Temps partiel 70%':
          workTimePercentage = 70.0;
          weeklyHours = 24.5;
          break;
        case 'Temps partiel 60%':
          workTimePercentage = 60.0;
          weeklyHours = 21.0;
          break;
        case 'Temps partiel 50%':
        case 'Mi-temps':
          workTimePercentage = 50.0;
          weeklyHours = 17.5;
          break;
        case 'Temps partiel 30%':
          workTimePercentage = 30.0;
          weeklyHours = 10.5;
          break;
        case 'Temps partiel 20%':
          workTimePercentage = 20.0;
          weeklyHours = 7.0;
          break;
        default:
          workTimePercentage = 100.0;
          weeklyHours = 35.0;
      }
    }
    
    return UserProfile(
      id: json['id'] as String,
      lastName: json['lastName'] as String,
      firstName: json['firstName'] as String,
      address: json['address'] as String? ?? '',
      maritalStatus: json['maritalStatus'] as String? ?? 'Non renseigné',
      dependentChildren: (json['dependentChildren'] as int?) ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      nationality: json['nationality'] as String? ?? 'France',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      employmentStatus: json['employmentStatus'] as String? ?? 'Salarié(e) CDI',
      companyName: json['companyName'] as String?,
      companyAddress: json['companyAddress'] as String?,
      jobTitle: json['jobTitle'] as String?,
      workTimePercentage: workTimePercentage,
      weeklyHours: weeklyHours,
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0.0,
      grossMonthlySalary: (json['grossMonthlySalary'] as num?)?.toDouble() ?? 0.0,
      taxSystem: json['taxSystem'] as String? ?? 'Prélèvement à la source',
      isNonCadre: json['isNonCadre'] as bool?,
      conventionalBonusMonths: (json['conventionalBonusMonths'] as num?)?.toDouble() ?? 0.0,
      companyEntryDate: json['companyEntryDate'] != null 
          ? DateTime.parse(json['companyEntryDate'] as String)
          : null,
      mutualEmployeeCost: (json['mutualEmployeeCost'] as num?)?.toDouble() ?? 0.0,
      transport: json['transport'] as Map<String, dynamic>?,
      mealExpenses: (json['mealExpenses'] as num?)?.toDouble(),
      mealAllowance: (json['mealAllowance'] as num?)?.toDouble(),
      mealTicketValue: (json['mealTicketValue'] as num?)?.toDouble(),
      mealTicketsPerMonth: json['mealTicketsPerMonth'] as int?,
      childcareType: json['childcareType'] as String?,
      childcareCost: (json['childcareCost'] as num?)?.toDouble(),
      childcareAids: (json['childcareAids'] as num?)?.toDouble(),
      workDaysPerWeek: (json['workDaysPerWeek'] as num?)?.toDouble(),
      remoteDaysPerWeek: (json['remoteDaysPerWeek'] as num?)?.toDouble(),
      remoteAllowance: (json['remoteAllowance'] as num?)?.toDouble(),
      remoteExpenses: (json['remoteExpenses'] as num?)?.toDouble(),
      remoteEquipment: (json['remoteEquipment'] as num?)?.toDouble(),
      workClothing: (json['workClothing'] as num?)?.toDouble(),
      professionalEquipment: (json['professionalEquipment'] as num?)?.toDouble(),
      trainingCost: (json['trainingCost'] as num?)?.toDouble(),
      unionFees: (json['unionFees'] as num?)?.toDouble(),
      fiscalRegime: json['fiscalRegime'] as String?,
      withholdingRate: (json['withholdingRate'] as num?)?.toDouble(),
      fiscalParts: (json['fiscalParts'] as num?)?.toDouble(),
      deductibleCSG: (json['deductibleCSG'] as num?)?.toDouble(),
      additionalDeductions: (json['additionalDeductions'] as num?)?.toDouble(),
    );
  }
}