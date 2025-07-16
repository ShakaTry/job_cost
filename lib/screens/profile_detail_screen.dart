import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/info_container.dart';
import '../constants/app_strings.dart';
import 'personal_info_screen.dart';
import 'professional_situation_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  final UserProfile profile;
  
  const ProfileDetailScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late UserProfile profile;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, profile);
        }
      },
      child: Scaffold(
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
                child: ProfileAvatar(
                  firstName: profile.firstName,
                  radius: 50,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 16),
              const InfoContainer(
                text: AppStrings.currentSituation,
                isBold: true,
              ),
              const SizedBox(height: 16),
              
              _buildSectionCard(
                context,
                icon: Icons.person,
                title: AppStrings.personalInfoSectionTitle,
                subtitle: AppStrings.personalInfoSectionSubtitle,
                onTap: () async {
                  try {
                    final updatedProfile = await Navigator.push<UserProfile>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoScreen(profile: profile),
                      ),
                    );
                    
                    if (updatedProfile != null && mounted) {
                      setState(() {
                        profile = updatedProfile;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur de navigation: $e')),
                      );
                    }
                  }
                },
              ),
              
              _buildSectionCard(
                context,
                icon: Icons.work,
                title: AppStrings.professionalSituationTitle,
                subtitle: AppStrings.professionalSituationSubtitle,
                onTap: () async {
                  try {
                    final updatedProfile = await Navigator.push<UserProfile>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfessionalSituationScreen(profile: profile),
                      ),
                    );
                    
                    if (updatedProfile != null && mounted) {
                      setState(() {
                        profile = updatedProfile;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur de navigation: $e')),
                      );
                    }
                  }
                },
              ),
              
              _buildSectionCard(
                context,
                icon: Icons.directions_car,
                title: AppStrings.transportTitle,
                subtitle: AppStrings.transportSubtitle,
                onTap: () {
                  // TODO: Navigation
                },
              ),
              
              _buildSectionCard(
                context,
                icon: Icons.receipt_long,
                title: AppStrings.professionalExpensesTitle,
                subtitle: AppStrings.professionalExpensesSubtitle,
                onTap: () {
                  // TODO: Navigation
                },
              ),
              
              _buildSectionCard(
                context,
                icon: Icons.account_balance,
                title: AppStrings.taxParametersTitle,
                subtitle: AppStrings.taxParametersSubtitle,
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
                      title: const Text(AppStrings.deleteProfileTitle),
                      content: Text('${AppStrings.deleteProfileMessage} ${profile.fullName} ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(AppStrings.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context, 'delete');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text(AppStrings.delete),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(AppStrings.deleteProfile),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
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
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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