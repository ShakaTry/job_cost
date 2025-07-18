#!/usr/bin/env python3
"""
Handle /gittest command to trigger automated test generation workflow.
This hook runs on UserPromptSubmit when /gittest is detected.
"""
import json
import sys
import re
import os

def parse_gittest_command(prompt):
    """Parse /gittest command and extract target"""
    # Pattern: /gittest [target]
    match = re.match(r'^/gittest\s*(.*?)$', prompt.strip(), re.IGNORECASE)
    if not match:
        return None
    
    target = match.group(1).strip()
    return target if target else "last_changes"

def generate_test_context(target):
    """Generate context for test generation"""
    
    context = f"""
AUTOMATED TEST GENERATION WORKFLOW TRIGGERED

Target: {target if target != "last_changes" else "dernières modifications"}

WORKFLOW STEPS:
1. Analyser {target}
2. Créer la documentation des tests dans /docs/tests/
3. Générer les tests unitaires dans /test/
4. Exécuter les tests
5. Si échec, corriger automatiquement le code ou les tests

INSTRUCTIONS POUR CLAUDE:
- Analyser soigneusement ce qui doit être testé
- Créer des tests complets avec cas nominaux et cas limites
- Utiliser les bonnes pratiques Flutter (testWidgets, expect, etc.)
- Documenter chaque test dans la doc
- Si les tests échouent, analyser et corriger

IMPORTANT: Les hooks vont automatiquement :
- Créer une branche docs/ et la merger
- Créer une branche test/ avec les tests générés
- Exécuter flutter test
- Créer une branche fix/ si nécessaire

Commence par analyser {target} et génère les tests appropriés.
"""
    
    # Mark session for test workflow
    workflow_marker = os.path.expanduser("~/.claude/job_cost_test_workflow.json")
    with open(workflow_marker, 'w') as f:
        json.dump({
            "active": True,
            "target": target,
            "command": "/gittest"
        }, f)
    
    return context

def main():
    try:
        # Read input
        input_data = json.load(sys.stdin)
        prompt = input_data.get("prompt", "")
        
        # Check if this is a /gittest command
        if not prompt.strip().lower().startswith("/gittest"):
            sys.exit(0)
        
        # Parse the command
        target = parse_gittest_command(prompt)
        if target is None:
            sys.exit(0)
        
        # Generate context
        context = generate_test_context(target)
        
        # Log for debugging
        print(f"[GITTEST] Triggered test generation for: {target}", file=sys.stderr)
        
        # Block the original prompt and provide our context
        output = {
            "decision": "block",
            "reason": context
        }
        print(json.dumps(output))
        sys.exit(0)
        
    except Exception as e:
        print(f"[HOOK ERROR] gittest-command.py: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()