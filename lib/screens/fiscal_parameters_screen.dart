import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../widgets/profile_avatar.dart';

class FiscalParametersScreen extends StatefulWidget {
  final UserProfile profile;

  const FiscalParametersScreen({
    super.key,
    required this.profile,
  });

  @override
  State<FiscalParametersScreen> createState() => _FiscalParametersScreenState();
}

class _FiscalParametersScreenState extends State<FiscalParametersScreen> {
  final _profileService = ProfileService();
  late UserProfile _profile;

  // Controllers pour régime fiscal
  final _withholdingRateController = TextEditingController();
  final _fiscalPartsController = TextEditingController();

  // Controllers pour barème kilométrique
  final _deductibleCSGController = TextEditingController();

  // Controllers pour autres déductions
  final _additionalDeductionsController = TextEditingController();

  String? _fiscalRegime;
  String? _mileageScaleCategory;

  // États d'expansion des sections
  bool _fiscalRegimeExpanded = false;
  bool _mileageScaleExpanded = false;
  bool _deductionsExpanded = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    // Régime fiscal
    _fiscalRegime = _profile.fiscalRegime;
    _withholdingRateController.text = _profile.withholdingRate?.toStringAsFixed(2) ?? '';
    _fiscalPartsController.text = _profile.fiscalParts?.toStringAsFixed(1) ?? '';

    // Barème kilométrique
    _mileageScaleCategory = _profile.mileageScaleCategory;
    _deductibleCSGController.text = _profile.deductibleCSG?.toStringAsFixed(2) ?? '';

    // Autres déductions
    _additionalDeductionsController.text = _profile.additionalDeductions?.toStringAsFixed(2) ?? '';
  }

  void _setupListeners() {
    // Listeners pour sauvegarde automatique
    _withholdingRateController.addListener(_saveProfile);
    _fiscalPartsController.addListener(_saveProfile);
    _deductibleCSGController.addListener(_saveProfile);
    _additionalDeductionsController.addListener(_saveProfile);
  }

  @override
  void dispose() {
    // Disposal des controllers
    _withholdingRateController.dispose();
    _fiscalPartsController.dispose();
    _deductibleCSGController.dispose();
    _additionalDeductionsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      _profile = _profile.copyWith(
        fiscalRegime: _fiscalRegime,
        withholdingRate: double.tryParse(_withholdingRateController.text),
        fiscalParts: double.tryParse(_fiscalPartsController.text),
        mileageScaleCategory: _mileageScaleCategory,
        deductibleCSG: double.tryParse(_deductibleCSGController.text),
        additionalDeductions: double.tryParse(_additionalDeductionsController.text),
      );

      await _profileService.updateProfile(_profile);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Navigator.pop(context, _profile);
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
                firstName: _profile.firstName,
                radius: AppConstants.smallAvatarRadius,
                fontSize: AppConstants.smallAvatarFontSize,
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.fiscalParametersTitle,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1 - Régime fiscal et prélèvement à la source
              Card(
                child: ExpansionTile(
                  initiallyExpanded: _fiscalRegimeExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _fiscalRegimeExpanded = expanded;
                    });
                  },
                  shape: const Border(),
                  title: const Text(
                    'Régime fiscal et prélèvement à la source',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _fiscalRegime,
                            decoration: const InputDecoration(
                              labelText: 'Régime fiscal',
                              border: OutlineInputBorder(),
                            ),
                            items: AppConstants.fiscalRegimes.map((regime) {
                              return DropdownMenuItem(
                                value: regime,
                                child: Text(regime),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _fiscalRegime = value;
                                _saveProfile();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _withholdingRateController,
                            decoration: const InputDecoration(
                              labelText: 'Taux de prélèvement à la source',
                              hintText: 'Ex: 7.50',
                              suffixText: '%',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fiscalPartsController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de parts fiscales',
                              hintText: 'Ex: 2.5',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 2 - Barème kilométrique
              Card(
                child: ExpansionTile(
                  initiallyExpanded: _mileageScaleExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _mileageScaleExpanded = expanded;
                    });
                  },
                  shape: const Border(),
                  title: const Text(
                    'Barème kilométrique',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _mileageScaleCategory,
                            decoration: const InputDecoration(
                              labelText: 'Catégorie du barème kilométrique',
                              border: OutlineInputBorder(),
                            ),
                            items: AppConstants.mileageScaleCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _mileageScaleCategory = value;
                                _saveProfile();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Le barème kilométrique sera utilisé pour calculer vos frais réels de transport',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 14,
                                    ),
                                  ),
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
              const SizedBox(height: 16),

              // Section 3 - Déductions fiscales
              Card(
                child: ExpansionTile(
                  initiallyExpanded: _deductionsExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _deductionsExpanded = expanded;
                    });
                  },
                  shape: const Border(),
                  title: const Text(
                    'Déductions fiscales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _deductibleCSGController,
                            decoration: const InputDecoration(
                              labelText: 'CSG déductible (si différent du standard)',
                              hintText: 'Laisser vide pour utiliser le taux standard',
                              suffixText: '%',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _additionalDeductionsController,
                            decoration: const InputDecoration(
                              labelText: 'Autres déductions fiscales mensuelles',
                              hintText: 'Pension alimentaire, épargne retraite, etc.',
                              suffixText: '€/mois',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            textInputAction: TextInputAction.done,
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