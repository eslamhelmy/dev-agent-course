# PR Reviewer Skill

Schedule: 9 AM, 1 PM, 5 PM daily (weekdays)

## Input

Read before processing:
- `.claude/preferences.md` -- repos to monitor (look for GitHub repos list)
- `.claude/priority-map.md` -- priority rules for flagging

Configuration (add to preferences.md if not present):
- `github_repos`: list of owner/repo to monitor
- `pr_review_threshold_lines`: 500 (large PR threshold)
- `pr_review_stale_days`: 3 (stale PR threshold)

## Process

1. **Query Open PRs**
   For each configured repo:
   - Use: `gh pr list --repo {owner/repo} --state open --json number,title,author,createdAt,additions,deletions,changedFiles,headRefName,baseRefName,mergeable,reviewDecision,labels`
   - If `gh` is not available, note it and skip

2. **Analyze Each PR**
   For each open PR, evaluate:

   a. **Size Check**: additions + deletions > 500 --> flag HIGH
   b. **Security Check**: flag HIGH if changed files touch auth, env, secrets, config
   c. **Test Check**: code files changed but no test files --> flag MEDIUM
   d. **Staleness Check**: open > 3 days --> flag MEDIUM; open > 6 days --> flag HIGH
   e. **Conflict Check**: mergeable == "CONFLICTING" --> flag HIGH
   f. **Review Status**: no reviews --> flag LOW; changes requested --> note

3. **Prioritize**
   Sort PRs by HIGH flag count (descending), then MEDIUM, then age

4. **Generate Report**
   Format as a digest with sections: Needs Attention, Monitor, On Track, Summary

## Output

Write the digest to `.claude/reports/pr-review-[date].md`

## State Update

- Append to progress.txt: `[timestamp] -- PR review: {total} open PRs, {high_count} need attention, {ready_count} ready to merge`
- If any PR has been flagged HIGH for 3+ consecutive runs, add a P1 task to tasks-active.md
