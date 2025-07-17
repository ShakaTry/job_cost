import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../constants/app_strings.dart';
import '../utils/validators.dart';
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
                                  if (profile.email == 'sophie.martin@example.com')
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Profil de démonstration',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
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
    final demoProfile = UserProfile.create(
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
      companyEntryDate: DateTime(2020, 3, 15), // Il y a ~4 ans
      mutualEmployeeCost: 35.0, // Part salarié mutuelle
      transport: {
        'mode': 'Voiture personnelle',
        'vehicleType': 'Voiture',
        'fuelType': 'Essence',
        'fiscalPower': 5,
        'dailyDistance': 25.0,
        'publicTransportCost': null,
        'parkingCost': 120.0,
        'tollsCost': 45.0,
        'employerReimbursement': 50.0,
      },
      // Frais professionnels - COMPLET
      mealTicketValue: 9.50, // Valeur titre-restaurant (classique)
      mealTicketsPerMonth: 19, // 19 jours travaillés au bureau
      mealExpenses: 120.0, // Frais de repas hors titres (6€/jour * 20 jours)
      mealAllowance: 0.0, // Pas d'indemnité repas supplémentaire
      childcareType: 'Assistant(e) maternel(le)',
      childcareCost: 850.0, // Coût mensuel garde (2 enfants)
      childcareAids: 294.0, // Aides CAF pour 2 enfants
      workDaysPerWeek: 5, // 5 jours par semaine
      remoteDaysPerWeek: 2, // 2 jours de télétravail
      remoteAllowance: 50.0, // Forfait télétravail employeur (2.5€/jour)
      remoteExpenses: 45.0, // Internet + électricité (estimation)
      remoteEquipment: 20.0, // Amortissement bureau/chaise (1000€ sur 4 ans)
      workClothing: 30.0, // Vêtements professionnels
      professionalEquipment: 15.0, // Souris/clavier ergonomiques
      trainingCost: 50.0, // Formation en ligne non remboursée
      unionFees: 18.0, // Cotisations syndicales CGT
    );

    setState(() {
      _profiles.add(demoProfile);
    });
    
    // Sauvegarder le profil
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
                Text('Profil créé'),
              ],
            ),
            content: const Text(
              'Le profil de démonstration "Sophie Martin" a été créé avec succès.\n\n'
              'Vous pouvez maintenant explorer toutes les fonctionnalités de l\'application.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectProfile(demoProfile);
                },
                child: const Text('Ouvrir le profil'),
              ),
            ],
          );
        },
      );
    }
  }
}