# Hooks

> Personnalisez et étendez le comportement de Claude Code en enregistrant des commandes shell

# Introduction

Les hooks de Claude Code sont des commandes shell définies par l'utilisateur qui s'exécutent à divers moments du cycle de vie de Claude Code. Les hooks fournissent un contrôle déterministe sur le comportement de Claude Code, garantissant que certaines actions se produisent toujours plutôt que de compter sur le LLM pour choisir de les exécuter.

Les cas d'usage d'exemple incluent :

* **Notifications** : Personnalisez la façon dont vous êtes notifié lorsque Claude Code attend votre saisie ou permission pour exécuter quelque chose.
* **Formatage automatique** : Exécutez `prettier` sur les fichiers .ts, `gofmt` sur les fichiers .go, etc. après chaque modification de fichier.
* **Journalisation** : Suivez et comptez toutes les commandes exécutées pour la conformité ou le débogage.
* **Retour d'information** : Fournissez un retour automatisé lorsque Claude Code produit du code qui ne suit pas les conventions de votre base de code.
* **Permissions personnalisées** : Bloquez les modifications aux fichiers de production ou aux répertoires sensibles.

En encodant ces règles comme hooks plutôt que comme instructions d'invite, vous transformez les suggestions en code au niveau de l'application qui s'exécute chaque fois qu'il est censé s'exécuter.

<Warning>
  Les hooks exécutent des commandes shell avec vos permissions utilisateur complètes sans confirmation. Vous êtes responsable de vous assurer que vos hooks sont sûrs et sécurisés. Anthropic n'est pas responsable de toute perte de données ou dommage système résultant de l'utilisation des hooks. Consultez [Considérations de sécurité](#security-considerations).
</Warning>

## Démarrage rapide

Dans ce démarrage rapide, vous ajouterez un hook qui journalise les commandes shell que Claude Code exécute.

Prérequis du démarrage rapide : Installez `jq` pour le traitement JSON en ligne de commande.

### Étape 1 : Ouvrir la configuration des hooks

Exécutez la [commande slash](/fr/docs/claude-code/slash-commands) `/hooks` et sélectionnez l'événement hook `PreToolUse`.

Les hooks `PreToolUse` s'exécutent avant les appels d'outils et peuvent les bloquer tout en fournissant un retour à Claude sur ce qu'il faut faire différemment.

### Étape 2 : Ajouter un matcher

Sélectionnez `+ Add new matcher…` pour exécuter votre hook uniquement sur les appels d'outils Bash.

Tapez `Bash` pour le matcher.

### Étape 3 : Ajouter le hook

Sélectionnez `+ Add new hook…` et entrez cette commande :

```bash
jq -r '"\(.tool_input.command) - \(.tool_input.description // "No description")"' >> ~/.claude/bash-command-log.txt
```

### Étape 4 : Sauvegarder votre configuration

Pour l'emplacement de stockage, sélectionnez `User settings` puisque vous journalisez dans votre répertoire personnel. Ce hook s'appliquera alors à tous les projets, pas seulement à votre projet actuel.

Puis appuyez sur Échap jusqu'à ce que vous retourniez au REPL. Votre hook est maintenant enregistré !

### Étape 5 : Vérifier votre hook

Exécutez `/hooks` à nouveau ou vérifiez `~/.claude/settings.json` pour voir votre configuration :

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "jq -r '\"\\(.tool_input.command) - \\(.tool_input.description // \"No description\")\"' >> ~/.claude/bash-command-log.txt"
        }
      ]
    }
  ]
}
```

## Configuration

Les hooks de Claude Code sont configurés dans vos [fichiers de paramètres](/fr/docs/claude-code/settings) :

* `~/.claude/settings.json` - Paramètres utilisateur
* `.claude/settings.json` - Paramètres de projet
* `.claude/settings.local.json` - Paramètres de projet locaux (non committé)
* Paramètres de politique gérée d'entreprise

### Structure

Les hooks sont organisés par matchers, où chaque matcher peut avoir plusieurs hooks :

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "your-command-here"
          }
        ]
      }
    ]
  }
}
```

* **matcher** : Motif pour faire correspondre les noms d'outils (applicable uniquement pour `PreToolUse` et `PostToolUse`)
    * Les chaînes simples correspondent exactement : `Write` correspond uniquement à l'outil Write
    * Supporte les regex : `Edit|Write` ou `Notebook.*`
    * Si omis ou chaîne vide, les hooks s'exécutent pour tous les événements correspondants
* **hooks** : Tableau de commandes à exécuter lorsque le motif correspond
    * `type` : Actuellement seul `"command"` est supporté
    * `command` : La commande bash à exécuter
    * `timeout` : (Optionnel) Combien de temps une commande doit s'exécuter, en secondes, avant d'annuler tous les hooks en cours.

## Événements de hooks

### PreToolUse

S'exécute après que Claude crée les paramètres d'outil et avant de traiter l'appel d'outil.

**Matchers communs :**

* `Task` - Tâches d'agent
* `Bash` - Commandes shell
* `Glob` - Correspondance de motifs de fichiers
* `Grep` - Recherche de contenu
* `Read` - Lecture de fichiers
* `Edit`, `MultiEdit` - Édition de fichiers
* `Write` - Écriture de fichiers
* `WebFetch`, `WebSearch` - Opérations web

### PostToolUse

S'exécute immédiatement après qu'un outil se termine avec succès.

Reconnaît les mêmes valeurs de matcher que PreToolUse.

### Notification

S'exécute lorsque Claude Code envoie des notifications.

### Stop

S'exécute lorsque l'agent principal Claude Code a fini de répondre.

### SubagentStop

S'exécute lorsqu'un sous-agent Claude Code (appel d'outil Task) a fini de répondre.

## Entrée de hook

Les hooks reçoivent des données JSON via stdin contenant des informations de session et des données spécifiques à l'événement :

```typescript
{
  // Champs communs
  session_id: string
  transcript_path: string  // Chemin vers le JSON de conversation

  // Champs spécifiques à l'événement
  ...
}
```

### Entrée PreToolUse

Le schéma exact pour `tool_input` dépend de l'outil.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  }
}
```

### Entrée PostToolUse

Le schéma exact pour `tool_input` et `tool_response` dépend de l'outil.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  },
  "tool_response": {
    "filePath": "/path/to/file.txt",
    "success": true
  }
}
```

### Entrée Notification

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "message": "Task completed successfully",
  "title": "Claude Code"
}
```

### Entrée Stop et SubagentStop

`stop_hook_active` est vrai lorsque Claude Code continue déjà suite à un hook d'arrêt. Vérifiez cette valeur ou traitez le transcript pour empêcher Claude Code de s'exécuter indéfiniment.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "stop_hook_active": true
}
```

## Sortie de hook

Il y a deux façons pour les hooks de retourner une sortie vers Claude Code. La sortie communique s'il faut bloquer et tout retour qui devrait être montré à Claude et à l'utilisateur.

### Simple : Code de sortie

Les hooks communiquent le statut via les codes de sortie, stdout et stderr :

* **Code de sortie 0** : Succès. `stdout` est montré à l'utilisateur en mode transcript (CTRL-R).
* **Code de sortie 2** : Erreur bloquante. `stderr` est renvoyé à Claude pour traitement automatique. Voir le comportement par événement de hook ci-dessous.
* **Autres codes de sortie** : Erreur non bloquante. `stderr` est montré à l'utilisateur et l'exécution continue.

<Warning>
  Rappel : Claude Code ne voit pas stdout si le code de sortie est 0.
</Warning>

#### Comportement du code de sortie 2

| Événement de hook | Comportement                                          |
| ----------------- | ----------------------------------------------------- |
| `PreToolUse`      | Bloque l'appel d'outil, montre l'erreur à Claude      |
| `PostToolUse`     | Montre l'erreur à Claude (l'outil a déjà été exécuté) |
| `Notification`    | N/A, montre stderr à l'utilisateur uniquement         |
| `Stop`            | Bloque l'arrêt, montre l'erreur à Claude              |
| `SubagentStop`    | Bloque l'arrêt, montre l'erreur au sous-agent Claude  |

### Avancé : Sortie JSON

Les hooks peuvent retourner du JSON structuré dans `stdout` pour un contrôle plus sophistiqué :

#### Champs JSON communs

Tous les types de hooks peuvent inclure ces champs optionnels :

```json
{
  "continue": true, // Si Claude doit continuer après l'exécution du hook (défaut : true)
  "stopReason": "string" // Message montré quand continue est false
  "suppressOutput": true, // Cacher stdout du mode transcript (défaut : false)
}
```

Si `continue` est false, Claude arrête le traitement après l'exécution des hooks.

* Pour `PreToolUse`, c'est différent de `"decision": "block"`, qui bloque seulement un appel d'outil spécifique et fournit un retour automatique à Claude.
* Pour `PostToolUse`, c'est différent de `"decision": "block"`, qui fournit un retour automatisé à Claude.
* Pour `Stop` et `SubagentStop`, cela prend la priorité sur toute sortie `"decision": "block"`.
* Dans tous les cas, `"continue" = false` prend la priorité sur toute sortie `"decision": "block"`.

`stopReason` accompagne `continue` avec une raison montrée à l'utilisateur, pas montrée à Claude.

#### Contrôle de décision `PreToolUse`

Les hooks `PreToolUse` peuvent contrôler si un appel d'outil procède.

* "approve" contourne le système de permissions. `reason` est montré à l'utilisateur mais pas à Claude.
* "block" empêche l'appel d'outil de s'exécuter. `reason` est montré à Claude.
* `undefined` mène au flux de permissions existant. `reason` est ignoré.

```json
{
  "decision": "approve" | "block" | undefined,
  "reason": "Explanation for decision"
}
```

#### Contrôle de décision `PostToolUse`

Les hooks `PostToolUse` peuvent contrôler si un appel d'outil procède.

* "block" invite automatiquement Claude avec `reason`.
* `undefined` ne fait rien. `reason` est ignoré.

```json
{
  "decision": "block" | undefined,
  "reason": "Explanation for decision"
}
```

#### Contrôle de décision `Stop`/`SubagentStop`

Les hooks `Stop` et `SubagentStop` peuvent contrôler si Claude doit continuer.

* "block" empêche Claude de s'arrêter. Vous devez remplir `reason` pour que Claude sache comment procéder.
* `undefined` permet à Claude de s'arrêter. `reason` est ignoré.

```json
{
  "decision": "block" | undefined,
  "reason": "Must be provided when Claude is blocked from stopping"
}
```

#### Exemple de sortie JSON : Édition de commande Bash

```python
#!/usr/bin/env python3
import json
import re
import sys

# Définir les règles de validation comme une liste de tuples (motif regex, message)
VALIDATION_RULES = [
    (
        r"\bgrep\b(?!.*\|)",
        "Use 'rg' (ripgrep) instead of 'grep' for better performance and features",
    ),
    (
        r"\bfind\s+\S+\s+-name\b",
        "Use 'rg --files | rg pattern' or 'rg --files -g pattern' instead of 'find -name' for better performance",
    ),
]


def validate_command(command: str) -> list[str]:
    issues = []
    for pattern, message in VALIDATION_RULES:
        if re.search(pattern, command):
            issues.append(message)
    return issues


try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
    sys.exit(1)

tool_name = input_data.get("tool_name", "")
tool_input = input_data.get("tool_input", {})
command = tool_input.get("command", "")

if tool_name != "Bash" or not command:
    sys.exit(1)

# Valider la commande
issues = validate_command(command)

if issues:
    for message in issues:
        print(f"• {message}", file=sys.stderr)
    # Le code de sortie 2 bloque l'appel d'outil et montre stderr à Claude
    sys.exit(2)
```

## Travailler avec les outils MCP

Les hooks de Claude Code fonctionnent parfaitement avec les [outils du Protocole de Contexte de Modèle (MCP)](/fr/docs/claude-code/mcp). Lorsque les serveurs MCP fournissent des outils, ils apparaissent avec un motif de nommage spécial que vous pouvez faire correspondre dans vos hooks.

### Nommage des outils MCP

Les outils MCP suivent le motif `mcp__<server>__<tool>`, par exemple :

* `mcp__memory__create_entities` - Outil de création d'entités du serveur Memory
* `mcp__filesystem__read_file` - Outil de lecture de fichier du serveur Filesystem
* `mcp__github__search_repositories` - Outil de recherche du serveur GitHub

### Configuration des hooks pour les outils MCP

Vous pouvez cibler des outils MCP spécifiques ou des serveurs MCP entiers :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__memory__.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Memory operation initiated' >> ~/mcp-operations.log"
          }
        ]
      },
      {
        "matcher": "mcp__.*__write.*",
        "hooks": [
          {
            "type": "command",
            "command": "/home/user/scripts/validate-mcp-write.py"
          }
        ]
      }
    ]
  }
}
```

## Exemples

### Formatage de code

Formatez automatiquement le code après les modifications de fichiers :

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "/home/user/scripts/format-code.sh"
          }
        ]
      }
    ]
  }
}
```

### Notification

Personnalisez la notification qui est envoyée lorsque Claude Code demande une permission ou lorsque l'entrée d'invite est devenue inactive.

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/my_custom_notifier.py"
          }
        ]
      }
    ]
  }
}
```

## Considérations de sécurité

### Avertissement

**UTILISEZ À VOS PROPRES RISQUES** : Les hooks de Claude Code exécutent des commandes shell arbitraires sur votre système automatiquement. En utilisant les hooks, vous reconnaissez que :

* Vous êtes seul responsable des commandes que vous configurez
* Les hooks peuvent modifier, supprimer ou accéder à tous les fichiers auxquels votre compte utilisateur peut accéder
* Les hooks malveillants ou mal écrits peuvent causer une perte de données ou des dommages système
* Anthropic ne fournit aucune garantie et n'assume aucune responsabilité pour tous dommages résultant de l'utilisation des hooks
* Vous devriez tester minutieusement les hooks dans un environnement sûr avant l'utilisation en production

Toujours réviser et comprendre toutes les commandes de hook avant de les ajouter à votre configuration.

### Meilleures pratiques de sécurité

Voici quelques pratiques clés pour écrire des hooks plus sécurisés :

1. **Valider et assainir les entrées** - Ne jamais faire confiance aveuglément aux données d'entrée
2. **Toujours citer les variables shell** - Utilisez `"$VAR"` pas `$VAR`
3. **Bloquer la traversée de chemin** - Vérifiez `..` dans les chemins de fichiers
4. **Utilisez des chemins absolus** - Spécifiez les chemins complets pour les scripts
5. **Évitez les fichiers sensibles** - Évitez `.env`, `.git/`, les clés, etc.

### Sécurité de configuration

Les modifications directes aux hooks dans les fichiers de paramètres ne prennent pas effet immédiatement. Claude Code :

1. Capture un instantané des hooks au démarrage
2. Utilise cet instantané tout au long de la session
3. Avertit si les hooks sont modifiés extérieurement
4. Nécessite une révision dans le menu `/hooks` pour que les changements s'appliquent

Cela empêche les modifications malveillantes de hooks d'affecter votre session actuelle.

## Détails d'exécution des hooks

* **Timeout** : Limite d'exécution de 60 secondes par défaut, configurable par commande.
    * Si une commande individuelle expire, tous les hooks en cours sont annulés.
* **Parallélisation** : Tous les hooks correspondants s'exécutent en parallèle
* **Environnement** : S'exécute dans le répertoire courant avec l'environnement de Claude Code
* **Entrée** : JSON via stdin
* **Sortie** :
    * PreToolUse/PostToolUse/Stop : Progrès montré dans le transcript (Ctrl-R)
    * Notification : Journalisé en debug uniquement (`--debug`)

## Débogage

Pour dépanner les hooks :

1. Vérifiez si le menu `/hooks` affiche votre configuration
2. Vérifiez que vos [fichiers de paramètres](/fr/docs/claude-code/settings) sont du JSON valide
3. Testez les commandes manuellement
4. Vérifiez les codes de sortie
5. Révisez les attentes de format stdout et stderr
6. Assurez-vous de l'échappement correct des guillemets
7. Utilisez `claude --debug` pour déboguer vos hooks. La sortie d'un hook réussi apparaît comme ci-dessous.

```
[DEBUG] Executing hooks for PostToolUse:Write
[DEBUG] Getting matching hook commands for PostToolUse with query: Write
[DEBUG] Found 1 hook matchers in settings
[DEBUG] Matched 1 hooks for query "Write"
[DEBUG] Found 1 hook commands to execute
[DEBUG] Executing hook command: <Your command> with timeout 60000ms
[DEBUG] Hook command completed with status 0: <Your stdout>
```

Les messages de progrès apparaissent en mode transcript (Ctrl-R) montrant :

* Quel hook s'exécute
* Commande en cours d'exécution
* Statut de succès/échec
* Messages de sortie ou d'erreur
