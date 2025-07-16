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
      'jobTitle': profile.jobTitle,
      'workTime': profile.workTime,
      'grossMonthlySalary': profile.grossMonthlySalary,
      'taxSystem': profile.taxSystem,
    };
  }
  
  UserProfile _profileFromJson(Map<String, dynamic> json) {
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
      employmentStatus: json['employmentStatus'] as String? ?? 'Sans emploi',
      companyName: json['companyName'] as String?,
      jobTitle: json['jobTitle'] as String?,
      workTime: json['workTime'] as String? ?? 'Temps plein',
      grossMonthlySalary: (json['grossMonthlySalary'] as num?)?.toDouble() ?? 0.0,
      taxSystem: json['taxSystem'] as String? ?? 'Prélèvement à la source',
    );
  }
}