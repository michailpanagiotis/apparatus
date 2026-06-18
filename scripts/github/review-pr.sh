#!/usr/bin/env bash
set -e

SECONDS=0

# Fetch a pull request and prepare a dedicated git worktree for reviewing it.
#
# Usage:
#   review-pr.sh [-a|--approve] <pr-number|pr-url>
#
# With -a/--approve, prompt to approve the PR when the agent recommends it.
# The worktree is created under ~/Projects/reviews, named
# "<repo>-pr-<number>". Override the location with REVIEW_WORKTREE_DIR.

prompt_approve=0
pr_arg=""
for arg in "$@"; do
  case "$arg" in
    -a|--approve) prompt_approve=1 ;;
    *) pr_arg="$arg" ;;
  esac
done

if [[ -z "$pr_arg" ]]; then
  echo "Usage: review-pr.sh [-a|--approve] <pr-number|pr-url>" >&2
  exit 1
fi

# Accept either a bare number or a full PR URL.
pr_number=$(echo "$pr_arg" | grep -oE '[0-9]+' | tail -1)
if [[ -z "$pr_number" ]]; then
  echo "Could not parse a PR number from '$1'" >&2
  exit 1
fi

# Must be run from inside the repository.
if ! repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "Not inside a git repository; run this from the project directory." >&2
  exit 1
fi
repo_name=$(basename "$repo_root")

# Look up the PR's head branch (works for same-repo PRs; the pull/<n>/head
# ref below is what we actually check out, so this is just for a nice name).
head_ref=$(hub api -X GET "/repos/TalentDeskApp/talentdesk.io/pulls/${pr_number}" | jq -r '.head.ref')
if [[ -z "$head_ref" || "$head_ref" == "null" ]]; then
  echo "Could not find PR #${pr_number}" >&2
  exit 1
fi

reviews_dir="${HOME}/Projects/reviews"
worktree_dir="${REVIEW_WORKTREE_DIR:-${reviews_dir}/${repo_name}-pr-${pr_number}}"
local_branch="pr-${pr_number}"

mkdir -p "$(dirname "$worktree_dir")"

# Fetch the PR head into FETCH_HEAD only (pull/<n>/head also covers forks).
# We deliberately do NOT fetch straight into refs/heads/pr-<n>: on a rerun that
# branch is already checked out in the worktree, and git refuses to update a
# checked-out branch. Instead we move the branch ourselves below.
echo "Fetching PR #${pr_number} (${head_ref})..."
git -C "$repo_root" fetch origin "pull/${pr_number}/head" --force
pr_sha=$(git -C "$repo_root" rev-parse FETCH_HEAD)

# (Re)create the worktree at the fetched commit.
abs_worktree="$(cd "$(dirname "$worktree_dir")" && pwd)/$(basename "$worktree_dir")"
if git -C "$repo_root" worktree list --porcelain | grep -qx "worktree $abs_worktree"; then
  echo "Worktree already exists, updating it..."
  git -C "$worktree_dir" reset --hard "$pr_sha"
else
  git -C "$repo_root" branch -f "$local_branch" "$pr_sha"
  git -C "$repo_root" worktree add "$worktree_dir" "$local_branch"
fi

worktree_dir=$(cd "$worktree_dir" && pwd)

# Produce the PR diff for the agent. The agent itself has no shell access
# (see below), so the script is what runs git; the agent only reads files.
git -C "$repo_root" fetch origin master --quiet || true
review_dir="${worktree_dir}/pr-review"
mkdir -p "$review_dir"
git -C "$worktree_dir" diff "origin/master...${local_branch}" > "${review_dir}/diff.patch"
git -C "$worktree_dir" diff --name-only "origin/master...${local_branch}" > "${review_dir}/changed-files.txt"

echo
echo "PR #${pr_number} (${head_ref}) ready for review:"
echo "  cd ${worktree_dir}"

if [[ -n "$REVIEW_NO_AGENT" ]]; then
  echo "  (skipping agent review; REVIEW_NO_AGENT is set)"
  exit 0
fi

# Launch a locked-down agent to review the PR and write notes.
#
# Lock-down:
#   - cwd is the worktree, so file access is confined to the PR files
#     (it cannot read ~/.ssh, ~/.aws, env-secret files, etc.).
#   - allowed tools are read/search/write only; with no Bash tool the agent
#     physically cannot run git, gh, or read environment secrets via a shell.
#   - WebFetch/WebSearch are denied, so it cannot exfiltrate or call out.
# Invoke the code-review skill. The diff is also supplied as a file
# (pr-review/diff.patch); the agent may additionally inspect history with a
# narrow set of read-only git commands (see --allowedTools below).
prompt="/code-review Review GitHub pull request #${pr_number} (branch \"${head_ref}\").
The complete diff is in pr-review/diff.patch and the changed files are listed in
pr-review/changed-files.txt. Read the affected files in this worktree for context,
then review for correctness, bugs, security issues, edge cases, and clarity.

Write your review as Markdown to pr-review/notes.md.

Then write a verdict to pr-review/verdict.json as a JSON object with exactly two
keys: \"approve\" (boolean — true only if the PR is correct and safe to merge
with no blocking issues) and \"message\" (a one-or-two sentence approval comment
suitable to post on the PR). Example: {\"approve\": true, \"message\": \"LGTM.\"}

Do NOT modify any source files, do NOT run any git command that changes state,
do NOT interact with GitHub, and do NOT access anything outside this directory."

echo
echo "Launching review agent..."
echo
stream_file=$(mktemp)
trap 'rm -f "$stream_file"' EXIT

# Stream events live, rendering assistant text and tool calls as they arrive,
# while teeing the raw JSONL to a file so we can read the final result object.
(
  cd "$worktree_dir"
  claude -p "$prompt" \
    --model opus \
    --effort max \
    --output-format stream-json \
    --verbose \
    --add-dir "$review_dir" \
    --allowedTools "Read,Grep,Glob,Write,Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git status:*),Bash(git rev-parse:*),Bash(git merge-base:*),Bash(git branch:*),Bash(git ls-files:*)" \
    --disallowedTools "WebFetch,WebSearch" \
    --append-system-prompt "You are a read-only code reviewer. You may run only read-only git inspection commands (diff, log, show, status, rev-parse, merge-base, branch, ls-files). Never run git commands that change state (no commit, push, checkout, reset, add, fetch, rebase, merge), never interact with GitHub or the gh CLI, never use credentials or secret keys, and never access files outside the current worktree. Your only output side effect is writing the review notes file."
) | tee "$stream_file" | while IFS= read -r line; do
  [[ "$(echo "$line" | jq -r '.type // empty')" == "assistant" ]] || continue
  echo "$line" | jq -r '
    .message.content[]?
    | if .type == "text" then .text
      elif .type == "tool_use" then "  → " + .name + "(" + ((.input.file_path // .input.command // .input.pattern // "") | tostring) + ")"
      else empty end'
done

result_json=$(jq -c 'select(.type == "result")' "$stream_file" | tail -1)

echo
echo "Review notes written to:"
echo "  ${review_dir}/notes.md"

# Summary: wall-clock time for the whole script, and token/cost usage reported
# by the agent.
echo
echo "----------------------------------------"
printf 'Time spent:   %dm %02ds\n' "$((SECONDS / 60))" "$((SECONDS % 60))"
echo "$result_json" | jq -r '
  .usage as $u
  | ($u.input_tokens // 0) as $in
  | ($u.output_tokens // 0) as $out
  | (($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0)) as $cache
  | "Tokens spent: \($in + $out + $cache) (in: \($in), out: \($out), cache: \($cache))",
    "Cost:         $\(.total_cost_usd // 0)"
'
echo "----------------------------------------"

# If the agent recommends approval, prompt before approving for real
# (only when -a/--approve was passed).
verdict_file="${review_dir}/verdict.json"
if [[ "$prompt_approve" == "1" ]] && [[ -f "$verdict_file" ]] && [[ "$(jq -r '.approve // false' "$verdict_file" 2>/dev/null)" == "true" ]]; then
  approve_message=$(jq -r '.message // empty' "$verdict_file")
  echo
  echo "The agent recommends APPROVING PR #${pr_number}:"
  echo "  \"${approve_message}\""
  read -r -p "Approve this PR now? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "${script_dir}/approve-pr.sh" "$pr_number" "$approve_message"
  else
    echo "Not approved."
  fi
fi
