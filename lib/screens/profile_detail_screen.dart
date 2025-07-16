import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import 'personal_info_screen.dart';

class ProfileDetailScreen extends StatelessWidget {
  final UserProfile profile;
  
  const ProfileDetailScreen({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(profile.fullName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    profile.firstName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Votre situation actuelle',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSectionCard(
                context,
                icon: Icons.person,
                title: 'Informations personnelles',
                subtitle: 'Nom, adresse, situation familiale',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalInfoScreen(profile: profile),
                    ),
                  );
                },
              ),
              
              _buildSectionCard(
                context,
                icon: Icons.work,
                title: 'Situation professionnelle actuelle',
                subtitle: 'Emploi actuel, statut, régime fiscal',
                onTap: () {
                  // TODO: Navigation
                },
              ),
              
              _buildSectionCard(
                context,
                icon: Icons.directions_car,
                title: 'Transport & Déplacements',
                subtitle: 'Mode de transport, distance domicile-travail',
                onTap: () {
                  // TODO: Navigation
                },
              ),
              
              _buildSectionCard(
                context,
                icon: Icons.receipt_long,
                title: 'Frais professionnels',
                subtitle: 'Repas, garde d\'enfants, équipements',
                onTap: () {
                  // TODO: Navigation
                },
              ),
              
              _buildSectionCard(
                context,
                icon: Icons.account_balance,
                title: 'Paramètres fiscaux',
                subtitle: 'Taux d\'imposition, crédits d\'impôt',
                onTap: () {
                  // TODO: Navigation
                },
              ),
              
              const SizedBox(height: 24),
              
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Supprimer le profil'),
                      content: Text('Voulez-vous vraiment supprimer le profil de ${profile.fullName} ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context, 'delete');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Supprimer ce profil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}