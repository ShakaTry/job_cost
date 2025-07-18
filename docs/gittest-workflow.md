# Workflow /gittest - Génération Automatique de Tests

## Vue d'ensemble

La commande `/gittest` déclenche un workflow intelligent qui :

1. **Génère automatiquement** des tests pour une fonctionnalité
2. **Documente** les tests créés
3. **Exécute** les tests pour vérifier
4. **Corrige automatiquement** si les tests échouent

## Utilisation

### Syntaxe

```
/gittest [cible]
```

### Exemples

```bash
# Tester la dernière fonctionnalité ajoutée
/gittest

# Tester un widget spécifique
/gittest ProfileAvatar

# Tester une classe ou fonction
/gittest UserProfile.calculateAge

# Tester les dernières modifications
/gittest dernières modifications
```

## Workflow détaillé

### 1. Déclenchement

Quand vous tapez `/gittest`, le hook :
- Intercepte la commande
- Remplace votre prompt par des instructions détaillées pour Claude
- Active le mode "test workflow"

### 2. Génération par Claude

Claude va automatiquement :
- Analyser la cible (widget, classe, fonction)
- Créer `/docs/tests/[feature]_test.md` avec la documentation
- Générer `/test/[path]/[feature]_test.dart` avec les tests complets
- Inclure : tests nominaux, cas limites, cas d'erreur

### 3. Orchestration automatique

Le système :
1. **Crée et merge** la branche documentation
2. **Crée** la branche de tests
3. **Exécute** `flutter test`
4. **Si succès** → Auto-merge
5. **Si échec** → Demande à Claude de corriger

### 4. Correction automatique

Si les tests échouent :
- Claude reçoit les détails des échecs
- Analyse si c'est le code ou les tests qui sont faux
- Génère les corrections nécessaires
- Le cycle continue jusqu'à ce que tout passe

## Exemple de session

```
User: /gittest ProfileAvatar

[GITTEST] Triggered test generation for: ProfileAvatar

Claude: Je vais générer des tests complets pour ProfileAvatar...
*Crée la documentation*
*Génère les tests*

[TEST-WORKFLOW] Step 1: Creating and merging documentation
✅ Created PR #123 - Auto-merged

[TEST-WORKFLOW] Step 2: Creating test branch
✅ Created PR #124

[TEST-WORKFLOW] Step 3: Running tests
❌ Tests failed: 2 failures

Claude: Je vais corriger ces échecs...
*Analyse les erreurs*
*Corrige le code ou les tests*

[TEST-WORKFLOW] Running tests again...
✅ All tests passed!
```

## Configuration requise

### Prérequis

- Flutter installé et configuré
- GitHub CLI (`gh`) authentifié
- Permissions de création de branches/PRs

### Structure de projet

```
project/
├── lib/           # Code source
├── test/          # Tests générés ici
├── docs/
│   └── tests/     # Documentation des tests
└── .claude/
    ├── settings.json
    └── hooks/
        ├── gittest-command.py
        └── test-workflow-orchestrator.py
```

## Personnalisation

### Modifier le comportement

Dans `gittest-command.py` :

```python
# Changer le répertoire de documentation
doc_path = "/docs/tests/"  # → "/documentation/tests/"

# Changer le format des branches
branch_name = f"test/auto-{timestamp}"  # → f"tests/{feature}-{timestamp}"
```

### Ajouter des frameworks

Dans `test-runner.py` :

```python
frameworks = [
    ("flutter test", "Flutter"),
    ("npm test", "Node.js"),     # Ajouter
    ("pytest", "Python"),        # Ajouter
]
```

## Avantages

1. **Gain de temps** : Plus besoin d'écrire manuellement les tests
2. **Cohérence** : Tests toujours structurés de la même façon
3. **Documentation** : Chaque test est documenté
4. **Qualité** : Corrections automatiques jusqu'à ce que tout passe
5. **Traçabilité** : PRs séparées pour chaque étape

## Limitations

- Fonctionne principalement avec Flutter (extensible)
- Nécessite une structure de projet standard
- Les tests complexes peuvent nécessiter des ajustements manuels

## Évolution future

- Support multi-frameworks (Jest, Pytest, etc.)
- Analyse de couverture de code
- Génération de tests d'intégration
- Tests de performance automatiques