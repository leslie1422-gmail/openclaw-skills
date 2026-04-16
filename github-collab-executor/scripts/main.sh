#!/usr/bin/env bash
#===========================================================
# github-collab-executor - Main entry point
# Fully self-contained Python implementation
#===========================================================

set -euo pipefail

SKILL_NAME="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
LOG_FILE="${HOME}/.openclaw/logs/${SKILL_NAME}.log"
REPORT_FILE="${HOME}/.openclaw/logs/github-collab-report.json"
mkdir -p "$(dirname "$LOG_FILE")"

# Load GH_TOKEN
if [[ -f "${HOME}/.hermes/.env" ]]; then
  set -a
  source "${HOME}/.hermes/.env"
  set +a
fi

GH_TOKEN="${GH_TOKEN:-}"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

#===============================================================
# All logic in Python (avoids bash variable escaping issues)
#===============================================================
python3 << 'PYEOF'
import json, urllib.request, os, sys
from datetime import datetime

LOG_FILE = os.path.expanduser("~/.openclaw/logs/github-collab-executor.log")
REPORT_FILE = os.path.expanduser("~/.openclaw/logs/github-collab-report.json")

# Load token
GH_TOKEN = os.environ.get("GH_TOKEN", "")
if not GH_TOKEN:
    print(json.dumps({"status": "error", "message": "GH_TOKEN not set"}))
    sys.exit(1)

API = "https://api.github.com"
headers = {
    "Authorization": f"token {GH_TOKEN}",
    "Accept": "application/vnd.github+json"
}

def gh_get(path):
    req = urllib.request.Request(f"{API}{path}", headers=headers)
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read())

def gh_get_or_empty(path):
    try:
        return gh_get(path)
    except:
        return []

log = lambda msg: print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}") or \
    open(LOG_FILE, "a").write(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")

log("Starting github-collab-executor")

# Phase 1: Get repos
repos = gh_get("/user/repos?per_page=100&sort=updated")
repo_count = len(repos)
log(f"Found {repo_count} repositories")

# Phase 2: Scan each repo
all_repos = []
total_issues = 0
total_prs = 0
total_workflows = 0

for repo in repos:
    full_name = repo["full_name"]
    log(f"  Scanning {full_name}...")

    # Open issues (exclude PRs)
    issues = gh_get_or_empty(f"/repos/{full_name}/issues?state=open&per_page=50")
    open_issues = sum(1 for i in issues if "pull_request" not in i)

    # Open PRs
    prs = gh_get_or_empty(f"/repos/{full_name}/pulls?state=open&per_page=50")
    open_prs = len(prs)

    # Workflows
    wf_data = gh_get_or_empty(f"/repos/{full_name}/actions/workflows")
    workflows = wf_data.get("total_count", 0) if isinstance(wf_data, dict) else 0

    total_issues += open_issues
    total_prs += open_prs
    total_workflows += workflows

    all_repos.append({
        "name": repo["name"],
        "full_name": full_name,
        "private": repo["private"],
        "language": repo.get("language") or "-",
        "updated_at": repo["updated_at"][:10],
        "open_issues": open_issues,
        "open_prs": open_prs,
        "workflows": workflows,
        "url": repo["html_url"]
    })

# Build report
report = {
    "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    "repos_scanned": repo_count,
    "total_issues": total_issues,
    "total_prs": total_prs,
    "total_workflows": total_workflows,
    "repos": all_repos
}

# Save report
with open(REPORT_FILE, "w") as f:
    json.dump(report, f, ensure_ascii=False, indent=2)

# Print table
print()
print(f"{'Repo':<45} {'Issues':>7} {'PRs':>4} {'CI':>4} {'Updated'}")
print("-" * 75)
for r in all_repos:
    icon = "🔒" if r["private"] else "🌐"
    print(f"{icon} {r['full_name']:<43} {r['open_issues']:>7} {r['open_prs']:>4} {r['workflows']:>4} {r['updated_at']}")
print(f"{'Total':<45} {total_issues:>7} {total_prs:>4} {total_workflows:>4}")
print()
print(f"Report: {REPORT_FILE}")
print()
print(json.dumps({
    "status": "success",
    "repos_scanned": repo_count,
    "total_issues": total_issues,
    "total_prs": total_prs
}))
log(f"Done. {total_issues} issues, {total_prs} PRs across {repo_count} repos")
PYEOF
