import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/info_container.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../utils/validators.dart';
import '../services/profile_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  final UserProfile profile;
  
  const PersonalInfoScreen({
    super.key,
    required this.profile,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _maritalStatus;
  late int _dependentChildren;
  late DateTime? _birthDate;
  late String _nationality;
  late UserProfile _modifiedProfile;


  @override
  void initState() {
    super.initState();
    _modifiedProfile = widget.profile;
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _addressController = TextEditingController(text: widget.profile.address);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _maritalStatus = widget.profile.maritalStatus == AppConstants.defaultMaritalStatus 
        ? AppConstants.maritalStatusOptions.first 
        : widget.profile.maritalStatus;
    _dependentChildren = widget.profile.dependentChildren;
    _birthDate = widget.profile.birthDate;
    _nationality = widget.profile.nationality;
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    _modifiedProfile = _modifiedProfile.copyWith(
      lastName: _lastNameController.text,
      firstName: _firstNameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      maritalStatus: _maritalStatus,
      dependentChildren: _dependentChildren,
      birthDate: _birthDate,
      nationality: _nationality,
    );
    
    // Sauvegarder automatiquement le profil
    _profileService.updateProfile(_modifiedProfile);
  }

  void _saveValidFieldsOnly() {
    // Valider le téléphone
    String phoneValue = _phoneController.text;
    if (!Validators.isPhoneValid(phoneValue)) {
      phoneValue = '';
      _phoneController.text = '';
    }

    // Valider l'email
    String emailValue = _emailController.text;
    if (!Validators.isEmailValid(emailValue)) {
      emailValue = '';
      _emailController.text = '';
    }

    // Sauvegarder avec les valeurs validées
    _modifiedProfile = _modifiedProfile.copyWith(
      lastName: _lastNameController.text,
      firstName: _firstNameController.text,
      address: _addressController.text,
      phone: phoneValue,
      email: emailValue,
      maritalStatus: _maritalStatus,
      dependentChildren: _dependentChildren,
      birthDate: _birthDate,
      nationality: _nationality,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (_formKey.currentState!.validate()) {
            _updateProfile();
            Navigator.pop(context, _modifiedProfile);
          } else {
            // Afficher un dialogue de confirmation
            final bool? shouldExit = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(AppStrings.invalidDataTitle),
                  content: const Text(
                    AppStrings.invalidDataMessage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(AppStrings.stayAndCorrect),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text(AppStrings.exitWithoutSaving),
                    ),
                  ],
                );
              },
            );
            
            if (shouldExit == true && mounted) {
              // Sauvegarder les champs valides et réinitialiser les invalides
              _saveValidFieldsOnly();
              // ignore: use_build_context_synchronously
              Navigator.pop(context, _modifiedProfile);
            }
          }
        }
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            ProfileAvatar(
              firstName: _modifiedProfile.firstName,
              radius: AppConstants.smallAvatarRadius,
              fontSize: AppConstants.smallAvatarFontSize,
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _modifiedProfile.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppStrings.personalInfoTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ProfileAvatar(
                  firstName: _firstNameController.text,
                  radius: 60,
                  fontSize: 48,
                  showEditButton: true,
                  onEditPressed: _pickImage,
                ),
              ),
              const SizedBox(height: 32),
              
              // Section Identité
              _buildSectionHeader(AppStrings.identitySection),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.lastName,
                  hintText: AppStrings.lastNameHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.validateName(value, AppStrings.lastName),
                onChanged: (_) => _updateProfile(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.firstName,
                  hintText: AppStrings.firstNameHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.validateName(value, AppStrings.firstName),
                onChanged: (value) {
                  if (mounted) setState(() {});
                  _updateProfile();
                },
                onFieldSubmitted: (_) {
                  // Ouvrir le date picker pour la date de naissance
                  _selectBirthDate();
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: AppStrings.birthDate,
                    hintText: AppStrings.selectDateHint,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate != null
                            ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                            : AppStrings.notSpecifiedDate,
                      ),
                      if (_birthDate != null)
                        Text(
                          '${_calculateAge()} ${AppStrings.yearsOld}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _nationality,
                decoration: const InputDecoration(
                  labelText: AppStrings.nationality,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: AppConstants.nationalityOptions.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    if (mounted) {
                      setState(() {
                        _nationality = newValue;
                      });
                    }
                    _updateProfile();
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              // Section Coordonnées
              _buildSectionHeader(AppStrings.contactSection),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: AppStrings.address,
                  hintText: AppStrings.addressHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                validator: Validators.validateAddress,
                onChanged: (_) => _updateProfile(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: AppStrings.phone,
                  hintText: AppStrings.phoneHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.validatePhone,
                onChanged: (value) {
                  // Formater automatiquement le numéro
                  final newValue = _formatPhoneNumber(value);
                  if (newValue != value) {
                    _phoneController.value = TextEditingValue(
                      text: newValue,
                      selection: TextSelection.collapsed(offset: newValue.length),
                    );
                  }
                  _updateProfile();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: AppStrings.email,
                  hintText: AppStrings.emailHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: Validators.validateEmail,
                onChanged: (_) => _updateProfile(),
              ),
              
              const SizedBox(height: 32),
              
              // Section Situation familiale
              _buildSectionHeader(AppStrings.familySection),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _maritalStatus,
                decoration: const InputDecoration(
                  labelText: AppStrings.maritalStatus,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                items: AppConstants.maritalStatusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    if (mounted) {
                      setState(() {
                        _maritalStatus = newValue;
                      });
                    }
                    _updateProfile();
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _dependentChildren,
                decoration: const InputDecoration(
                  labelText: AppStrings.dependentChildren,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.child_care),
                ),
                items: List.generate(11, (index) => index).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value == 0 ? AppStrings.none : '$value'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    if (mounted) {
                      setState(() {
                        _dependentChildren = newValue;
                      });
                    }
                    _updateProfile();
                  }
                },
              ),
              
              const SizedBox(height: 24),
              const InfoContainer(
                text: AppStrings.socialTaxInfo,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  int _calculateAge() {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month || 
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    return age;
  }

  String _formatPhoneNumber(String value) {
    // Enlever tous les caractères non numériques
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    
    // Limiter à 10 chiffres pour les numéros français
    if (cleaned.length > 10 && !cleaned.startsWith('33')) {
      cleaned = cleaned.substring(0, 10);
    }
    
    // Formater selon la longueur
    if (cleaned.length <= 2) {
      return cleaned;
    } else if (cleaned.length <= 4) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2)}';
    } else if (cleaned.length <= 6) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4)}';
    } else if (cleaned.length <= 8) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6)}';
    } else {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, cleaned.length > 10 ? 10 : cleaned.length)}';
    }
  }

  void _selectBirthDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (picked != null && picked != _birthDate) {
        if (mounted) {
          setState(() {
            _birthDate = picked;
          });
        }
        _updateProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection de la date: $e')),
        );
      }
    }
  }

  void _pickImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.profilePhotoTitle),
          content: const Text(AppStrings.profilePhotoInfo),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.ok),
            ),
          ],
        );
      },
    );
  }

}