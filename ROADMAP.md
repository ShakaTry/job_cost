# Job Cost - Roadmap des fonctionnalités

## 📱 Pages et sections à développer

### ✅ Pages complétées
- [x] Sélection de profil
- [x] Création de profil (dialogue)
- [x] Vue détaillée du profil
- [x] Informations personnelles (complète)
  - [x] Nom/Prénom avec validation
  - [x] Adresse complète
  - [x] Téléphone avec formatage automatique
  - [x] Email avec validation
  - [x] Date de naissance avec calcul d'âge
  - [x] Nationalité (dropdown)
  - [x] Situation familiale (état civil, enfants)
  - [x] Navigation clavier entre champs
  - [x] Sauvegarde automatique

**Améliorations futures (optionnel) :**
- [ ] Upload photo de profil fonctionnel
- [ ] Extraction automatique du département depuis le code postal
- [ ] Intégration avec l'appareil photo pour la photo de profil
- [ ] Numéro de sécurité sociale (optionnel pour calculs précis)

### 📋 Pages à créer

#### 1. 💼 Situation professionnelle actuelle
**Champs à inclure :**
- [ ] Statut professionnel (CDI, CDD, Intérim, Chômage, Étudiant, Indépendant)
- [ ] Nom de l'employeur actuel
- [ ] Poste/Fonction occupée
- [ ] Date d'embauche (calcul ancienneté)
- [ ] Salaire brut mensuel actuel
- [ ] Convention collective
- [ ] Temps de travail (temps plein, temps partiel %)
- [ ] Nombre de jours de présence par semaine (présentiel/télétravail)
- [ ] Avantages actuels (mutuelle, tickets resto, etc.)

#### 2. 🚗 Transport & Déplacements
**Champs à inclure :**
- [ ] Permis de conduire (types détenus)
- [ ] Mode de transport principal (voiture, transport en commun, vélo, marche)
- [ ] Distance domicile-travail (km)
- [ ] Temps de trajet moyen (aller simple)
- [ ] Si voiture :
  - [ ] Type de véhicule
  - [ ] Carburant (essence, diesel, électrique, hybride)
  - [ ] Consommation moyenne
  - [ ] Frais de stationnement
- [ ] Si transport en commun :
  - [ ] Type d'abonnement
  - [ ] Coût mensuel
  - [ ] Participation employeur

#### 3. 💰 Frais professionnels
**Champs à inclure :**
- [ ] Repas :
  - [ ] Cantine entreprise (oui/non, prix)
  - [ ] Tickets restaurant (valeur, participation)
  - [ ] Frais de repas moyens
- [ ] Télétravail :
  - [ ] Nombre de jours par semaine
  - [ ] Indemnité télétravail
  - [ ] Frais internet/électricité
- [ ] Équipements :
  - [ ] Téléphone professionnel
  - [ ] Ordinateur
  - [ ] Vêtements de travail obligatoires
- [ ] Garde d'enfants :
  - [ ] Mode de garde
  - [ ] Coût mensuel
  - [ ] Aides employeur
- [ ] Formation :
  - [ ] Formations suivies
  - [ ] Coûts non pris en charge

#### 4. 🏦 Paramètres fiscaux
**Champs à inclure :**
- [ ] Taux marginal d'imposition
- [ ] Nombre de parts fiscales
- [ ] Régime (réel ou forfaitaire)
- [ ] Statut handicap/RQTH (abattements)
- [ ] Crédits et réductions d'impôt :
  - [ ] Emploi à domicile
  - [ ] Dons aux associations
  - [ ] Frais de garde
- [ ] Déductions :
  - [ ] Intérêts prêt immobilier
  - [ ] Pension alimentaire
  - [ ] Épargne retraite
- [ ] Numéro fiscal
- [ ] Centre des impôts de rattachement
- [ ] Revenus du conjoint (si déclaration commune)
- [ ] Autres personnes à charge (parents, etc.)

### 🎯 Fonctionnalités principales

#### Écran de calcul
- [ ] Saisie d'une offre d'emploi
- [ ] Calcul du salaire net après toutes charges
- [ ] Comparaison avec situation actuelle
- [ ] Export des résultats (basique)

#### Gestion des données
- [ ] Sauvegarde locale (SQLite)
- [ ] Export/Import de profil
- [ ] Synchronisation cloud (version Premium)

## 💎 Fonctionnalités Premium (Monétisation)

### Version Gratuite
- ✅ 3 profils maximum
- ✅ Saisie manuelle des données
- ✅ Calculs de base (distance approximative par code postal)
- ✅ Export simple des résultats

### Version Premium (5€/mois ou 50€/an)
- [ ] **Profils illimités**
- [ ] **Automatisations intelligentes :**
  - [ ] Autocomplétion d'adresses (Google Maps API)
  - [ ] Calcul précis distance/temps avec trafic en temps réel
  - [ ] Import automatique depuis :
    - [ ] LinkedIn (profil professionnel)
    - [ ] Pôle Emploi (historique)
    - [ ] Fiches de paie PDF (OCR)
  - [ ] Détection automatique convention collective
- [ ] **Suggestions contextuelles :**
  - [ ] Frais de repas moyens selon la zone
  - [ ] Coût parking selon le quartier
  - [ ] Mode de transport optimal
  - [ ] Estimation frais de garde selon département
- [ ] **Données actualisées :**
  - [ ] Prix carburant en temps réel
  - [ ] Tarifs transport en commun à jour
  - [ ] Barèmes fiscaux actualisés
- [ ] **Fonctionnalités avancées :**
  - [ ] Comparaison multi-offres simultanée
  - [ ] Simulation sur 5 ans
  - [ ] Export PDF détaillé avec graphiques
  - [ ] Historique des comparaisons
  - [ ] Notifications de changements fiscaux

### Intégrations API Premium
- [ ] Google Maps (Places, Distance Matrix)
- [ ] INSEE (données statistiques)
- [ ] API prix carburant gouvernementale
- [ ] Services de transport locaux
- [ ] OCR pour lecture documents

## 📊 Priorités de développement

### Phase 1 - MVP (Version gratuite)
1. **Haute priorité** : Pages essentielles
   - Situation professionnelle
   - Transport & Déplacements
   - Écran de calcul basique
   
2. **Priorité moyenne** : Précision
   - Frais professionnels
   - Paramètres fiscaux
   - Sauvegarde locale

### Phase 2 - Monétisation
1. **Système de paiement**
   - Intégration Stripe/PayPal
   - Gestion des abonnements
   - Écran de souscription

2. **Fonctionnalités Premium**
   - APIs externes
   - Automatisations
   - Export avancé

### Phase 3 - Croissance
1. **Marketing**
   - Page de présentation des features Premium
   - Période d'essai gratuite
   - Programme de parrainage

2. **Améliorations UX**
   - Mode sombre
   - Tutoriel interactif
   - Support multi-langues