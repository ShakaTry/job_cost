# Pattern de Sauvegarde Automatique

## Vue d'ensemble
Ce document décrit le pattern de sauvegarde automatique utilisé dans l'application Job Cost pour les écrans de formulaire. Ce pattern garantit que les modifications sont sauvegardées en temps réel et correctement propagées dans la hiérarchie des écrans.

## Architecture

### 1. Navigation et propagation des données
```
ProfileSelectionScreen
    ↓ (passe UserProfile)
ProfileDetailScreen  
    ↓ (passe UserProfile)
FormScreen (ex: PersonalInfoScreen, ProfessionalSituationScreen)
    ↑ (retourne UserProfile modifié)
ProfileDetailScreen (met à jour son état)
    ↑ (retourne UserProfile modifié)
ProfileSelectionScreen (met à jour la liste)
```

### 2. Composants essentiels

#### A. Dans le FormScreen (écran de formulaire)

```dart
class FormScreen extends StatefulWidget {
  final UserProfile profile;
  
  const FormScreen({
    super.key,
    required this.profile,
  });
}

class _FormScreenState extends State<FormScreen> {
  final ProfileService _profileService = ProfileService();
  late UserProfile _modifiedProfile;
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _modifiedProfile = widget.profile;
    _controller = TextEditingController(text: widget.profile.someField);
    
    // Listener pour sauvegarde automatique
    _controller.addListener(() {
      _updateProfile();
    });
  }
  
  void _updateProfile() {
    _modifiedProfile = _modifiedProfile.copyWith(
      someField: _controller.text,
    );
    
    // Sauvegarde automatique immédiate
    _profileService.updateProfile(_modifiedProfile);
  }
  
  @override
  Widget build(BuildContext context) {
    // IMPORTANT: PopScope pour renvoyer le profil modifié
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Navigator.pop(context, _modifiedProfile);
        }
      },
      child: Scaffold(
        // Contenu du formulaire
      ),
    );
  }
}
```

#### B. Dans ProfileDetailScreen (écran parent)

```dart
// Navigation vers un écran de formulaire
final updatedProfile = await Navigator.push<UserProfile>(
  context,
  MaterialPageRoute(
    builder: (context) => FormScreen(profile: profile),
  ),
);

// Mise à jour de l'état local si le profil a été modifié
if (updatedProfile != null && mounted) {
  setState(() {
    profile = updatedProfile;
  });
}
```

#### C. Dans ProfileSelectionScreen (écran racine)

```dart
// Gestion du retour depuis ProfileDetailScreen
if (result is UserProfile) {
  setState(() {
    final index = _profiles.indexWhere((p) => p.id == result.id);
    if (index != -1) {
      _profiles[index] = result;
    }
  });
  await _profileService.saveProfiles(_profiles);
}
```

## Points clés d'implémentation

### 1. Sauvegarde en temps réel
- Utiliser des `TextEditingController.addListener()` pour détecter les changements
- Appeler `_updateProfile()` à chaque modification
- Sauvegarder immédiatement avec `_profileService.updateProfile()`

### 2. Retour du profil modifié
- **OBLIGATOIRE**: Utiliser `PopScope` avec `canPop: false`
- Dans `onPopInvokedWithResult`, toujours faire `Navigator.pop(context, _modifiedProfile)`
- Cela garantit que le profil modifié est renvoyé à l'écran parent

### 3. Gestion des champs complexes
Pour les champs avec calculs (comme salaire/taux horaire):
```dart
_salaryController.addListener(() {
  if (!_isUpdating) {
    _updateCalculations();  // D'abord les calculs
    _updateProfile();       // Ensuite la sauvegarde
    if (mounted) setState(() {});  // Enfin le rafraîchissement UI
  }
});
```

### 4. Éviter les callbacks redondants
- Si vous utilisez des listeners, n'ajoutez PAS `onChanged` dans les TextFormField
- Les listeners sont suffisants pour la sauvegarde automatique

## Exemple complet: PersonalInfoScreen

```dart
class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final ProfileService _profileService = ProfileService();
  late UserProfile _modifiedProfile;
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  
  @override
  void initState() {
    super.initState();
    _modifiedProfile = widget.profile;
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    
    // Listeners pour sauvegarde automatique
    _lastNameController.addListener(_updateProfile);
    _firstNameController.addListener(_updateProfile);
  }
  
  void _updateProfile() {
    _modifiedProfile = _modifiedProfile.copyWith(
      lastName: _lastNameController.text,
      firstName: _firstNameController.text,
    );
    
    // Sauvegarde automatique
    _profileService.updateProfile(_modifiedProfile);
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Validation optionnelle avant de quitter
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context, _modifiedProfile);
          } else {
            // Gérer les erreurs de validation
          }
        }
      },
      child: Scaffold(
        // Formulaire
      ),
    );
  }
}
```

## Checklist pour implémenter un nouvel écran

- [ ] Créer une variable `_modifiedProfile` initialisée avec `widget.profile`
- [ ] Créer des `TextEditingController` pour chaque champ
- [ ] Ajouter des listeners dans `initState()` pour la sauvegarde automatique
- [ ] Implémenter `_updateProfile()` qui copie et sauvegarde
- [ ] Envelopper le Scaffold dans un `PopScope`
- [ ] Dans `onPopInvokedWithResult`, renvoyer `_modifiedProfile`
- [ ] L'écran parent doit gérer le profil retourné avec `setState()`
- [ ] Ne PAS ajouter `onChanged` si des listeners sont déjà en place

## Erreurs courantes à éviter

1. **Oublier le PopScope**: Sans lui, les modifications ne remontent pas
2. **Utiliser `widget.profile` au lieu de `_modifiedProfile`**: Toujours travailler avec la copie locale
3. **Double sauvegarde**: Ne pas appeler `_updateProfile()` dans `onChanged` ET dans un listener
4. **Oublier `mounted` avant `setState`**: Toujours vérifier dans les callbacks asynchrones
5. **Ne pas initialiser `_modifiedProfile`**: Doit être fait dans `initState()`

## Tests recommandés

1. Modifier un champ et naviguer en arrière → vérifier que la modification est conservée
2. Modifier plusieurs champs rapidement → vérifier que toutes les modifications sont sauvegardées
3. Quitter l'app et revenir → vérifier la persistance des données
4. Annuler avec validation échouée → vérifier que les champs valides sont conservés