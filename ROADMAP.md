# 🎯 Job Cost - Roadmap

## 📱 Vue d'ensemble
Application Flutter pour calculer le salaire réel net en déduisant tous les frais liés à un emploi.

## 🚨 PRIORITÉ CRITIQUE : MVP Minimal Fonctionnel

### Phase 1 : Fonctionnalités Essentielles (2-3 semaines)
**Sans ces fonctionnalités, l'application n'a AUCUNE valeur**

#### 1. 🧮 Écran de calcul (PRIORITÉ ABSOLUE)
- [ ] Interface de saisie d'offre d'emploi
  - [ ] Salaire proposé (brut/net)
  - [ ] Localisation du poste
  - [ ] Avantages (tickets resto, mutuelle, etc.)
- [ ] Moteur de calcul complet
  - [ ] Calcul du net après charges sociales
  - [ ] Déduction des frais de transport
  - [ ] Déduction des frais professionnels
  - [ ] Calcul du "vrai net" final
- [ ] Affichage des résultats détaillés
  - [ ] Décomposition ligne par ligne
  - [ ] Comparaison avec situation actuelle
  - [ ] Gain/perte mensuel et annuel

#### 2. 📊 Paramètres fiscaux simplifiés
- [ ] Régime fiscal (prélèvement à la source)
- [ ] Taux de prélèvement personnalisé
- [ ] Nombre de parts fiscales
- [ ] Crédits d'impôt basiques

#### 3. 🍽️ Frais professionnels essentiels
- [ ] Repas (cantine d'entreprise vs tickets restaurant vs rien)
- [ ] Garde d'enfants (si enfants à charge détectés)
- [ ] Forfait télétravail de base

#### 4. 📤 Export basique
- [ ] Export texte simple des calculs
- [ ] Partage via apps natives (WhatsApp, email, etc.)

### Phase 2 : MVP Complet (1-2 semaines)

#### 5. 💼 Frais professionnels complets
- [ ] Équipements professionnels
- [ ] Formations obligatoires
- [ ] Vêtements de travail
- [ ] Frais de déménagement

#### 6. 💾 Persistance SQLite
- [ ] Migration depuis SharedPreferences
- [ ] Historique des calculs
- [ ] Sauvegarde des offres comparées

#### 7. 📈 Comparaison avancée
- [ ] Comparaison simultanée de 3 offres
- [ ] Graphiques de comparaison
- [ ] Simulation sur 12 mois

## 📊 État actuel du projet (Décembre 2024)

### ✅ Complété (57.5%)
1. **Pages terminées (5/8)**
   - ✅ Sélection de profil
   - ✅ Informations personnelles
   - ✅ Situation professionnelle
   - ✅ Transport & Déplacements
   - ✅ Vue détail du profil

2. **Fonctionnalités implémentées**
   - ✅ Profil de démonstration "Sophie Martin"
   - ✅ Sauvegarde automatique (pattern PopScope)
   - ✅ Calculs salaire brut/horaire bidirectionnels
   - ✅ Heures supplémentaires (25%/50%)
   - ✅ Barème kilométrique 2024
   - ✅ Validation et formatage des données

### 🚧 En cours / À faire (42.5%)
1. **Fonctionnalités critiques manquantes**
   - ❌ Écran de calcul (BLOQUANT)
   - ❌ Paramètres fiscaux
   - ❌ Frais professionnels
   - ❌ Export des résultats

2. **Améliorations techniques**
   - ❌ Persistance SQLite
   - ❌ Tests unitaires
   - ❌ State management avancé

## 💎 Fonctionnalités Premium (Post-MVP)

### Version Gratuite
- ✅ 3 profils maximum
- ✅ Saisie manuelle des données
- ✅ Calculs de base
- ✅ Export texte simple

### Version Premium (5€/mois ou 50€/an)
- [ ] Profils illimités
- [ ] Import automatique (LinkedIn, fiches de paie PDF)
- [ ] API Google Maps pour distances précises
- [ ] Prix carburant en temps réel
- [ ] Détection convention collective
- [ ] Export PDF professionnel
- [ ] Simulations sur 5 ans
- [ ] Notifications changements fiscaux

## 🔧 Recommandations techniques urgentes

### Court terme (pour le MVP)
1. **Créer le moteur de calcul**
   ```dart
   class SalaryCalculator {
     static CalculationResult calculate(UserProfile profile, JobOffer offer)
   }
   ```

2. **Refactorer le modèle transport**
   ```dart
   // Remplacer Map<String, dynamic>? par
   TransportData? transport;
   ```

3. **Ajouter des tests critiques**
   - Tests des calculs de salaire
   - Tests des majorations heures sup
   - Tests du barème kilométrique

## ⏱️ Timeline réaliste

### MVP Minimal (3 semaines)
- **Semaine 1** : Écran de calcul + moteur
- **Semaine 2** : Paramètres fiscaux + frais essentiels  
- **Semaine 3** : Export + tests + finalisation

### MVP Complet (+2 semaines)
- **Semaine 4** : Frais pro complets + SQLite
- **Semaine 5** : Comparaison + polish final

**Total : 5 semaines pour un MVP commercialisable**

## 🎯 Prochaines étapes immédiates

1. **ARRÊTER** le développement de nouvelles pages de saisie
2. **COMMENCER** l'écran de calcul immédiatement
3. **TESTER** avec des cas réels (Sophie Martin)
4. **VALIDER** les calculs avec des fiches de paie réelles

---

*Dernière mise à jour : 17 décembre 2024*
*Progression réelle : 57.5% (11.5/20 fonctionnalités MVP)*