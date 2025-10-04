#!/usr/bin/env python3
"""
git-brush: A tool to clean up your git repository
"""

import subprocess
import sys
import argparse


def run_command(command, check=True):
    """Run a shell command and return the output."""
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=check,
            capture_output=True,
            text=True
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except subprocess.CalledProcessError as e:
        if check:
            print(f"Error running command: {command}", file=sys.stderr)
            print(f"Error: {e.stderr}", file=sys.stderr)
            sys.exit(1)
        return None


def get_merged_branches(current_branch):
    """Get list of branches that have been merged into the current branch."""
    output = run_command("git branch --merged")
    branches = []
    for line in output.split('\n'):
        branch = line.strip().replace('* ', '')
        # Skip main, master, develop, and current branch
        if branch and branch not in ['main', 'master', 'develop', current_branch]:
            branches.append(branch)
    return branches


def get_current_branch():
    """Get the name of the current branch."""
    return run_command("git branch --show-current")


def delete_branch(branch_name, force=False):
    """Delete a local branch."""
    flag = '-D' if force else '-d'
    run_command(f"git branch {flag} {branch_name}")
    print(f"Deleted branch: {branch_name}")


def clean_merged_branches(dry_run=False, force=False):
    """Delete all merged branches except main/master/develop."""
    # Check if we're in a git repository first
    if run_command("git rev-parse --git-dir", check=False) is None:
        print("Error: Not a git repository", file=sys.stderr)
        sys.exit(1)
    
    current = get_current_branch()
    print(f"Current branch: {current}")
    
    merged = get_merged_branches(current)
    
    if not merged:
        print("No merged branches to clean up.")
        return
    
    print(f"\nFound {len(merged)} merged branch(es):")
    for branch in merged:
        print(f"  - {branch}")
    
    if dry_run:
        print("\nDry run mode - no branches were deleted.")
        print("Run without --dry-run to delete these branches.")
        return
    
    print("\nDeleting merged branches...")
    for branch in merged:
        delete_branch(branch, force)
    
    print(f"\nCleaned up {len(merged)} branch(es).")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="git-brush: Clean up your git repository"
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be deleted without actually deleting'
    )
    parser.add_argument(
        '--force',
        action='store_true',
        help='Force delete branches (use -D instead of -d)'
    )
    
    args = parser.parse_args()
    
    clean_merged_branches(dry_run=args.dry_run, force=args.force)


if __name__ == '__main__':
    main()
