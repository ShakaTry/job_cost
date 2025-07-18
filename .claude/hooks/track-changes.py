#!/usr/bin/env python3
"""
Track file changes during the session.
This hook runs on PostToolUse for Write/Edit operations.
"""
import json
import sys
import os
from datetime import datetime

# File to store tracked changes
TRACKING_FILE = os.path.expanduser("~/.claude/job_cost_changes.json")

def load_tracking_data():
    """Load existing tracking data"""
    if os.path.exists(TRACKING_FILE):
        try:
            with open(TRACKING_FILE, 'r') as f:
                return json.load(f)
        except:
            pass
    return {
        "session_start": datetime.now().isoformat(),
        "changes": []
    }

def save_tracking_data(data):
    """Save tracking data with atomic write"""
    os.makedirs(os.path.dirname(TRACKING_FILE), exist_ok=True)
    # Write to temp file first then rename (atomic operation)
    temp_file = TRACKING_FILE + '.tmp'
    try:
        with open(temp_file, 'w') as f:
            json.dump(data, f, indent=2)
        # Atomic rename
        os.rename(temp_file, TRACKING_FILE)
    except Exception as e:
        # Clean up temp file if it exists
        if os.path.exists(temp_file):
            os.remove(temp_file)
        raise e

def categorize_file(file_path):
    """Categorize file based on path and name"""
    file_lower = file_path.lower()
    
    # Documentation files
    if any(pattern in file_lower for pattern in ['/docs/', '.md', 'readme', 'documentation']):
        return "documentation"
    
    # Test files
    if any(pattern in file_lower for pattern in ['test', 'spec', '_test.', '.test.', 'tests/']):
        return "test"
    
    # Configuration files
    if any(pattern in file_lower for pattern in ['.json', '.yaml', '.yml', 'config', 'settings']):
        return "config"
    
    # Source code - check for fixes
    if any(pattern in file_lower for pattern in ['fix', 'bug', 'patch', 'hotfix']):
        return "fix"
    
    # Default to feature
    return "feature"

def main():
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        tool_response = input_data.get("tool_response", {})
        
        # Only track Write/Edit operations
        if tool_name not in ["Write", "Edit", "MultiEdit"]:
            sys.exit(0)
        
        # Extract file path
        file_path = tool_input.get("file_path", "")
        if not file_path:
            sys.exit(0)
        
        # Load tracking data
        tracking_data = load_tracking_data()
        
        # Track the change
        change_entry = {
            "timestamp": datetime.now().isoformat(),
            "tool": tool_name,
            "file": file_path,
            "category": categorize_file(file_path),
            "success": tool_response.get("success", True)
        }
        
        # For Edit operations, track what was changed
        if tool_name in ["Edit", "MultiEdit"]:
            if "old_string" in tool_input:
                change_entry["change_type"] = "edit"
                change_entry["description"] = f"Modified content in {os.path.basename(file_path)}"
            elif "edits" in tool_input:
                change_entry["change_type"] = "multi_edit"
                change_entry["edit_count"] = len(tool_input["edits"])
        else:
            change_entry["change_type"] = "write"
            change_entry["description"] = f"Created/Updated {os.path.basename(file_path)}"
        
        # Add to tracking data
        tracking_data["changes"].append(change_entry)
        
        # Save tracking data
        save_tracking_data(tracking_data)
        
        # Output for transcript mode (optional)
        category = change_entry["category"]
        print(f"[TRACKED] {category.upper()}: {file_path}")
        
        sys.exit(0)
        
    except Exception as e:
        # Log error but don't block operations
        print(f"[HOOK ERROR] track-changes.py: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()