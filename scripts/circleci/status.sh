#!/usr/bin/env bash
set -e

echo 'CircleCI'
echo '  My pipelines:'

response=$(curl -s -H "Circle-Token: ${CIRCLECI_TOKEN}" \
  "https://circleci.com/api/v1.1/recent-builds?limit=30")

# Check if response is an error
if echo "$response" | jq -e '.message' > /dev/null 2>&1; then
  echo "	Error: $(echo "$response" | jq -r '.message')"
  exit 0
fi

echo "$response" | \
  jq -r '.[] | select(.user.login == "michailpanagiotis" and .workflows != null) | "\(.workflows.workflow_id)\t\(.build_url | sub("/[0-9]+$"; ""))/workflows/\(.workflows.workflow_id)\t\(.branch // "unknown")\t\(.status // "unknown")"' | \
  sort -u -t$'\t' -k1,1 | head -10 | cut -f2- | \
  while IFS=$'\t' read -r url branch status; do
    printf '\t%s (%s) [%s]\n' "$url" "$branch" "$status"
  done
