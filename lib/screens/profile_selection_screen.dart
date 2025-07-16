import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import 'add_profile_screen.dart';

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
      address: '15 rue du Commerce, 75015 Paris',
      maritalStatus: 'Marié(e)',
      dependentChildren: 2,
    ),
    UserProfile.create(
      lastName: 'Martin', 
      firstName: 'Sophie',
      address: '8 avenue Victor Hugo, 69002 Lyon',
      maritalStatus: 'Célibataire',
      dependentChildren: 0,
    ),
    UserProfile.create(
      lastName: 'Bernard', 
      firstName: 'Pierre',
      address: '23 boulevard de la Liberté, 59000 Lille',
      maritalStatus: 'Divorcé(e)',
      dependentChildren: 1,
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
                                  const SizedBox(height: 4),
                                  Text(
                                    '${profile.maritalStatus} • ${profile.dependentChildren} enfant${profile.dependentChildren > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
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

  void _selectProfile(UserProfile profile) {
    // TODO: Navigation vers l'écran principal avec le profil sélectionné
    // Pour l'instant, on affiche juste un message temporaire
    debugPrint('Profil sélectionné: ${profile.name}');
  }

  void _addNewProfile() async {
    final UserProfile? newProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProfileScreen(),
      ),
    );

    if (newProfile != null) {
      setState(() {
        _profiles.add(newProfile);
      });
    }
  }
}