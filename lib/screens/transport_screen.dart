import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../widgets/info_container.dart';

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
  final _publicTransportController = TextEditingController();
  final _parkingController = TextEditingController();
  final _tollsController = TextEditingController();
  
  // State
  String _transportMode = 'Voiture personnelle';
  String _vehicleType = 'Voiture';
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
      _transportMode = transport['mode'] ?? 'Voiture personnelle';
      _vehicleType = transport['vehicleType'] ?? 'Voiture';
      _fiscalPower = transport['fiscalPower'] ?? 5;
      _distanceController.text = transport['dailyDistance']?.toString() ?? '';
      _workDaysController.text = transport['workDaysPerWeek']?.toString() ?? '';
      _publicTransportController.text = transport['publicTransportCost']?.toString() ?? '';
      _parkingController.text = transport['parkingCost']?.toString() ?? '';
      _tollsController.text = transport['tollsCost']?.toString() ?? '';
    }
  }

  void _setupListeners() {
    _distanceController.addListener(_onDataChanged);
    _workDaysController.addListener(_onDataChanged);
    _publicTransportController.addListener(_onDataChanged);
    _parkingController.addListener(_onDataChanged);
    _tollsController.addListener(_onDataChanged);
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
    _publicTransportController.dispose();
    _parkingController.dispose();
    _tollsController.dispose();
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
          'mode': _transportMode,
          'vehicleType': _vehicleType,
          'fiscalPower': _fiscalPower,
          'dailyDistance': double.tryParse(_distanceController.text),
          'workDaysPerWeek': int.tryParse(_workDaysController.text),
          'publicTransportCost': double.tryParse(_publicTransportController.text),
          'parkingCost': double.tryParse(_parkingController.text),
          'tollsCost': double.tryParse(_tollsController.text),
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

  double _calculateMileageRate() {
    // Barème kilométrique 2024 (simplifié)
    if (_vehicleType == 'Voiture') {
      if (_fiscalPower <= 3) return 0.529;
      if (_fiscalPower == 4) return 0.606;
      if (_fiscalPower == 5) return 0.636;
      if (_fiscalPower == 6) return 0.665;
      return 0.697; // 7 CV et plus
    } else if (_vehicleType == 'Moto') {
      return 0.395; // Tarif moyen moto
    }
    return 0.529; // Défaut
  }

  double _calculateAnnualKilometers() {
    final distance = double.tryParse(_distanceController.text) ?? 0;
    final workDays = int.tryParse(_workDaysController.text) ?? 0;
    return distance * workDays * 47; // 47 semaines travaillées
  }

  double _calculateAnnualMileageCost() {
    return _calculateAnnualKilometers() * _calculateMileageRate();
  }

  double _calculateTotalAnnualCost() {
    double total = 0;
    
    if (_transportMode == 'Voiture personnelle' || _transportMode == 'Moto personnelle') {
      total += _calculateAnnualMileageCost();
    } else if (_transportMode == 'Transports en commun') {
      total += (double.tryParse(_publicTransportController.text) ?? 0) * 12;
    }
    
    // Ajouter parking et péages
    total += (double.tryParse(_parkingController.text) ?? 0) * 12;
    total += (double.tryParse(_tollsController.text) ?? 0) * 12;
    
    return total;
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
                // Mode de transport
                const Text(
                  'Mode de transport principal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _transportMode,
                  items: AppConstants.transportModes.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _transportMode = value!;
                      _hasModifications = true;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                
                // Section véhicule personnel
                if (_transportMode == 'Voiture personnelle' || _transportMode == 'Moto personnelle') ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Informations véhicule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                  
                  // Info barème kilométrique
                  const SizedBox(height: 16),
                  const InfoContainer(
                    text: 'Barème kilométrique 2024',
                    isBold: true,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Taux applicable : ${_calculateMileageRate().toStringAsFixed(3)} €/km'),
                        if (_calculateAnnualKilometers() > 0) ...[
                          const SizedBox(height: 4),
                          Text('Distance annuelle : ${_calculateAnnualKilometers().toStringAsFixed(0)} km'),
                          Text('Frais annuels : ${_calculateAnnualMileageCost().toStringAsFixed(2)} €'),
                        ],
                      ],
                    ),
                  ),
                ],
                
                // Section transports en commun
                if (_transportMode == 'Transports en commun') ...[
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _publicTransportController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Coût mensuel des transports',
                      border: OutlineInputBorder(),
                      suffixText: '€/mois',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ],
                
                // Frais additionnels
                const SizedBox(height: 24),
                const Text(
                  'Frais additionnels',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                  textInputAction: TextInputAction.done,
                ),
                
                // Récapitulatif
                if (_calculateTotalAnnualCost() > 0) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Récapitulatif annuel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (_transportMode == 'Voiture personnelle' || _transportMode == 'Moto personnelle') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Frais kilométriques :'),
                              Text(
                                '${_calculateAnnualMileageCost().toStringAsFixed(2)} €',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        if (_transportMode == 'Transports en commun' && _publicTransportController.text.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Transports en commun :'),
                              Text(
                                '${((double.tryParse(_publicTransportController.text) ?? 0) * 12).toStringAsFixed(2)} €',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        if (_parkingController.text.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Parking :'),
                              Text(
                                '${((double.tryParse(_parkingController.text) ?? 0) * 12).toStringAsFixed(2)} €',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        if (_tollsController.text.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Péages :'),
                              Text(
                                '${((double.tryParse(_tollsController.text) ?? 0) * 12).toStringAsFixed(2)} €',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total annuel :',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_calculateTotalAnnualCost().toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 80), // Espace en bas
              ],
            ),
          ),
        ),
      ),
    );
  }
}