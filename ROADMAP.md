# 🎯 Job Cost - Roadmap

## 📱 Vue d'ensemble
Application Flutter pour calculer le salaire réel net en déduisant tous les frais liés à un emploi.

## 🚀 Stratégie de développement

### Approche itérative : Développer → Réviser → Améliorer
1. **Développer** chaque page avec soin
2. **Réviser** les pages existantes après chaque ajout
3. **Améliorer** continuellement pour maintenir la cohérence
4. **Adapter** l'ensemble à chaque nouvelle fonctionnalité

### Principe clé
À chaque nouvelle page ajoutée :
- Revoir et corriger les pages précédentes
- Adapter les modèles de données si nécessaire
- Assurer la cohérence globale
- Tester avec le profil de démonstration

## 📋 Phase 1 : Pages de données essentielles (1-2 semaines)

### ✅ Pages complétées
1. **Informations personnelles** ✅
   - Situation familiale (pour calcul impôts)
   - Localisation (pour frais transport)
   
2. **Situation professionnelle** ✅
   - Salaire actuel (pour comparaison)
   - Adresse de l'entreprise
   - Heures supplémentaires
   - Prime conventionnelle
   - Avantages sociaux (ancienneté, mutuelle, titres-restaurant)
   - UX optimisée mobile (saisie de date manuelle)
   
3. **Transport & Déplacements** ✅
   - Véhicule personnel uniquement (MVP)
   - Type de véhicule et carburant
   - Distance et frais (parking, péages)
   - Jours de télétravail par semaine
   - Remboursement transport employeur

### 🚧 Pages à compléter

#### 1. Paramètres fiscaux (PRIORITÉ 1)
- [ ] Régime fiscal (prélèvement à la source)
- [ ] Taux de prélèvement personnalisé
- [ ] Nombre de parts fiscales
- [ ] Crédits et réductions d'impôt basiques
- [ ] Barème kilométrique (déplacé depuis Transport)

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

### Progression : 62.5% (12.5/20 fonctionnalités MVP)

| Catégorie | Complété | Total | % |
|-----------|----------|-------|---|
| Pages données | 3 | 5 | 60% |
| Écran calcul | 0 | 1 | 0% |
| Fonctionnalités | 9.5 | 14 | 68% |

### ✅ Fonctionnalités implémentées
- Profil de démonstration "Sophie Martin"
- Sauvegarde automatique (pattern PopScope)
- Calculs salaire brut/horaire bidirectionnels
- Heures supplémentaires (25%/50%)
- Validation et formatage des données
- Navigation entre pages
- Avantages sociaux (ancienneté, mutuelle, titres-restaurant)
- UX mobile optimisée (saisie de date manuelle)
- Organisation visuelle avec Cards
- Adresse entreprise dans situation professionnelle
- Jours de télétravail et remboursement transport

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
- ✅ Calculs complets pour CDI uniquement
- ✅ Export texte

### Version Premium (5€/mois)
- Profils illimités
- **Statuts professionnels avancés** :
  - Salarié(e) CDD (prime précarité 10%)
  - Intérimaire (IFM + ICCP)
  - Auto-entrepreneur (cotisations spécifiques)
  - Indépendant/Freelance
- Import automatique (LinkedIn, PDF)
- API distances précises
- Prix carburant temps réel
- Export PDF professionnel
- Simulations 5 ans
- Comparaison multi-statuts
- **Frais véhicule avancés** :
  - Assurance véhicule (coût mensuel)
  - Entretien annuel (révisions, pneus, réparations)
  - Amortissement du véhicule
  - Contrôle technique

## 🤖 Fonctionnalités IA (Futur lointain - Version Premium+)

### Scan intelligent de fiche de paie
- **Capture optimisée avec Flutter** :
  - Détection automatique des bords du document (packages: `document_scanner_flutter`, `edge_detection`)
  - Correction automatique de perspective
  - Amélioration contraste/luminosité spécifique aux fiches de paie
  - Interface de recadrage manuel style "Genius Scan"
  - Prévisualisation avant validation

- **OCR + IA pour extraction de données** :
  - **Google Cloud Vision API** : OCR haute précision (~1,50$/1000 pages, 1000 gratuites/mois)
  - **Google Gemini Pro** : Analyse intelligente du texte avec prompt personnalisé (~0,50$/1M tokens)
  - Extraction automatique des données françaises : nom, salaire brut, heures sup, cotisations, net à payer
  - Remplissage automatique du profil utilisateur
  - Validation et correction manuelle possible

- **Coûts estimés par utilisateur** :
  - Usage normal (2-3 fiches/mois) : ~0,01€/mois
  - Usage intensif (10 fiches/mois) : ~0,05€/mois
  - Tarification suggérée : 10-20 scans inclus, puis 0,10-0,20€/scan supplémentaire

- **Optimisations techniques** :
  - Cache des résultats pour éviter re-scan identiques
  - Preprocessing intelligent côté Flutter
  - Détection zones importantes (en-tête, montants, cotisations)
  - Format JSON structuré pour intégration directe

## 🎯 Prochaines étapes immédiates (approche itérative)

### 1. Révision des pages existantes
- **Revenir sur "Situation professionnelle"**
  - Améliorer/corriger selon les besoins
  - Adapter aux nouvelles exigences
  
- **Finaliser "Transport & Déplacements"**
  - Corriger les éventuels bugs
  - Optimiser l'expérience utilisateur

### 2. Développement des nouvelles pages
- **Page "Paramètres fiscaux"**
  - Développer la page
  - Réviser les pages existantes
  - Adapter le modèle de données

- **Page "Frais professionnels"**
  - Développer avec les frais essentiels
  - Réviser toutes les pages
  - Assurer la cohérence

### 2.1 Améliorations futures
- **Option globale pour les InfoContainers**
  - Ajouter un paramètre dans les préférences utilisateur
  - Permettre d'activer/désactiver tous les "i" informatifs
  - Appliquer le paramètre à toutes les pages de l'application

### 3. Écran de calcul
- **Développer avec toutes les données disponibles**
- **Réviser l'ensemble de l'application**
- **Tester intensivement avec Sophie Martin**

---

*Dernière mise à jour : 19 décembre 2024*
*Note : Stratégie révisée pour collecter d'abord toutes les données nécessaires*