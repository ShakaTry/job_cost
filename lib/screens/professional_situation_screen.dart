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
  late TextEditingController _grossMonthlySalaryController;
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
    _grossMonthlySalaryController = TextEditingController(
      text: widget.profile.grossMonthlySalary > 0 
          ? widget.profile.grossMonthlySalary.toStringAsFixed(0) 
          : ''
    );
    _employmentStatus = widget.profile.employmentStatus;
    _workTime = widget.profile.workTime;
    _taxSystem = widget.profile.taxSystem;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _jobTitleController.dispose();
    _grossMonthlySalaryController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    double salary = 0.0;
    if (_grossMonthlySalaryController.text.isNotEmpty) {
      salary = double.tryParse(_grossMonthlySalaryController.text.replaceAll(' ', '')) ?? 0.0;
    }

    _modifiedProfile = _modifiedProfile.copyWith(
      companyName: _companyNameController.text.isEmpty ? null : _companyNameController.text,
      jobTitle: _jobTitleController.text.isEmpty ? null : _jobTitleController.text,
      grossMonthlySalary: salary,
      employmentStatus: _employmentStatus,
      workTime: _workTime,
      taxSystem: _taxSystem,
    );
    
    // Sauvegarder automatiquement le profil
    _profileService.updateProfile(_modifiedProfile);
  }

  String _formatSalary(String value) {
    // Enlever tous les espaces
    String cleaned = value.replaceAll(' ', '');
    
    // Ne garder que les chiffres
    cleaned = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.isEmpty) return '';
    
    // Formater avec des espaces tous les 3 chiffres
    String formatted = '';
    for (int i = cleaned.length - 1, count = 0; i >= 0; i--, count++) {
      if (count == 3) {
        formatted = ' $formatted';
        count = 0;
      }
      formatted = cleaned[i] + formatted;
    }
    
    return formatted;
  }

  double _calculateAnnualSalary() {
    double monthlySalary = 0.0;
    if (_grossMonthlySalaryController.text.isNotEmpty) {
      monthlySalary = double.tryParse(_grossMonthlySalaryController.text.replaceAll(' ', '')) ?? 0.0;
    }
    return monthlySalary * 12;
  }

  double _calculateNetSalary() {
    double grossSalary = 0.0;
    if (_grossMonthlySalaryController.text.isNotEmpty) {
      grossSalary = double.tryParse(_grossMonthlySalaryController.text.replaceAll(' ', '')) ?? 0.0;
    }
    
    // Estimation simple : environ 77% du brut en net pour un salarié
    // Cette valeur sera affinée avec les paramètres fiscaux détaillés
    double netRatio = 0.77;
    
    // Ajustement selon le statut
    if (_employmentStatus == 'Auto-entrepreneur' || _employmentStatus == 'Indépendant') {
      netRatio = 0.65; // Plus de charges pour les indépendants
    }
    
    return grossSalary * netRatio;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _updateProfile();
          Navigator.pop(context, _modifiedProfile);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.professionalSituationScreenTitle),
          centerTitle: true,
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
                    firstName: _modifiedProfile.firstName,
                    radius: 60,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Section Emploi actuel
                _buildSectionHeader(AppStrings.currentEmploymentSection),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _employmentStatus,
                  decoration: const InputDecoration(
                    labelText: AppStrings.employmentStatus,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: AppConstants.employmentStatusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      if (mounted) {
                        setState(() {
                          _employmentStatus = newValue;
                        });
                      }
                      _updateProfile();
                    }
                  },
                ),
                
                if (_employmentStatus != 'Sans emploi' && _employmentStatus != 'Étudiant(e)' && _employmentStatus != 'Retraité(e)') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.companyName,
                      hintText: AppStrings.companyNameHint,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _updateProfile(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jobTitleController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.jobTitle,
                      hintText: AppStrings.jobTitleHint,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _updateProfile(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _workTime,
                    decoration: const InputDecoration(
                      labelText: AppStrings.workTime,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    items: AppConstants.workTimeOptions.map((String time) {
                      return DropdownMenuItem<String>(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        if (mounted) {
                          setState(() {
                            _workTime = newValue;
                          });
                        }
                        _updateProfile();
                      }
                    },
                  ),
                ],
                
                if (_employmentStatus != 'Sans emploi' && _employmentStatus != 'Étudiant(e)') ...[
                  const SizedBox(height: 32),
                  
                  // Section Salaire et revenus
                  _buildSectionHeader(AppStrings.salarySection),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _grossMonthlySalaryController,
                    decoration: InputDecoration(
                      labelText: AppStrings.grossMonthlySalary,
                      hintText: AppStrings.salaryHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.euro),
                      suffixText: AppStrings.euroSymbol,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      final newValue = _formatSalary(value);
                      if (newValue != value) {
                        _grossMonthlySalaryController.value = TextEditingValue(
                          text: newValue,
                          selection: TextSelection.collapsed(offset: newValue.length),
                        );
                      }
                      if (mounted) setState(() {});
                      _updateProfile();
                    },
                  ),
                  
                  if (_grossMonthlySalaryController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSalaryInfo(
                      AppStrings.grossAnnualSalary,
                      _calculateAnnualSalary(),
                      AppStrings.annualAmount,
                    ),
                    const SizedBox(height: 8),
                    _buildSalaryInfo(
                      AppStrings.netMonthlySalary,
                      _calculateNetSalary(),
                      AppStrings.monthlyAmount,
                      isEstimate: true,
                    ),
                  ],
                ],
                
                const SizedBox(height: 32),
                
                // Section Régime fiscal
                _buildSectionHeader(AppStrings.taxSection),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _taxSystem,
                  decoration: const InputDecoration(
                    labelText: AppStrings.taxSystem,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: AppConstants.taxSystemOptions.map((String system) {
                    return DropdownMenuItem<String>(
                      value: system,
                      child: Text(system),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      if (mounted) {
                        setState(() {
                          _taxSystem = newValue;
                        });
                      }
                      _updateProfile();
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                InfoContainer(
                  text: _employmentStatus != 'Sans emploi' && _employmentStatus != 'Étudiant(e)' 
                      ? AppStrings.professionalInfoMessage
                      : AppStrings.salaryInfoMessage,
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

  Widget _buildSalaryInfo(String label, double amount, String period, {bool isEstimate = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEstimate ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEstimate ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (isEstimate)
                  Text(
                    '(Estimation)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatSalary(amount.toStringAsFixed(0))} ${AppStrings.euroSymbol}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEstimate ? Colors.green[700] : Colors.black87,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}