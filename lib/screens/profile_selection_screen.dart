import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import 'profile_detail_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  final List<UserProfile> _profiles = [
    UserProfile.create(
      lastName: 'Dupont', 
      firstName: 'Jean',
    ),
    UserProfile.create(
      lastName: 'Martin', 
      firstName: 'Sophie',
    ),
    UserProfile.create(
      lastName: 'Bernard', 
      firstName: 'Pierre',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez votre profil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
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
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                profile.firstName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                profile.fullName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
              label: const Text('Ajouter un nouveau profil'),
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
    } else if (result is UserProfile) {
      // Mettre à jour le profil dans la liste
      setState(() {
        final index = _profiles.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          _profiles[index] = result;
        }
      });
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
          title: const Text('Nouveau profil'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    hintText: 'Ex: Dupont',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    if (value.length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    hintText: 'Ex: Jean',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prénom';
                    }
                    if (value.length < 2) {
                      return 'Le prénom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
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
              child: const Text('Annuler'),
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
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    if (newProfile != null) {
      setState(() {
        _profiles.add(newProfile);
      });
      
      // Naviguer directement vers le profil créé
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(profile: newProfile),
          ),
        );
      }
    }
  }
}