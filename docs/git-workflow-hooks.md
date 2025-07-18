# Système de Hooks pour Automatisation du Workflow Git

## Vue d'ensemble

Ce système de hooks Claude Code automatise la création de branches Git et de pull requests en fonction des changements effectués pendant une session de développement. Il organise automatiquement les modifications en branches appropriées (documentation, tests, corrections, fonctionnalités).

## Architecture

### Structure des fichiers

```
.claude/
├── settings.json          # Configuration des hooks
└── hooks/
    ├── analyze-workflow.py      # Analyse les prompts utilisateur
    ├── track-changes.py         # Suit les modifications de fichiers
    └── orchestrate-branches.py  # Crée les branches et PRs
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

### 3. Orchestration (Stop)

Le script `orchestrate-branches.py` :
- S'exécute à la fin de la session Claude Code
- Lit les changements suivis
- Crée des branches séparées pour chaque catégorie :
  - `docs/auto-[branch]-[timestamp]`
  - `test/auto-[branch]-[timestamp]`
  - `fix/auto-[branch]-[timestamp]`
  - `feature/auto-[branch]-[timestamp]`
- Crée une PR pour chaque branche avec le label approprié

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

### Exemple de workflow

1. **Prompt utilisateur** : "Crée un système d'automatisation de branches Git"
2. **Claude Code** : Développe le système
3. **Hooks actifs** :
   - `analyze-workflow.py` détecte l'intention
   - `track-changes.py` suit chaque fichier modifié
   - `orchestrate-branches.py` crée les branches à la fin

### Résultat attendu

```
[WORKFLOW] Workflow automation completed! Created 3 branches:

• Documentation: docs/auto-feature-git-workflow-20241219-143052
  PR: https://github.com/user/repo/pull/123

• Feature: feature/auto-feature-git-workflow-20241219-143052  
  PR: https://github.com/user/repo/pull/124

• Config: config/auto-feature-git-workflow-20241219-143052
  PR: https://github.com/user/repo/pull/125
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

1. **Tests automatiques** : Exécuter les tests avant création de PR
2. **Validation du code** : Linting et formatage automatique
3. **Intégration CI/CD** : Déclencher des pipelines après PR
4. **Notifications** : Slack/Discord pour les PRs créées
5. **Configuration par projet** : `.claude/project-settings.json`

### Contribution

Pour améliorer le système :
1. Modifier les scripts dans `.claude/hooks/`
2. Tester avec `claude --debug`
3. Documenter les changements
4. Créer une PR avec le préfixe `[Hooks]`