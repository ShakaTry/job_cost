import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../widgets/profile_avatar.dart';

class ProfessionalExpensesScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfessionalExpensesScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ProfessionalExpensesScreen> createState() => _ProfessionalExpensesScreenState();
}

class _ProfessionalExpensesScreenState extends State<ProfessionalExpensesScreen> {
  final _profileService = ProfileService();
  late UserProfile _profile;

  // Controllers pour frais de repas
  final _mealExpensesController = TextEditingController();
  final _mealAllowanceController = TextEditingController();
  final _mealTicketValueController = TextEditingController();
  final _mealTicketsPerMonthController = TextEditingController();

  // Controllers pour garde d'enfants
  final _childcareCostController = TextEditingController();
  final _childcareAidsController = TextEditingController();

  // Controllers pour télétravail
  final _workDaysPerWeekController = TextEditingController();
  final _remoteDaysPerWeekController = TextEditingController();
  final _remoteAllowanceController = TextEditingController();
  final _remoteExpensesController = TextEditingController();
  final _remoteEquipmentController = TextEditingController();

  // Controllers pour équipements et autres
  final _workClothingController = TextEditingController();
  final _professionalEquipmentController = TextEditingController();
  final _trainingCostController = TextEditingController();
  final _unionFeesController = TextEditingController();

  String? _childcareType;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    // Frais de repas
    _mealExpensesController.text = _profile.mealExpenses?.toStringAsFixed(2) ?? '';
    _mealAllowanceController.text = _profile.mealAllowance?.toStringAsFixed(2) ?? '';
    _mealTicketValueController.text = _profile.mealTicketValue?.toStringAsFixed(2) ?? '';
    _mealTicketsPerMonthController.text = _profile.mealTicketsPerMonth?.toString() ?? '';

    // Garde d'enfants
    _childcareType = _profile.childcareType;
    _childcareCostController.text = _profile.childcareCost?.toStringAsFixed(2) ?? '';
    _childcareAidsController.text = _profile.childcareAids?.toStringAsFixed(2) ?? '';

    // Télétravail
    _workDaysPerWeekController.text = _profile.workDaysPerWeek?.toStringAsFixed(1) ?? '';
    _remoteDaysPerWeekController.text = _profile.remoteDaysPerWeek?.toStringAsFixed(1) ?? '';
    _remoteAllowanceController.text = _profile.remoteAllowance?.toStringAsFixed(2) ?? '';
    _remoteExpensesController.text = _profile.remoteExpenses?.toStringAsFixed(2) ?? '';
    _remoteEquipmentController.text = _profile.remoteEquipment?.toStringAsFixed(2) ?? '';

    // Équipements et autres
    _workClothingController.text = _profile.workClothing?.toStringAsFixed(2) ?? '';
    _professionalEquipmentController.text = _profile.professionalEquipment?.toStringAsFixed(2) ?? '';
    _trainingCostController.text = _profile.trainingCost?.toStringAsFixed(2) ?? '';
    _unionFeesController.text = _profile.unionFees?.toStringAsFixed(2) ?? '';
  }

  void _setupListeners() {
    // Listeners pour sauvegarde automatique
    _mealExpensesController.addListener(_saveProfile);
    _mealAllowanceController.addListener(_saveProfile);
    _mealTicketValueController.addListener(_saveProfile);
    _mealTicketsPerMonthController.addListener(_saveProfile);
    _childcareCostController.addListener(_saveProfile);
    _childcareAidsController.addListener(_saveProfile);
    _workDaysPerWeekController.addListener(_saveProfile);
    _remoteDaysPerWeekController.addListener(_saveProfile);
    _remoteAllowanceController.addListener(_saveProfile);
    _remoteExpensesController.addListener(_saveProfile);
    _remoteEquipmentController.addListener(_saveProfile);
    _workClothingController.addListener(_saveProfile);
    _professionalEquipmentController.addListener(_saveProfile);
    _trainingCostController.addListener(_saveProfile);
    _unionFeesController.addListener(_saveProfile);
  }

  @override
  void dispose() {
    // Disposal des controllers
    _mealExpensesController.dispose();
    _mealAllowanceController.dispose();
    _mealTicketValueController.dispose();
    _mealTicketsPerMonthController.dispose();
    _childcareCostController.dispose();
    _childcareAidsController.dispose();
    _workDaysPerWeekController.dispose();
    _remoteDaysPerWeekController.dispose();
    _remoteAllowanceController.dispose();
    _remoteExpensesController.dispose();
    _remoteEquipmentController.dispose();
    _workClothingController.dispose();
    _professionalEquipmentController.dispose();
    _trainingCostController.dispose();
    _unionFeesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      _profile = _profile.copyWith(
        // Frais de repas
        mealExpenses: double.tryParse(_mealExpensesController.text),
        mealAllowance: double.tryParse(_mealAllowanceController.text),
        mealTicketValue: double.tryParse(_mealTicketValueController.text),
        mealTicketsPerMonth: int.tryParse(_mealTicketsPerMonthController.text),

        // Garde d'enfants
        childcareType: _childcareType,
        childcareCost: double.tryParse(_childcareCostController.text),
        childcareAids: double.tryParse(_childcareAidsController.text),

        // Télétravail
        workDaysPerWeek: double.tryParse(_workDaysPerWeekController.text),
        remoteDaysPerWeek: double.tryParse(_remoteDaysPerWeekController.text),
        remoteAllowance: double.tryParse(_remoteAllowanceController.text),
        remoteExpenses: double.tryParse(_remoteExpensesController.text),
        remoteEquipment: double.tryParse(_remoteEquipmentController.text),

        // Équipements et autres
        workClothing: double.tryParse(_workClothingController.text),
        professionalEquipment: double.tryParse(_professionalEquipmentController.text),
        trainingCost: double.tryParse(_trainingCostController.text),
        unionFees: double.tryParse(_unionFeesController.text),
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
                      AppStrings.professionalExpensesTitle,
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
              // Card 1 - Frais de repas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frais de repas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _mealTicketValueController,
                              decoration: const InputDecoration(
                                labelText: 'Valeur du titre-restaurant',
                                suffixText: '€',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _mealTicketsPerMonthController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre/mois',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mealExpensesController,
                        decoration: const InputDecoration(
                          labelText: 'Frais de repas mensuels (hors titres)',
                          hintText: 'Repas pris sur le lieu de travail',
                          suffixText: '€/mois',
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
                        controller: _mealAllowanceController,
                        decoration: const InputDecoration(
                          labelText: 'Indemnité repas employeur',
                          suffixText: '€/mois',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card 2 - Garde d'enfants (seulement si enfants à charge)
              if (_profile.dependentChildren > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Garde d\'enfants',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _childcareType,
                          decoration: const InputDecoration(
                            labelText: 'Type de garde',
                            border: OutlineInputBorder(),
                          ),
                          items: AppConstants.childcareTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _childcareType = value;
                              _saveProfile();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _childcareCostController,
                          decoration: const InputDecoration(
                            labelText: 'Coût mensuel de la garde',
                            suffixText: '€/mois',
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
                          controller: _childcareAidsController,
                          decoration: const InputDecoration(
                            labelText: 'Aides reçues (CAF, employeur)',
                            suffixText: '€/mois',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Card 3 - Télétravail
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Télétravail',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _workDaysPerWeekController,
                              decoration: const InputDecoration(
                                labelText: 'Jours travaillés/semaine',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                              ],
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _remoteDaysPerWeekController,
                              decoration: const InputDecoration(
                                labelText: 'Jours télétravail/semaine',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                              ],
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _remoteAllowanceController,
                        decoration: const InputDecoration(
                          labelText: 'Forfait télétravail employeur',
                          suffixText: '€/mois',
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
                        controller: _remoteExpensesController,
                        decoration: const InputDecoration(
                          labelText: 'Frais réels estimés (internet, électricité)',
                          suffixText: '€/mois',
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
                        controller: _remoteEquipmentController,
                        decoration: const InputDecoration(
                          labelText: 'Équipement (bureau, chaise) - amortissement',
                          suffixText: '€/mois',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card 4 - Équipements et autres frais
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Équipements et autres frais',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _workClothingController,
                        decoration: const InputDecoration(
                          labelText: 'Vêtements de travail',
                          suffixText: '€/mois',
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
                        controller: _professionalEquipmentController,
                        decoration: const InputDecoration(
                          labelText: 'Matériel professionnel',
                          suffixText: '€/mois',
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
                        controller: _trainingCostController,
                        decoration: const InputDecoration(
                          labelText: 'Formation non remboursée',
                          suffixText: '€/mois',
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
                        controller: _unionFeesController,
                        decoration: const InputDecoration(
                          labelText: 'Cotisations syndicales',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}