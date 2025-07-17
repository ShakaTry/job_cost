import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../constants/app_strings.dart';
import '../utils/validators.dart';
import '../utils/profile_validator.dart';
import '../services/profile_service.dart';
import 'profile_detail_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  final ProfileService _profileService = ProfileService();
  List<UserProfile> _profiles = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }
  
  Future<void> _loadProfiles() async {
    try {
      final profiles = await _profileService.loadProfiles();
      if (mounted) {
        setState(() {
          _profiles = profiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(AppStrings.selectProfileTitle),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(AppStrings.selectProfileTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: _profiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun profil créé',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Créez votre premier profil',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 32),
                          OutlinedButton.icon(
                            onPressed: _createDemoProfile,
                            icon: const Icon(Icons.science),
                            label: const Text('Créer un profil de démonstration'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final profile = _profiles[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        _selectProfile(profile);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ProfileAvatar(
                              firstName: profile.firstName,
                              radius: 30,
                              fontSize: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (profile.email == 'sophie.martin@example.com' || profile.email == 'marc.durand@invalid')
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profile.email == 'sophie.martin@example.com' 
                                          ? Colors.green.shade100 
                                          : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        profile.email == 'sophie.martin@example.com' 
                                          ? 'Profil de démonstration (complet)'
                                          : 'Profil de démonstration (avec erreurs)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: profile.email == 'sophie.martin@example.com' 
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  _buildProfileValidationInfo(profile),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                _buildValidationIcon(ProfileValidator.getOverallProfileStatus(profile)),
                                const SizedBox(height: 4),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addNewProfile,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addNewProfile),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectProfile(UserProfile profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(profile: profile),
      ),
    );
    
    if (result == 'delete') {
      setState(() {
        _profiles.remove(profile);
      });
      await _profileService.saveProfiles(_profiles);
    } else if (result is UserProfile) {
      // Mettre à jour le profil dans la liste
      setState(() {
        final index = _profiles.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          _profiles[index] = result;
        }
      });
      await _profileService.saveProfiles(_profiles);
    }
  }

  void _addNewProfile() async {
    final formKey = GlobalKey<FormState>();
    final lastNameController = TextEditingController();
    final firstNameController = TextEditingController();

    final UserProfile? newProfile = await showDialog<UserProfile>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.newProfileTitle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.lastName,
                    hintText: AppStrings.lastNameHint,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  validator: (value) => Validators.validateName(value, AppStrings.lastName),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.firstName,
                    hintText: AppStrings.firstNameHint,
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.validateName(value, AppStrings.firstName),
                  onFieldSubmitted: (_) {
                    if (formKey.currentState!.validate()) {
                      final profile = UserProfile.create(
                        lastName: lastNameController.text,
                        firstName: firstNameController.text,
                      );
                      Navigator.of(context).pop(profile);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final profile = UserProfile.create(
                    lastName: lastNameController.text,
                    firstName: firstNameController.text,
                  );
                  Navigator.of(context).pop(profile);
                }
              },
              child: const Text(AppStrings.create),
            ),
          ],
        );
      },
    );

    if (newProfile != null) {
      setState(() {
        _profiles.add(newProfile);
      });
      
      // Sauvegarder les profils
      await _profileService.saveProfiles(_profiles);
      
      // Naviguer directement vers le profil créé
      if (mounted) {
        final updatedProfile = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(profile: newProfile),
          ),
        );
        
        if (updatedProfile is UserProfile) {
          setState(() {
            final index = _profiles.indexWhere((p) => p.id == updatedProfile.id);
            if (index != -1) {
              _profiles[index] = updatedProfile;
            }
          });
          await _profileService.saveProfiles(_profiles);
        }
      }
    }
  }

  void _createDemoProfile() async {
    // PROFIL 1 : Sophie Martin - COMPLET ET VALIDE
    final demoProfileComplete = UserProfile.create(
      lastName: 'Martin',
      firstName: 'Sophie',
      address: '15 rue de la République, 75001 Paris',
      maritalStatus: 'Marié(e)',
      dependentChildren: 2,
      phone: '06 12 34 56 78',
      email: 'sophie.martin@example.com',
      birthDate: DateTime(1985, 6, 15),
      nationality: 'France',
      employmentStatus: 'Salarié(e) CDI',
      companyName: 'Tech Solutions SARL',
      companyAddress: '50 avenue des Champs-Élysées, 75008 Paris',
      jobTitle: 'Développeuse Full Stack',
      workTimePercentage: 100.0,
      weeklyHours: 35.0,
      overtimeHours: 4.0,
      grossMonthlySalary: 3500,
      taxSystem: 'Prélèvement à la source',
      isNonCadre: true,
      conventionalBonusMonths: 1.0,
      companyEntryDate: DateTime(2020, 3, 15),
      mutualEmployeeCost: 35.0,
      transport: {
        'mode': 'Voiture personnelle',
        'vehicleType': 'Voiture',
        'fuelType': 'Essence',
        'fiscalPower': 5,
        'dailyDistance': 25.0,
        'distanceToWork': 25.0, // Distance domicile-travail aller simple
        'publicTransportCost': null,
        'parkingCost': 120.0,
        'tollsCost': 45.0,
        'employerReimbursement': 50.0,
      },
      // Frais professionnels - COMPLET
      mealTicketValue: 9.50,
      mealTicketsPerMonth: 19,
      mealExpenses: 120.0,
      mealAllowance: 80.0,
      childcareType: 'Assistant(e) maternel(le)',
      childcareCost: 850.0,
      childcareAids: 294.0,
      workDaysPerWeek: 5,
      remoteDaysPerWeek: 2,
      remoteAllowance: 50.0,
      remoteExpenses: 45.0,
      remoteEquipment: 20.0,
      workClothing: 30.0,
      professionalEquipment: 15.0,
      trainingCost: 50.0,
      unionFees: 18.0,
      // Paramètres fiscaux - AJOUT COMPLET
      fiscalRegime: 'Frais réels',
      withholdingRate: 12.5, // Taux de prélèvement à la source
      fiscalParts: 2.5, // Mariée + 2 enfants (2 + 0.5*2 = 3, mais plafonné)
      deductibleCSG: 6.8, // CSG déductible standard
      additionalDeductions: 25.0, // Autres déductions mensuelles
    );

    // PROFIL 2 : Marc Durand - AVEC ERREURS VOLONTAIRES
    final demoProfileWithErrors = UserProfile.create(
      lastName: 'Durand',
      firstName: 'Marc',
      address: '', // ERREUR : Adresse vide
      maritalStatus: 'Célibataire',
      dependentChildren: 1,
      phone: '123456', // ERREUR : Format téléphone invalide
      email: 'marc.durand@invalid', // ERREUR : Email invalide
      birthDate: DateTime(1990, 12, 10),
      nationality: 'France',
      employmentStatus: 'Salarié(e) CDI',
      companyName: 'Digital Corp',
      companyAddress: '25 boulevard Voltaire, 75011 Paris',
      jobTitle: 'Chef de projet',
      workTimePercentage: 100.0,
      weeklyHours: 35.0,
      overtimeHours: 2.0,
      grossMonthlySalary: 4200,
      taxSystem: 'Prélèvement à la source',
      isNonCadre: false,
      conventionalBonusMonths: 1.0,
      companyEntryDate: DateTime(2021, 9, 1),
      mutualEmployeeCost: 45.0,
      transport: {
        'mode': 'Voiture personnelle',
        'vehicleType': 'Voiture',
        'fuelType': 'Diesel',
        'fiscalPower': 6,
        'dailyDistance': 35.0,
        'distanceToWork': 35.0,
        'publicTransportCost': null,
        'parkingCost': 150.0,
        'tollsCost': 25.0,
        'employerReimbursement': 40.0,
      },
      // Frais professionnels avec erreurs
      mealTicketValue: 8.50,
      mealTicketsPerMonth: 20,
      mealExpenses: -50.0, // ERREUR : Valeur négative
      mealAllowance: 60.0,
      childcareType: 'Crèche',
      childcareCost: -200.0, // ERREUR : Valeur négative
      childcareAids: 150.0,
      workDaysPerWeek: 15, // ERREUR : Plus de 7 jours par semaine
      remoteDaysPerWeek: 1,
      remoteAllowance: 30.0,
      remoteExpenses: 35.0,
      remoteEquipment: 15.0,
      workClothing: 25.0,
      professionalEquipment: 10.0,
      trainingCost: 75.0,
      unionFees: 12.0,
      // Paramètres fiscaux
      fiscalRegime: 'Forfaitaire',
      withholdingRate: 8.2,
      fiscalParts: 1.5, // Célibataire + 1 enfant
      deductibleCSG: 6.8,
      additionalDeductions: 15.0,
    );

    setState(() {
      _profiles.add(demoProfileComplete);
      _profiles.add(demoProfileWithErrors);
    });
    
    // Sauvegarder les profils
    await _profileService.saveProfiles(_profiles);
    
    // Afficher un message de confirmation
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Profils créés'),
              ],
            ),
            content: const Text(
              'Deux profils de démonstration ont été créés :\n\n'
              '• Sophie Martin (complet et valide)\n'
              '• Marc Durand (avec erreurs à corriger)\n\n'
              'Vous pouvez maintenant explorer la validation des profils.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectProfile(demoProfileComplete);
                },
                child: const Text('Voir Sophie Martin'),
              ),
            ],
          );
        },
      );
    }
  }

  // Widget pour l'icône de validation globale
  Widget _buildValidationIcon(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.valid:
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
      case ValidationStatus.error:
        return const Icon(Icons.error, color: Colors.red, size: 24);
      case ValidationStatus.incomplete:
        return const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24);
    }
  }

  // Widget pour afficher les informations de validation du profil
  Widget _buildProfileValidationInfo(UserProfile profile) {
    final completedSections = ProfileValidator.getCompletedSectionsCount(profile);
    final totalSections = ProfileValidator.totalSectionsCount;
    final status = ProfileValidator.getOverallProfileStatus(profile);

    String statusText;
    Color statusColor;

    switch (status) {
      case ValidationStatus.valid:
        statusText = 'Profil complet';
        statusColor = Colors.green;
        break;
      case ValidationStatus.error:
        statusText = 'Erreurs à corriger';
        statusColor = Colors.red;
        break;
      case ValidationStatus.incomplete:
        statusText = '$completedSections/$totalSections sections';
        statusColor = Colors.grey.shade600;
        break;
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 12,
        color: statusColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}