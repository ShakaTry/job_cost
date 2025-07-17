# 🎯 Job Cost - Roadmap

## 📱 Vue d'ensemble
Application Flutter pour calculer le salaire réel net en déduisant tous les frais liés à un emploi.

## 🚀 Stratégie de développement

### Approche logique : Données → Calculs → Résultats
1. **Collecter** toutes les données nécessaires (pages de saisie)
2. **Calculer** le salaire net réel (moteur de calcul)
3. **Présenter** les résultats détaillés (écran de calcul)

## 📋 Phase 1 : Pages de données essentielles (1-2 semaines)

### ✅ Pages complétées
1. **Informations personnelles** ✅
   - Situation familiale (pour calcul impôts)
   - Localisation (pour frais transport)
   
2. **Situation professionnelle** ✅
   - Salaire actuel (pour comparaison)
   - Heures supplémentaires
   - Prime conventionnelle
   
3. **Transport & Déplacements** ✅
   - Mode de transport
   - Distance et frais
   - Barème kilométrique 2024

### 🚧 Pages à compléter

#### 1. Paramètres fiscaux (PRIORITÉ 1)
- [ ] Régime fiscal (prélèvement à la source)
- [ ] Taux de prélèvement personnalisé
- [ ] Nombre de parts fiscales
- [ ] Crédits et réductions d'impôt basiques

#### 2. Frais professionnels essentiels (PRIORITÉ 2)
- [ ] Repas (cantine, tickets restaurant, panier)
- [ ] Garde d'enfants (assistant maternel, crèche)
- [ ] Télétravail (forfait)
- [ ] Équipements obligatoires

## 📊 Phase 2 : Moteur de calcul et interface (1-2 semaines)

### 3. Écran de calcul (PRIORITÉ 3)
- [ ] Interface de saisie d'offre d'emploi
  - [ ] Salaire brut proposé
  - [ ] Localisation du poste
  - [ ] Avantages (tickets resto, mutuelle, etc.)
- [ ] Moteur de calcul complet
  - [ ] Calcul charges sociales → net
  - [ ] Calcul impôts avec données fiscales
  - [ ] Déduction frais transport (données existantes)
  - [ ] Déduction frais professionnels
- [ ] Affichage des résultats
  - [ ] Salaire net après charges
  - [ ] Net après impôts
  - [ ] Net après frais = SALAIRE RÉEL
  - [ ] Comparaison avec situation actuelle

### 4. Export et partage (PRIORITÉ 4)
- [ ] Export texte simple
- [ ] Partage via apps natives
- [ ] Sauvegarde des calculs

## 🎯 Phase 3 : MVP Complet (1 semaine)

### 5. Améliorations essentielles
- [ ] Comparaison multi-offres (3 max)
- [ ] Graphiques simples
- [ ] Historique des calculs

### 6. Persistance SQLite
- [ ] Migration depuis SharedPreferences
- [ ] Optimisation des performances

## 📊 État actuel du projet (Décembre 2024)

### Progression : 57.5% (11.5/20 fonctionnalités MVP)

| Catégorie | Complété | Total | % |
|-----------|----------|-------|---|
| Pages données | 3 | 5 | 60% |
| Écran calcul | 0 | 1 | 0% |
| Fonctionnalités | 8.5 | 14 | 61% |

### ✅ Fonctionnalités implémentées
- Profil de démonstration "Sophie Martin"
- Sauvegarde automatique (pattern PopScope)
- Calculs salaire brut/horaire bidirectionnels
- Heures supplémentaires (25%/50%)
- Barème kilométrique 2024
- Validation et formatage des données
- Navigation entre pages

### 🚧 Fonctionnalités manquantes critiques
- Paramètres fiscaux (BLOQUANT pour calculs)
- Frais professionnels essentiels
- Écran de calcul
- Export des résultats

## ⏱️ Timeline actualisée

### Semaine 1-2 : Finaliser les données
- **2-3 jours** : Page Paramètres fiscaux
- **2-3 jours** : Page Frais professionnels essentiels
- **1 jour** : Tests avec profil Sophie Martin

### Semaine 3 : Écran de calcul
- **2 jours** : Modèle JobOffer + UI saisie
- **2 jours** : Moteur de calcul
- **1 jour** : UI résultats

### Semaine 4 : Finalisation MVP
- **2 jours** : Export et partage
- **2 jours** : Tests et corrections
- **1 jour** : Polish final

**Total réaliste : 4 semaines pour MVP fonctionnel**

## 💎 Fonctionnalités Premium (Post-MVP)

### Version Gratuite
- ✅ 3 profils maximum
- ✅ Saisie manuelle
- ✅ Calculs complets
- ✅ Export texte

### Version Premium (5€/mois)
- Profils illimités
- Import automatique (LinkedIn, PDF)
- API distances précises
- Prix carburant temps réel
- Export PDF professionnel
- Simulations 5 ans

## 🎯 Prochaines étapes immédiates

1. **Créer la page "Paramètres fiscaux"** 
   - Simple et focalisée sur l'essentiel
   - Taux personnalisé + parts fiscales

2. **Créer la page "Frais professionnels"**
   - Seulement les frais majeurs (repas, garde)
   - Autres frais en phase 2

3. **Développer l'écran de calcul**
   - Utiliser toutes les données collectées
   - Calculs précis et transparents

4. **Tester avec Sophie Martin**
   - Valider tous les calculs
   - Comparer avec fiche de paie réelle

---

*Dernière mise à jour : 17 décembre 2024*
*Note : Stratégie révisée pour collecter d'abord toutes les données nécessaires*