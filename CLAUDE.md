Il # Job Cost - Documentation Claude

## Projet
Application Android/iOS développée avec Flutter pour estimer le salaire réel net en déduisant tous les frais annexes pour un emploi ou recherche d'emploi.

## Gestion Git
- Claude gère entièrement Git pour ce projet
- Stratégie Git Flow : main, develop, feature/*, bugfix/*, hotfix/*
- Commits réguliers avec messages descriptifs
- URL du repo : https://github.com/ShakaTry/job_cost.git
- Branche actuelle : feature/fiscal-and-expenses-pages

## État actuel du projet

### Résumé de progression
- **Pages complétées** : 7 sur 8 pages prévues (87.5%)
- **Fonctionnalités MVP** : 75% complétées (15/20 fonctionnalités)
- **Prochaine étape** : Paramètres fiscaux (dernière page de collecte de données)
- **État** : Toutes les pages de saisie transformées en ExpansionTile, interface cohérente

### Pages complétées
1. **Sélection de profil** - Écran principal avec liste des profils
   - Bouton création de profil de démonstration
   - Badge "Profil de démonstration" pour Sophie Martin
2. **Création de profil** - Dialog simple (nom/prénom uniquement)
3. **Vue détaillée du profil** - Affiche les sections disponibles
   - Avatar avec bouton d'édition préparé pour future implémentation
   - Sous-titre "Vue d'ensemble du profil" dans l'AppBar
4. **Informations personnelles** - Formulaire restructuré avec Cards :
   - **Card 1 - Identité** : nom, prénom, date de naissance (avec UX mobile double-clic), nationalité
   - **Card 2 - Coordonnées** : adresse, téléphone, email
   - **Card 3 - Situation familiale** : état civil, enfants à charge
   - Interface épurée : avatar seulement dans l'AppBar, pas de texte d'âge
   - InfoContainer supprimé (future option globale prévue)
   - Validation des formulaires
   - Sauvegarde automatique avec pattern PopScope
   - Navigation clavier optimisée
5. **Situation professionnelle** - Formulaire restructuré avec Cards :
   - **Card 1 - Emploi actuel** :
     - Statut d'emploi (CDI seulement dans MVP)
     - Entreprise et poste
     - Adresse de l'entreprise
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
6. **Transport & Déplacements** - Formulaire avec ExpansionTile :
   - **Section 1 - Véhicule** :
     - Type de véhicule (voiture/moto)
     - Carburant (essence, diesel, hybride, électrique, GPL)
     - Puissance fiscale (slider 3-10 CV pour voiture)
   - **Section 2 - Trajet** :
     - Distance domicile-travail aller simple
   - **Section 3 - Frais additionnels** :
     - Parking mensuel
     - Péages mensuels
     - Remboursement transport employeur
   - Sections collapsibles fermées par défaut
   - Sauvegarde automatique avec pattern PopScope
   - Note: Télétravail déplacé vers "Frais professionnels"
7. **Frais professionnels** - Formulaire avec ExpansionTile :
   - **Section 1 - Frais de repas** :
     - Titres-restaurant (valeur et nombre/mois) - déplacé depuis Situation pro
     - Frais de repas mensuels hors titres
     - Indemnité repas employeur
   - **Section 2 - Garde d'enfants** (si enfants > 0) :
     - Type de garde (assistant maternel, crèche, etc.)
     - Coût mensuel et aides reçues
   - **Section 3 - Télétravail** :
     - Jours travaillés et télétravail par semaine - déplacé depuis Transport
     - Forfait télétravail employeur
     - Frais réels estimés (internet, électricité)
     - Équipement (amortissement bureau/chaise)
   - **Section 4 - Équipements et autres frais** :
     - Vêtements de travail
     - Matériel professionnel
     - Formation non remboursée
     - Cotisations syndicales
   - Sections collapsibles fermées par défaut
   - 17 nouveaux champs dans le modèle UserProfile
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
│   ├── professional_situation_screen.dart
│   ├── transport_screen.dart
│   └── professional_expenses_screen.dart
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
- Interface cohérente avec ExpansionTile dans toutes les pages de formulaire
- Sections collapsibles fermées par défaut pour une navigation claire
- Suppression des lignes de séparation des ExpansionTile (shape: Border())

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
1. **Créer "Paramètres fiscaux"** 🎯 **PROCHAINE ÉTAPE - DERNIÈRE PAGE DE COLLECTE**
   - Régime fiscal, taux de prélèvement, parts fiscales, barème kilométrique
   - Transformer en ExpansionTile comme les autres pages
   - Mettre à jour le profil de démonstration Sophie Martin
2. **Créer l'écran de calcul** 🎯 **PHASE MAJEURE**
   - Interface de saisie d'offre d'emploi
   - Moteur de calcul complet utilisant toutes les données collectées
   - Affichage des résultats avec comparaison
3. **Export et finalisation MVP**
   - Export texte simple
   - Tests finaux et polish

### Notes importantes
- L'application est Android/iOS uniquement (pas de support desktop)
- Focus sur les salariés CDI uniquement pour le MVP
- CDD, Intérim et autres statuts réservés à la version Premium
- Développement itératif : réviser l'existant à chaque ajout
- Les 3 profils d'exemple sont temporaires pour le développement
- Toujours exécuter `flutter analyze` avant de commit/push
- Profil de démonstration "Sophie Martin" créé avec données complètes :
  - 4h d'heures sup, statut non cadre, prime 13ème mois
  - Adresse entreprise : 50 avenue des Champs-Élysées, 75008 Paris
  - Transport : voiture essence 5CV, 25km/jour
  - Frais transport : parking 120€/mois, péages 45€/mois, remboursement employeur 50€/mois
  - Frais professionnels : titres-restaurant 9,50€×19, repas 120€/mois, indemnité repas 80€/mois
  - Garde d'enfants : 850€/mois (2 enfants), aides CAF 294€/mois
  - Télétravail : 2j/semaine, forfait 50€/mois, frais réels 45€/mois, équipement 20€/mois
  - Autres : vêtements pro 30€/mois, équipement 15€/mois, formation 50€/mois, syndicat 18€/mois
- Calculs de salaire basés sur 151,67h/mois (durée légale officielle)
- Précision maximale en interne, arrondi seulement pour l'affichage
- Le régime fiscal a été déplacé de "Situation professionnelle" vers "Paramètres fiscaux"
- Le barème kilométrique a été déplacé de "Transport" vers "Paramètres fiscaux" (à implémenter)
- Pattern de sauvegarde automatique avec PopScope obligatoire pour toutes les pages de formulaire
- Bug d'overflow sur mobile corrigé avec widgets Flexible dans les récapitulatifs
- Toutes les pages transformées en ExpansionTile collapsibles (Informations personnelles, 
  Situation professionnelle, Transport, Frais professionnels)
- Sections fermées par défaut pour une navigation claire
- Lignes de séparation supprimées (shape: Border()) pour un rendu propre
- UX mobile : double-clic sur les champs de date pour saisie manuelle
- Future option globale pour activer/désactiver tous les InfoContainers prévue
- **IMPORTANT** : Interface cohérente maintenue sur toutes les pages de formulaire

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