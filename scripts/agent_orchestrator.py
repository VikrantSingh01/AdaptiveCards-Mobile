#!/usr/bin/env python3
"""
Agent Orchestrator for AdaptiveCards-Mobile
============================================
Manages Copilot and Claude AI coding agents on VikrantSingh01/AdaptiveCards-Mobile.

Commands:
  create-issue   Create a well-structured issue and assign to an agent
  list-issues    List open issues by agent assignment
  list-prs       List open PRs from agents
  check-pr       Check if a PR passes test requirements
  comment-pr     Post a comment on a PR
  enforce-tests  Verify agent PRs meet test requirements, comment if not
  batch-create   Create multiple issues from a YAML/JSON task file

Usage:
  python3 scripts/agent_orchestrator.py create-issue --agent copilot --title "Fix X" --body "..."
  python3 scripts/agent_orchestrator.py list-prs
  python3 scripts/agent_orchestrator.py enforce-tests --pr 39
  python3 scripts/agent_orchestrator.py batch-create --file scripts/agent_tasks.json
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import textwrap
from datetime import datetime
from pathlib import Path

# ──────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────

UPSTREAM_REPO = "VikrantSingh01/AdaptiveCards-Mobile"
FORK_REPO = "hggz/AdaptiveCards-Mobile-1"

# Agent identifiers — how GitHub recognizes each agent
AGENTS = {
    "copilot": {
        "assign": "copilot-swe-agent",       # GitHub app slug for assignment
        "mention": "@copilot",                # Mention in issue/PR comments
        "label": "copilot",                   # Label to tag issues
        "description": "GitHub Copilot SWE Agent",
    },
    "claude": {
        "assign": "claude",                   # GitHub user for assignment
        "mention": "@claude",                 # Mention in issue/PR comments
        "label": "claude",                    # Label to tag issues
        "description": "Claude Code Agent",
    },
}

# Test requirements that MUST pass for any agent PR
TEST_REQUIREMENTS = """
## Test Requirements (MANDATORY)

All changes **must** pass these tests before the PR can be merged:

### iOS Snapshot Tests
```bash
cd ios && xcodebuild test \\
  -scheme AdaptiveCards-Package \\
  -sdk iphonesimulator \\
  -destination 'platform=iOS Simulator,name=iPhone 16e' \\
  -only-testing:VisualTests/CardElementSnapshotTests \\
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```
**Expected**: 10/10 tests pass, all baselines match within tolerance.

### iOS Unit Tests
```bash
cd ios && swift test
```

### Android Unit Tests
```bash
cd android && ./gradlew test
```

### Critical Build Flags (iOS)
You **MUST** include these flags for Xcode 26 SPM test targets:
- `CODE_SIGN_IDENTITY=-`
- `CODE_SIGNING_REQUIRED=NO`
- `CODE_SIGNING_ALLOWED=NO`

Without these, the test bundle will fail with "bundle format unrecognized".

### Snapshot Rendering Rules
- Do NOT use `ScrollView` or `LazyVStack` in `PreParsedCardView` — they defeat `layer.render` snapshot capture
- Do NOT use `@StateObject` in snapshot views — SwiftUI lifecycle doesn't fire during `layer.render`
- Use `VStack` with synchronous `CardViewModel` property assignment
- `drawHierarchy` returns `false` in SPM XCTest — this is expected, `layer.render` fallback works

### Baseline Recording
If you modify rendering code, re-record baselines:
1. `touch ios/Tests/VisualTests/Snapshots/.record`
2. Run the snapshot tests (they'll record new baselines)
3. `rm ios/Tests/VisualTests/Snapshots/.record`
4. Run again to verify (compare mode)
5. Commit the updated `.png` baselines
"""

# ──────────────────────────────────────────────────────────────
# GitHub API helpers (via gh CLI)
# ──────────────────────────────────────────────────────────────

def gh(args: list[str], input_data: str | None = None) -> dict | list | str:
    """Run a gh CLI command and return parsed JSON or raw output."""
    cmd = ["gh"] + args
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            input=input_data,
            timeout=30,
        )
        if result.returncode != 0:
            print(f"  ✗ gh error: {result.stderr.strip()}", file=sys.stderr)
            return {}
        output = result.stdout.strip()
        if not output:
            return {}
        try:
            return json.loads(output)
        except json.JSONDecodeError:
            return output
    except subprocess.TimeoutExpired:
        print("  ✗ gh command timed out", file=sys.stderr)
        return {}


def gh_raw(args: list[str], input_data: str | None = None) -> str:
    """Run gh and return raw string output."""
    cmd = ["gh"] + args
    result = subprocess.run(cmd, capture_output=True, text=True, input=input_data, timeout=30)
    return result.stdout.strip()


def ensure_label(repo: str, label: str, color: str = "0366d6"):
    """Create a label if it doesn't exist."""
    existing = gh(["api", f"repos/{repo}/labels/{label}", "--jq", ".name"])
    if not existing:
        gh(["api", f"repos/{repo}/labels", "-X", "POST",
            "-f", f"name={label}", "-f", f"color={color}",
            "-f", f"description=Assigned to {label} agent"])


# ──────────────────────────────────────────────────────────────
# Commands
# ──────────────────────────────────────────────────────────────

def cmd_create_issue(args):
    """Create a GitHub issue with test requirements and assign to an agent."""
    agent = AGENTS[args.agent]
    repo = args.repo or UPSTREAM_REPO

    # Build issue body
    body_parts = []

    if args.body:
        body_parts.append(args.body)
    elif args.body_file:
        body_parts.append(Path(args.body_file).read_text())

    # Add platform scope
    if args.platform:
        body_parts.append(f"\n## Platform Scope\n- **Target**: {args.platform}")

    # Add acceptance criteria
    if args.acceptance:
        criteria = "\n".join(f"- [ ] {c}" for c in args.acceptance)
        body_parts.append(f"\n## Acceptance Criteria\n{criteria}")

    # Always append test requirements
    body_parts.append(TEST_REQUIREMENTS)

    # Add agent mention to trigger it
    body_parts.append(f"\n---\n{agent['mention']} Please implement this.")

    full_body = "\n".join(body_parts)

    # Build labels (deduplicated)
    labels = [agent["label"]]
    if args.platform:
        labels.append(args.platform.lower())
    if args.labels:
        labels.extend(args.labels)
    labels = list(dict.fromkeys(labels))  # Deduplicate preserving order

    print(f"Creating issue on {repo}...")
    print(f"  Title: {args.title}")
    print(f"  Agent: {agent['description']}")
    print(f"  Labels: {', '.join(labels)}")

    if args.dry_run:
        print("\n[DRY RUN] Would create issue with body:")
        print(full_body[:500] + "..." if len(full_body) > 500 else full_body)
        return

    # Ensure labels exist
    for label in labels:
        ensure_label(repo, label)

    # Create issue via gh CLI
    label_args = []
    for l in labels:
        label_args.extend(["-l", l])

    result = gh_raw(
        ["issue", "create", "-R", repo,
         "--title", args.title,
         "--body", full_body] + label_args
    )

    if result and "github.com" in result:
        print(f"  ✓ Created: {result}")
        # Extract issue number
        issue_num = result.rstrip("/").split("/")[-1]
        print(f"  Issue #{issue_num} assigned to {agent['description']}")
    else:
        print(f"  ✗ Failed to create issue: {result}")


def cmd_list_issues(args):
    """List open issues, optionally filtered by agent."""
    repo = args.repo or UPSTREAM_REPO
    label_filter = ""
    if args.agent:
        label_filter = AGENTS[args.agent]["label"]

    api_url = f"repos/{repo}/issues?state=open&per_page=50"
    if label_filter:
        api_url += f"&labels={label_filter}"

    issues = gh(["api", api_url])
    if not issues:
        print("No open issues found.")
        return

    print(f"\nOpen issues on {repo}:")
    print(f"{'#':<6} {'Labels':<20} {'Title'}")
    print("-" * 70)
    for issue in issues:
        if issue.get("pull_request"):
            continue  # Skip PRs
        labels = ", ".join(l["name"] for l in issue.get("labels", []))
        print(f"#{issue['number']:<5} {labels:<20} {issue['title'][:50]}")


def cmd_list_prs(args):
    """List open PRs, showing which are from agents."""
    repo = args.repo or UPSTREAM_REPO
    prs = gh(["api", f"repos/{repo}/pulls?state=open&per_page=50"])
    if not prs:
        print("No open PRs found.")
        return

    print(f"\nOpen PRs on {repo}:")
    print(f"{'#':<6} {'Author':<20} {'Branch':<40} {'Title'}")
    print("-" * 100)
    for pr in prs:
        author = pr["user"]["login"]
        # Highlight agent PRs
        marker = ""
        if author in ("copilot-swe-agent", "copilot[bot]", "github-copilot[bot]"):
            marker = " 🤖"
        elif author == "claude":
            marker = " 🧠"
        branch = pr["head"]["ref"][:38]
        print(f"#{pr['number']:<5} {author + marker:<20} {branch:<40} {pr['title'][:40]}")


def cmd_check_pr(args):
    """Check a PR's test/CI status and report."""
    repo = args.repo or UPSTREAM_REPO
    pr_num = args.pr

    # Get PR details
    pr = gh(["api", f"repos/{repo}/pulls/{pr_num}"])
    if not pr:
        print(f"PR #{pr_num} not found.")
        return

    print(f"\nPR #{pr_num}: {pr['title']}")
    print(f"  Author: {pr['user']['login']}")
    print(f"  Branch: {pr['head']['ref']}")
    print(f"  State:  {pr['state']} {'(draft)' if pr.get('draft') else ''}")
    print(f"  Merge:  {'mergeable' if pr.get('mergeable') else 'not mergeable / unknown'}")

    # Get check runs
    sha = pr["head"]["sha"]
    checks = gh(["api", f"repos/{repo}/commits/{sha}/check-runs", "--jq", ".check_runs"])
    if checks:
        print(f"\n  CI Status ({len(checks)} checks):")
        for check in checks:
            status = check.get("conclusion") or check.get("status", "pending")
            icon = {"success": "✓", "failure": "✗", "pending": "⏳", "in_progress": "⏳"}.get(status, "?")
            print(f"    {icon} {check['name']}: {status}")
    else:
        print("\n  No CI checks found.")

    # Get commit statuses
    statuses = gh(["api", f"repos/{repo}/commits/{sha}/status", "--jq", ".statuses"])
    if statuses:
        print(f"\n  Commit Statuses:")
        for s in statuses:
            icon = {"success": "✓", "failure": "✗", "pending": "⏳"}.get(s["state"], "?")
            print(f"    {icon} {s['context']}: {s['state']}")

    # Check for test-related comments
    comments = gh(["api", f"repos/{repo}/issues/{pr_num}/comments", "--jq",
                    '[.[] | select(.body | test("test|pass|fail|snapshot"; "i")) | {user: .user.login, body: .body[:100]}]'])
    if comments:
        print(f"\n  Test-related comments:")
        for c in comments:
            print(f"    @{c['user']}: {c['body'][:80]}...")


def cmd_comment_pr(args):
    """Post a comment on a PR."""
    repo = args.repo or UPSTREAM_REPO
    pr_num = args.pr

    if args.body:
        body = args.body
    elif args.enforce:
        body = _build_enforcement_comment(repo, pr_num)
    else:
        print("Must provide --body or --enforce")
        return

    if args.dry_run:
        print(f"[DRY RUN] Would comment on PR #{pr_num}:")
        print(body[:300])
        return

    result = gh(["api", f"repos/{repo}/issues/{pr_num}/comments",
                  "-X", "POST", "-f", f"body={body}"])
    if result and result.get("id"):
        print(f"  ✓ Comment posted on PR #{pr_num}")
    else:
        print(f"  ✗ Failed to comment")


def _build_enforcement_comment(repo: str, pr_num: int) -> str:
    """Build a test enforcement comment for an agent PR."""
    return textwrap.dedent(f"""\
    ## ⚠️ Test Requirements Not Met

    This PR must pass the following tests before it can be merged:

    ### iOS Snapshot Tests (Required)
    ```bash
    cd ios && xcodebuild test \\
      -scheme AdaptiveCards-Package \\
      -sdk iphonesimulator \\
      -destination 'platform=iOS Simulator,name=iPhone 16e' \\
      -only-testing:VisualTests/CardElementSnapshotTests \\
      CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
    ```
    All 10 tests must pass. If you changed rendering code, re-record baselines first.

    ### iOS Unit Tests (Required)
    ```bash
    cd ios && swift test
    ```

    ### Android Unit Tests (Required)
    ```bash
    cd android && ./gradlew test
    ```

    ### Key Constraints
    - **Do NOT use ScrollView/LazyVStack** in PreParsedCardView (breaks snapshot capture)
    - **Do NOT use @StateObject** in snapshot views (SwiftUI lifecycle unavailable)
    - **MUST include CodeSign flags** for Xcode 26: `CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`

    Please fix and push again. I'll re-check when you update.
    """)


def cmd_enforce_tests(args):
    """Check agent PRs and post enforcement comments if tests aren't passing."""
    repo = args.repo or UPSTREAM_REPO

    if args.pr:
        prs_to_check = [args.pr]
    else:
        # Find all open agent PRs
        all_prs = gh(["api", f"repos/{repo}/pulls?state=open&per_page=50"])
        if not all_prs:
            print("No open PRs found.")
            return
        agent_authors = {"copilot-swe-agent", "copilot[bot]", "github-copilot[bot]", "claude"}
        prs_to_check = [
            pr["number"] for pr in all_prs
            if pr["user"]["login"] in agent_authors
        ]
        if not prs_to_check:
            print("No agent PRs found.")
            return

    for pr_num in prs_to_check:
        pr = gh(["api", f"repos/{repo}/pulls/{pr_num}"])
        if not pr:
            continue

        sha = pr["head"]["sha"]
        checks = gh(["api", f"repos/{repo}/commits/{sha}/check-runs", "--jq", ".check_runs"])

        has_failure = False
        has_pending = False
        all_pass = True

        if checks:
            for check in checks:
                conclusion = check.get("conclusion")
                if conclusion == "failure":
                    has_failure = True
                    all_pass = False
                elif conclusion is None:
                    has_pending = True
                    all_pass = False
        else:
            all_pass = False
            has_pending = True

        author = pr["user"]["login"]
        print(f"PR #{pr_num} by @{author}: ", end="")

        if all_pass:
            print("✓ All checks passing")
        elif has_failure:
            print("✗ FAILING — posting enforcement comment")
            if not args.dry_run:
                comment = _build_enforcement_comment(repo, pr_num)
                gh(["api", f"repos/{repo}/issues/{pr_num}/comments",
                    "-X", "POST", "-f", f"body={comment}"])
            else:
                print("  [DRY RUN] Would post enforcement comment")
        elif has_pending:
            print("⏳ Checks still running")
        else:
            print("? Unknown status")


def cmd_batch_create(args):
    """Create multiple issues from a JSON task file."""
    task_file = Path(args.file)
    if not task_file.exists():
        print(f"Task file not found: {args.file}")
        return

    tasks = json.loads(task_file.read_text())
    if not isinstance(tasks, list):
        tasks = tasks.get("tasks", [])

    print(f"Creating {len(tasks)} issues...")
    for i, task in enumerate(tasks, 1):
        print(f"\n[{i}/{len(tasks)}] {task['title']}")
        # Build args namespace
        ns = argparse.Namespace(
            agent=task.get("agent", "copilot"),
            title=task["title"],
            body=task.get("body", ""),
            body_file=None,
            platform=task.get("platform"),
            acceptance=task.get("acceptance", []),
            labels=task.get("labels", []),
            repo=args.repo,
            dry_run=args.dry_run,
        )
        cmd_create_issue(ns)


def cmd_status(args):
    """Show overall status: open issues, agent PRs, CI health."""
    repo = args.repo or UPSTREAM_REPO
    print(f"=== Agent Orchestrator Status for {repo} ===\n")

    # Issues
    issues = gh(["api", f"repos/{repo}/issues?state=open&per_page=100"])
    issue_count = sum(1 for i in (issues or []) if not i.get("pull_request"))

    copilot_issues = sum(1 for i in (issues or [])
                         if not i.get("pull_request")
                         and any(l["name"] == "copilot" for l in i.get("labels", [])))
    claude_issues = sum(1 for i in (issues or [])
                        if not i.get("pull_request")
                        and any(l["name"] == "claude" for l in i.get("labels", [])))

    print(f"Open Issues: {issue_count} total")
    print(f"  🤖 Copilot: {copilot_issues}")
    print(f"  🧠 Claude:  {claude_issues}")

    # PRs
    prs = gh(["api", f"repos/{repo}/pulls?state=open&per_page=50"])
    if prs:
        agent_prs = [pr for pr in prs if pr["user"]["login"] in
                     {"copilot-swe-agent", "copilot[bot]", "github-copilot[bot]", "claude", "hggz"}]
        print(f"\nOpen PRs: {len(prs)} total ({len(agent_prs)} from agents/us)")
        for pr in prs:
            sha = pr["head"]["sha"]
            checks = gh(["api", f"repos/{repo}/commits/{sha}/check-runs",
                         "--jq", "[.check_runs[].conclusion]"])
            if checks:
                if all(c == "success" for c in checks if c):
                    ci = "✓ passing"
                elif any(c == "failure" for c in checks):
                    ci = "✗ failing"
                else:
                    ci = "⏳ pending"
            else:
                ci = "— no checks"
            draft = " (draft)" if pr.get("draft") else ""
            print(f"  #{pr['number']} [{ci}] {pr['user']['login']}: {pr['title'][:50]}{draft}")
    else:
        print("\nNo open PRs.")

    print(f"\nTimestamp: {datetime.now().isoformat()}")


# ──────────────────────────────────────────────────────────────
# CLI argument parser
# ──────────────────────────────────────────────────────────────

def build_parser():
    parser = argparse.ArgumentParser(
        description="Agent Orchestrator — manage Copilot & Claude agents on AdaptiveCards-Mobile",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
        Examples:
          # Create an issue for Copilot
          %(prog)s create-issue --agent copilot \\
            --title "Fix ColumnSet rendering in snapshots" \\
            --body "ColumnSet baselines are empty white..." \\
            --platform ios \\
            --acceptance "ColumnSet baselines show visible columns" "All 10 snapshot tests pass"

          # Create an issue for Claude
          %(prog)s create-issue --agent claude \\
            --title "Add CODE_SIGNING_ALLOWED=NO to CI" \\
            --body "The visual-regression.yml workflow needs CodeSign flags" \\
            --platform ci

          # Show status dashboard
          %(prog)s status

          # Enforce test requirements on all agent PRs
          %(prog)s enforce-tests

          # Batch-create issues from task file
          %(prog)s batch-create --file scripts/agent_tasks.json
        """)
    )
    parser.add_argument("--repo", default=None,
                        help=f"Target repo (default: {UPSTREAM_REPO})")
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview actions without executing")

    sub = parser.add_subparsers(dest="command", required=True)

    # create-issue
    ci = sub.add_parser("create-issue", help="Create issue and assign to agent")
    ci.add_argument("--agent", required=True, choices=AGENTS.keys(),
                    help="Agent to assign")
    ci.add_argument("--title", required=True, help="Issue title")
    ci.add_argument("--body", help="Issue body text")
    ci.add_argument("--body-file", help="File containing issue body")
    ci.add_argument("--platform", choices=["ios", "android", "shared", "ci"],
                    help="Target platform")
    ci.add_argument("--acceptance", nargs="+", help="Acceptance criteria items")
    ci.add_argument("--labels", nargs="+", help="Additional labels")

    # list-issues
    li = sub.add_parser("list-issues", help="List open issues")
    li.add_argument("--agent", choices=AGENTS.keys(), help="Filter by agent")

    # list-prs
    sub.add_parser("list-prs", help="List open PRs")

    # check-pr
    cp = sub.add_parser("check-pr", help="Check PR test status")
    cp.add_argument("--pr", required=True, type=int, help="PR number")

    # comment-pr
    cpr = sub.add_parser("comment-pr", help="Comment on a PR")
    cpr.add_argument("--pr", required=True, type=int, help="PR number")
    cpr.add_argument("--body", help="Comment text")
    cpr.add_argument("--enforce", action="store_true",
                     help="Post test enforcement comment")

    # enforce-tests
    et = sub.add_parser("enforce-tests", help="Enforce tests on agent PRs")
    et.add_argument("--pr", type=int, help="Specific PR (default: all agent PRs)")

    # batch-create
    bc = sub.add_parser("batch-create", help="Create issues from task file")
    bc.add_argument("--file", required=True, help="JSON task file path")

    # status
    sub.add_parser("status", help="Dashboard: issues, PRs, CI health")

    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()

    commands = {
        "create-issue": cmd_create_issue,
        "list-issues": cmd_list_issues,
        "list-prs": cmd_list_prs,
        "check-pr": cmd_check_pr,
        "comment-pr": cmd_comment_pr,
        "enforce-tests": cmd_enforce_tests,
        "batch-create": cmd_batch_create,
        "status": cmd_status,
    }

    cmd_func = commands.get(args.command)
    if cmd_func:
        cmd_func(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
