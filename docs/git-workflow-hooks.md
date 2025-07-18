# Système de Hooks pour Automatisation du Workflow Git

## Vue d'ensemble

Ce système de hooks Claude Code automatise un workflow Git séquentiel intelligent :

1. **Documentation** → Commit → PR → Auto-merge
2. **Tests** → Commit → PR → Exécution des tests
3. **Fixes** → Si les tests échouent → Commit → PR
4. **Features** → Pour les autres changements → Commit → PR

Le système suit les changements, les catégorise, et orchestre automatiquement le workflow complet.

## Architecture

### Structure des fichiers

```
.claude/
├── settings.json          # Configuration des hooks
└── hooks/
    ├── analyze-workflow.py      # Analyse les prompts utilisateur
    ├── track-changes.py         # Suit les modifications de fichiers
    ├── orchestrate-branches.py  # Crée les branches et PRs séquentiellement
    └── test-runner.py          # Exécute les tests et analyse les échecs
```

## Fonctionnement

### 1. Analyse du prompt (UserPromptSubmit)

Le script `analyze-workflow.py` :
- Détecte les intentions d'automatisation dans les prompts
- Ajoute du contexte pour Claude sur le workflow attendu
- Mots-clés détectés : "automatiser", "branches", "workflow git", etc.

### 2. Suivi des changements (PostToolUse)

Le script `track-changes.py` :
- S'exécute après chaque modification de fichier
- Catégorise les fichiers modifiés :
  - **documentation** : fichiers dans `/docs/` ou `.md`
  - **test** : fichiers contenant "test", "spec"
  - **fix** : fichiers contenant "fix", "bug"
  - **config** : fichiers `.json`, `.yaml`
  - **feature** : tout le reste
- Stocke les changements dans `~/.claude/job_cost_changes.json`

### 3. Orchestration séquentielle (Stop)

Le script `orchestrate-branches.py` exécute un workflow intelligent :

#### Étape 1 : Documentation
- Crée la branche `docs/auto-[branch]-[timestamp]`
- Commit les fichiers de documentation
- Crée une PR avec label "documentation"
- **Auto-merge immédiat** (la doc est toujours safe)

#### Étape 2 : Tests
- Crée la branche `test/auto-[branch]-[timestamp]`
- Commit les fichiers de test
- Crée une PR avec label "test"
- **Exécute `flutter test`** pour vérifier
- Si succès → Auto-merge
- Si échec → Passe à l'étape 3

#### Étape 3 : Fixes (si nécessaire)
- Activé si des tests échouent
- Crée la branche `fix/auto-[branch]-[timestamp]`
- Crée une PR avec label "fix"
- Ajoute un commentaire avec les échecs détectés
- Attend une intervention manuelle

#### Étape 4 : Features
- Crée la branche `feature/auto-[branch]-[timestamp]`
- Commit les autres changements
- Crée une PR avec label "feature"

## Configuration

### Installation

1. Les scripts sont dans `.claude/hooks/`
2. La configuration est dans `.claude/settings.json`
3. Les scripts doivent être exécutables (`chmod +x`)

### Personnalisation

#### Modifier les catégories de fichiers

Dans `track-changes.py`, fonction `categorize_file()` :

```python
# Ajouter une nouvelle catégorie
if any(pattern in file_lower for pattern in ['migration', 'upgrade']):
    return "migration"
```

#### Changer les préfixes de branches

Dans `orchestrate-branches.py` :

```python
# Modifier le format des noms de branches
branch_name = f"docs/auto-{current_branch}-{datetime.now().strftime('%Y%m%d')}"
```

#### Ajuster les labels de PR

Dans `orchestrate-branches.py`, fonction `create_branch_and_pr()` :

```python
# Ajouter des labels supplémentaires
pr_cmd = f'gh pr create --label "{branch_type}" --label "auto-generated"'
```

## Utilisation

### Activation automatique

Les hooks s'activent automatiquement quand Claude Code détecte :
- Des mots-clés d'automatisation dans votre prompt
- Des modifications de fichiers pendant la session
- La fin d'une session de développement

### Exemple de workflow séquentiel

1. **Prompt utilisateur** : "Crée des tests pour le widget ProfileAvatar"
2. **Claude Code** :
   - Crée `/docs/tests/profile_avatar_test.md` (documentation)
   - Crée `/test/widgets/profile_avatar_test.dart` (tests)
   - Modifie `/lib/widgets/profile_avatar.dart` (fix si nécessaire)

3. **Workflow automatique** :

```
[WORKFLOW] Step 1: Documentation
✅ Created PR #123 - Auto-merged

[WORKFLOW] Step 2: Tests
Creating test branch...
Running flutter test...
❌ 2 tests failed

[WORKFLOW] Step 3: Fixes
Created PR #125 with test failures:
- ProfileAvatar should display initials
- ProfileAvatar should handle null image

[WORKFLOW] Workflow completed:
• Documentation: PR #123 (merged)
• Tests: PR #124 (pending - tests failed)
• Fixes: PR #125 (pending - addresses test failures)
```

### Résultat idéal (tests passent)

```
[WORKFLOW] Step 1: Documentation
✅ Created PR #123 - Auto-merged

[WORKFLOW] Step 2: Tests
✅ All tests passed - Auto-merged PR #124

[WORKFLOW] Workflow completed successfully!
```

## Sécurité

### Protections intégrées

- Les branches `main` et `develop` sont protégées
- Les changements sont stashés avant création des branches
- Gestion d'erreurs complète avec rollback
- Timeout configuré pour chaque hook

### Permissions requises

- Accès en écriture au repository Git
- GitHub CLI (`gh`) configuré avec token
- Permissions de création de branches et PRs

## Dépannage

### Les hooks ne s'exécutent pas

1. Vérifier que les scripts sont exécutables
2. Vérifier les chemins absolus dans `settings.json`
3. Utiliser `claude --debug` pour voir l'exécution

### Erreurs Git

- Le script stash automatiquement les changements
- En cas d'erreur, vérifier `git status` et `git stash list`
- Les données de tracking sont dans `~/.claude/job_cost_changes.json`

### Nettoyage

Pour réinitialiser le système :
```bash
rm ~/.claude/job_cost_changes.json
git stash clear
```

## Évolutions futures

### Améliorations possibles

1. **Multi-framework tests** : Support pour Jest, Pytest, etc.
2. **Fix automatique** : Génération de code pour corriger les tests
3. **Intégration CI/CD** : Attendre les checks GitHub Actions
4. **Notifications** : Webhook Discord/Slack pour le statut
5. **Analyse de couverture** : Vérifier la couverture de code
6. **Rollback automatique** : Revert si les tests échouent après merge

### Contribution

Pour améliorer le système :
1. Modifier les scripts dans `.claude/hooks/`
2. Tester avec `claude --debug`
3. Documenter les changements
4. Créer une PR avec le préfixe `[Hooks]`