#!/usr/bin/env python3
"""
Orchestrate automatic branch creation based on tracked changes.
This hook runs on Stop event to create appropriate branches and PRs.
Implements a sequential workflow: docs -> tests -> fixes
"""
import json
import sys
import os
import subprocess
import time
from datetime import datetime

# Import lock utilities
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lock_utils import acquire_lock, release_lock, cleanup_stale_locks

# File where changes are tracked
TRACKING_FILE = os.path.expanduser("~/.claude/job_cost_changes.json")
# File to track test results
TEST_RESULTS_FILE = os.path.expanduser("~/.claude/job_cost_test_results.json")

def run_git_command(cmd, check=True):
    """Execute Git command and return output"""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        raise Exception(f"Git command failed: {cmd}\nError: {result.stderr}")
    return result.stdout.strip(), result.returncode

def load_tracking_data():
    """Load tracked changes"""
    if not os.path.exists(TRACKING_FILE):
        return None
    
    try:
        with open(TRACKING_FILE, 'r') as f:
            return json.load(f)
    except:
        return None

def clear_tracking_data():
    """Clear tracking data after processing"""
    if os.path.exists(TRACKING_FILE):
        os.remove(TRACKING_FILE)

def get_current_branch():
    """Get current Git branch"""
    branch, _ = run_git_command("git branch --show-current")
    return branch

def categorize_changes(tracking_data):
    """Categorize all tracked changes"""
    categories = {
        "documentation": [],
        "test": [],
        "fix": [],
        "feature": [],
        "config": []
    }
    
    for change in tracking_data.get("changes", []):
        category = change.get("category", "feature")
        categories[category].append(change)
    
    return categories

def wait_for_pr_checks(pr_number, timeout=300):
    """Wait for PR checks to complete"""
    print(f"[WORKFLOW] Waiting for PR #{pr_number} checks...")
    start_time = time.time()
    
    while time.time() - start_time < timeout:
        # Check PR status
        status_cmd = f"gh pr checks {pr_number} --json state,name"
        output, _ = run_git_command(status_cmd, check=False)
        
        if output:
            try:
                checks = json.loads(output)
                all_completed = all(check['state'] != 'pending' for check in checks)
                if all_completed:
                    return checks
            except:
                pass
        
        time.sleep(10)
    
    return None

def merge_pr_if_safe(pr_number, branch_type):
    """Merge PR if it's safe (docs always, others if tests pass)"""
    if branch_type == "documentation":
        # Always merge documentation PRs
        print(f"[WORKFLOW] Auto-merging documentation PR #{pr_number}")
        merge_cmd = f"gh pr merge {pr_number} --merge --delete-branch"
        run_git_command(merge_cmd)
        return True
    else:
        # For other types, check if tests pass
        checks = wait_for_pr_checks(pr_number)
        if checks and all(check['state'] == 'success' for check in checks):
            print(f"[WORKFLOW] Tests passed, auto-merging PR #{pr_number}")
            merge_cmd = f"gh pr merge {pr_number} --merge --delete-branch"
            run_git_command(merge_cmd)
            return True
        else:
            print(f"[WORKFLOW] PR #{pr_number} has failing checks, manual review required")
            return False

def run_tests_and_get_failures():
    """Run tests and return list of failures"""
    print("[WORKFLOW] Running tests to detect failures...")
    
    # Try Flutter tests first
    test_cmd = "flutter test"
    result = subprocess.run(test_cmd, shell=True, capture_output=True, text=True)
    
    if result.returncode != 0:
        # Parse test output for failures
        failures = []
        lines = result.stdout.split('\n') + result.stderr.split('\n')
        for line in lines:
            if 'FAILED' in line or 'Error:' in line:
                failures.append(line.strip())
        
        return failures
    
    return []

def create_branch_and_pr(branch_type, branch_name, files, base_branch="develop", auto_merge=True):
    """Create a branch, commit files, create PR, and optionally auto-merge"""
    
    print(f"\n[WORKFLOW] Creating {branch_type} branch: {branch_name}")
    
    # Create and checkout new branch
    run_git_command(f"git checkout -b {branch_name} {base_branch}")
    
    # Add specific files
    for file_info in files:
        file_path = file_info["file"]
        if os.path.exists(file_path):
            run_git_command(f"git add {file_path}")
    
    # Check if there are files to commit
    status, _ = run_git_command("git status --porcelain")
    if not status:
        print(f"[WORKFLOW] No files to commit for {branch_type}")
        run_git_command(f"git checkout {base_branch}")
        run_git_command(f"git branch -d {branch_name}")
        return None, None
    
    # Commit
    commit_message = f"[{branch_type.capitalize()}] Automated {branch_type} from Claude Code session"
    run_git_command(f'git commit -m "{commit_message}"')
    
    # Push branch
    run_git_command(f"git push -u origin {branch_name}")
    
    # Create PR
    pr_title = f"[{branch_type.capitalize()}] {branch_type.capitalize()} updates from Claude Code"
    pr_body = f"""## Automated {branch_type.capitalize()} PR

This PR was automatically created by Claude Code workflow hooks.

### Files changed:
{chr(10).join(f"- {f['file']}" for f in files)}

### Workflow Step: {branch_type}
### Auto-merge: {'Yes' if auto_merge else 'No'}

### Generated at: {datetime.now().isoformat()}

🤖 Generated with Claude Code workflow automation
"""
    
    pr_cmd = f'''gh pr create --base {base_branch} --title "{pr_title}" --body "{pr_body}" --label "{branch_type}"'''
    pr_output, _ = run_git_command(pr_cmd)
    
    # Extract PR number from output
    pr_number = None
    if pr_output and '/pull/' in pr_output:
        pr_number = pr_output.split('/pull/')[-1].strip()
    
    # Auto-merge if requested
    if auto_merge and pr_number:
        merge_pr_if_safe(pr_number, branch_type)
    
    return pr_output, pr_number

def main():
    # Clean up old locks first
    cleanup_stale_locks()
    
    # Try to acquire workflow lock
    if not acquire_lock("workflow_orchestration"):
        print("[WORKFLOW] Another workflow is already running, skipping")
        sys.exit(0)
    
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        
        # Check if this is a stop hook continuation
        if input_data.get("stop_hook_active", False):
            print("[WORKFLOW] Already in stop hook, skipping to prevent loop")
            sys.exit(0)
        
        # Check if we're in a test workflow - if yes, delegate to test orchestrator
        test_workflow_marker = os.path.expanduser("~/.claude/job_cost_test_workflow.json")
        if os.path.exists(test_workflow_marker):
            try:
                with open(test_workflow_marker, 'r') as f:
                    data = json.load(f)
                    if data.get("active", False):
                        # Delegate to test workflow orchestrator
                        import subprocess
                        test_orchestrator = "/home/shaka/AndroidStudioProjects/job_cost/.claude/hooks/test-workflow-orchestrator.py"
                        result = subprocess.run([test_orchestrator], input=json.dumps(input_data), 
                                              capture_output=True, text=True, shell=False)
                        print(result.stdout)
                        if result.stderr:
                            print(result.stderr, file=sys.stderr)
                        sys.exit(result.returncode)
            except:
                pass
        
        # Load tracking data
        tracking_data = load_tracking_data()
        if not tracking_data or not tracking_data.get("changes"):
            print("[WORKFLOW] No changes tracked, nothing to orchestrate")
            sys.exit(0)
        
        # Get current branch
        current_branch = get_current_branch()
        if current_branch == "main" or current_branch == "develop":
            print(f"[WORKFLOW] On protected branch {current_branch}, skipping automation")
            sys.exit(0)
        
        # Check if we're already on an auto-created branch
        if "auto-" in current_branch:
            print(f"[WORKFLOW] Already on auto-created branch {current_branch}, skipping to prevent loops")
            sys.exit(0)
        
        # Verify we have a clean git state for critical operations
        try:
            # Check if git repo is in a good state
            run_git_command("git rev-parse --git-dir")
        except Exception as e:
            print(f"[WORKFLOW ERROR] Git repository check failed: {e}", file=sys.stderr)
            sys.exit(1)
        
        # Categorize changes
        categories = categorize_changes(tracking_data)
        
        # Check if there are changes to stash
        status_output, _ = run_git_command("git status --porcelain", check=False)
        if status_output.strip():
            # Stash any uncommitted changes
            run_git_command("git stash push -u -m 'Claude Code workflow automation stash'")
        
        created_branches = []
        
        try:
            # STEP 1: Create and merge documentation branch
            if categories["documentation"]:
                print("\n[WORKFLOW] Step 1: Documentation")
                branch_name = f"docs/auto-{current_branch}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
                pr_url, pr_number = create_branch_and_pr("documentation", branch_name, categories["documentation"], auto_merge=True)
                if pr_url:
                    created_branches.append(("Documentation", branch_name, pr_url))
                    # Wait for merge to complete
                    time.sleep(5)
                    run_git_command("git pull origin develop")
            
            # STEP 2: Create test branch and run tests
            test_failures = []
            if categories["test"]:
                print("\n[WORKFLOW] Step 2: Tests")
                branch_name = f"test/auto-{current_branch}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
                pr_url, pr_number = create_branch_and_pr("test", branch_name, categories["test"], auto_merge=False)
                if pr_url:
                    created_branches.append(("Test", branch_name, pr_url))
                    
                    # Run tests to check for failures
                    print("\n[WORKFLOW] Running tests to check for failures...")
                    test_failures = run_tests_and_get_failures()
                    
                    if not test_failures:
                        # Tests pass, auto-merge
                        print("[WORKFLOW] All tests passed!")
                        if pr_number:
                            merge_pr_if_safe(pr_number, "test")
                    else:
                        print(f"[WORKFLOW] Found {len(test_failures)} test failures")
                        # Save test failures for fix generation
                        with open(TEST_RESULTS_FILE, 'w') as f:
                            json.dump({"failures": test_failures}, f)
            
            # STEP 3: Create fix branch if tests failed or if fixes were tracked
            if test_failures or categories["fix"]:
                print("\n[WORKFLOW] Step 3: Fixes")
                branch_name = f"fix/auto-{current_branch}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
                
                # If we have test failures, prompt for fix creation
                if test_failures:
                    fix_reason = f"Fix {len(test_failures)} test failures"
                else:
                    fix_reason = "Apply tracked fixes"
                
                pr_url, pr_number = create_branch_and_pr("fix", branch_name, categories["fix"], auto_merge=False)
                if pr_url:
                    created_branches.append(("Fix", branch_name, pr_url))
                    
                    # If this was for test failures, add a comment to the PR
                    if test_failures and pr_number:
                        comment = f"This PR addresses the following test failures:\n\n"
                        for failure in test_failures[:5]:  # Show first 5 failures
                            comment += f"- {failure}\n"
                        if len(test_failures) > 5:
                            comment += f"\n... and {len(test_failures) - 5} more failures"
                        
                        run_git_command(f'gh pr comment {pr_number} --body "{comment}"')
            
            # Skip feature branch creation - not needed in simplified workflow
            
        finally:
            # Return to original branch
            run_git_command(f"git checkout {current_branch}")
            
            # Restore stash if any
            stash_list, _ = run_git_command("git stash list", check=False)
            if stash_list and "Claude Code workflow automation stash" in stash_list:
                try:
                    run_git_command("git stash pop")
                except Exception as e:
                    print(f"[WORKFLOW WARNING] Could not restore stash: {e}", file=sys.stderr)
        
        # Clear tracking data
        clear_tracking_data()
        
        # Report results
        if created_branches:
            output = {
                "decision": "block",
                "reason": f"Workflow automation completed! Created {len(created_branches)} branches:\n\n" + 
                         "\n".join([f"• {type}: {branch}\n  PR: {pr}" for type, branch, pr in created_branches]) +
                         "\n\nPlease review the PRs and merge as appropriate.",
                "suppressOutput": False
            }
            print(json.dumps(output))
        else:
            print("[WORKFLOW] No branches were created (no eligible changes)")
        
        sys.exit(0)
        
    except Exception as e:
        # Log error and clear tracking data
        clear_tracking_data()
        error_msg = f"[WORKFLOW ERROR] orchestrate-branches.py: {e}"
        print(error_msg, file=sys.stderr)
        
        # Return error to user
        output = {
            "decision": "block",
            "reason": f"Workflow automation encountered an error:\n{str(e)}\n\nPlease check the Git state manually.",
            "suppressOutput": False
        }
        print(json.dumps(output))
        sys.exit(0)
    finally:
        # Always release the lock
        release_lock("workflow_orchestration")

if __name__ == "__main__":
    main()