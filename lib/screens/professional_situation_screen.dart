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
      if (mounted) setState(() {});
      _saveData();
    });
    _hourlyRateController.addListener(() {
      if (mounted) setState(() {});
      _saveData();
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


  // Simple calculation methods without cross-updates
  double _getCurrentMonthlySalary() {
    final salaryText = _salaryController.text.replaceAll(' ', '');
    return double.tryParse(salaryText) ?? 0.0;
  }

  double _getCurrentHourlyRate() {
    return double.tryParse(_hourlyRateController.text) ?? 0.0;
  }

  double _getWeeklyHours() {
    switch (_workTime) {
      case 'Temps plein':
        return 35;
      case 'Temps partiel 80%':
        return 28;
      case 'Temps partiel 60%':
        return 21;
      case 'Temps partiel 50%':
      case 'Mi-temps':
        return 17.5;
      default:
        return 35;
    }
  }

  // Show calculated values without modifying input fields
  double _getCalculatedHourlyFromSalary() {
    final monthly = _getCurrentMonthlySalary();
    if (monthly <= 0) return 0;
    final weeklyHours = _getWeeklyHours();
    return monthly / (weeklyHours * 52 / 12);
  }

  double _getCalculatedSalaryFromHourly() {
    final hourly = _getCurrentHourlyRate();
    if (hourly <= 0) return 0;
    final weeklyHours = _getWeeklyHours();
    return hourly * (weeklyHours * 52 / 12);
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

  String _getWeeklyHoursText() {
    final hours = _getWeeklyHours();
    return '$hours ${AppStrings.hoursPerWeek}';
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
              const SizedBox(height: AppConstants.smallPadding),
              
              // Affichage des équivalences calculées
              if (_getCurrentMonthlySalary() > 0 || _getCurrentHourlyRate() > 0) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  ),
                  child: Column(
                    children: [
                      if (_getCurrentMonthlySalary() > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Équivalent horaire:', style: TextStyle(fontSize: 12)),
                            Text(
                              '${_getCalculatedHourlyFromSalary().toStringAsFixed(2)} €/h',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      if (_getCurrentHourlyRate() > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Équivalent mensuel:', style: TextStyle(fontSize: 12)),
                            Text(
                              '${_getCalculatedSalaryFromHourly().round()} €/mois',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      if (_workTime != 'Autre')
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Base: ${_getWeeklyHoursText()}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              
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