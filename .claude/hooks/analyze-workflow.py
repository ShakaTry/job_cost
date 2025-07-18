#!/usr/bin/env python3
"""
Analyze user prompts to detect workflow automation intentions.
This hook runs on UserPromptSubmit to add context for Claude.
"""
import json
import sys
import re

def analyze_prompt(prompt):
    """Analyze the prompt to detect workflow patterns"""
    
    # Keywords indicating workflow automation
    workflow_patterns = [
        (r'\b(automat\w+)\s+(branch|workflow|git)', 'AUTOMATION'),
        (r'\b(cr[ée]er?\s+des?\s+branch)', 'BRANCH_CREATION'),
        (r'\b(test|doc|fix)\s+.*\s+(branch|automatique)', 'MULTI_BRANCH'),
        (r'\b(workflow)\s+(git|complet)', 'FULL_WORKFLOW'),
    ]
    
    detected_patterns = []
    for pattern, label in workflow_patterns:
        if re.search(pattern, prompt, re.IGNORECASE):
            detected_patterns.append(label)
    
    return detected_patterns

def generate_context(patterns):
    """Generate context message based on detected patterns"""
    
    if not patterns:
        return None
    
    context_parts = []
    
    if 'AUTOMATION' in patterns or 'FULL_WORKFLOW' in patterns:
        context_parts.append("""
WORKFLOW AUTOMATION CONTEXT:
The user wants automated Git workflow management. The system will:
1. Track all changes during the session
2. Automatically create appropriate branches at completion
3. Generate PRs with proper labels
""")
    
    if 'MULTI_BRANCH' in patterns:
        context_parts.append("""
MULTI-BRANCH WORKFLOW:
- Documentation changes → docs/auto-[feature] branch
- Test files → test/auto-[feature] branch  
- Bug fixes → fix/auto-[feature] branch
- Each branch gets its own PR with appropriate labels
""")
    
    if 'BRANCH_CREATION' in patterns:
        context_parts.append("""
BRANCH CREATION RULES:
- Always branch from 'develop'
- Use semantic prefixes (docs/, test/, fix/, feature/)
- Include descriptive names
- Set up tracking with origin
""")
    
    # Add reminder about the hooks
    context_parts.append("""
NOTE: Git workflow hooks are active. Changes will be automatically organized
into appropriate branches when the session completes.
""")
    
    return "\n".join(context_parts)

def main():
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        prompt = input_data.get("prompt", "")
        
        # Analyze the prompt
        patterns = analyze_prompt(prompt)
        
        # Generate context if patterns detected
        context = generate_context(patterns)
        
        if context:
            # Output context for Claude to see
            print(context)
            # Log for debugging
            print(f"[HOOK] Detected workflow patterns: {patterns}", file=sys.stderr)
        
        # Always exit successfully
        sys.exit(0)
        
    except Exception as e:
        # Log error but don't block the prompt
        print(f"[HOOK ERROR] analyze-workflow.py: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()