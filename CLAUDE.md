# Job Cost - Guide de développement

## Stratégie de branches Git

### Branches principales
- **`main`** : Branche de production (protégée). Contient uniquement le code stable et testé.
- **`develop`** : Branche de développement principal. Toutes les features sont intégrées ici.

### Branches de travail
- **`feature/*`** : Pour les nouvelles fonctionnalités
  - Créée depuis : `develop`
  - Merge vers : `develop`
  - Exemple : `feature/add-job-form`, `feature/cost-calculator`
  
- **`bugfix/*`** : Pour les corrections de bugs non critiques
  - Créée depuis : `develop`
  - Merge vers : `develop`
  - Exemple : `bugfix/fix-calculation-error`, `bugfix/ui-alignment`
  
- **`hotfix/*`** : Pour les corrections urgentes en production
  - Créée depuis : `main`
  - Merge vers : `main` ET `develop`
  - Exemple : `hotfix/critical-crash-fix`
  
- **`release/*`** : Pour préparer une nouvelle version
  - Créée depuis : `develop`
  - Merge vers : `main` ET `develop`
  - Exemple : `release/1.0.0`, `release/1.1.0`

### Workflow
1. Toujours créer une nouvelle branche depuis `develop` (sauf hotfix)
2. Faire des commits atomiques avec des messages clairs
3. Tester localement avant de pousser
4. Créer une Pull Request vers `develop`
5. Code review avant merge
6. Supprimer la branche après merge

### Commandes utiles
```bash
# Créer une nouvelle feature
git checkout develop
git pull origin develop
git checkout -b feature/nom-de-la-feature

# Pousser la branche
git push -u origin feature/nom-de-la-feature

# Après merge, nettoyer
git branch -d feature/nom-de-la-feature
git push origin --delete feature/nom-de-la-feature
```

## Conventions de code

### Structure des fichiers
- Un widget par fichier
- Noms de fichiers en snake_case
- Noms de classes en PascalCase
- Constantes en UPPER_SNAKE_CASE

### Organisation des imports
1. Imports Dart (dart:*)
2. Imports Flutter (flutter/*)
3. Imports de packages externes
4. Imports relatifs du projet

### Tests
- Toujours exécuter `flutter analyze` avant de commit
- Exécuter `flutter test` pour vérifier les tests
- Maintenir une couverture de test > 80%

## Commandes de développement

```bash
# Analyser le code
flutter analyze

# Exécuter les tests
flutter test

# Formater le code
dart format .

# Nettoyer le projet
flutter clean

# Générer les fichiers
flutter pub get
```