# Job Cost - Documentation Claude

## Projet
Application Android/iOS développée avec Flutter pour estimer le salaire réel net en déduisant tous les frais annexes pour un emploi ou recherche d'emploi.

## Gestion Git
- Claude gère entièrement Git pour ce projet
- Stratégie Git Flow : main, develop, feature/*, bugfix/*, hotfix/*
- Commits réguliers avec messages descriptifs
- URL du repo : https://github.com/ShakaTry/job_cost.git
- Branche actuelle : feature/setup-base-structure

## État actuel du projet

### Pages complétées
1. **Sélection de profil** - Écran principal avec liste des profils
2. **Création de profil** - Dialog simple (nom/prénom uniquement)
3. **Vue détaillée du profil** - Affiche les sections disponibles
4. **Informations personnelles** - Formulaire complet avec :
   - Identité (nom, prénom, date de naissance, nationalité)
   - Coordonnées (adresse, téléphone, email)
   - Situation familiale (état civil, enfants à charge)
   - Validation des formulaires
   - Sauvegarde automatique
   - Navigation clavier optimisée

### Architecture du code
```
lib/
├── constants/
│   ├── app_constants.dart  # Constantes de l'app (valeurs par défaut, listes)
│   └── app_strings.dart    # Toutes les chaînes de caractères
├── models/
│   └── user_profile.dart   # Modèle de données utilisateur
├── screens/
│   ├── profile_selection_screen.dart
│   ├── profile_detail_screen.dart
│   └── personal_info_screen.dart
├── utils/
│   └── validators.dart     # Validation centralisée des formulaires
├── widgets/
│   ├── profile_avatar.dart # Avatar réutilisable
│   └── info_container.dart  # Container d'info bleu réutilisable
└── main.dart
```

### Conventions de code
- Utilisation de widgets réutilisables pour éviter la duplication
- Constantes centralisées (pas de strings hardcodées)
- Validation centralisée avec la classe Validators
- Gestion d'erreurs avec try-catch sur les opérations async
- Vérification mounted avant setState dans les contextes async
- Formatage automatique du téléphone français
- textInputAction pour navigation clavier entre champs

### Préférences UX de l'utilisateur
- Pas de titres redondants
- Dialogs centrés au lieu de snackbars en bas
- Sauvegarde automatique (pas de bouton save)
- Gestion intelligente des erreurs (préserver les données valides)
- Navigation clavier entre les champs de formulaire (Tab/Entrée)
- Dropdown pour la nationalité (standardisation)
- Formatage automatique du téléphone pour éviter les erreurs

### Stratégie de monétisation (future)
**Version gratuite :**
- 3 profils maximum
- Saisie manuelle des données
- Calculs basiques

**Version Premium (5€/mois ou 50€/an) :**
- Profils illimités
- Autocomplétion d'adresses (Google Maps)
- Import automatique (LinkedIn, fiches de paie PDF)
- Calculs précis avec données temps réel
- Export PDF détaillé

### Prochaines étapes
1. Créer la page "Situation professionnelle"
2. Créer la page "Transport & Déplacements"
3. Créer la page "Frais professionnels"
4. Créer la page "Paramètres fiscaux"
5. Implémenter l'écran de calcul
6. Ajouter la persistance des données (SQLite)

### Notes importantes
- L'application est Android/iOS uniquement (pas de support desktop)
- Focus sur les candidats/employés uniquement
- Développement progressif sans précipitation
- Les 3 profils d'exemple sont temporaires pour le développement
- Toujours exécuter `flutter analyze` avant de commit/push

### Commandes utiles
```bash
# Vérifier le code
flutter analyze

# Lancer sur émulateur Android
flutter run -d emulator-5554

# Nettoyer et récupérer les dépendances
flutter clean && flutter pub get
```

## Gestion Git (rappel du workflow)

### Branches principales
- **`main`** : Branche de production (protégée)
- **`develop`** : Branche de développement principal

### Workflow type
1. Créer une feature branch depuis develop
2. Développer et tester
3. Commits réguliers avec messages descriptifs
4. Push vers GitHub
5. Créer une Pull Request vers develop
6. Merge après review

### Format des commits
```
type: Description courte

- Détail 1
- Détail 2

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types : feat, fix, docs, style, refactor, test, chore