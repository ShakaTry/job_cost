import 'dart:math';
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
  late String _taxSystem;
  late UserProfile _modifiedProfile;

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
    _taxSystem = widget.profile.taxSystem;
    
    _companyNameController.addListener(_saveData);
    _jobTitleController.addListener(_saveData);
    _salaryController.addListener(() {
      if (!_isUpdating) {
        _updateHourlyFromSalary();
        if (mounted) setState(() {});
        _saveData();
      }
    });
    _hourlyRateController.addListener(() {
      if (!_isUpdating) {
        _updateSalaryFromHourly();
        if (mounted) setState(() {});
        _saveData();
      }
    });
    _weeklyHoursController.addListener(() {
      if (!_isUpdating) {
        _updatePercentageFromHours();
        _updateHourlyFromSalary();
        if (mounted) setState(() {});
        _saveData();
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
    super.dispose();
  }

  String _formatSalary(String value) {
    value = value.replaceAll(' ', '');
    if (value.isEmpty) return '';
    
    int? number = int.tryParse(value);
    if (number == null) return value;
    
    String result = '';
    String numberStr = number.toString();
    for (int i = 0; i < numberStr.length; i++) {
      if (i > 0 && (numberStr.length - i) % 3 == 0) {
        result += ' ';
      }
      result += numberStr[i];
    }
    return result;
  }


  bool _isUpdating = false;

  double _getCurrentMonthlySalary() {
    final salaryText = _salaryController.text.replaceAll(' ', '');
    return double.tryParse(salaryText) ?? 0.0;
  }

  // Constantes officielles selon la documentation
  static const double _dureeLegaleMensuelle = 151.67; // heures/mois pour 35h/semaine
  static const double _dureeLegaleHebdo = 35.0; // heures/semaine
  static const int _precisionTauxHoraire = 4; // décimales pour taux horaire
  static const int _precisionSalaire = 2; // décimales pour salaire

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

  // Fonction d'arrondi selon les spécifications officielles
  double _roundToPrecision(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }

  void _updateHourlyFromSalary() {
    final salaryText = _salaryController.text.replaceAll(' ', '');
    final salary = double.tryParse(salaryText);
    if (salary != null && salary > 0) {
      // Calcul avec coefficient de temps de travail selon la documentation officielle
      final coefficient = _getWorkTimeCoefficient();
      final dureeReelle = _dureeLegaleMensuelle * coefficient;
      
      // Formule officielle : Taux_Horaire_Brut = Salaire_Mensuel_Brut / Durée_Mensuelle_Travail
      final hourlyRate = salary / dureeReelle;
      
      _isUpdating = true;
      // Affichage avec précision recommandée (4 décimales pour taux horaire)
      _hourlyRateController.text = _roundToPrecision(hourlyRate, _precisionTauxHoraire).toString();
      _isUpdating = false;
    } else if (salaryText.isEmpty) {
      _isUpdating = true;
      _hourlyRateController.clear();
      _isUpdating = false;
    }
  }

  void _updateSalaryFromHourly() {
    final hourlyText = _hourlyRateController.text;
    final hourlyRate = double.tryParse(hourlyText);
    if (hourlyRate != null && hourlyRate > 0) {
      // Calcul avec coefficient de temps de travail selon la documentation officielle
      final coefficient = _getWorkTimeCoefficient();
      final dureeReelle = _dureeLegaleMensuelle * coefficient;
      
      // Formule officielle : Salaire_Mensuel_Brut = Taux_Horaire_Brut × Durée_Mensuelle_Travail
      final monthlySalary = hourlyRate * dureeReelle;
      
      _isUpdating = true;
      // Arrondir à 2 décimales (centimes) pour le salaire selon les spécifications
      final roundedSalary = _roundToPrecision(monthlySalary, _precisionSalaire);
      _salaryController.text = roundedSalary.toString();
      _isUpdating = false;
    } else if (hourlyText.isEmpty) {
      _isUpdating = true;
      _salaryController.clear();
      _isUpdating = false;
    }
  }


  double _calculateAnnualSalary(double monthlySalary) {
    return monthlySalary * 12;
  }


  bool _hasEmployment() {
    return _employmentStatus != 'Sans emploi' && 
           _employmentStatus != 'Étudiant(e)' && 
           _employmentStatus != 'Retraité(e)';
  }

  void _saveData() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final weeklyHours = double.tryParse(_weeklyHoursController.text) ?? 35.0;
        _modifiedProfile = widget.profile.copyWith(
          employmentStatus: _employmentStatus,
          companyName: _companyNameController.text.trim().isEmpty ? null : _companyNameController.text.trim(),
          jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
          workTimePercentage: _workTimePercentage,
          weeklyHours: weeklyHours,
          grossMonthlySalary: _getCurrentMonthlySalary(),
          taxSystem: _taxSystem,
        );

        await _profileService.updateProfile(_modifiedProfile);
      } catch (e) {
        if (mounted) {
          debugPrint('Erreur lors de la sauvegarde: $e');
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final monthlySalary = _getCurrentMonthlySalary();
    final annualSalary = _calculateAnnualSalary(monthlySalary);

    return Scaffold(
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
                    _saveData();
                  });
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
                    _saveData();
                  });
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
                      decoration: const InputDecoration(
                        labelText: 'Salaire brut',
                        hintText: 'En euros',
                        border: OutlineInputBorder(),
                        suffixText: '€/mois',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
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
                      const Text(AppStrings.grossAnnualSalary),
                      Text(
                        '${_formatSalary(annualSalary.toStringAsFixed(0))} ${AppStrings.euroSymbol}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            
            const SizedBox(height: AppConstants.largePadding),
            
            Text(
              AppStrings.taxSection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            
            DropdownButtonFormField<String>(
              value: _taxSystem,
              decoration: const InputDecoration(
                labelText: AppStrings.taxSystem,
                border: OutlineInputBorder(),
              ),
              items: AppConstants.taxSystemOptions
                  .map((system) => DropdownMenuItem(
                        value: system,
                        child: Text(system),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _taxSystem = value;
                    _saveData();
                  });
                }
              },
            ),
            
            const SizedBox(height: AppConstants.largePadding),
          ],
        ),
      ),
    );
  }
}