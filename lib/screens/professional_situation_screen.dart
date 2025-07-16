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
  late UserProfile _modifiedProfile;
  late FocusNode _salaryFocusNode;

  @override
  void initState() {
    super.initState();
    _modifiedProfile = widget.profile;
    _companyNameController = TextEditingController(text: widget.profile.companyName ?? '');
    _jobTitleController = TextEditingController(text: widget.profile.jobTitle ?? '');
    _salaryController = TextEditingController(
      text: widget.profile.grossMonthlySalary > 0 
        ? widget.profile.grossMonthlySalary.toStringAsFixed(0) 
        : ''
    );
    _hourlyRateController = TextEditingController();
    _employmentStatus = widget.profile.employmentStatus;
    _workTimePercentage = widget.profile.workTimePercentage;
    _weeklyHoursController = TextEditingController(text: widget.profile.weeklyHours.toString());
    _overtimeHoursController = TextEditingController(text: widget.profile.overtimeHours > 0 ? widget.profile.overtimeHours.toString() : '');
    _salaryFocusNode = FocusNode();
    
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
    
    // Formater le salaire quand l'utilisateur quitte le champ
    _salaryFocusNode.addListener(() {
      if (!_salaryFocusNode.hasFocus && !_isUpdating) {
        // Délai pour éviter les conflits avec les autres listeners
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _formatSalaryInput();
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
    _salaryFocusNode.dispose();
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
    _weeklyHoursController.text = newWeeklyHours.toStringAsFixed(1);
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
  
  // Calcul des heures supplémentaires mensuelles par taux
  Map<String, double> _getOvertimeHoursByRate() {
    final overtimeHours = double.tryParse(_overtimeHoursController.text) ?? 0.0;
    
    if (overtimeHours <= 0) {
      return {'hours25': 0.0, 'hours50': 0.0};
    }
    
    // Conversion hebdo -> mensuel
    const weeksPerMonth = 52.0 / 12.0;
    
    if (overtimeHours <= 8) {
      return {
        'hours25': overtimeHours * weeksPerMonth,
        'hours50': 0.0,
      };
    } else {
      return {
        'hours25': 8.0 * weeksPerMonth,
        'hours50': (overtimeHours - 8) * weeksPerMonth,
      };
    }
  }


  bool _hasEmployment() {
    return _employmentStatus != 'Sans emploi' && 
           _employmentStatus != 'Étudiant(e)' && 
           _employmentStatus != 'Retraité(e)';
  }

  void _updateProfile() {
    final weeklyHours = double.tryParse(_weeklyHoursController.text) ?? 35.0;
    final overtimeHours = double.tryParse(_overtimeHoursController.text) ?? 0.0;
    _modifiedProfile = _modifiedProfile.copyWith(
      employmentStatus: _employmentStatus,
      companyName: _companyNameController.text.trim().isEmpty ? null : _companyNameController.text.trim(),
      jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
      workTimePercentage: _workTimePercentage,
      weeklyHours: weeklyHours,
      overtimeHours: overtimeHours,
      grossMonthlySalary: _getCurrentMonthlySalary(),
    );
    
    // Sauvegarder automatiquement le profil (comme sur la page d'infos personnelles)
    _profileService.updateProfile(_modifiedProfile);
  }


  @override
  Widget build(BuildContext context) {
    final monthlySalary = _getCurrentMonthlySalary();
    final annualSalary = _calculateAnnualSalary(monthlySalary);

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
              
              // Champ heures hebdomadaires
              TextFormField(
                controller: _weeklyHoursController,
                decoration: const InputDecoration(
                  labelText: 'Heures hebdomadaires',
                  hintText: 'Ex: 35.0',
                  border: OutlineInputBorder(),
                  suffixText: 'h/semaine',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textInputAction: TextInputAction.next,
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
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Section Heures supplémentaires
              Text(
                AppStrings.overtimeSection,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              
              TextFormField(
                controller: _overtimeHoursController,
                decoration: const InputDecoration(
                  labelText: AppStrings.overtimeHours,
                  hintText: AppStrings.overtimeHoursHint,
                  border: OutlineInputBorder(),
                  suffixText: 'h/semaine',
                  helperText: 'Au-delà de 35h : +25% (36-43h), +50% (>43h)',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textInputAction: TextInputAction.done,
              ),
              
              // Cadre récapitulatif unique
              if (monthlySalary > 0) ...[
                const SizedBox(height: AppConstants.defaultPadding),
                
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  ),
                  child: Column(
                    children: [
                      // Salaire annuel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppStrings.grossAnnualSalary),
                          Text(
                            '${_formatSalary(annualSalary.toStringAsFixed(2))} ${AppStrings.euroSymbol}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      // Heures supplémentaires si présentes
                      if (_calculateOvertimeSalary() > 0) ...[
                        const SizedBox(height: AppConstants.defaultPadding),
                        const Divider(),
                        const SizedBox(height: AppConstants.defaultPadding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(AppStrings.overtimeMonthlyAmount),
                                const SizedBox(height: 4),
                                Text(
                                  '${_getOvertimeHoursByRate()['hours25']!.toStringAsFixed(1)}h à 125% + ${_getOvertimeHoursByRate()['hours50']!.toStringAsFixed(1)}h à 150%/mois',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_formatSalary(_calculateOvertimeSalary().toStringAsFixed(2))} ${AppStrings.euroSymbol}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        const Divider(),
                        const SizedBox(height: AppConstants.defaultPadding),
                        Row(
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
                              '${_formatSalary((annualSalary + _calculateOvertimeSalary() * 12).toStringAsFixed(2))} ${AppStrings.euroSymbol}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      ),
    );
  }
}