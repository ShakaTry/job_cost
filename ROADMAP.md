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
   - 3 sections ExpansionTile : Identité, Coordonnées, Situation familiale
   - Situation familiale (pour calcul impôts)
   - Localisation (pour frais transport)
   - Interface cohérente et épurée
   
2. **Situation professionnelle** ✅
   - 3 sections ExpansionTile : Emploi actuel, Temps de travail et rémunération, Avantages sociaux
   - Salaire actuel (pour comparaison)
   - Adresse de l'entreprise
   - Heures supplémentaires
   - Prime conventionnelle
   - Avantages sociaux (ancienneté, mutuelle)
   - UX optimisée mobile (saisie de date manuelle)
   
3. **Transport & Déplacements** ✅
   - 3 sections ExpansionTile : Véhicule, Trajet, Frais additionnels
   - Véhicule personnel uniquement (MVP)
   - Type de véhicule et carburant
   - Distance et frais (parking, péages)
   - Remboursement transport employeur

4. **Frais professionnels** ✅
   - 4 sections ExpansionTile : Frais de repas, Garde d'enfants, Télétravail, Équipements
   - Titres-restaurant (déplacé depuis Situation professionnelle)
   - Frais de repas et indemnités employeur
   - Garde d'enfants (coût, aides, type)
   - Télétravail (jours, forfait, frais réels, équipement)
   - Vêtements, matériel, formation, cotisations syndicales
   - 17 nouveaux champs dans le modèle de données

### 🚧 Pages à compléter

#### 1. Paramètres fiscaux (PRIORITÉ 1 - DERNIÈRE PAGE DE COLLECTE)
- [ ] ExpansionTile cohérent avec les autres pages
- [ ] Régime fiscal (prélèvement à la source)
- [ ] Taux de prélèvement personnalisé
- [ ] Nombre de parts fiscales
- [ ] Crédits et réductions d'impôt basiques
- [ ] Barème kilométrique (déplacé depuis Transport)
- [ ] Mise à jour profil démonstration Sophie Martin

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

### Progression : 87.5% pages collecte - 80% fonctionnalités MVP

| Catégorie | Complété | Total | % |
|-----------|----------|-------|---|
| Pages données | 4 | 5 | 80% |
| Écran calcul | 0 | 1 | 0% |
| Fonctionnalités | 16 | 20 | 80% |

### ✅ Fonctionnalités implémentées
- **Interface utilisateur :**
  - ExpansionTile sur toutes les pages de formulaire (sections collapsibles)
  - Interface cohérente et épurée (lignes de séparation supprimées)
  - Sauvegarde automatique (pattern PopScope)
  - UX mobile optimisée (saisie de date manuelle)
  - Navigation clavier entre champs
- **Gestion des données :**
  - Profil de démonstration "Sophie Martin" complet (toutes les pages)
  - 17 nouveaux champs pour frais professionnels
  - Validation et formatage des données
  - Calculs salaire brut/horaire bidirectionnels
  - Heures supplémentaires (25%/50%)
- **Fonctionnalités métier :**
  - Informations personnelles complètes
  - Situation professionnelle (CDI uniquement)
  - Transport véhicule personnel
  - Frais professionnels complets (repas, garde enfants, télétravail, équipements)

### 🚧 Fonctionnalités manquantes critiques
- **Paramètres fiscaux** (BLOQUANT pour calculs) - dernière page de collecte
- **Écran de calcul complet** avec moteur utilisant toutes les données
- **Export des résultats** en format texte

## ⏱️ Timeline actualisée

### Semaine 1 : Finaliser collecte de données
- **2-3 jours** : Page Paramètres fiscaux (ExpansionTile + mise à jour Sophie Martin)
- **1 jour** : Tests et corrections finales sur toutes les pages

### Semaine 2-3 : Écran de calcul (PHASE MAJEURE)
- **2 jours** : Modèle JobOffer + UI saisie d'offre
- **3 jours** : Moteur de calcul complet (toutes les données collectées)
- **2 jours** : UI résultats avec comparaison

### Semaine 4 : Finalisation MVP
- **2 jours** : Export et partage
- **2 jours** : Tests intensifs et corrections
- **1 jour** : Polish final et préparation release

**Total réaliste : 4 semaines pour MVP fonctionnel**
**État actuel : 80% terminé, phase calcul à développer**

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