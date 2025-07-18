#!/usr/bin/env python3
"""
Orchestrate automatic branch creation based on tracked changes.
This hook runs on Stop event to create appropriate branches and PRs.
"""
import json
import sys
import os
import subprocess
from datetime import datetime

# File where changes are tracked
TRACKING_FILE = os.path.expanduser("~/.claude/job_cost_changes.json")

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

def create_branch_and_pr(branch_type, branch_name, files, base_branch="develop"):
    """Create a branch, commit files, and create PR"""
    
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
        return None
    
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

### Generated at: {datetime.now().isoformat()}

🤖 Generated with Claude Code workflow automation
"""
    
    pr_cmd = f'''gh pr create --base {base_branch} --title "{pr_title}" --body "{pr_body}" --label "{branch_type}"'''
    pr_url, _ = run_git_command(pr_cmd)
    
    return pr_url

def main():
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        
        # Check if this is a stop hook continuation
        if input_data.get("stop_hook_active", False):
            print("[WORKFLOW] Already in stop hook, skipping to prevent loop")
            sys.exit(0)
        
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
        
        # Categorize changes
        categories = categorize_changes(tracking_data)
        
        # Stash any uncommitted changes
        run_git_command("git stash push -u -m 'Claude Code workflow automation stash'")
        
        created_branches = []
        
        try:
            # Create documentation branch if needed
            if categories["documentation"]:
                branch_name = f"docs/auto-{current_branch}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
                pr_url = create_branch_and_pr("documentation", branch_name, categories["documentation"])
                if pr_url:
                    created_branches.append(("Documentation", branch_name, pr_url))
            
            # Create test branch if needed
            if categories["test"]:
                branch_name = f"test/auto-{current_branch}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
                pr_url = create_branch_and_pr("test", branch_name, categories["test"])
                if pr_url:
                    created_branches.append(("Test", branch_name, pr_url))
            
            # Create fix branch if needed
            if categories["fix"]:
                branch_name = f"fix/auto-{current_branch}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
                pr_url = create_branch_and_pr("fix", branch_name, categories["fix"])
                if pr_url:
                    created_branches.append(("Fix", branch_name, pr_url))
            
            # Create feature branch for remaining changes
            if categories["feature"] or categories["config"]:
                branch_name = f"feature/auto-{current_branch}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
                all_feature_files = categories["feature"] + categories["config"]
                pr_url = create_branch_and_pr("feature", branch_name, all_feature_files)
                if pr_url:
                    created_branches.append(("Feature", branch_name, pr_url))
            
        finally:
            # Return to original branch
            run_git_command(f"git checkout {current_branch}")
            
            # Restore stash if any
            stash_list, _ = run_git_command("git stash list", check=False)
            if "Claude Code workflow automation stash" in stash_list:
                run_git_command("git stash pop")
        
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

if __name__ == "__main__":
    main()