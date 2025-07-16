import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class PersonalInfoScreen extends StatefulWidget {
  final UserProfile profile;
  
  const PersonalInfoScreen({
    super.key,
    required this.profile,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _maritalStatus;
  late int _dependentChildren;
  late DateTime? _birthDate;
  late UserProfile _modifiedProfile;

  final List<String> _maritalStatusOptions = [
    'Célibataire',
    'Marié(e)',
    'Divorcé(e)',
    'Veuf(ve)',
    'Pacsé(e)',
    'Union libre',
  ];

  @override
  void initState() {
    super.initState();
    _modifiedProfile = widget.profile;
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _addressController = TextEditingController(text: widget.profile.address);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _maritalStatus = widget.profile.maritalStatus == 'Non renseigné' 
        ? 'Célibataire' 
        : widget.profile.maritalStatus;
    _dependentChildren = widget.profile.dependentChildren;
    _birthDate = widget.profile.birthDate;
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    _modifiedProfile = _modifiedProfile.copyWith(
      lastName: _lastNameController.text,
      firstName: _firstNameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      maritalStatus: _maritalStatus,
      dependentChildren: _dependentChildren,
      birthDate: _birthDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _updateProfile();
        Navigator.pop(context, _modifiedProfile);
        return false;
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Informations personnelles'),
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
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        _firstNameController.text.isNotEmpty
                            ? _firstNameController.text[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Section Identité
              _buildSectionHeader('Identité'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Ex: Dupont',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
                onChanged: (_) => _updateProfile(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  hintText: 'Ex: Jean',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                  _updateProfile();
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _birthDate) {
                    setState(() {
                      _birthDate = picked;
                    });
                    _updateProfile();
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    hintText: 'Sélectionner une date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _birthDate != null
                        ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                        : 'Non renseignée',
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Section Coordonnées
              _buildSectionHeader('Coordonnées'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse complète',
                  hintText: 'Ex: 123 rue de la Paix, 75001 Paris',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
                onChanged: (_) => _updateProfile(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  hintText: 'Ex: 06 12 34 56 78',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (_) => _updateProfile(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Ex: jean.dupont@email.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Simple validation email
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Email invalide';
                    }
                  }
                  return null;
                },
                onChanged: (_) => _updateProfile(),
              ),
              
              const SizedBox(height: 32),
              
              // Section Situation familiale
              _buildSectionHeader('Situation familiale'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _maritalStatus,
                decoration: const InputDecoration(
                  labelText: 'État civil',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                items: _maritalStatusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _maritalStatus = newValue;
                    });
                    _updateProfile();
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _dependentChildren,
                decoration: const InputDecoration(
                  labelText: 'Nombre d\'enfants à charge',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.child_care),
                ),
                items: List.generate(11, (index) => index).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value == 0 ? 'Aucun' : '$value'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _dependentChildren = newValue;
                    });
                    _updateProfile();
                  }
                },
              ),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ces informations sont essentielles pour calculer vos charges sociales et fiscales',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
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

  void _pickImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Photo de profil'),
          content: const Text('Cette fonctionnalité sera bientôt disponible.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}