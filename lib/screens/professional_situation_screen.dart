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
  late String _workTime;
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
    _workTime = widget.profile.workTime;
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
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _jobTitleController.dispose();
    _salaryController.dispose();
    _hourlyRateController.dispose();
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

  double _getMonthlyHours() {
    switch (_workTime) {
      case 'Temps plein':
        return 151.67; // 35h/semaine selon la réglementation française
      case 'Temps partiel 90%':
        return 136.5; // 31.5h/semaine (31.5 × 52 ÷ 12)
      case 'Temps partiel 80%':
        return 121.33; // 28h/semaine (28 × 52 ÷ 12)
      case 'Temps partiel 70%':
        return 106.17; // 24.5h/semaine (24.5 × 52 ÷ 12)
      case 'Temps partiel 60%':
        return 91.0; // 21h/semaine (21 × 52 ÷ 12)
      case 'Temps partiel 50%':
      case 'Mi-temps':
        return 75.83; // 17.5h/semaine (17.5 × 52 ÷ 12)
      case 'Temps partiel 30%':
        return 45.5; // 10.5h/semaine (10.5 × 52 ÷ 12)
      case 'Temps partiel 20%':
        return 30.33; // 7h/semaine (7 × 52 ÷ 12)
      case 'Autre':
        return 151.67; // Par défaut temps plein, l'utilisateur peut ajuster manuellement
      default:
        return 151.67;
    }
  }

  void _updateHourlyFromSalary() {
    final salaryText = _salaryController.text.replaceAll(' ', '');
    final salary = int.tryParse(salaryText);
    if (salary != null && salary > 0) {
      final monthlyHours = _getMonthlyHours();
      // Formule française officielle : salaire mensuel ÷ heures mensuelles
      final hourlyRate = salary / monthlyHours;
      
      _isUpdating = true;
      _hourlyRateController.text = hourlyRate.toStringAsFixed(2);
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
      final monthlyHours = _getMonthlyHours();
      // Formule française officielle : taux horaire × heures mensuelles
      final monthlySalary = (hourlyRate * monthlyHours).round();
      
      _isUpdating = true;
      _salaryController.text = monthlySalary.toString();
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
        _modifiedProfile = widget.profile.copyWith(
          employmentStatus: _employmentStatus,
          companyName: _companyNameController.text.trim().isEmpty ? null : _companyNameController.text.trim(),
          jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
          workTime: _workTime,
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
              
              DropdownButtonFormField<String>(
                value: _workTime,
                decoration: const InputDecoration(
                  labelText: AppStrings.workTime,
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.workTimeOptions
                    .map((time) => DropdownMenuItem(
                          value: time,
                          child: Text(time),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _workTime = value;
                      _saveData();
                    });
                  }
                },
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