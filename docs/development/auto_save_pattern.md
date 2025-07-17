# Pattern de Sauvegarde Automatique

## Vue d'ensemble
Ce document décrit le pattern de sauvegarde automatique utilisé dans l'application Job Cost pour les écrans de formulaire. Ce pattern garantit que les modifications sont sauvegardées à la sortie de l'écran et correctement propagées dans la hiérarchie des écrans.

## Pattern de Sauvegarde : PopScope

### Principe
- **Pendant la saisie** : Aucune sauvegarde (performance optimale)
- **À la sortie** : Sauvegarde unique via PopScope
- **Navigation** : Le profil modifié est retourné à l'écran parent

### Implémentation standard

```dart
class FormScreen extends StatefulWidget {
  final UserProfile profile;
  
  const FormScreen({super.key, required this.profile});
}

class _FormScreenState extends State<FormScreen> {
  final _profileService = ProfileService();
  late UserProfile _profile;
  
  // Controllers pour les champs
  final _fieldController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _initializeControllers();
  }
  
  void _initializeControllers() {
    _fieldController.text = _profile.field ?? '';
  }
  
  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }
  
  Future<void> _saveProfile() async {
    try {
      _profile = _profile.copyWith(
        field: _fieldController.text,
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
          await _saveProfile();
          if (mounted) {
            Navigator.pop(context, _profile);
          }
        }
      },
      child: Scaffold(
        // Contenu du formulaire
      ),
    );
  }
}
```

## Navigation et propagation des données

### Architecture
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

### Dans l'écran parent (ProfileDetailScreen)

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

## Points clés d'implémentation

### 1. PopScope obligatoire
- **OBLIGATOIRE**: Utiliser `PopScope` avec `canPop: false`
- Dans `onPopInvokedWithResult`, toujours faire `await _saveProfile()` puis `Navigator.pop(context, _profile)`
- Cela garantit que le profil modifié est renvoyé à l'écran parent

### 2. Copie locale du profil
- Créer une variable `_profile` initialisée avec `widget.profile`
- Toujours travailler sur cette copie locale
- Utiliser `copyWith` pour les modifications

### 3. Sauvegarde unique
- Une seule méthode `_saveProfile()` asynchrone
- Appelée uniquement dans `PopScope`
- Pas de listeners ou `onChanged` pour la sauvegarde

## Checklist pour implémenter un nouvel écran

- [ ] Créer une variable `_profile` initialisée avec `widget.profile`
- [ ] Créer des `TextEditingController` pour chaque champ
- [ ] Initialiser les controllers dans `initState()`
- [ ] Implémenter `_saveProfile()` qui copie et sauvegarde
- [ ] Envelopper le Scaffold dans un `PopScope`
- [ ] Dans `onPopInvokedWithResult`, appeler `await _saveProfile()` puis retourner `_profile`
- [ ] L'écran parent doit gérer le profil retourné avec `setState()`
- [ ] Disposer les controllers dans `dispose()`

## Erreurs courantes à éviter

1. **Oublier le PopScope**: Sans lui, les modifications ne remontent pas
2. **Utiliser `widget.profile` au lieu de `_profile`**: Toujours travailler avec la copie locale
3. **Sauvegarde temps réel**: Ne pas appeler `_saveProfile()` dans des listeners ou `onChanged`
4. **Oublier `mounted` avant `setState`**: Toujours vérifier dans les callbacks asynchrones
5. **Ne pas initialiser `_profile`**: Doit être fait dans `initState()`

## Avantages de ce pattern

- **Performance**: Une seule opération d'écriture disque par session
- **Simplicité**: Code plus lisible et maintenable  
- **Robustesse**: Comportement prédictible
- **UX**: Pas de ralentissement pendant la saisie