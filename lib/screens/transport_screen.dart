import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../services/profile_service.dart';
import '../utils/validators.dart';

class TransportScreen extends StatefulWidget {
  final UserProfile profile;

  const TransportScreen({super.key, required this.profile});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  late UserProfile _modifiedProfile;
  
  // Controllers
  final _distanceController = TextEditingController();
  final _parkingController = TextEditingController();
  final _tollsController = TextEditingController();
  final _employerReimbursementController = TextEditingController();
  
  // State
  String _vehicleType = 'Voiture';
  String _fuelType = 'Essence';
  int _fiscalPower = 5;
  bool _hasModifications = false;
  bool _isSaving = false;

  // États d'expansion des sections
  bool _vehicleExpanded = false;
  bool _tripExpanded = false;
  bool _expensesExpanded = false;

  // Système de tracking des erreurs par section
  final Map<String, bool> _sectionHasError = {
    'vehicle': false,
    'trip': false,
    'expenses': false,
  };

  final Map<String, bool> _sectionIsComplete = {
    'vehicle': false,
    'trip': false,
    'expenses': false,
  };

  @override
  void initState() {
    super.initState();
    _modifiedProfile = widget.profile;
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    final transport = widget.profile.transport;
    if (transport != null) {
      _vehicleType = transport['vehicleType'] ?? 'Voiture';
      _fuelType = transport['fuelType'] ?? 'Essence';
      _fiscalPower = transport['fiscalPower'] ?? 5;
      _distanceController.text = transport['dailyDistance']?.toString() ?? '';
      _parkingController.text = transport['parkingCost']?.toString() ?? '';
      _tollsController.text = transport['tollsCost']?.toString() ?? '';
      _employerReimbursementController.text = transport['employerReimbursement']?.toString() ?? '';
    }
  }

  void _setupListeners() {
    _distanceController.addListener(_onDataChanged);
    _parkingController.addListener(_onDataChanged);
    _tollsController.addListener(_onDataChanged);
    _employerReimbursementController.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (!_hasModifications) {
      setState(() {
        _hasModifications = true;
      });
    }
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _parkingController.dispose();
    _tollsController.dispose();
    _employerReimbursementController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving || !_hasModifications) return;

    setState(() {
      _isSaving = true;
    });

    try {
      _modifiedProfile = _modifiedProfile.copyWith(
        transport: {
          'vehicleType': _vehicleType,
          'fuelType': _fuelType,
          'fiscalPower': _fiscalPower,
          'dailyDistance': double.tryParse(_distanceController.text),
          'parkingCost': double.tryParse(_parkingController.text),
          'tollsCost': double.tryParse(_tollsController.text),
          'employerReimbursement': double.tryParse(_employerReimbursementController.text),
        },
      );

      await _profileService.updateProfile(_modifiedProfile);
      
      // Mettre à jour l'état des erreurs
      _updateSectionErrorStatus();
      
      if (mounted) {
        setState(() {
          _hasModifications = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showErrorDialog(AppStrings.errorGeneric);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.errorTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  // Méthodes de validation par section
  bool _hasVehicleErrors() {
    return false; // Pas d'erreurs possibles car tous les champs sont des dropdowns/sliders
  }

  bool _hasTripErrors() {
    final distance = double.tryParse(_distanceController.text);
    return distance == null || distance <= 0;
  }

  bool _hasExpensesErrors() {
    return Validators.validatePositiveNumber(_parkingController.text) != null ||
           Validators.validatePositiveNumber(_tollsController.text) != null ||
           Validators.validatePositiveNumber(_employerReimbursementController.text) != null;
  }

  bool _isVehicleComplete() {
    return _vehicleType.isNotEmpty && _fuelType.isNotEmpty;
  }

  bool _isTripComplete() {
    final distance = double.tryParse(_distanceController.text);
    return distance != null && distance > 0;
  }

  bool _isExpensesComplete() {
    return true; // Section optionnelle
  }

  void _updateSectionErrorStatus() {
    setState(() {
      _sectionHasError['vehicle'] = _hasVehicleErrors();
      _sectionHasError['trip'] = _hasTripErrors();
      _sectionHasError['expenses'] = _hasExpensesErrors();
      
      _sectionIsComplete['vehicle'] = _isVehicleComplete() && !_hasVehicleErrors();
      _sectionIsComplete['trip'] = _isTripComplete() && !_hasTripErrors();
      _sectionIsComplete['expenses'] = _isExpensesComplete() && !_hasExpensesErrors();
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
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          if (_hasModifications) {
            await _saveProfile();
          }
          if (context.mounted) {
            Navigator.of(context).pop(_modifiedProfile);
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
                firstName: widget.profile.firstName,
                radius: AppConstants.smallAvatarRadius,
                fontSize: AppConstants.smallAvatarFontSize,
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.transportTitle,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1 - Véhicule
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: _vehicleExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _vehicleExpanded = expanded;
                      });
                    },
                    shape: const Border(),
                    title: Row(
                      children: [
                        const Text(
                          'Véhicule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildValidationIcon('vehicle'),
                      ],
                    ),
                    backgroundColor: _sectionHasError['vehicle']! 
                      ? Colors.red.withValues(alpha: 0.1) 
                      : Colors.transparent,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Type de véhicule
                            DropdownButtonFormField<String>(
                              value: _vehicleType,
                              items: ['Voiture', 'Moto'].map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _vehicleType = value!;
                                  _hasModifications = true;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Type de véhicule',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Type de carburant
                            DropdownButtonFormField<String>(
                              value: _fuelType,
                              items: AppConstants.fuelTypes.map((fuel) {
                                return DropdownMenuItem(
                                  value: fuel,
                                  child: Text(fuel),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _fuelType = value!;
                                  _hasModifications = true;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Type de carburant',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Puissance fiscale (seulement pour voiture)
                            if (_vehicleType == 'Voiture') ...[
                              Text(
                                'Puissance fiscale: $_fiscalPower CV',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              Slider(
                                value: _fiscalPower.toDouble(),
                                min: 3,
                                max: 10,
                                divisions: 7,
                                label: '$_fiscalPower CV',
                                onChanged: (value) {
                                  setState(() {
                                    _fiscalPower = value.round();
                                    _hasModifications = true;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Section 2 - Trajet
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: _tripExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _tripExpanded = expanded;
                      });
                    },
                    shape: const Border(),
                    title: Row(
                      children: [
                        const Text(
                          'Trajet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildValidationIcon('trip'),
                      ],
                    ),
                    backgroundColor: _sectionHasError['trip']! 
                      ? Colors.red.withValues(alpha: 0.1) 
                      : Colors.transparent,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Distance domicile-travail
                            TextFormField(
                              controller: _distanceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Distance domicile-travail (aller simple)',
                                suffixText: 'km',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Section 3 - Frais additionnels
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: _expensesExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expensesExpanded = expanded;
                      });
                    },
                    shape: const Border(),
                    title: Row(
                      children: [
                        const Text(
                          'Frais additionnels',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildValidationIcon('expenses'),
                      ],
                    ),
                    backgroundColor: _sectionHasError['expenses']! 
                      ? Colors.red.withValues(alpha: 0.1) 
                      : Colors.transparent,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Parking mensuel
                            TextFormField(
                              controller: _parkingController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Parking mensuel',
                                suffixText: '€/mois',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Péages mensuels
                            TextFormField(
                              controller: _tollsController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Péages mensuels',
                                suffixText: '€/mois',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Remboursement transport employeur
                            TextFormField(
                              controller: _employerReimbursementController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Remboursement transport employeur',
                                suffixText: '€/mois',
                                border: OutlineInputBorder(),
                              ),
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
      ),
    );
  }
}