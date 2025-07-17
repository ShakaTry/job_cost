Il # Job Cost - Documentation Claude

## Projet
Application Android/iOS développée avec Flutter pour estimer le salaire réel net en déduisant tous les frais annexes pour un emploi ou recherche d'emploi.

## Gestion Git
- Claude gère entièrement Git pour ce projet
- Stratégie Git Flow : main, develop, feature/*, bugfix/*, hotfix/*
- Commits réguliers avec messages descriptifs
- URL du repo : https://github.com/ShakaTry/job_cost.git
- Branche actuelle : feature/setup-base-structure

## État actuel du projet

### Résumé de progression
- **Pages complétées** : 6 sur 8 pages prévues
- **Fonctionnalités MVP** : 62.5% complétées (12.5/20 fonctionnalités)
- **Prochaine étape** : Paramètres fiscaux
- **État** : Base solide, focus sur CDI uniquement pour le MVP

### Pages complétées
1. **Sélection de profil** - Écran principal avec liste des profils
   - Bouton création de profil de démonstration
   - Badge "Profil de démonstration" pour Sophie Martin
2. **Création de profil** - Dialog simple (nom/prénom uniquement)
3. **Vue détaillée du profil** - Affiche les sections disponibles
4. **Informations personnelles** - Formulaire complet avec :
   - Identité (nom, prénom, date de naissance, nationalité)
   - Coordonnées (adresse, téléphone, email)
   - Situation familiale (état civil, enfants à charge)
   - Validation des formulaires
   - Sauvegarde automatique avec pattern PopScope
   - Navigation clavier optimisée
5. **Situation professionnelle** - Formulaire restructuré avec Cards :
   - **Card 1 - Emploi actuel** :
     - Statut d'emploi (CDI seulement dans MVP)
     - Entreprise et poste
     - Case à cocher "Salarié non cadre"
   - **Card 2 - Temps de travail et rémunération** :
     - Temps de travail (curseur 10-100% + heures hebdomadaires manuelles côte à côte avec heures sup)
     - Heures supplémentaires (saisie simple, calcul automatique 25%/50%)
     - Salaire brut mensuel / Taux horaire (calcul bidirectionnel automatique)
     - Prime conventionnelle (slider 0-4 mois)
   - **Card 3 - Avantages sociaux** :
     - Date d'entrée dans l'entreprise (avec UX mobile optimisée)
     - Part salarié mutuelle (€/mois)
     - Titres-restaurant (valeur et nombre/mois)
   - Support des décimales avec format 2 chiffres (ex: 2500.00)
   - Formatage automatique à 2 décimales pour heures/semaine et heures sup
   - Calculs officiels selon durée légale 151,67h/mois
   - Sauvegarde automatique avec pattern PopScope
   - UX mobile : double-clic pour saisie manuelle de date avec formatage automatique
   - Note: Le régime fiscal a été déplacé vers "Paramètres fiscaux"
6. **Transport & Déplacements** - Formulaire complet avec :
   - Mode de transport principal (dropdown)
   - Pour véhicule personnel :
     - Type de véhicule (voiture/moto)
     - Puissance fiscale (slider 3-10 CV pour voiture)
     - Distance domicile-travail aller simple
     - Jours travaillés par semaine
     - Calcul automatique du barème kilométrique 2024
   - Pour transports en commun :
     - Coût mensuel
   - Frais additionnels :
     - Parking mensuel
     - Péages mensuels
   - Récapitulatif annuel avec total des frais
   - Sauvegarde automatique avec pattern PopScope

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
│   ├── personal_info_screen.dart
│   └── professional_situation_screen.dart
├── services/
│   └── profile_service.dart  # Service de gestion des profils (CRUD)
├── utils/
│   └── validators.dart     # Validation centralisée des formulaires
├── widgets/
│   ├── profile_avatar.dart # Avatar réutilisable
│   └── info_container.dart  # Container d'info bleu réutilisable
└── main.dart

docs/
├── calculations/
│   ├── salary_calculations.md     # Documentation officielle des calculs de salaire
│   └── overtime_calculations.md   # Documentation des calculs d'heures supplémentaires
└── development/
    └── auto_save_pattern.md       # Pattern de sauvegarde automatique
```

### Conventions de code
- Utilisation de widgets réutilisables pour éviter la duplication
- Constantes centralisées (pas de strings hardcodées)
- Validation centralisée avec la classe Validators
- Gestion d'erreurs avec try-catch sur les opérations async
- Vérification mounted avant setState dans les contextes async
- Formatage automatique du téléphone français
- textInputAction pour navigation clavier entre champs
- Pattern PopScope pour la sauvegarde automatique (voir docs/development/auto_save_pattern.md)
- Calculs de précision maximale en interne, arrondi seulement à l'affichage
- Listeners sur TextEditingController pour sauvegarde temps réel

### Préférences UX de l'utilisateur
- Pas de titres redondants
- Dialogs centrés au lieu de snackbars en bas
- Sauvegarde automatique (pas de bouton save)
- Gestion intelligente des erreurs (préserver les données valides)
- Navigation clavier entre les champs de formulaire (Tab/Entrée)
- Dropdown pour la nationalité (standardisation)
- Formatage automatique du téléphone pour éviter les erreurs
- UX mobile optimisée pour les dates (double-clic pour saisie manuelle)

### Stratégie de monétisation
Voir ROADMAP.md pour le détail complet des fonctionnalités Premium.
Focus actuel : MVP/Version gratuite uniquement.

### 🔄 STRATÉGIE ITÉRATIVE (17/12/2024)
Approche de développement adoptée :
- **Développer** chaque page avec soin
- **Réviser** les pages existantes après chaque ajout
- **Améliorer** continuellement la cohérence
- **Principe** : À chaque nouvelle page, on adapte et corrige l'existant

### Prochaines étapes (ordre précis)
1. **Créer "Paramètres fiscaux"** 🎯 **PROCHAINE ÉTAPE**
   - Régime fiscal, taux de prélèvement, parts fiscales
   - Puis réviser toutes les pages existantes
2. **Créer "Frais professionnels"**
   - Repas, garde d'enfants, télétravail, équipements
   - Puis nouvelle révision globale
3. **Créer l'écran de calcul**
   - Interface de saisie d'offre d'emploi
   - Moteur de calcul complet
   - Affichage des résultats
4. **Export et partage**
   - Export texte simple
   - Sauvegarde des calculs
5. **Tests finaux et polish**

### Notes importantes
- L'application est Android/iOS uniquement (pas de support desktop)
- Focus sur les salariés CDI uniquement pour le MVP
- CDD, Intérim et autres statuts réservés à la version Premium
- Développement itératif : réviser l'existant à chaque ajout
- Les 3 profils d'exemple sont temporaires pour le développement
- Toujours exécuter `flutter analyze` avant de commit/push
- Profil de démonstration "Sophie Martin" créé avec données complètes :
  - 4h d'heures sup
  - Statut non cadre
  - Prime 13ème mois
  - Transport : voiture 5CV, 25km/jour, parking 120€/mois
- Calculs de salaire basés sur 151,67h/mois (durée légale officielle)
- Précision maximale en interne, arrondi seulement pour l'affichage
- Le régime fiscal a été déplacé de "Situation professionnelle" vers "Paramètres fiscaux"
- Pattern de sauvegarde automatique avec PopScope obligatoire pour toutes les pages de formulaire
- Bug d'overflow sur mobile corrigé avec widgets Flexible dans les récapitulatifs
- **IMPORTANT** : Après chaque nouvelle page, réviser et adapter les pages existantes

### Commandes utiles
```bash
# Vérifier le code
flutter analyze

# Lancer sur émulateur Android
flutter run -d emulator-5554

# Nettoyer et récupérer les dépendances
flutter clean && flutter pub get
```

### Note importante pour Claude
- NE JAMAIS utiliser `flutter run` directement car cela créera toujours un timeout
- L'utilisateur lancera l'application lui-même et donnera son feedback
- Se contenter de vérifier le code avec `flutter analyze`

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