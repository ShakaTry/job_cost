# 📋 Stratégie MVP - Job Cost

## 🔄 Évolution de la stratégie (17/12/2024)

### Problème identifié
Nous développions l'application "de bas en haut" :
- ✅ Pages de saisie de données (profil, situation, transport)
- ❌ Mais PAS la fonctionnalité principale (calcul du salaire réel)

**Résultat** : Une app avec plein de formulaires mais qui ne peut rien calculer !

### Nouvelle approche : "Top-Down"
Développer d'abord ce qui apporte de la VALEUR à l'utilisateur :
1. **Écran de calcul** : L'utilisateur peut immédiatement calculer son salaire réel
2. **Données minimales** : Ajouter seulement les données nécessaires aux calculs
3. **Itérations** : Améliorer progressivement la précision

## 🎯 MVP Minimal : Ce qui est VRAIMENT nécessaire

### Fonctionnalité principale
**Calculer le salaire net réel après tous les frais**

### Données minimales requises
1. **Profil basique**
   - Situation familiale (pour les impôts)
   - Localisation (pour les transports)
   
2. **Offre d'emploi**
   - Salaire brut proposé
   - Localisation du poste
   - Avantages (tickets resto, etc.)

3. **Calculs essentiels**
   - Charges sociales → salaire net
   - Impôts → net après impôt
   - Transport → coût réel
   - Repas → frais quotidiens
   - **= SALAIRE NET RÉEL**

### Ce qui peut attendre
- ❌ Heures supplémentaires complexes
- ❌ Tous les types de frais possibles
- ❌ Historique et comparaisons avancées
- ❌ Import automatique de données

## 📊 Nouvelle roadmap technique

### Sprint 1 : Écran de calcul (1 semaine)
```dart
// 1. Créer le modèle JobOffer
class JobOffer {
  final double grossSalary;
  final String location;
  final Map<String, dynamic> benefits;
}

// 2. Créer le moteur de calcul
class SalaryCalculator {
  static CalculationResult calculate(
    UserProfile profile,
    JobOffer offer,
  );
}

// 3. Créer l'UI de saisie et résultats
CalculationScreen
```

### Sprint 2 : Données fiscales (3-4 jours)
- Page simple pour le taux d'imposition
- Nombre de parts fiscales
- Intégration dans le calcul

### Sprint 3 : Frais essentiels (3-4 jours)
- Repas (avec/sans cantine)
- Garde d'enfants si applicable
- Intégration dans le calcul

### Sprint 4 : Export & Polish (1 semaine)
- Export texte des calculs
- Tests avec cas réels
- Corrections et ajustements

## 📝 Décision finale

Après réflexion, il est plus logique de **finir d'abord toutes les pages de données** avant l'écran de calcul, car :
1. L'écran de calcul a besoin de TOUTES les données pour fonctionner correctement
2. Les paramètres fiscaux sont essentiels pour calculer le net après impôt
3. Les frais professionnels (repas, garde) ont un impact majeur sur le salaire réel

**Nouvelle séquence** :
1. ✅ Pages de profil (FAIT)
2. 🚧 Paramètres fiscaux
3. 🚧 Frais professionnels
4. 🚧 Écran de calcul (avec toutes les données disponibles)

## ✅ Critères de succès du MVP

1. **L'utilisateur peut** :
   - Entrer une offre d'emploi
   - Voir son salaire net réel calculé
   - Comprendre la décomposition
   - Exporter le résultat

2. **Les calculs incluent** :
   - Charges sociales exactes
   - Impôts personnalisés
   - Frais de transport réels
   - Frais de repas

3. **Précision** :
   - Écart < 5% avec une fiche de paie réelle
   - Validation avec le profil Sophie Martin

## 🚀 Avantages de cette approche

1. **Valeur immédiate** : L'app est utile dès le Sprint 1
2. **Feedback rapide** : On peut tester avec de vrais utilisateurs
3. **Itérations** : On améliore based on feedback réel
4. **Time to market** : 3 semaines au lieu de 8

## 📝 Notes pour le développement

- **TOUJOURS** commencer par le cas d'usage principal
- **ÉVITER** le perfectionnisme sur les features secondaires
- **TESTER** avec des données réelles (Sophie Martin)
- **VALIDER** chaque calcul avec des sources officielles

---

*"Mieux vaut une app qui fait UNE chose bien que dix choses mal"*