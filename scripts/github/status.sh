#!/usr/bin/env bash
set -e

# Start fetching master and staging2 early (in background)
(
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$current_branch" == "master" ]]; then
    git pull --quiet
    git fetch origin staging2:staging2 --quiet
  elif [[ "$current_branch" == "staging2" ]]; then
    git fetch origin master:master --quiet
    git pull --quiet
  else
    git fetch origin master:master --quiet
    git fetch origin staging2:staging2 --quiet
  fi
) &
git_fetch_pid=$!

# Function to print PR URL and its HEAD branch name (parallel, ordered)
print_pr_with_branch() {
  local urls=()
  while read -r url; do
    [[ -n "$url" ]] && urls+=("$url")
  done

  [[ ${#urls[@]} -eq 0 ]] && return

  local tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" RETURN

  for i in "${!urls[@]}"; do
    (
      url="${urls[$i]}"
      pr_number=$(echo "$url" | grep -oE '[0-9]+$')
      branch=$(hub api -X GET "/repos/TalentDeskApp/talentdesk.io/pulls/${pr_number}" | jq -r '.head.ref')
      printf '\t%s (%s)\n' "$url" "$branch" > "$tmpdir/$i"
    ) &
  done
  wait

  for i in "${!urls[@]}"; do
    cat "$tmpdir/$i"
  done
}

echo 'Github'
echo '  Requested:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:GeorgeLinardis author:willbell71 user-review-requested:@me' | jq -r '.items[].html_url' | print_pr_with_branch

echo '  Pending:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:required' | jq -r '.items[].html_url' | print_pr_with_branch

echo '  Denied:'
hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:changes_requested' | jq -r '.items[].html_url' | print_pr_with_branch

# Wait for early git fetches to complete before QA check
wait $git_fetch_pid 2>/dev/null || true

# Run Approved and QA checks in parallel
tmp_approved=$(mktemp)
tmp_qa=$(mktemp)
trap "rm -f '$tmp_approved' '$tmp_qa'" EXIT

# Approved check in background
(
  urls=$(hub api -X GET search/issues -f q='repo:TalentDeskApp/talentdesk.io updated:>2025-01-01 is:pr is:open author:michailpanagiotis review:approved' | jq -r '.items[].html_url')
  tmpdir=$(mktemp -d)
  i=0
  for url in $urls; do
    (
      pr_number=$(echo "$url" | grep -oE '[0-9]+$')
      branch=$(hub api -X GET "/repos/TalentDeskApp/talentdesk.io/pulls/${pr_number}" | jq -r '.head.ref')
      printf '%s\t%s\n' "$branch" "$url" > "$tmpdir/$i"
    ) &
    ((i++)) || true
  done
  wait
  for f in "$tmpdir"/*; do
    [[ -f "$f" ]] && cat "$f"
  done > "$tmp_approved"
  rm -rf "$tmpdir"
) &

# QA check in background
(
  tmp_staging2=$(mktemp)
  tmp_master=$(mktemp)
  git branch -r --merged staging2 | grep -iE 'pmichail|michailpanagiotis' | sed 's/^ *//' | sort > "$tmp_staging2" &
  git branch -r --merged master | sed 's/^ *//' | sort > "$tmp_master" &
  wait
  comm -23 "$tmp_staging2" "$tmp_master" | sed 's/^origin\///' > "$tmp_qa"
  rm -f "$tmp_staging2" "$tmp_master"
) &

wait

# Print Approved, marking ones in QA
echo '  Approved:'
while IFS=$'\t' read -r branch url; do
  if grep -qx "$branch" "$tmp_qa" 2>/dev/null; then
    printf '\t%s (%s) [QA]\n' "$url" "$branch"
  else
    printf '\t%s (%s)\n' "$url" "$branch"
  fi
done < "$tmp_approved"

# Print QA branches not in Approved
echo '  QA:'
while read -r branch; do
  if ! grep -q "^$branch"$'\t' "$tmp_approved" 2>/dev/null; then
    printf '\t%s\n' "$branch"
  fi
done < "$tmp_qa"
