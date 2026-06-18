#!/usr/bin/env bash
set -e

echo 'CircleCI'
echo '  My pipelines:'

# Get recent builds and filter by user
response=$(curl -s -H "Circle-Token: ${CIRCLECI_TOKEN}" \
  "https://circleci.com/api/v1.1/recent-builds?limit=100")

# Check if response is an error
if echo "$response" | jq -e '.message' > /dev/null 2>&1; then
  echo "	Error: $(echo "$response" | jq -r '.message')"
  exit 0
fi

echo "$response" | \
  jq -r '.[] | select(.user.login == "michailpanagiotis") | select(.workflows != null) | "\(.workflows.workflow_id)\t\(.build_url)\t\(.branch // "unknown")\t\(.status // "unknown")"' | \
  sort -u -t$'\t' -k1,1 | head -10 | cut -f2- | \
  while IFS=$'\t' read -r url branch status; do
    printf '\t%s (%s) [%s]\n' "$url" "$branch" "$status"
  done

# Check QA branches on staging2
qa_commits_file="/tmp/qa_commits"
if [[ -f "$qa_commits_file" ]] && [[ -s "$qa_commits_file" ]]; then
  echo '  QA on staging2:'

  # Get recent staging2 build commits (separate request for staging2 branch)
  staging2_response=$(curl -s -H "Circle-Token: ${CIRCLECI_TOKEN}" \
    "https://circleci.com/api/v1.1/project/github/TalentDeskApp/talentdesk.io/tree/staging2?limit=10&filter=successful")

  staging2_commits=""
  if ! echo "$staging2_response" | jq -e '.message' > /dev/null 2>&1; then
    staging2_commits=$(echo "$staging2_response" | jq -r '.[].vcs_revision' 2>/dev/null | head -5)
  fi

  if [[ -z "$staging2_commits" ]]; then
    echo "	No recent staging2 builds found"
  else
    while IFS=$'\t' read -r qa_commit qa_branch; do
      built="no"
      for s2_commit in $staging2_commits; do
        if git merge-base --is-ancestor "$qa_commit" "$s2_commit" 2>/dev/null; then
          built="yes"
          break
        fi
      done
      if [[ "$built" == "yes" ]]; then
        printf '\t%s ✓\n' "$qa_branch"
      else
        printf '\t%s ✗\n' "$qa_branch"
      fi
    done < "$qa_commits_file"
  fi
fi
