# Git Workflow - Job Cost

## 🔄 WORKFLOW OBLIGATOIRE

**DÉCLENCHEURS** : 
- Mot-clé "git" dans une conversation
- Commande slash "/git"
- Après toute modification de fichier significative
- Avant de terminer une session de travail

## 📋 CHECKLIST SYSTÉMATIQUE

### 1. **VÉRIFICATIONS PRÉALABLES**
```bash
git status          # Voir fichiers modifiés
git diff            # Voir changements détaillés  
git log --oneline -5  # Voir style commits récents
```

### 2. **ANALYSE DES CHANGEMENTS**
- ✅ Identifier tous les fichiers modifiés
- ✅ Vérifier que les changements sont cohérents
- ✅ S'assurer qu'aucun secret/clé n'est exposé
- ✅ Analyser l'impact des modifications

### 3. **COMMIT SYSTÉMATIQUE**
```bash
# Ajouter fichiers pertinents
git add [fichiers_modifiés]

# Commit avec message structuré (HEREDOC obligatoire)
git commit -m "$(cat <<'EOF'
type: Description courte (max 50 caractères)

- Détail 1 des changements
- Détail 2 des changements  
- Détail 3 si nécessaire

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 4. **PUSH AUTOMATIQUE**
```bash
git push origin feature/fiscal-and-expenses-pages
```

## 📝 FORMAT DES MESSAGES

### Types de commit
- **feat**: Nouvelle fonctionnalité
- **fix**: Correction de bug
- **docs**: Documentation uniquement
- **style**: Formatage (pas de changement code)
- **refactor**: Refactoring sans nouvelle fonctionnalité
- **test**: Ajout/modification tests
- **chore**: Maintenance, config

### Exemples conformes
```
feat: Ajouter validation ExpansionTile avec indicateurs visuels

- Implémenter système tracking erreurs par section
- Ajouter icônes d'erreur/succès sur ExpansionTile  
- Auto-expansion première section avec erreur
- Résout problème validation invisible P1

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
fix: Corriger logique asymétrique calculs salaire-taux

- Unifier détection modification utilisateur dans _updateHourlyFromSalary()
- Préserver valeurs exactes lors recalculs automatiques
- Test validation: 3000€ → taux → heures → retour 3000€
- Résout problème calcul asymétrique P2

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## ⚠️ RÈGLES STRICTES

1. **JAMAIS de commit sans message descriptif**
2. **TOUJOURS utiliser le HEREDOC pour les messages multi-lignes**
3. **JAMAIS oublier la signature Claude Code**
4. **TOUJOURS analyser git status ET git diff avant commit**
5. **JAMAIS commit de secrets/clés/tokens**
6. **TOUJOURS push immédiatement après commit**

## 🎯 DÉCLENCHEMENT AUTOMATIQUE

**Quand appliquer ce workflow :**
- ✅ Après création/modification de fichiers
- ✅ À la fin d'une tâche/fonctionnalité
- ✅ Quand l'utilisateur dit "git" ou "/git"
- ✅ Avant de terminer une conversation
- ✅ Après résolution d'un problème du plan d'optimisation

## 📊 INFORMATIONS PROJET

- **Repository** : https://github.com/ShakaTry/job_cost.git
- **Branche actuelle** : feature/fiscal-and-expenses-pages  
- **Stratégie** : Git Flow (main, develop, feature/*, bugfix/*, hotfix/*)
- **Commits** : Réguliers avec messages descriptifs

## 🔍 COMMANDES DE VÉRIFICATION

```bash
# Avant chaque commit
flutter analyze  # Vérifier code Dart/Flutter

# Si erreurs détectées
flutter analyze --fix  # Corrections automatiques
```

**IMPORTANT** : Ce workflow est OBLIGATOIRE et doit être appliqué systématiquement, sans exception.