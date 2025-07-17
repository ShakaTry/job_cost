# Job Cost 📱

Une application mobile Flutter pour calculer le **salaire réel net** en déduisant tous les frais annexes liés à un emploi ou une recherche d'emploi.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)

## 📋 Table des matières

- [À propos](#à-propos)
- [Fonctionnalités](#fonctionnalités)
- [Captures d'écran](#captures-décran)
- [Installation](#installation)
- [Architecture](#architecture)
- [Développement](#développement)
- [Roadmap](#roadmap)
- [Contribution](#contribution)
- [License](#license)

## 🎯 À propos

Job Cost est une application mobile développée avec Flutter qui permet d'estimer précisément le **coût réel d'un emploi** en prenant en compte tous les frais annexes souvent négligés :

- **Transport et déplacements** (carburant, péages, parking)
- **Frais professionnels** (repas, garde d'enfants, télétravail, équipements)
- **Paramètres fiscaux** (régime fiscal, taux de prélèvement)
- **Charges sociales** et avantages sociaux

L'objectif est de fournir une **vision réaliste** du salaire net après déduction de tous ces coûts, permettant une meilleure prise de décision lors d'une recherche d'emploi ou d'une négociation salariale.

## ✨ Fonctionnalités

### 🏗️ Fonctionnalités Implémentées (MVP)

#### **Gestion des Profils**
- Création et sélection de profils utilisateur
- Profil de démonstration (Sophie Martin) avec données complètes
- Sauvegarde automatique des données

#### **Collecte de Données Complète (7/8 pages)**
1. **Informations Personnelles**
   - Identité, coordonnées, situation familiale
   - Validation des formulaires et formatage automatique

2. **Situation Professionnelle**
   - Statut d'emploi (CDI focus MVP)
   - Temps de travail et rémunération
   - Calculs automatiques salaire ↔ taux horaire
   - Heures supplémentaires (25%/50%)
   - Avantages sociaux (mutuelle, titres-restaurant)

3. **Transport & Déplacements**
   - Type de véhicule et carburant
   - Distance domicile-travail
   - Frais de parking et péages
   - Remboursements employeur

4. **Frais Professionnels**
   - Frais de repas et titres-restaurant
   - Garde d'enfants (si applicable)
   - Télétravail (jours/semaine, forfaits, équipements)
   - Autres frais (vêtements, matériel, formation, syndicats)

5. **Paramètres Fiscaux** *(en cours de développement)*
   - Régime fiscal et taux de prélèvement
   - Parts fiscales et barème kilométrique

#### **Interface Utilisateur**
- Design Material Design moderne
- Navigation intuitive avec ExpansionTile
- Sections collapsibles pour une meilleure UX
- Sauvegarde automatique optimisée (pattern PopScope)
- Support complet mobile Android/iOS

### 🔮 Fonctionnalités Prévues

#### **Phase Majeure : Écran de Calcul**
- Interface de saisie d'offre d'emploi
- Moteur de calcul complet utilisant toutes les données
- Comparaison salaire brut vs net réel
- Visualisations graphiques

#### **Finalisation MVP**
- Export des résultats (texte, PDF)
- Optimisations et polish final

### 🎁 Version Premium (Roadmap Long Terme)
- Support CDD, Intérim, Freelance
- Fonctionnalités IA (scan fiche de paie)
- Comparaisons multi-offres
- Synchronisation cloud

## 📱 Captures d'écran

*Screenshots à venir après finalisation de l'interface*

## 🚀 Installation

### Prérequis

- **Flutter SDK** 3.0+ 
- **Dart SDK** 3.0+
- **Android Studio** ou **VS Code** avec extensions Flutter
- **Git** pour le contrôle de version

### Setup du projet

1. **Cloner le repository**
   ```bash
   git clone https://github.com/ShakaTry/job_cost.git
   cd job_cost
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Vérifier l'installation**
   ```bash
   flutter doctor
   flutter analyze
   ```

4. **Lancer l'application**
   ```bash
   # Android
   flutter run -d android
   
   # iOS (macOS uniquement)
   flutter run -d ios
   ```

### Commandes utiles

```bash
# Analyse du code (obligatoire avant commit)
flutter analyze

# Tests
flutter test

# Build release
flutter build apk
flutter build ios
```

## 🏗️ Architecture

### Structure du projet

```
lib/
├── constants/
│   ├── app_constants.dart      # Constantes de l'application
│   └── app_strings.dart        # Chaînes de caractères centralisées
├── models/
│   └── user_profile.dart       # Modèle de données principal
├── screens/
│   ├── profile_selection_screen.dart     # Sélection de profil
│   ├── profile_detail_screen.dart        # Vue détaillée du profil
│   ├── personal_info_screen.dart         # Informations personnelles
│   ├── professional_situation_screen.dart # Situation professionnelle
│   ├── transport_screen.dart             # Transport & déplacements
│   └── professional_expenses_screen.dart # Frais professionnels
├── services/
│   └── profile_service.dart     # Service CRUD pour les profils
├── utils/
│   └── validators.dart          # Validation centralisée
├── widgets/
│   ├── profile_avatar.dart      # Avatar réutilisable
│   └── info_container.dart      # Container d'info réutilisable
└── main.dart                    # Point d'entrée de l'app

docs/
├── calculations/
│   ├── salary_calculations.md     # Documentation des calculs officiels
│   └── overtime_calculations.md   # Calculs heures supplémentaires
└── development/
    └── auto_save_pattern.md       # Pattern de sauvegarde optimisé
```

### Patterns & Technologies

- **State Management** : StatefulWidget avec services dédiés
- **Persistance** : SharedPreferences pour données locales
- **Navigation** : Navigator 2.0 avec retour de données
- **Sauvegarde** : Pattern PopScope optimisé (performance)
- **Validation** : Validators centralisés avec gestion d'erreurs
- **UI/UX** : Material Design, ExpansionTile, navigation clavier

### Calculs Métier

- **Salaire officiel** : 151,67h/mois (durée légale)
- **Heures supplémentaires** : 25% (8 premières) / 50% (suivantes)
- **Précision maximale** : Calculs internes sans arrondi
- **Barème kilométrique** : Fiscal officiel selon puissance véhicule

## 👨‍💻 Développement

### Standards de Code

- **Architecture** : Clean Architecture avec séparation des responsabilités
- **Conventions** : Variables et méthodes en camelCase, classes en PascalCase
- **Documentation** : Code autodocumenté + docs techniques
- **Qualité** : Validation obligatoire avec `flutter analyze`

### Workflow Git

- **Stratégie** : Git Flow (main, develop, feature/*, bugfix/*, hotfix/*)
- **Branches** : 
  - `main` : Production (protégée)
  - `develop` : Développement principal
  - `feature/*` : Nouvelles fonctionnalités
- **Commits** : Messages descriptifs avec co-authoring Claude

### Pattern de Sauvegarde

Le projet utilise un **pattern de sauvegarde optimisé** :

```dart
// Sauvegarde unique à la sortie (PopScope)
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
  child: Scaffold(/* ... */)
);
```

**Avantages** : Performance optimale, UX fluide, robustesse

### Contribuer

1. **Fork** le repository
2. **Créer** une branche feature (`git checkout -b feature/amazing-feature`)
3. **Commit** vos changements (`git commit -m 'Add amazing feature'`)
4. **Push** vers la branche (`git push origin feature/amazing-feature`)
5. **Ouvrir** une Pull Request

**Important** : Toujours exécuter `flutter analyze` avant de commit.

## 🗺️ Roadmap

### MVP - Version Gratuite (En cours - 87.5% complété)

- [x] **Gestion de profils** (Sélection, création, démonstration)
- [x] **7 pages de collecte** (Infos perso, pro, transport, frais)
- [ ] **Paramètres fiscaux** (Dernière page - En développement)
- [ ] **Écran de calcul** (Phase majeure suivante)
- [ ] **Export simple** (Texte, résultats de base)

### Version Premium (Long terme)

- [ ] **Statuts étendus** (CDD, Intérim, Freelance, Fonction publique)
- [ ] **IA & Automatisation** (Scan fiche de paie, saisie automatique)
- [ ] **Fonctionnalités avancées** (Multi-comparaisons, historique, cloud)
- [ ] **Monétisation** (Abonnement, fonctionnalités premium)

**Stratégie** : Focus MVP solide avant extension Premium

## 📄 License

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

**Développé avec ❤️ et Flutter**

*Application en développement actif - Contributions bienvenues !*