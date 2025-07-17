# Guide des Formules de Calcul de Paie en France

## 1. CONSTANTES OFFICIELLES

### Durée légale du travail
```
DUREE_LEGALE_HEBDO = 35 heures
DUREE_LEGALE_MENSUELLE = 151,67 heures (35h × 52 semaines / 12 mois)
SEMAINES_PAR_AN = 52
MOIS_PAR_AN = 12
```

### Base de calcul mensuelle
La durée mensuelle de 151,67 heures est fixée par l'article L3121-27 du Code du travail.

## 2. FORMULES OFFICIELLES

### 2.1 Calcul du taux horaire brut à partir du salaire mensuel

```
Taux_Horaire_Brut = Salaire_Mensuel_Brut / Durée_Mensuelle_Travail

Pour un temps plein :
Taux_Horaire_Brut = Salaire_Mensuel_Brut / 151,67
```

### 2.2 Calcul du salaire mensuel brut à partir du taux horaire

```
Salaire_Mensuel_Brut = Taux_Horaire_Brut × Durée_Mensuelle_Travail

Pour un temps plein :
Salaire_Mensuel_Brut = Taux_Horaire_Brut × 151,67
```

### 2.3 Formule générale avec coefficient de temps partiel

```
Coefficient_Temps = Heures_Hebdo_Réelles / 35

Durée_Mensuelle_Réelle = 151,67 × Coefficient_Temps

Salaire_Mensuel_Brut = Taux_Horaire_Brut × Durée_Mensuelle_Réelle
```

## 3. GESTION DES TEMPS PARTIELS

### 3.1 Tableau des temps partiels courants

| Temps de travail | Heures/semaine | Coefficient | Heures/mois    |
|-----------------|----------------|-------------|----------------|
| 100% (temps plein) | 35h         | 1,00        | 151,67h        |
| 80%             | 28h            | 0,80        | 121,33h        |
| 60%             | 21h            | 0,60        | 91,00h         |
| 50% (mi-temps)  | 17,5h          | 0,50        | 75,83h         |
| 30%             | 10,5h          | 0,30        | 45,50h         |
| 20%             | 7h             | 0,20        | 30,33h         |

### 3.2 Formules pour temps partiels

```
Pour un temps partiel à X heures/semaine :

Durée_Mensuelle = (X × 52) / 12

Exemple pour 17,5h/semaine (mi-temps) :
Durée_Mensuelle = (17,5 × 52) / 12 = 75,833... heures
```

## 4. PRÉCISION MATHÉMATIQUE ET ARRONDIS

### 4.1 Règles d'arrondi officielles

**Pour les salaires :**
- Arrondir à 2 décimales (centimes d'euro)
- Arrondi mathématique standard (0,005 → 0,01)

**Pour les heures :**
- Conserver au minimum 2 décimales dans les calculs intermédiaires
- Arrondir à 2 décimales pour l'affichage

### 4.2 Algorithme recommandé pour éviter les erreurs d'arrondi

```pseudo
FONCTION CalculerTauxHoraire(salaireMensuel, coefficientTemps):
    // Étape 1 : Calculer la durée mensuelle exacte
    duréeMensuelle = 151.67 * coefficientTemps
    
    // Étape 2 : Calculer le taux horaire avec précision étendue
    tauxHoraire = salaireMensuel / duréeMensuelle
    
    // Étape 3 : Arrondir UNIQUEMENT pour l'affichage
    RETOURNER arrondir(tauxHoraire, 4)  // 4 décimales pour précision

FONCTION CalculerSalaireMensuel(tauxHoraire, coefficientTemps):
    // Étape 1 : Calculer la durée mensuelle exacte
    duréeMensuelle = 151.67 * coefficientTemps
    
    // Étape 2 : Calculer le salaire avec précision étendue
    salaireMensuel = tauxHoraire * duréeMensuelle
    
    // Étape 3 : Arrondir à 2 décimales (centimes)
    RETOURNER arrondir(salaireMensuel, 2)
```

### 4.3 Gestion de la précision dans le code

```dart
// Exemple en Dart/Flutter
class CalculateurPaie {
  static const double DUREE_LEGALE_MENSUELLE = 151.67;
  static const int DECIMALES_SALAIRE = 2;
  static const int DECIMALES_TAUX_HORAIRE = 4;
  
  static double calculerTauxHoraire(double salaireMensuel, double coefficientTemps) {
    double dureeReelle = DUREE_LEGALE_MENSUELLE * coefficientTemps;
    double tauxHoraire = salaireMensuel / dureeReelle;
    // Conserver la précision maximale, arrondir seulement à l'affichage
    return tauxHoraire;
  }
  
  static double arrondir(double valeur, int decimales) {
    double facteur = pow(10, decimales);
    return (valeur * facteur).round() / facteur;
  }
}
```

## 5. CAS PRATIQUES

### 5.1 Exemple 1 : 3000€ brut/mois en temps plein → taux horaire

```
Données :
- Salaire mensuel brut = 3000,00 €
- Temps de travail = 100% (151,67h/mois)

Calcul :
Taux horaire = 3000,00 / 151,67
Taux horaire = 19,7802... €/h
Taux horaire arrondi = 19,78 €/h (affichage)

Vérification inverse :
Salaire = 19,7802... × 151,67 = 3000,00 € ✓
```

### 5.2 Exemple 2 : 20€/h en mi-temps → salaire mensuel

```
Données :
- Taux horaire = 20,00 €/h
- Temps de travail = 50% (75,835h/mois)

Calcul :
Durée mensuelle = 151,67 × 0,5 = 75,835h
Salaire mensuel = 20,00 × 75,835
Salaire mensuel = 1516,70 €

Vérification inverse :
Taux horaire = 1516,70 / 75,835 = 20,00 €/h ✓
```

### 5.3 Test de cohérence aller-retour

```
Test avec 2500€ à 80% :
1. Salaire initial : 2500,00 €
2. Durée mensuelle : 151,67 × 0,8 = 121,336h
3. Taux horaire : 2500 / 121,336 = 20,6044... €/h
4. Retour : 20,6044... × 121,336 = 2500,00 € ✓
```

## 6. RÉGLEMENTATION ET RÉFÉRENCES

### 6.1 Sources officielles

- **Code du travail** : Articles L3121-27 à L3121-34 (durée du travail)
- **Décret n°2000-815** : Durée et aménagement du temps de travail
- **Convention collective** : Peut prévoir des dispositions plus favorables

### 6.2 Différences selon les statuts

**Cadres au forfait jours :**
- Pas de calcul horaire direct
- Base : 218 jours/an maximum

**Non-cadres :**
- Application stricte des 35h/semaine
- Heures supplémentaires au-delà

**Fonction publique :**
- Base : 1607 heures annuelles
- Calcul mensuel : 1607 / 12 = 133,92h

### 6.3 Heures supplémentaires

```
Majoration légale :
- 25% pour les 8 premières heures (36e à 43e heure)
- 50% au-delà de la 43e heure

Calcul :
Taux_HS_25 = Taux_Horaire_Base × 1,25
Taux_HS_50 = Taux_Horaire_Base × 1,50
```

## 7. ALGORITHME COMPLET ANTI-ERREURS

```pseudo
CLASSE CalculateurSalaire {
    CONSTANTES:
        DUREE_LEGALE_MENSUELLE = 151.67
        PRECISION_INTERNE = 6  // décimales
        PRECISION_SALAIRE = 2
        PRECISION_TAUX = 4
    
    FONCTION calculerAvecPrecision(salaireBrut, heuresHebdo) {
        // 1. Calcul du coefficient exact
        coefficient = heuresHebdo / 35.0
        
        // 2. Durée mensuelle exacte
        dureeReelle = DUREE_LEGALE_MENSUELLE * coefficient
        
        // 3. Calculs avec précision maximale
        SI salaireBrut est fourni:
            tauxHoraire = salaireBrut / dureeReelle
            // Stocker avec précision complète
            RETOURNER {
                tauxHoraire: tauxHoraire,
                tauxHoraireAffiche: arrondir(tauxHoraire, PRECISION_TAUX),
                salaireMensuel: salaireBrut,
                dureeReelle: dureeReelle
            }
        
        SI tauxHoraire est fourni:
            salaireMensuel = tauxHoraire * dureeReelle
            RETOURNER {
                tauxHoraire: tauxHoraire,
                salaireMensuel: arrondir(salaireMensuel, PRECISION_SALAIRE),
                dureeReelle: dureeReelle
            }
    }
}
```

## 8. VALIDATION ET TESTS

### Tests unitaires recommandés

```dart
void testCalculsPaie() {
  // Test 1: Conversion aller-retour temps plein
  assert(calculerSalaire(19.78, 1.0) == 3000.00);
  assert(calculerTaux(3000.00, 1.0) == 19.78);
  
  // Test 2: Temps partiels
  assert(calculerDureeMensuelle(0.5) == 75.835);
  assert(calculerDureeMensuelle(0.8) == 121.336);
  
  // Test 3: Précision des arrondis
  double salaire = 2543.67;
  double taux = calculerTaux(salaire, 1.0);
  double salairRetour = calculerSalaire(taux, 1.0);
  assert((salaire - salairRetour).abs() < 0.01);
}
```

## NOTES IMPORTANTES

1. **Ne jamais arrondir les valeurs intermédiaires** - Conserver la précision maximale
2. **Utiliser des types décimaux** (Decimal en Dart) pour les calculs financiers critiques
3. **Toujours vérifier la cohérence** avec un calcul inverse
4. **Documenter les arrondis** appliqués pour la traçabilité

## RÉFÉRENCES COMPLÉMENTAIRES

- [Legifrance - Code du travail](https://www.legifrance.gouv.fr/codes/id/LEGISCTA000033020112/)
- [Service-public.fr - Durée du travail](https://www.service-public.fr/particuliers/vosdroits/F1903)
- [URSSAF - Base de calcul des cotisations](https://www.urssaf.fr/portail/home/employeur/calculer-les-cotisations/la-base-de-calcul.html)