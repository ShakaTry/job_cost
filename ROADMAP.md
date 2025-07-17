# 🗺️ Roadmap Produit - Job Cost

*Dernière mise à jour : 17 juillet 2025*

## 1. Vision & Stratégie Produit

### Mission
Aider les professionnels en France à prendre des décisions de carrière éclairées en leur fournissant un calcul précis et transparent de leur **salaire net réel** après déduction de tous les frais et impôts.

### Modèle Économique : Freemium
La stratégie est d'acquérir une base d'utilisateurs solide avec une version gratuite puissante (MVP), puis de monétiser via une offre Premium apportant une valeur ajoutée significative.

-   **Job Cost (Gratuit)** : L'outil de calcul le plus complet du marché pour un salarié en CDI. Il permet de créer un profil, de saisir toutes les données pertinentes et d'obtenir une simulation fiable.
    -   **Objectif** : Acquisition, validation du product-market fit, collecte de feedback.

-   **Job Cost Premium (Payant)** : Une suite d'outils avancés pour les professionnels exigeants, incluant la gestion de statuts multiples, des simulations complexes et des automatisations.
    -   **Objectif** : Revenus, rétention, expansion du marché.

---

## 2. Timeline & Phases de Développement

### Phase 1 : Finalisation du MVP (Terminé à 87.5%)
*Timeline : Juillet 2025 - Août 2025*

**Objectif : Lancer la v1.0 sur les stores (Android & iOS).**
Cette version doit être stable, complète et offrir une valeur immédiate à notre cœur de cible : les salariés en CDI.

| Priorité | Livrable Clé | Statut | Détails |
| :--- | :--- | :--- | :--- |
| 1 | **Écran "Paramètres Fiscaux"** | 🚧 À faire | Dernière page de collecte de données. Indispensable pour la fiabilité du calcul. |
| 2 | **Écran de Synthèse & Calcul** | 🚧 À faire | Le cœur de l'application. Doit présenter un résultat clair et une comparaison pertinente. |
| 3 | **Tests de bout en bout & Débogage** | 🚧 À faire | Valider le parcours utilisateur complet avec le profil de démo "Sophie Martin". |
| 4 | **Publication v1.0** | 🚧 Bloqué | Dépend de la finalisation des 3 points précédents. |

**Critère de succès :** L'application est disponible publiquement et les premiers retours utilisateurs confirment la pertinence et la fiabilité du calcul.

### Phase 2 : Lancement & Itération (Post-MVP)
*Timeline : Septembre 2025 - Q4 2025*

**Objectif : Analyser les retours utilisateurs, stabiliser l'application et préparer l'infrastructure pour la version Premium.**

| Priorité | Livrable Clé | Détails |
| :--- | :--- | :--- |
| 1 | **Collecte & Analyse du Feedback** | Mettre en place des canaux de feedback (store reviews, email, etc.). |
| 2 | **Optimisations & Corrections** | Adresser les bugs et les points de friction identifiés par les premiers utilisateurs. |
| 3 | **Infrastructure Premium** | Commencer le développement du backend : authentification, base de données (cloud). |

**Critère de succès :** Atteindre une note moyenne de 4.5+ sur les stores. Avoir une architecture backend prête à accueillir les fonctionnalités Premium.

### Phase 3 : Développement de Job Cost Premium
*Timeline : Q1 2026 - Q2 2026*

**Objectif : Développer et lancer l'offre payante pour commencer la monétisation.**

| Priorité | Fonctionnalité Premium | Description |
| :--- | :--- | :--- |
| 1 | **Gestion Multi-Profils & Statuts** | Supporter CDD, Intérim, Freelance. Permettre la comparaison entre statuts. |
| 2 | **Simulations "What-if"** | Projeter l'impact d'un changement (déménagement, augmentation, etc.). |
| 3 | **Export PDF & CSV** | Générer des rapports professionnels pour les négociations ou la comptabilité. |
| 4 | **Synchronisation Cloud** | Sauvegarder et synchroniser les profils sur plusieurs appareils. |

**Critère de succès :** Lancement de l'offre Premium avec un taux de conversion viable des utilisateurs actifs gratuits.

### Phase 4 : Vision Long Terme
*Timeline : Post-2026*

**Objectif : Devenir l'outil de référence pour la gestion de carrière en France.**

-   **Intégrations** : Connexion avec des outils de comptabilité, plateformes de recherche d'emploi.
-   **IA & Automatisation** : Scan de fiches de paie, suggestions personnalisées.
-   **Internationalisation** : Adapter le moteur de calcul pour d'autres pays.
-   **Dashboard Analytique** : Suivi de l'évolution de carrière, benchmarks de salaires.

---

## 3. Priorités Techniques Détaillées

### Étape 1 : Finaliser le MVP (Focus Immédiat)

#### 1.1 Développement UI/UX - `fiscal_parameters_screen.dart`
-   Créer le formulaire en utilisant le pattern `ExpansionTile` existant.
-   Intégrer les champs : régime fiscal, taux, parts, barème kilométrique.
-   Mettre à jour le modèle `UserProfile` et le service `ProfileService`.
-   Ajouter les données correspondantes au profil de démo "Sophie Martin".

#### 1.2 Développement UI/UX - Écran de Calcul
-   Concevoir une interface claire pour la saisie d'une offre d'emploi.
-   Afficher la synthèse des résultats : Net après charges, Net après impôts, **Net Réel**.
-   Mettre en place la comparaison "Situation Actuelle" vs "Nouvelle Offre".

#### 1.3 Implémentation du Moteur de Calcul
-   Créer une classe `CalculationService` qui prend en entrée un `UserProfile`.
-   Implémenter la logique de calcul en se basant sur les `docs/calculations`.
-   Assurer la précision et la testabilité des calculs.

#### 1.4 Tests & Débogage
-   Écrire des tests unitaires pour le `CalculationService`.
-   Effectuer des tests manuels complets du parcours utilisateur.

### Étape 2 : Préparation de l'Infrastructure Premium (Moyen Terme)
-   **Choix technologique** : Évaluer des solutions BaaS (Firebase, Supabase) pour accélérer le développement.
-   **Authentification** : Mettre en place un système de connexion (Email/Password, Google/Apple Sign-In).
-   **Base de données** : Concevoir le schéma de la base de données cloud pour stocker les profils de manière sécurisée.
-   **Migration des données locales** : Planifier la stratégie pour migrer les profils locaux des utilisateurs existants vers le cloud.

### Étape 3 : Développement des Fonctionnalités Premium (Long Terme)
Le développement de chaque fonctionnalité Premium suivra un cycle :
1.  Mise à jour du modèle de données (local et cloud).
2.  Développement de l'interface utilisateur.
3.  Mise à jour du moteur de calcul pour supporter le nouveau cas d'usage.
4.  Intégration avec le système de paiement (In-App Purchase).

---

## 4. État Actuel du Projet

### Progression : 87.5% pages collecte - 75% fonctionnalités MVP

| Catégorie | Complété | Total | % |
|-----------|----------|-------|---|
| Pages données | 7 | 8 | 87.5% |
| Écran calcul | 0 | 1 | 0% |
| Fonctionnalités MVP | 15 | 20 | 75% |

### ✅ Fonctionnalités Implémentées
- **Interface utilisateur :**
  - ExpansionTile sur toutes les pages de formulaire (sections collapsibles)
  - Interface cohérente et épurée 
  - Sauvegarde automatique optimisée (pattern PopScope)
  - UX mobile optimisée
  - Navigation clavier entre champs

- **Gestion des données :**
  - Profil de démonstration "Sophie Martin" complet
  - 17 nouveaux champs pour frais professionnels
  - Validation et formatage des données
  - Calculs salaire brut/horaire bidirectionnels
  - Heures supplémentaires (25%/50%)

- **Pages complétées (7/8) :**
  1. Sélection de profil
  2. Création de profil  
  3. Vue détaillée du profil
  4. Informations personnelles
  5. Situation professionnelle
  6. Transport & déplacements
  7. Frais professionnels

### 🚧 Fonctionnalités Manquantes Critiques
- **Paramètres fiscaux** (BLOQUANT pour calculs) - dernière page de collecte
- **Écran de calcul complet** avec moteur utilisant toutes les données
- **Export des résultats** en format texte

---

## 5. Fonctionnalités Premium (Post-MVP)

### Version Gratuite (MVP)
- ✅ 3 profils maximum
- ✅ Saisie manuelle
- ✅ Calculs complets pour CDI uniquement
- ✅ Export texte simple

### Version Premium (Abonnement)
#### Statuts Professionnels Avancés
- Salarié(e) CDD (prime précarité 10%)
- Intérimaire (IFM + ICCP)
- Auto-entrepreneur (cotisations spécifiques)
- Indépendant/Freelance
- Fonction publique

#### Fonctionnalités Avancées
- Profils illimités
- Import automatique (LinkedIn, PDF)
- Export PDF professionnel
- Simulations multi-scénarios
- Comparaison multi-statuts
- Historique et tendances
- Synchronisation cloud

#### Automatisations IA (Vision Long Terme)
- **Scan intelligent de fiche de paie** :
  - OCR haute précision (Google Cloud Vision)
  - Analyse IA avec Gemini Pro
  - Remplissage automatique du profil
- **Coûts estimés** : ~0,01-0,05€/mois par utilisateur
- **Tarification suggérée** : 10-20 scans inclus, puis 0,10-0,20€/scan

---

## 6. Timeline Immédiate (Juillet-Août 2025)

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

---

*Cette roadmap sera mise à jour régulièrement selon l'avancement du projet et les retours utilisateurs.*