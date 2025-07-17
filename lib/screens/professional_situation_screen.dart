import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../services/profile_service.dart';

class ProfessionalSituationScreen extends StatefulWidget {
  final UserProfile profile;
  
  const ProfessionalSituationScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ProfessionalSituationScreen> createState() => _ProfessionalSituationScreenState();
}

class _ProfessionalSituationScreenState extends State<ProfessionalSituationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  late TextEditingController _companyNameController;
  late TextEditingController _companyAddressController;
  late TextEditingController _jobTitleController;
  late TextEditingController _salaryController;
  late TextEditingController _hourlyRateController;
  late String _employmentStatus;
  late double _workTimePercentage;
  late TextEditingController _weeklyHoursController;
  late TextEditingController _overtimeHoursController;
  late double _bonusMonths;
  late UserProfile _modifiedProfile;
  late FocusNode _salaryFocusNode;
  late FocusNode _weeklyHoursFocusNode;
  late FocusNode _overtimeHoursFocusNode;
  late TextEditingController _mutualCostController;
  DateTime? _companyEntryDate;

  // États d'expansion des sections
  bool _employmentExpanded = false;
  bool _workTimeExpanded = false;
  bool _benefitsExpanded = false;

  // Système de tracking des erreurs par section
  final Map<String, bool> _sectionHasError = {
    'employment': false,
    'worktime': false,
    'benefits': false,
  };

  final Map<String, bool> _sectionIsComplete = {
    'employment': false,
    'worktime': false,
    'benefits': false,
  };

  @override
  void initState() {
    super.initState();
    _modifiedProfile = widget.profile;
    _companyNameController = TextEditingController(text: widget.profile.companyName ?? '');
    _companyAddressController = TextEditingController(text: widget.profile.companyAddress ?? '');
    _jobTitleController = TextEditingController(text: widget.profile.jobTitle ?? '');
    _salaryController = TextEditingController(
      text: widget.profile.grossMonthlySalary > 0 
        ? widget.profile.grossMonthlySalary.toStringAsFixed(2) 
        : ''
    );
    _hourlyRateController = TextEditingController();
    _employmentStatus = widget.profile.employmentStatus;
    _workTimePercentage = widget.profile.workTimePercentage;
    _weeklyHoursController = TextEditingController(text: widget.profile.weeklyHours.toStringAsFixed(2));
    _overtimeHoursController = TextEditingController(text: widget.profile.overtimeHours > 0 ? widget.profile.overtimeHours.toStringAsFixed(2) : '');
    _bonusMonths = widget.profile.conventionalBonusMonths;
    _companyEntryDate = widget.profile.companyEntryDate;
    _mutualCostController = TextEditingController(
      text: widget.profile.mutualEmployeeCost > 0 
        ? widget.profile.mutualEmployeeCost.toStringAsFixed(2) 
        : ''
    );
    _salaryFocusNode = FocusNode();
    _weeklyHoursFocusNode = FocusNode();
    _overtimeHoursFocusNode = FocusNode();
    
    // Initialiser les valeurs exactes
    _exactMonthlySalary = widget.profile.grossMonthlySalary;
    if (_exactMonthlySalary > 0) {
      final coefficient = widget.profile.weeklyHours / _dureeLegaleHebdo;
      final dureeReelle = _dureeLegaleMensuelle * coefficient;
      _exactHourlyRate = _exactMonthlySalary / dureeReelle;
      _hourlyRateController.text = _exactHourlyRate.toStringAsFixed(2);
    }
    
    // Sauvegarde automatique comme sur la page d'infos personnelles
    _companyNameController.addListener(() {
      _updateProfile();
    });
    _companyAddressController.addListener(() {
      _updateProfile();
    });
    _jobTitleController.addListener(() {
      _updateProfile();
    });
    _salaryController.addListener(() {
      if (!_isUpdating) {
        _updateHourlyFromSalary();
        _updateProfile();
        if (mounted) setState(() {});
      }
    });
    _hourlyRateController.addListener(() {
      if (!_isUpdating) {
        _updateSalaryFromHourly();
        _updateProfile();
        if (mounted) setState(() {});
      }
    });
    _weeklyHoursController.addListener(() {
      if (!_isUpdating) {
        _updatePercentageFromHours();
        // Recalculer avec les valeurs exactes pour maintenir la précision
        if (_exactMonthlySalary > 0) {
          _updateHourlyFromSalary();
        } else if (_exactHourlyRate > 0) {
          _updateSalaryFromHourly();
        }
        _updateProfile();
        if (mounted) setState(() {});
      }
    });
    _overtimeHoursController.addListener(() {
      _updateProfile();
      if (mounted) setState(() {});
    });
    _mutualCostController.addListener(() {
      _updateProfile();
    });
    
    // Formater le salaire quand l'utilisateur quitte le champ
    _salaryFocusNode.addListener(() {
      if (!_salaryFocusNode.hasFocus && !_isUpdating) {
        // Délai pour éviter les conflits avec les autres listeners
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _formatSalaryInput();
        });
      }
    });
    
    // Formater les heures quand l'utilisateur quitte les champs
    _weeklyHoursFocusNode.addListener(() {
      if (!_weeklyHoursFocusNode.hasFocus && !_isUpdating) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _formatHoursInput(_weeklyHoursController);
        });
      }
    });
    
    _overtimeHoursFocusNode.addListener(() {
      if (!_overtimeHoursFocusNode.hasFocus && !_isUpdating) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _formatHoursInput(_overtimeHoursController);
        });
      }
    });
    
    // Initialiser l'état des erreurs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSectionErrorStatus();
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _jobTitleController.dispose();
    _salaryController.dispose();
    _hourlyRateController.dispose();
    _weeklyHoursController.dispose();
    _overtimeHoursController.dispose();
    _mutualCostController.dispose();
    _salaryFocusNode.dispose();
    _weeklyHoursFocusNode.dispose();
    _overtimeHoursFocusNode.dispose();
    super.dispose();
  }


  void _formatSalaryInput() {
    final currentText = _salaryController.text.replaceAll(' ', '');
    if (currentText.isNotEmpty) {
      final salary = double.tryParse(currentText);
      if (salary != null) {
        _isUpdating = true;
        // Formater avec 2 décimales si c'est un nombre entier
        if (salary == salary.toInt()) {
          _salaryController.text = salary.toStringAsFixed(2);
        } else {
          _salaryController.text = salary.toString();
        }
        _isUpdating = false;
      }
    }
  }
  
  void _formatHoursInput(TextEditingController controller) {
    final currentText = controller.text;
    if (currentText.isNotEmpty) {
      final hours = double.tryParse(currentText);
      if (hours != null) {
        _isUpdating = true;
        controller.text = hours.toStringAsFixed(2);
        _isUpdating = false;
      }
    }
  }

  bool _isUpdating = false;
  
  // Variables pour conserver la précision maximale (selon documentation)
  double _exactHourlyRate = 0.0;
  double _exactMonthlySalary = 0.0;

  double _getCurrentMonthlySalary() {
    // Retourner la valeur exacte si disponible (précision maximale)
    if (_exactMonthlySalary > 0) {
      return _exactMonthlySalary;
    }
    final salaryText = _salaryController.text.replaceAll(' ', '');
    return double.tryParse(salaryText) ?? 0.0;
  }

  // Constantes officielles selon la documentation
  static const double _dureeLegaleMensuelle = 151.67; // heures/mois pour 35h/semaine
  static const double _dureeLegaleHebdo = 35.0; // heures/semaine

  double _getWorkTimeCoefficient() {
    final weeklyHours = double.tryParse(_weeklyHoursController.text) ?? _dureeLegaleHebdo;
    // Coefficient = heures_réelles / 35h
    return weeklyHours / _dureeLegaleHebdo;
  }

  void _updatePercentageFromHours() {
    final weeklyHours = double.tryParse(_weeklyHoursController.text) ?? _dureeLegaleHebdo;
    _isUpdating = true;
    _workTimePercentage = (weeklyHours / _dureeLegaleHebdo * 100).clamp(10.0, 100.0);
    _isUpdating = false;
  }

  void _updateHoursFromPercentage() {
    final newWeeklyHours = (_dureeLegaleHebdo * _workTimePercentage / 100);
    _isUpdating = true;
    _weeklyHoursController.text = newWeeklyHours.toStringAsFixed(2);
    _isUpdating = false;
  }


  void _updateHourlyFromSalary() {
    final salaryText = _salaryController.text.replaceAll(' ', '');
    final salary = double.tryParse(salaryText);
    if (salary != null && salary > 0) {
      // AJOUT : Même logique que _updateSalaryFromHourly
      final currentDisplayed = _exactMonthlySalary.toStringAsFixed(2);
      final isUserModified = salaryText != currentDisplayed;
      
      final exactSalary = isUserModified ? salary : _exactMonthlySalary;
      
      // Mettre à jour la valeur exacte si modifiée par l'utilisateur
      if (isUserModified) {
        _exactMonthlySalary = salary;
      }
      
      // Calcul avec coefficient de temps de travail selon la documentation officielle
      final coefficient = _getWorkTimeCoefficient();
      final dureeReelle = _dureeLegaleMensuelle * coefficient;
      
      // Formule officielle : Taux_Horaire_Brut = Salaire_Mensuel_Brut / Durée_Mensuelle_Travail
      _exactHourlyRate = exactSalary / dureeReelle; // Utiliser exactSalary au lieu de salary direct
      
      _isUpdating = true;
      // Affichage arrondi seulement (selon documentation: "arrondir seulement à l'affichage")
      _hourlyRateController.text = _exactHourlyRate.toStringAsFixed(2); // 2 décimales pour UX
      _isUpdating = false;
    } else if (salaryText.isEmpty) {
      _exactMonthlySalary = 0.0;
      _exactHourlyRate = 0.0;
      _isUpdating = true;
      _hourlyRateController.clear();
      _isUpdating = false;
    }
  }

  void _updateSalaryFromHourly() {
    final hourlyText = _hourlyRateController.text;
    final hourlyRate = double.tryParse(hourlyText);
    if (hourlyRate != null && hourlyRate > 0) {
      // Si l'utilisateur a modifié manuellement le taux, utiliser cette nouvelle valeur
      // Sinon utiliser la valeur exacte calculée précédemment
      final currentDisplayed = _exactHourlyRate.toStringAsFixed(2);
      final isUserModified = hourlyText != currentDisplayed;
      
      final exactRate = isUserModified ? hourlyRate : _exactHourlyRate;
      
      // Mettre à jour la valeur exacte si modifiée par l'utilisateur
      if (isUserModified) {
        _exactHourlyRate = hourlyRate;
      }
      
      // Calcul avec coefficient de temps de travail selon la documentation officielle
      final coefficient = _getWorkTimeCoefficient();
      final dureeReelle = _dureeLegaleMensuelle * coefficient;
      
      // Formule officielle : Salaire_Mensuel_Brut = Taux_Horaire_Brut × Durée_Mensuelle_Travail
      _exactMonthlySalary = exactRate * dureeReelle; // Conserver précision maximale
      
      _isUpdating = true;
      // Affichage arrondi seulement (selon documentation: "arrondir seulement à l'affichage")
      _salaryController.text = _exactMonthlySalary.toStringAsFixed(2);
      _isUpdating = false;
    } else if (hourlyText.isEmpty) {
      _exactHourlyRate = 0.0;
      _exactMonthlySalary = 0.0;
      _isUpdating = true;
      _salaryController.clear();
      _isUpdating = false;
    }
  }


  


  bool _hasEmployment() {
    // Tous les statuts disponibles dans le MVP correspondent à des emplois
    return true;
  }

  void _updateProfile() {
    final weeklyHours = double.tryParse(_weeklyHoursController.text) ?? 35.0;
    final overtimeHours = double.tryParse(_overtimeHoursController.text) ?? 0.0;
    final mutualCost = double.tryParse(_mutualCostController.text) ?? 0.0;
    
    _modifiedProfile = _modifiedProfile.copyWith(
      employmentStatus: _employmentStatus,
      companyName: _companyNameController.text.trim().isEmpty ? null : _companyNameController.text.trim(),
      companyAddress: _companyAddressController.text.trim().isEmpty ? null : _companyAddressController.text.trim(),
      jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
      workTimePercentage: _workTimePercentage,
      weeklyHours: weeklyHours,
      overtimeHours: overtimeHours,
      grossMonthlySalary: _getCurrentMonthlySalary(),
      conventionalBonusMonths: _bonusMonths,
      companyEntryDate: _companyEntryDate,
      mutualEmployeeCost: mutualCost,
    );
    
    // Mettre à jour l'état des erreurs
    _updateSectionErrorStatus();
    
    // Sauvegarder automatiquement le profil (comme sur la page d'infos personnelles)
    _profileService.updateProfile(_modifiedProfile);
  }



  void _showManualDateInput() {
    final TextEditingController dateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Saisir la date d\'entrée'),
          content: TextFormField(
            controller: dateController,
            decoration: const InputDecoration(
              labelText: 'Date d\'entrée',
              hintText: 'jj/mm/aaaa',
              border: OutlineInputBorder(),
              helperText: 'Format : 17/07/2020',
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
                    if (date.isAfter(DateTime(1989)) && date.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                      setState(() {
                        _companyEntryDate = date;
                      });
                      _updateProfile();
                      Navigator.of(context).pop();
                    } else {
                      // Afficher erreur de plage
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Date invalide : doit être entre 1990 et aujourd\'hui')),
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

  // Méthodes de validation par section
  bool _hasEmploymentErrors() {
    return (_companyNameController.text.isEmpty) ||
           (_jobTitleController.text.isEmpty);
  }

  bool _hasWorkTimeErrors() {
    return (_salaryController.text.isEmpty) ||
           (double.tryParse(_salaryController.text.replaceAll(' ', '')) == null) ||
           ((double.tryParse(_salaryController.text.replaceAll(' ', '')) ?? 0) <= 0);
  }

  bool _hasBenefitsErrors() {
    return false; // Pas d'erreurs spécifiques pour cette section
  }

  bool _isEmploymentComplete() {
    return _companyNameController.text.isNotEmpty && 
           _jobTitleController.text.isNotEmpty;
  }

  bool _isWorkTimeComplete() {
    return _salaryController.text.isNotEmpty &&
           (double.tryParse(_salaryController.text.replaceAll(' ', '')) ?? 0) > 0;
  }

  bool _isBenefitsComplete() {
    return true; // Section optionnelle
  }

  void _updateSectionErrorStatus() {
    setState(() {
      _sectionHasError['employment'] = _hasEmploymentErrors();
      _sectionHasError['worktime'] = _hasWorkTimeErrors();
      _sectionHasError['benefits'] = _hasBenefitsErrors();
      
      _sectionIsComplete['employment'] = _isEmploymentComplete() && !_hasEmploymentErrors();
      _sectionIsComplete['worktime'] = _isWorkTimeComplete() && !_hasWorkTimeErrors();
      _sectionIsComplete['benefits'] = _isBenefitsComplete() && !_hasBenefitsErrors();
    });
  }

  Widget _buildValidationIcon(String section) {
    if (_sectionHasError[section]!) {
      return const Icon(Icons.error, color: Colors.red, size: 20);
    } else if (_sectionIsComplete[section]!) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else {
      return const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Navigator.pop(context, _modifiedProfile);
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
                    AppStrings.professionalSituationScreenTitle,
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
            // Section 1 - Emploi actuel
            Card(
              child: ExpansionTile(
                initiallyExpanded: _employmentExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _employmentExpanded = expanded;
                  });
                },
                shape: const Border(),
                title: Row(
                  children: [
                    Text(
                      AppStrings.currentEmploymentSection,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildValidationIcon('employment'),
                  ],
                ),
                backgroundColor: _sectionHasError['employment']! 
                  ? Colors.red.withValues(alpha: 0.1) 
                  : Colors.transparent,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                    
                    DropdownButtonFormField<String>(
                      value: _employmentStatus,
                      decoration: const InputDecoration(
                        labelText: AppStrings.employmentStatus,
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.employmentStatusOptions
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _employmentStatus = value;
                          });
                          _updateProfile();
                        }
                      },
                    ),
                    
                    if (_hasEmployment()) ...[
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.companyName,
                          hintText: AppStrings.companyNameHint,
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      TextFormField(
                        controller: _companyAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse de l\'entreprise',
                          hintText: 'Ex: 10 rue de la Paix, 75001 Paris',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      TextFormField(
                        controller: _jobTitleController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.jobTitle,
                          hintText: AppStrings.jobTitleHint,
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // Case à cocher salarié non cadre
                      CheckboxListTile(
                        value: _modifiedProfile.isNonCadre ?? false,
                        onChanged: (value) {
                          setState(() {
                            _modifiedProfile = _modifiedProfile.copyWith(
                              isNonCadre: value,
                            );
                          });
                          _updateProfile();
                        },
                        title: const Text('Salarié non cadre'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
              
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Section 2 - Temps de travail et rémunération
            Card(
              child: ExpansionTile(
                initiallyExpanded: _workTimeExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _workTimeExpanded = expanded;
                  });
                },
                shape: const Border(),
                title: Row(
                  children: [
                    const Text(
                      'Temps de travail et rémunération',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildValidationIcon('worktime'),
                  ],
                ),
                backgroundColor: _sectionHasError['worktime']! 
                  ? Colors.red.withValues(alpha: 0.1) 
                  : Colors.transparent,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                    
                    // Curseur de pourcentage de temps de travail
                    Text(
                      'Temps de travail: ${_workTimePercentage.round()}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    Slider(
                      value: _workTimePercentage,
                      min: 10.0,
                      max: 100.0,
                      divisions: 9, // 10%, 20%, 30%, ..., 100%
                      label: '${_workTimePercentage.round()}%',
                      onChanged: (value) {
                        setState(() {
                          _workTimePercentage = value;
                          _updateHoursFromPercentage();
                          _updateHourlyFromSalary();
                        });
                        _updateProfile();
                      },
                    ),
                    
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Heures hebdomadaires et supplémentaires côte à côte
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weeklyHoursController,
                            focusNode: _weeklyHoursFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Heures/semaine',
                              hintText: 'Ex: 35.00',
                              border: OutlineInputBorder(),
                              suffixText: 'h/sem',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeHoursController,
                            focusNode: _overtimeHoursFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Heures sup.',
                              hintText: 'Ex: 4.00',
                              border: OutlineInputBorder(),
                              suffixText: 'h/sem',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _salaryController,
                            focusNode: _salaryFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Salaire brut',
                              hintText: 'Ex: 2500.00',
                              border: OutlineInputBorder(),
                              suffixText: '€/mois',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                          child: Icon(
                            Icons.sync_alt,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _hourlyRateController,
                            decoration: const InputDecoration(
                              labelText: 'Taux horaire',
                              hintText: 'En euros',
                              border: OutlineInputBorder(),
                              suffixText: '€/h',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Prime conventionnelle avec slider
                    Text(
                      'Prime conventionnelle: ${_bonusMonths.round()} mois',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    Slider(
                      value: _bonusMonths,
                      min: 0.0,
                      max: 4.0,
                      divisions: 4,
                      label: '${_bonusMonths.round()} mois',
                      onChanged: (value) {
                        setState(() {
                          _bonusMonths = value;
                        });
                        _updateProfile();
                      },
                    ),
                    
                    Text(
                      _bonusMonths == 0 ? 'Aucune prime' : 
                      _bonusMonths == 1 ? '13ème mois' : 
                      '${12 + _bonusMonths.round()}ème mois',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Section 3 - Avantages sociaux
            Card(
              child: ExpansionTile(
                initiallyExpanded: _benefitsExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _benefitsExpanded = expanded;
                  });
                },
                shape: const Border(),
                title: Row(
                  children: [
                    const Text(
                      'Avantages sociaux',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildValidationIcon('benefits'),
                  ],
                ),
                backgroundColor: _sectionHasError['benefits']! 
                  ? Colors.red.withValues(alpha: 0.1) 
                  : Colors.transparent,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                    
                    // Date d'entrée dans l'entreprise
                    GestureDetector(
                      onDoubleTap: () {
                        // Activer la saisie manuelle sur double-tap
                        _showManualDateInput();
                      },
                      child: TextFormField(
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _companyEntryDate ?? DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _companyEntryDate = picked;
                            });
                            _updateProfile();
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Date d\'entrée dans l\'entreprise',
                          hintText: 'Appuyez ou double-cliquez pour saisir',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                          helperText: 'Double-clic pour saisie manuelle',
                        ),
                        controller: TextEditingController(
                          text: _companyEntryDate != null
                              ? '${_companyEntryDate!.day.toString().padLeft(2, '0')}/${_companyEntryDate!.month.toString().padLeft(2, '0')}/${_companyEntryDate!.year}'
                              : '',
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Part salarié mutuelle
                    TextFormField(
                      controller: _mutualCostController,
                      decoration: const InputDecoration(
                        labelText: 'Part salarié mutuelle',
                        hintText: 'Ex: 35.00',
                        border: OutlineInputBorder(),
                        suffixText: '€/mois',
                        helperText: 'Montant déduit de votre salaire',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}