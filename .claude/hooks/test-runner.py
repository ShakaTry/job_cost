#!/usr/bin/env python3
"""
Test runner hook that executes tests and provides detailed feedback.
Can be triggered by workflow automation or manually.
"""
import json
import sys
import subprocess
import re
from datetime import datetime

def detect_test_framework():
    """Detect which test framework is available"""
    frameworks = [
        ("flutter test", "Flutter"),
        ("npm test", "Node.js"),
        ("python -m pytest", "Python pytest"),
        ("go test ./...", "Go"),
        ("cargo test", "Rust"),
    ]
    
    for cmd, name in frameworks:
        try:
            # Check if command exists
            check_cmd = cmd.split()[0] + " --version"
            result = subprocess.run(check_cmd, shell=True, capture_output=True)
            if result.returncode == 0:
                return cmd, name
        except:
            continue
    
    return None, None

def parse_flutter_test_output(output):
    """Parse Flutter test output for failures"""
    failures = []
    current_test = None
    
    lines = output.split('\n')
    for i, line in range(len(lines)):
        # Look for test failures
        if '✗' in line or 'FAILED' in line:
            current_test = line.strip()
        elif current_test and ('Error:' in line or 'Expected:' in line):
            failures.append({
                "test": current_test,
                "error": line.strip(),
                "file": extract_file_from_line(line)
            })
            current_test = None
    
    return failures

def extract_file_from_line(line):
    """Extract file path from error line"""
    # Look for patterns like "test/widget_test.dart:15:5"
    match = re.search(r'(\S+\.dart):(\d+):(\d+)', line)
    if match:
        return match.group(1)
    return None

def run_tests():
    """Run tests and return structured results"""
    test_cmd, framework = detect_test_framework()
    
    if not test_cmd:
        return {
            "success": False,
            "framework": "unknown",
            "error": "No test framework detected",
            "failures": []
        }
    
    print(f"[TEST-RUNNER] Detected {framework} framework")
    print(f"[TEST-RUNNER] Running: {test_cmd}")
    
    # Run tests
    result = subprocess.run(test_cmd, shell=True, capture_output=True, text=True)
    
    # Parse results
    if result.returncode == 0:
        return {
            "success": True,
            "framework": framework,
            "message": "All tests passed!",
            "stats": parse_test_stats(result.stdout)
        }
    else:
        failures = []
        if framework == "Flutter":
            failures = parse_flutter_test_output(result.stdout + result.stderr)
        
        return {
            "success": False,
            "framework": framework,
            "failures": failures,
            "raw_output": result.stdout + result.stderr
        }

def parse_test_stats(output):
    """Extract test statistics from output"""
    stats = {
        "total": 0,
        "passed": 0,
        "failed": 0,
        "skipped": 0
    }
    
    # Flutter pattern: "All tests passed!"
    if "All tests passed!" in output:
        # Extract number from "00:03 +15: All tests passed!"
        match = re.search(r'\+(\d+):', output)
        if match:
            stats["total"] = int(match.group(1))
            stats["passed"] = stats["total"]
    
    return stats

def generate_fix_suggestions(failures):
    """Generate suggestions for fixing test failures"""
    suggestions = []
    
    for failure in failures:
        suggestion = {
            "file": failure.get("file", "unknown"),
            "test": failure.get("test", ""),
            "suggestion": analyze_failure(failure)
        }
        suggestions.append(suggestion)
    
    return suggestions

def analyze_failure(failure):
    """Analyze a test failure and suggest fixes"""
    error = failure.get("error", "")
    
    if "Expected:" in error and "Actual:" in error:
        return "Update test expectations to match actual output"
    elif "type 'Null' is not a subtype" in error:
        return "Check for null safety issues, add null checks"
    elif "No widget found" in error:
        return "Ensure widget is properly built in test setup"
    elif "assertion" in error.lower():
        return "Review assertion conditions"
    else:
        return "Review test implementation and error details"

def main():
    """Main entry point for test runner"""
    try:
        # Run tests
        results = run_tests()
        
        # Save results
        results_file = "/tmp/claude_test_results.json"
        with open(results_file, 'w') as f:
            json.dump(results, f, indent=2)
        
        # Generate output
        if results["success"]:
            print(f"\n✅ {results['message']}")
            if "stats" in results:
                stats = results["stats"]
                print(f"   Tests run: {stats['total']}")
                print(f"   Passed: {stats['passed']}")
        else:
            print(f"\n❌ Tests failed in {results['framework']}")
            print(f"   Failures: {len(results['failures'])}")
            
            # Show first few failures
            for i, failure in enumerate(results['failures'][:3]):
                print(f"\n   {i+1}. {failure['test']}")
                print(f"      {failure['error']}")
            
            if len(results['failures']) > 3:
                print(f"\n   ... and {len(results['failures']) - 3} more failures")
            
            # Generate fix suggestions
            suggestions = generate_fix_suggestions(results['failures'])
            print("\n📝 Fix suggestions:")
            for s in suggestions[:3]:
                print(f"   - {s['file']}: {s['suggestion']}")
        
        # Exit with appropriate code
        sys.exit(0 if results["success"] else 1)
        
    except Exception as e:
        print(f"[TEST-RUNNER ERROR] {e}", file=sys.stderr)
        sys.exit(2)

if __name__ == "__main__":
    main()