#!/usr/bin/env python3
"""
GitHub Actions Cleanup Script.
Deletes failed/cancelled workflow runs to keep repository clean.
"""
import os
import sys
import requests
import argparse
from datetime import datetime, timedelta

# GitHub API configuration
GITHUB_API = "https://api.github.com"
REPO_OWNER = "madcap-syd"
REPO_NAME = "ada-fuzz-lab"

def get_github_token():
    """Get GitHub token from environment or input."""
    token = os.environ.get('GITHUB_TOKEN')
    if not token:
        print("⚠️  GITHUB_TOKEN not found in environment.")
        print("Create a token at: https://github.com/settings/tokens")
        print("Required scope: 'repo' (full control of private repositories)")
        token = input("Enter your GitHub token: ").strip()
    return token

def get_workflow_runs(token, status_filter='failed', days_old=7):
    """Get workflow runs filtered by status and age."""
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Calculate date threshold
    cutoff_date = datetime.now() - timedelta(days=days_old)
    
    url = f"{GITHUB_API}/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs"
    params = {
        'per_page': 100,
        'page': 1
    }
    
    runs_to_delete = []
    
    print(f"🔍 Fetching workflow runs (status: {status_filter}, older than {days_old} days)...")
    
    while True:
        response = requests.get(url, headers=headers, params=params)
        if response.status_code != 200:
            print(f" Error fetching runs: {response.status_code}")
            print(response.json())
            break
        
        data = response.json()
        workflow_runs = data.get('workflow_runs', [])
        
        if not workflow_runs:
            break
        
        for run in workflow_runs:
            run_id = run['id']
            run_status = run['status']
            run_conclusion = run['conclusion']
            run_name = run['name']
            created_at = datetime.fromisoformat(run['created_at'].replace('Z', '+00:00'))
            run_date = created_at.replace(tzinfo=None)
            
            # Check if run is old enough
            if run_date > cutoff_date:
                continue
            
            # Check status filter
            should_delete = False
            if status_filter == 'failed' and run_conclusion == 'failure':
                should_delete = True
            elif status_filter == 'cancelled' and run_conclusion == 'cancelled':
                should_delete = True
            elif status_filter == 'all' and run_status == 'completed' and run_conclusion in ['failure', 'cancelled']:
                should_delete = True
            
            if should_delete:
                runs_to_delete.append({
                    'id': run_id,
                    'name': run_name,
                    'conclusion': run_conclusion,
                    'created_at': run['created_at'],
                    'url': run['html_url']
                })
        
        params['page'] += 1
    
    return runs_to_delete

def delete_workflow_run(token, run_id, run_name, dry_run=True):
    """Delete a single workflow run."""
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    url = f"{GITHUB_API}/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs/{run_id}"
    
    if dry_run:
        print(f"  [DRY-RUN] Would delete run #{run_id}: {run_name}")
        return True
    
    response = requests.delete(url, headers=headers)
    if response.status_code == 204:
        print(f"  ✅ Deleted run #{run_id}: {run_name}")
        return True
    else:
        print(f"  ❌ Failed to delete run #{run_id}: {response.status_code}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Clean up failed GitHub Actions runs')
    parser.add_argument('--status', choices=['failed', 'cancelled', 'all'], 
                       default='failed', help='Which runs to delete (default: failed)')
    parser.add_argument('--days', type=int, default=7, 
                       help='Delete runs older than N days (default: 7)')
    parser.add_argument('--dry-run', action='store_true', 
                       help='Show what would be deleted without actually deleting')
    parser.add_argument('--force', action='store_true',
                       help='Skip confirmation prompt')
    
    args = parser.parse_args()
    
    print("=" * 70)
    print("🧹 GitHub Actions Cleanup Script")
    print("=" * 70)
    print(f"Repository: {REPO_OWNER}/{REPO_NAME}")
    print(f"Status filter: {args.status}")
    print(f"Age filter: older than {args.days} days")
    print(f"Mode: {'DRY-RUN' if args.dry_run else 'LIVE'}")
    print("=" * 70)
    
    # Get GitHub token
    token = get_github_token()
    
    # Get workflow runs
    runs = get_workflow_runs(token, args.status, args.days)
    
    if not runs:
        print(f"\n✅ No {args.status} runs found older than {args.days} days.")
        sys.exit(0)
    
    print(f"\n📊 Found {len(runs)} runs to delete:")
    print("-" * 70)
    for run in runs:
        date = run['created_at'].split('T')[0]
        print(f"  #{run['id']}: {run['name']} - {run['conclusion']} ({date})")
    
    print("-" * 70)
    
    # Confirm deletion
    if not args.dry_run and not args.force:
        confirm = input(f"\n⚠️  Delete {len(runs)} workflow runs? (yes/no): ").strip().lower()
        if confirm not in ['yes', 'y']:
            print("❌ Operation cancelled.")
            sys.exit(0)
    
    # Delete runs
    print(f"\n🗑️  Deleting runs...")
    deleted = 0
    failed = 0
    
    for run in runs:
        if delete_workflow_run(token, run['id'], run['name'], args.dry_run):
            deleted += 1
        else:
            failed += 1
    
    print("\n" + "=" * 70)
    print(f"✅ Cleanup complete!")
    print(f"   Deleted: {deleted}")
    print(f"   Failed: {failed}")
    if args.dry_run:
        print(f"   (DRY-RUN mode - nothing was actually deleted)")
    print("=" * 70)

if __name__ == "__main__":
    main()
