#!/usr/bin/env python3
"""
Utility functions for managing locks in Claude Code hooks.
Prevents concurrent execution of critical operations.
"""
import os
import time
import json
from datetime import datetime

LOCK_DIR = os.path.expanduser("~/.claude/locks")
LOCK_TIMEOUT = 300  # 5 minutes

def acquire_lock(lock_name, timeout=LOCK_TIMEOUT):
    """
    Acquire a lock with timeout protection.
    Returns True if lock acquired, False otherwise.
    """
    os.makedirs(LOCK_DIR, exist_ok=True)
    lock_file = os.path.join(LOCK_DIR, f"{lock_name}.lock")
    
    # Check if lock exists and is still valid
    if os.path.exists(lock_file):
        try:
            with open(lock_file, 'r') as f:
                lock_data = json.load(f)
            
            # Check if lock is expired
            lock_time = datetime.fromisoformat(lock_data['timestamp'])
            age = (datetime.now() - lock_time).total_seconds()
            
            if age < timeout:
                # Lock is still valid
                return False
            else:
                # Lock is expired, remove it
                os.remove(lock_file)
        except:
            # Invalid lock file, remove it
            os.remove(lock_file)
    
    # Create new lock
    try:
        # Use exclusive create to prevent race conditions
        fd = os.open(lock_file, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        lock_data = {
            'timestamp': datetime.now().isoformat(),
            'pid': os.getpid()
        }
        os.write(fd, json.dumps(lock_data).encode())
        os.close(fd)
        return True
    except FileExistsError:
        # Another process created the lock
        return False
    except Exception as e:
        print(f"[LOCK ERROR] Failed to acquire lock {lock_name}: {e}")
        return False

def release_lock(lock_name):
    """Release a lock."""
    lock_file = os.path.join(LOCK_DIR, f"{lock_name}.lock")
    try:
        if os.path.exists(lock_file):
            os.remove(lock_file)
    except Exception as e:
        print(f"[LOCK ERROR] Failed to release lock {lock_name}: {e}")

def with_lock(lock_name, func, *args, **kwargs):
    """Execute a function with lock protection."""
    if not acquire_lock(lock_name):
        raise Exception(f"Could not acquire lock: {lock_name}")
    
    try:
        return func(*args, **kwargs)
    finally:
        release_lock(lock_name)

def cleanup_stale_locks(max_age=3600):
    """Clean up locks older than max_age seconds."""
    if not os.path.exists(LOCK_DIR):
        return
    
    now = datetime.now()
    for lock_file in os.listdir(LOCK_DIR):
        if lock_file.endswith('.lock'):
            lock_path = os.path.join(LOCK_DIR, lock_file)
            try:
                with open(lock_path, 'r') as f:
                    lock_data = json.load(f)
                
                lock_time = datetime.fromisoformat(lock_data['timestamp'])
                age = (now - lock_time).total_seconds()
                
                if age > max_age:
                    os.remove(lock_path)
                    print(f"[LOCK] Cleaned up stale lock: {lock_file}")
            except:
                # Invalid lock file, remove it
                os.remove(lock_path)