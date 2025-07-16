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
        ? _formatSalary(widget.profile.grossMonthlySalary.toStringAsFixed(0)) 
        : ''
    );
    _hourlyRateController = TextEditingController();
    _employmentStatus = widget.profile.employmentStatus;
    _workTime = widget.profile.workTime;
    _taxSystem = widget.profile.taxSystem;
    
    _companyNameController.addListener(_saveData);
    _jobTitleController.addListener(_saveData);
    _salaryController.addListener(_onSalaryChanged);
    _hourlyRateController.addListener(_onHourlyRateChanged);
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

  void _onSalaryChanged() {
    final cursorPosition = _salaryController.selection.baseOffset;
    final oldLength = _salaryController.text.length;
    final formatted = _formatSalary(_salaryController.text);
    
    if (formatted != _salaryController.text) {
      final newLength = formatted.length;
      final diff = newLength - oldLength;
      
      _salaryController.text = formatted;
      _salaryController.selection = TextSelection.fromPosition(
        TextPosition(offset: (cursorPosition + diff).clamp(0, formatted.length)),
      );
    }
    
    // Calculate hourly rate from monthly salary
    _updateHourlyRateFromSalary();
    
    _saveData();
  }

  void _onHourlyRateChanged() {
    // Calculate monthly salary from hourly rate
    _updateSalaryFromHourlyRate();
    
    _saveData();
  }

  void _updateHourlyRateFromSalary() {
    final monthlySalary = _parseSalary(_salaryController.text);
    if (monthlySalary > 0) {
      final weeklyHours = _getWeeklyHoursNumber();
      final hourlyRate = monthlySalary / (weeklyHours * 4.33);
      
      // Update hourly rate without triggering listener
      _hourlyRateController.removeListener(_onHourlyRateChanged);
      _hourlyRateController.text = hourlyRate.toStringAsFixed(2);
      _hourlyRateController.addListener(_onHourlyRateChanged);
    } else {
      _hourlyRateController.removeListener(_onHourlyRateChanged);
      _hourlyRateController.clear();
      _hourlyRateController.addListener(_onHourlyRateChanged);
    }
  }

  void _updateSalaryFromHourlyRate() {
    final hourlyRate = double.tryParse(_hourlyRateController.text) ?? 0.0;
    if (hourlyRate > 0) {
      final weeklyHours = _getWeeklyHoursNumber();
      final monthlySalary = hourlyRate * weeklyHours * 4.33;
      
      // Update salary without triggering listener
      _salaryController.removeListener(_onSalaryChanged);
      _salaryController.text = _formatSalary(monthlySalary.toStringAsFixed(0));
      _salaryController.addListener(_onSalaryChanged);
    } else {
      _salaryController.removeListener(_onSalaryChanged);
      _salaryController.clear();
      _salaryController.addListener(_onSalaryChanged);
    }
  }

  double _calculateMonthlyFromHourly() {
    final hourlyRate = double.tryParse(_hourlyRateController.text) ?? 0.0;
    final weeklyHours = _getWeeklyHoursNumber();
    return hourlyRate * weeklyHours * 4.33;
  }

  double _getWeeklyHoursNumber() {
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
        return 35; // Default to full time
    }
  }

  double _parseSalary(String value) {
    value = value.replaceAll(' ', '');
    return double.tryParse(value) ?? 0.0;
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
          grossMonthlySalary: _salaryController.text.isNotEmpty ? _parseSalary(_salaryController.text) : _calculateMonthlyFromHourly(),
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

  String _getWeeklyHours() {
    switch (_workTime) {
      case 'Temps plein':
        return '35 ${AppStrings.hoursPerWeek}';
      case 'Temps partiel 80%':
        return '28 ${AppStrings.hoursPerWeek}';
      case 'Temps partiel 60%':
        return '21 ${AppStrings.hoursPerWeek}';
      case 'Temps partiel 50%':
      case 'Mi-temps':
        return '17.5 ${AppStrings.hoursPerWeek}';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    double monthlySalary = _parseSalary(_salaryController.text);
    
    // Calculate monthly from hourly if no monthly salary is set
    if (monthlySalary == 0 && _hourlyRateController.text.isNotEmpty) {
      monthlySalary = _calculateMonthlyFromHourly();
    }
    
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
                      // Recalculate when work time changes
                      if (_salaryController.text.isNotEmpty) {
                        _updateHourlyRateFromSalary();
                      } else if (_hourlyRateController.text.isNotEmpty) {
                        _updateSalaryFromHourlyRate();
                      }
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
              
              InfoContainer(
                text: AppStrings.salaryInfoMessage,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: AppStrings.grossMonthlySalary,
                  hintText: AppStrings.salaryHint,
                  border: OutlineInputBorder(),
                  suffixText: AppStrings.euroSymbol,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              Center(
                child: Text(
                  AppStrings.or,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hourlyRateController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.grossHourlyRate,
                        hintText: AppStrings.hourlyRateHint,
                        border: OutlineInputBorder(),
                        suffixText: AppStrings.euroSymbol,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  if (_workTime == 'Temps plein' || _workTime == 'Temps partiel 80%' || _workTime == 'Temps partiel 60%' || _workTime == 'Temps partiel 50%')
                    Padding(
                      padding: const EdgeInsets.only(left: AppConstants.smallPadding),
                      child: Text(
                        _getWeeklyHours(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
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