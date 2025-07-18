# Stratégie de Tests - Job Cost

## Vue d'ensemble

Ce document liste tous les tests à implémenter pour couvrir l'application Job Cost.
Les tests sont organisés par phases de priorité, du plus critique au moins critique.

## 📊 État actuel

- **Tests existants** : 0 (seulement compilation Flutter)
- **Couverture cible** : 80% minimum
- **Approche** : Tests unitaires et widgets tests

## 🎯 Phase 1 : Composants Réutilisables (Priorité HAUTE)

Ces composants sont utilisés partout dans l'app et doivent être testés en premier.

### Widgets
- [ ] `/gittest ProfileAvatar` - Widget d'avatar utilisateur
- [ ] `/gittest InfoContainer` - Container d'information bleu

### Utilitaires  
- [ ] `/gittest Validators` - Validateurs de formulaires (email, téléphone, etc.)
- [ ] `/gittest "format functions"` - Fonctions de formatage (téléphone, montants)

## 🎯 Phase 2 : Services et Logique Métier (Priorité HAUTE)

### Services
- [ ] `/gittest ProfileService` - Service CRUD des profils
- [ ] `/gittest "UserProfile model"` - Modèle de données et sérialisation

### Calculs (Future)
- [ ] `/gittest SalaryCalculator` - Moteur de calcul de salaire (quand implémenté)
- [ ] `/gittest TaxCalculator` - Calculs fiscaux (quand implémenté)

## 🎯 Phase 3 : Écrans Principaux (Priorité MOYENNE)

### Écrans de navigation
- [ ] `/gittest ProfileSelectionScreen` - Écran de sélection de profil
- [ ] `/gittest ProfileDetailScreen` - Vue détaillée du profil

### Écrans de formulaire
- [ ] `/gittest PersonalInfoScreen` - Informations personnelles
- [ ] `/gittest ProfessionalSituationScreen` - Situation professionnelle  
- [ ] `/gittest TransportScreen` - Transport & déplacements
- [ ] `/gittest ProfessionalExpensesScreen` - Frais professionnels

## 🎯 Phase 4 : Fonctionnalités Spécifiques (Priorité BASSE)

### Interactions complexes
- [ ] `/gittest "date picker interactions"` - Sélecteurs de date
- [ ] `/gittest "slider interactions"` - Sliders (temps de travail, CV, etc.)
- [ ] `/gittest "expansion tile states"` - États des sections collapsibles

### Dialogs
- [ ] `/gittest "create profile dialog"` - Dialog de création de profil
- [ ] `/gittest "error dialogs"` - Gestion des erreurs

## 🎯 Phase 5 : Tests d'Intégration (Priorité BASSE)

### Workflows complets
- [ ] `/gittest "profile creation flow"` - Flux complet de création
- [ ] `/gittest "profile editing flow"` - Flux de modification
- [ ] `/gittest "form validation flow"` - Validation multi-écrans

## 📈 Métriques de progression

### Par type de composant
- **Widgets** : 0/2 testés
- **Services** : 0/2 testés  
- **Écrans** : 0/6 testés
- **Utilitaires** : 0/2 testés

### Estimation temps
- Phase 1 : 2-3 heures
- Phase 2 : 2-3 heures
- Phase 3 : 4-6 heures
- Phase 4 : 2-3 heures
- Phase 5 : 3-4 heures

**Total estimé** : 13-19 heures de génération/correction de tests

## 🚀 Comment utiliser ce document

1. **Commencez par la Phase 1** - Les composants les plus critiques
2. **Exécutez chaque commande** `/gittest` listée
3. **Laissez le système** générer, tester et corriger
4. **Cochez les cases** au fur et à mesure
5. **Passez à la phase suivante** une fois la précédente complète

## 💡 Conseils

- Faites une phase complète avant de passer à la suivante
- Committez après chaque groupe de tests réussis
- Surveillez la couverture de code avec `flutter test --coverage`
- Les tests générés incluront toujours :
  - Cas nominaux
  - Cas limites
  - Gestion d'erreurs
  - États null/vides

## 📝 Notes

- Ce document sera mis à jour au fur et à mesure de l'avancement
- Les commandes `/gittest` peuvent être exécutées dans n'importe quel ordre au sein d'une phase
- Certains tests de phases ultérieures dépendent de l'implémentation de fonctionnalités (calculs, etc.)