import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/info_container.dart';
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
  late TextEditingController _mealVoucherValueController;
  late TextEditingController _mealVouchersCountController;
  DateTime? _companyEntryDate;

  @override
  void initState() {
    super.initState();
    _modifiedProfile = widget.profile;
    _companyNameController = TextEditingController(text: widget.profile.companyName ?? '');
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
    _mealVoucherValueController = TextEditingController(
      text: widget.profile.mealVoucherValue != null 
        ? widget.profile.mealVoucherValue!.toStringAsFixed(2) 
        : ''
    );
    _mealVouchersCountController = TextEditingController(
      text: widget.profile.mealVouchersPerMonth != null 
        ? widget.profile.mealVouchersPerMonth.toString() 
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
    _mealVoucherValueController.addListener(() {
      _updateProfile();
    });
    _mealVouchersCountController.addListener(() {
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
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _jobTitleController.dispose();
    _salaryController.dispose();
    _hourlyRateController.dispose();
    _weeklyHoursController.dispose();
    _overtimeHoursController.dispose();
    _mutualCostController.dispose();
    _mealVoucherValueController.dispose();
    _mealVouchersCountController.dispose();
    _salaryFocusNode.dispose();
    _weeklyHoursFocusNode.dispose();
    _overtimeHoursFocusNode.dispose();
    super.dispose();
  }

  String _formatSalary(String value) {
    value = value.replaceAll(' ', '');
    if (value.isEmpty) return '';
    
    double? number = double.tryParse(value);
    if (number == null) return value;
    
    // Séparer partie entière et décimale
    final parts = value.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Formater la partie entière avec espaces
    String result = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        result += ' ';
      }
      result += integerPart[i];
    }
    
    // Ajouter la partie décimale si elle existe
    if (decimalPart.isNotEmpty) {
      result += '.$decimalPart';
    }
    
    return result;
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
      // Stocker la valeur exacte du salaire (précision maximale)
      _exactMonthlySalary = salary;
      
      // Calcul avec coefficient de temps de travail selon la documentation officielle
      final coefficient = _getWorkTimeCoefficient();
      final dureeReelle = _dureeLegaleMensuelle * coefficient;
      
      // Formule officielle : Taux_Horaire_Brut = Salaire_Mensuel_Brut / Durée_Mensuelle_Travail
      _exactHourlyRate = salary / dureeReelle; // Conserver précision maximale
      
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


  double _calculateAnnualSalary(double monthlySalary) {
    return monthlySalary * 12;
  }
  
  // Calculs des heures supplémentaires
  double _calculateOvertimeSalary() {
    final overtimeHours = double.tryParse(_overtimeHoursController.text) ?? 0.0;
    if (overtimeHours <= 0 || _exactHourlyRate <= 0) return 0.0;
    
    // Heures supplémentaires par mois (semaines * 52 / 12)
    final monthlyOvertimeHours = overtimeHours * 52 / 12;
    
    // Calcul selon les taux de majoration
    double overtimeSalary = 0.0;
    
    if (overtimeHours <= 8) {
      // Toutes les heures à 25%
      overtimeSalary = monthlyOvertimeHours * _exactHourlyRate * 1.25;
    } else {
      // 8 premières heures à 25%
      final hours25 = 8.0 * 52 / 12;
      // Heures restantes à 50%
      final hours50 = (overtimeHours - 8) * 52 / 12;
      
      overtimeSalary = (hours25 * _exactHourlyRate * 1.25) + 
                      (hours50 * _exactHourlyRate * 1.50);
    }
    
    return overtimeSalary;
  }
  


  bool _hasEmployment() {
    // Tous les statuts disponibles dans le MVP correspondent à des emplois
    return true;
  }

  void _updateProfile() {
    final weeklyHours = double.tryParse(_weeklyHoursController.text) ?? 35.0;
    final overtimeHours = double.tryParse(_overtimeHoursController.text) ?? 0.0;
    final mutualCost = double.tryParse(_mutualCostController.text) ?? 0.0;
    final mealVoucherValue = double.tryParse(_mealVoucherValueController.text);
    final mealVouchersCount = int.tryParse(_mealVouchersCountController.text);
    
    _modifiedProfile = _modifiedProfile.copyWith(
      employmentStatus: _employmentStatus,
      companyName: _companyNameController.text.trim().isEmpty ? null : _companyNameController.text.trim(),
      jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
      workTimePercentage: _workTimePercentage,
      weeklyHours: weeklyHours,
      overtimeHours: overtimeHours,
      grossMonthlySalary: _getCurrentMonthlySalary(),
      conventionalBonusMonths: _bonusMonths,
      companyEntryDate: _companyEntryDate,
      mutualEmployeeCost: mutualCost,
      mealVoucherValue: mealVoucherValue,
      mealVouchersPerMonth: mealVouchersCount,
    );
    
    // Sauvegarder automatiquement le profil (comme sur la page d'infos personnelles)
    _profileService.updateProfile(_modifiedProfile);
  }


  // Calcul de la prime conventionnelle
  double _calculateConventionalBonus() {
    if (_bonusMonths <= 0 || _getCurrentMonthlySalary() <= 0) return 0.0;
    
    return _getCurrentMonthlySalary() * _bonusMonths;
  }

  // Calcul de l'avantage mensuel des titres-restaurant
  double _calculateMealVoucherAdvantage() {
    final value = double.tryParse(_mealVoucherValueController.text) ?? 0.0;
    final count = int.tryParse(_mealVouchersCountController.text) ?? 0;
    
    if (value <= 0 || count <= 0) return 0.0;
    
    // L'avantage = différence entre valeur faciale et part salarié
    // En général, l'employeur paie 60% donc le salarié économise 60% de la valeur
    const employerRate = AppConstants.defaultEmployerMealVoucherRate; // 60%
    return value * count * employerRate;
  }

  // Calcul de la déduction mensuelle mutuelle
  double _getMutualDeduction() {
    return double.tryParse(_mutualCostController.text) ?? 0.0;
  }

  // Helper pour calculer et formater l'impact net
  String _getFormattedNetImpact() {
    final netImpact = _calculateMealVoucherAdvantage() - _getMutualDeduction();
    final sign = netImpact >= 0 ? '+' : '';
    return '$sign${_formatSalary(netImpact.toStringAsFixed(2))} ${AppStrings.euroSymbol}';
  }

  @override
  Widget build(BuildContext context) {
    final monthlySalary = _getCurrentMonthlySalary();
    final annualSalary = _calculateAnnualSalary(monthlySalary);
    final conventionalBonus = _calculateConventionalBonus();

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
            InfoContainer(
              text: AppStrings.professionalInfoMessage,
            ),
            const SizedBox(height: AppConstants.largePadding),
            
            Text(
              AppStrings.currentEmploymentSection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            
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
              
              const SizedBox(height: AppConstants.defaultPadding),
              
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
              
              const SizedBox(height: AppConstants.largePadding),
              
              Text(
                AppStrings.salarySection,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Section Avantages sociaux
              Text(
                'Avantages sociaux',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Date d'entrée dans l'entreprise
              InkWell(
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
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: Text(
                          _companyEntryDate != null
                              ? 'Entrée en entreprise: ${_companyEntryDate!.day}/${_companyEntryDate!.month}/${_companyEntryDate!.year}'
                              : 'Date d\'entrée dans l\'entreprise',
                          style: TextStyle(
                            color: _companyEntryDate != null ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
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
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Titres-restaurant
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mealVoucherValueController,
                      decoration: const InputDecoration(
                        labelText: 'Valeur titre-restaurant',
                        hintText: 'Ex: 9.00',
                        border: OutlineInputBorder(),
                        suffixText: '€',
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
                      controller: _mealVouchersCountController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre/mois',
                        hintText: 'Ex: 19',
                        border: OutlineInputBorder(),
                        suffixText: 'titres',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              
              // Cadre récapitulatif
              if (monthlySalary > 0) ...[
                const SizedBox(height: AppConstants.defaultPadding),
                
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total annuel brut',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        '${_formatSalary((annualSalary + _calculateOvertimeSalary() * 12 + conventionalBonus).toStringAsFixed(2))} ${AppStrings.euroSymbol}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Récapitulatif des avantages sociaux
                if (_calculateMealVoucherAdvantage() > 0 || _getMutualDeduction() > 0) ...[
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avantages sociaux (impact mensuel)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        
                        // Avantages (positifs)
                        if (_calculateMealVoucherAdvantage() > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '+ Titres-restaurant',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '+${_formatSalary(_calculateMealVoucherAdvantage().toStringAsFixed(2))} ${AppStrings.euroSymbol}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        // Déductions (négatives)
                        if (_getMutualDeduction() > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '- Mutuelle (part salarié)',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '-${_formatSalary(_getMutualDeduction().toStringAsFixed(2))} ${AppStrings.euroSymbol}',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        // Impact net
                        const SizedBox(height: AppConstants.smallPadding),
                        const Divider(height: 1),
                        const SizedBox(height: AppConstants.smallPadding),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Impact net mensuel',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _getFormattedNetImpact(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
      ),
    );
  }
}