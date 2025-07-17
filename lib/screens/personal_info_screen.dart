import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/profile_avatar.dart';
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

  // États d'expansion des sections
  bool _identityExpanded = false;
  bool _contactExpanded = false;
  bool _familyExpanded = false;

  // Système de tracking des erreurs par section
  final Map<String, bool> _sectionHasError = {
    'identity': false,
    'contact': false,
    'family': false,
  };

  final Map<String, bool> _sectionIsComplete = {
    'identity': false,
    'contact': false,
    'family': false,
  };


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
    
    // Mettre à jour l'état des erreurs
    _updateSectionErrorStatus();
    
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

  // Méthodes de validation par section
  bool _hasIdentityErrors() {
    return Validators.validateName(_lastNameController.text, AppStrings.lastName) != null ||
           Validators.validateName(_firstNameController.text, AppStrings.firstName) != null;
  }

  bool _hasContactErrors() {
    return Validators.validateAddress(_addressController.text) != null ||
           Validators.validatePhone(_phoneController.text) != null ||
           Validators.validateEmail(_emailController.text) != null;
  }

  bool _hasFamilyErrors() {
    // Pas d'erreurs possibles dans la section famille pour le moment
    return false;
  }

  bool _isIdentityComplete() {
    return _lastNameController.text.isNotEmpty && 
           _firstNameController.text.isNotEmpty &&
           _birthDate != null;
  }

  bool _isContactComplete() {
    return _addressController.text.isNotEmpty;
  }

  bool _isFamilyComplete() {
    return true; // Toujours complète car pas de champs obligatoires
  }

  void _updateSectionErrorStatus() {
    setState(() {
      _sectionHasError['identity'] = _hasIdentityErrors();
      _sectionHasError['contact'] = _hasContactErrors();
      _sectionHasError['family'] = _hasFamilyErrors();
      
      _sectionIsComplete['identity'] = _isIdentityComplete() && !_hasIdentityErrors();
      _sectionIsComplete['contact'] = _isContactComplete() && !_hasContactErrors();
      _sectionIsComplete['family'] = _isFamilyComplete() && !_hasFamilyErrors();
    });
  }

  String _findFirstErrorSection() {
    if (_sectionHasError['identity']!) return 'identity';
    if (_sectionHasError['contact']!) return 'contact';
    if (_sectionHasError['family']!) return 'family';
    return '';
  }

  void _validateAndShowErrors() {
    _updateSectionErrorStatus();
    if (!_formKey.currentState!.validate()) {
      String errorSection = _findFirstErrorSection();
      
      // Ouvrir automatiquement la section avec erreur
      if (errorSection.isNotEmpty) {
        setState(() {
          if (errorSection == 'identity') _identityExpanded = true;
          if (errorSection == 'contact') _contactExpanded = true;
          if (errorSection == 'family') _familyExpanded = true;
        });
        
        // Guider l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur dans la section "$errorSection" - section ouverte'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    }
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
            // Déclencher la validation avec indicateurs visuels
            _validateAndShowErrors();
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
              // Section 1 - Identité
              Card(
                child: ExpansionTile(
                  initiallyExpanded: _identityExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _identityExpanded = expanded;
                    });
                  },
                  shape: const Border(),
                  title: Row(
                    children: [
                      Text(
                        AppStrings.identitySection,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_sectionHasError['identity']!) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const Text(' (erreur)', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ] else if (_sectionIsComplete['identity']!) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ]
                    ],
                  ),
                  backgroundColor: _sectionHasError['identity']! 
                    ? Colors.red.withValues(alpha: 0.1) 
                    : Colors.transparent,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        children: [
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
                      GestureDetector(
                        onDoubleTap: () {
                          // Activer la saisie manuelle sur double-tap
                          _showManualBirthDateInput();
                        },
                        child: TextFormField(
                          readOnly: true,
                          onTap: _selectBirthDate,
                          decoration: const InputDecoration(
                            labelText: AppStrings.birthDate,
                            hintText: AppStrings.selectDateHint,
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: _birthDate != null
                                ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                                : '',
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Section 2 - Coordonnées
              Card(
                child: ExpansionTile(
                  initiallyExpanded: _contactExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _contactExpanded = expanded;
                    });
                  },
                  shape: const Border(),
                  title: Row(
                    children: [
                      Text(
                        AppStrings.contactSection,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_sectionHasError['contact']!) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const Text(' (erreur)', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ] else if (_sectionIsComplete['contact']!) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ]
                    ],
                  ),
                  backgroundColor: _sectionHasError['contact']! 
                    ? Colors.red.withValues(alpha: 0.1) 
                    : Colors.transparent,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Section 3 - Situation familiale
              Card(
                child: ExpansionTile(
                  initiallyExpanded: _familyExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _familyExpanded = expanded;
                    });
                  },
                  shape: const Border(),
                  title: Row(
                    children: [
                      Text(
                        AppStrings.familySection,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_sectionHasError['family']!) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const Text(' (erreur)', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ] else if (_sectionIsComplete['family']!) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ]
                    ],
                  ),
                  backgroundColor: _sectionHasError['family']! 
                    ? Colors.red.withValues(alpha: 0.1) 
                    : Colors.transparent,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
        ),
      ),
      ),
    );
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

  void _showManualBirthDateInput() {
    final TextEditingController dateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Saisir la date de naissance'),
          content: TextFormField(
            controller: dateController,
            decoration: const InputDecoration(
              labelText: 'Date de naissance',
              hintText: 'jj/mm/aaaa',
              border: OutlineInputBorder(),
              helperText: 'Format : 17/07/1990',
            ),
            keyboardType: TextInputType.datetime,
            autofocus: true,
            onChanged: (value) {
              // Formater automatiquement avec des slashes
              String formatted = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (formatted.length > 2) {
                formatted = '${formatted.substring(0, 2)}/${formatted.substring(2)}';
              }
              if (formatted.length > 5) {
                formatted = '${formatted.substring(0, 5)}/${formatted.substring(5)}';
              }
              if (formatted.length > 10) {
                formatted = formatted.substring(0, 10);
              }
              
              if (formatted != value) {
                dateController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final dateText = dateController.text;
                if (dateText.length == 10) {
                  try {
                    final parts = dateText.split('/');
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);
                    
                    final date = DateTime(year, month, day);
                    
                    // Vérifier que la date est valide et dans la plage autorisée
                    if (date.isAfter(DateTime(1899)) && date.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                      setState(() {
                        _birthDate = date;
                      });
                      _updateProfile();
                      Navigator.of(context).pop();
                    } else {
                      // Afficher erreur de plage
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Date invalide : doit être entre 1900 et aujourd\'hui')),
                      );
                    }
                  } catch (e) {
                    // Afficher erreur de format
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Format invalide : utilisez jj/mm/aaaa')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Date incomplète : utilisez le format jj/mm/aaaa')),
                  );
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

}