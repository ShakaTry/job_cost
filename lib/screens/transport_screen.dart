import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

class TransportScreen extends StatefulWidget {
  final UserProfile profile;

  const TransportScreen({super.key, required this.profile});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  
  // Controllers
  final _distanceController = TextEditingController();
  final _workDaysController = TextEditingController();
  final _teleworkDaysController = TextEditingController();
  final _parkingController = TextEditingController();
  final _tollsController = TextEditingController();
  final _employerReimbursementController = TextEditingController();
  
  // State
  String _vehicleType = 'Voiture';
  String _fuelType = 'Essence';
  int _fiscalPower = 5;
  bool _hasModifications = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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
      _workDaysController.text = transport['workDaysPerWeek']?.toString() ?? '';
      _teleworkDaysController.text = transport['teleworkDaysPerWeek']?.toString() ?? '';
      _parkingController.text = transport['parkingCost']?.toString() ?? '';
      _tollsController.text = transport['tollsCost']?.toString() ?? '';
      _employerReimbursementController.text = transport['employerReimbursement']?.toString() ?? '';
    }
  }

  void _setupListeners() {
    _distanceController.addListener(_onDataChanged);
    _workDaysController.addListener(_onDataChanged);
    _teleworkDaysController.addListener(_onDataChanged);
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
    _workDaysController.dispose();
    _teleworkDaysController.dispose();
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
      final updatedProfile = widget.profile.copyWith(
        transport: {
          'vehicleType': _vehicleType,
          'fuelType': _fuelType,
          'fiscalPower': _fiscalPower,
          'dailyDistance': double.tryParse(_distanceController.text),
          'workDaysPerWeek': int.tryParse(_workDaysController.text),
          'teleworkDaysPerWeek': int.tryParse(_teleworkDaysController.text),
          'parkingCost': double.tryParse(_parkingController.text),
          'tollsCost': double.tryParse(_tollsController.text),
          'employerReimbursement': double.tryParse(_employerReimbursementController.text),
        },
      );

      await _profileService.updateProfile(updatedProfile);
      
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


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasModifications,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop && _hasModifications) {
          await _saveProfile();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transport & Déplacements'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card 1 - Véhicule
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Véhicule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
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
                            labelText: 'Carburant',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                  
                        // Puissance fiscale
                        if (_vehicleType == 'Voiture') ...[
                    const Text('Puissance fiscale (CV)'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
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
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '$_fiscalPower CV',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card 2 - Trajet
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trajet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Distance domicile-travail
                        TextFormField(
                          controller: _distanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Distance domicile-travail (km aller simple)',
                            border: OutlineInputBorder(),
                            suffixText: 'km',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Jours travaillés par semaine
                        TextFormField(
                          controller: _workDaysController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Jours travaillés par semaine',
                            border: OutlineInputBorder(),
                            suffixText: 'jours',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Jours de télétravail
                        TextFormField(
                          controller: _teleworkDaysController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Jours de télétravail par semaine',
                            border: OutlineInputBorder(),
                            suffixText: 'jours',
                            helperText: 'Réduit les frais de transport',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card 3 - Frais additionnels
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Frais additionnels',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Parking
                        TextFormField(
                          controller: _parkingController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Frais de parking mensuel',
                            border: OutlineInputBorder(),
                            suffixText: '€/mois',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Péages
                        TextFormField(
                          controller: _tollsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Frais de péages mensuel',
                            border: OutlineInputBorder(),
                            suffixText: '€/mois',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Remboursement employeur
                        TextFormField(
                          controller: _employerReimbursementController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Remboursement transport employeur',
                            border: OutlineInputBorder(),
                            suffixText: '€/mois',
                            helperText: 'Montant remboursé par l\'employeur',
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ),
                
                
                const SizedBox(height: 80), // Espace en bas
              ],
            ),
          ),
        ),
      ),
    );
  }
}