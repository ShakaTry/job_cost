#!/usr/bin/env python3
"""
Orchestrate the test generation workflow triggered by /gittest.
This replaces the standard orchestrate-branches.py for test workflows.
"""
import json
import sys
import os
import subprocess
import time
from datetime import datetime

# Workflow marker file
WORKFLOW_MARKER = os.path.expanduser("~/.claude/job_cost_test_workflow.json")
TRACKING_FILE = os.path.expanduser("~/.claude/job_cost_changes.json")

def run_git_command(cmd, check=True):
    """Execute Git command and return output"""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        raise Exception(f"Git command failed: {cmd}\nError: {result.stderr}")
    return result.stdout.strip(), result.returncode

def is_test_workflow_active():
    """Check if we're in a test workflow session"""
    if os.path.exists(WORKFLOW_MARKER):
        try:
            with open(WORKFLOW_MARKER, 'r') as f:
                data = json.load(f)
                return data.get("active", False)
        except:
            pass
    return False

def clear_workflow_marker():
    """Clear the workflow marker"""
    if os.path.exists(WORKFLOW_MARKER):
        os.remove(WORKFLOW_MARKER)

def get_current_branch():
    """Get current Git branch"""
    branch, _ = run_git_command("git branch --show-current")
    return branch

def create_and_merge_branch(branch_name, files, commit_message):
    """Create branch, commit, push, create PR and auto-merge"""
    base_branch = "develop"
    
    # Create and checkout branch
    run_git_command(f"git checkout -b {branch_name} {base_branch}")
    
    # Add files
    has_files = False
    for file_path in files:
        if os.path.exists(file_path):
            run_git_command(f"git add {file_path}")
            has_files = True
    
    if not has_files:
        run_git_command(f"git checkout {base_branch}")
        run_git_command(f"git branch -d {branch_name}")
        return None
    
    # Commit and push
    run_git_command(f'git commit -m "{commit_message}"')
    run_git_command(f"git push -u origin {branch_name}")
    
    # Create PR
    pr_title = commit_message.split('\n')[0]
    pr_body = f"""## Automated Test Workflow PR

Part of the /gittest automated workflow.

### Files:
{chr(10).join(f"- {f}" for f in files)}

🤖 Generated with Claude Code test automation
"""
    
    pr_cmd = f'''gh pr create --base {base_branch} --title "{pr_title}" --body "{pr_body}"'''
    pr_output, _ = run_git_command(pr_cmd)
    
    # Extract PR number
    pr_number = None
    if pr_output and '/pull/' in pr_output:
        pr_number = pr_output.split('/pull/')[-1].strip()
    
    # Auto-merge
    if pr_number:
        print(f"[TEST-WORKFLOW] Auto-merging PR #{pr_number}")
        merge_cmd = f"gh pr merge {pr_number} --merge --delete-branch"
        run_git_command(merge_cmd)
        time.sleep(3)
        run_git_command(f"git checkout {base_branch}")
        run_git_command("git pull origin develop")
    
    return pr_output

def run_tests():
    """Run Flutter tests and return results"""
    print("[TEST-WORKFLOW] Running flutter test...")
    result = subprocess.run("flutter test", shell=True, capture_output=True, text=True)
    
    if result.returncode == 0:
        return True, "All tests passed!"
    else:
        # Extract failure details
        failures = []
        lines = (result.stdout + result.stderr).split('\n')
        for line in lines:
            if 'FAILED' in line or 'Error:' in line or '✗' in line:
                failures.append(line.strip())
        return False, failures

def trigger_fix_generation(test_failures):
    """Create a context for Claude to fix the failing tests"""
    
    failure_details = "\n".join(test_failures[:10])  # First 10 failures
    
    fix_prompt = f"""
Les tests ont échoué. Voici les erreurs :

{failure_details}

TÂCHE : Corrige automatiquement ces échecs de tests.

Analyse les erreurs et :
1. Si c'est un problème dans le code source → corrige le code
2. Si c'est un problème dans les tests → corrige les tests
3. Si c'est un problème de configuration → corrige la configuration

Crée les corrections nécessaires pour que tous les tests passent.
"""
    
    return fix_prompt

def main():
    try:
        # Check if we're in a test workflow
        if not is_test_workflow_active():
            # Not a test workflow, exit silently
            sys.exit(0)
        
        print("\n[TEST-WORKFLOW] Starting automated test workflow")
        
        # Get tracking data
        if not os.path.exists(TRACKING_FILE):
            print("[TEST-WORKFLOW] No changes tracked yet")
            sys.exit(0)
        
        with open(TRACKING_FILE, 'r') as f:
            tracking_data = json.load(f)
        
        # Categorize files
        doc_files = []
        test_files = []
        other_files = []
        
        for change in tracking_data.get("changes", []):
            file_path = change["file"]
            category = change["category"]
            
            if category == "documentation":
                doc_files.append(file_path)
            elif category == "test":
                test_files.append(file_path)
            else:
                other_files.append(file_path)
        
        current_branch = get_current_branch()
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        
        # Step 1: Documentation
        if doc_files:
            print("\n[TEST-WORKFLOW] Step 1: Creating and merging documentation")
            doc_branch = f"docs/test-auto-{timestamp}"
            create_and_merge_branch(
                doc_branch,
                doc_files,
                "[Docs] Test documentation for automated test workflow"
            )
        
        # Step 2: Tests
        if test_files:
            print("\n[TEST-WORKFLOW] Step 2: Creating test branch")
            test_branch = f"test/auto-{timestamp}"
            pr_url = create_and_merge_branch(
                test_branch,
                test_files,
                "[Tests] Automated tests from /gittest command"
            )
            
            # Run tests
            print("\n[TEST-WORKFLOW] Step 3: Running tests")
            success, result = run_tests()
            
            if success:
                print(f"✅ {result}")
                clear_workflow_marker()
                
                output = {
                    "decision": "block",
                    "reason": f"Test workflow completed successfully!\n\n✅ All tests passed!\n\nWorkflow summary:\n- Documentation merged\n- Tests created and merged\n- All tests passing",
                    "suppressOutput": False
                }
                print(json.dumps(output))
            else:
                print(f"❌ Tests failed: {len(result)} failures")
                
                # Generate fix context
                fix_context = trigger_fix_generation(result)
                
                output = {
                    "decision": "block", 
                    "reason": f"Tests failed! Generating fixes...\n\n{fix_context}",
                    "suppressOutput": False
                }
                print(json.dumps(output))
        
        else:
            print("[TEST-WORKFLOW] No test files generated yet")
        
        # Don't clear workflow marker if tests failed - we need to fix them
        if success:
            clear_workflow_marker()
        
        # Clear tracking file
        if os.path.exists(TRACKING_FILE):
            os.remove(TRACKING_FILE)
        
        sys.exit(0)
        
    except Exception as e:
        clear_workflow_marker()
        print(f"[TEST-WORKFLOW ERROR] {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()