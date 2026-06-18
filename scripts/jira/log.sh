#!/usr/bin/env bash
set -e

# Log hours to ~/.apparatus/scripts/jira/hours.json
#
# Usage:
#   log.sh HOURS TAG [TAG...]           (today)
#   log.sh DATE HOURS TAG [TAG...]      (specific date, format: YYYY-MM-DD)
#
# HOURS: integer or decimal, optional trailing 'h' (e.g. 3, 3h, 2.5, 2.5h)
# Tags matching the pattern [A-Z]+-[0-9]+ automatically get the JIRA tag added.
#
# Examples:
#   log.sh 3h BT-4152
#   log.sh 1.5h meeting sprint-planning
#   log.sh 2026-05-05 2h PAYM-1125

LOG_FILE="${HOME}/.hours.json"

# Parse optional date argument
if [[ "${1:-}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  date="$1"
  shift
else
  date=$(date +%Y-%m-%d)
fi

if [[ $# -lt 2 ]]; then
  echo "Usage: log.sh [DATE] HOURS TAG [TAG...]" >&2
  exit 1
fi

# Parse hours (strip trailing h)
hours_raw="${1%h}"
if ! [[ "$hours_raw" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Invalid hours: $1" >&2
  exit 1
fi
hours=$(echo "$hours_raw" | awk '{printf "%g", $1}')
shift

# Collect tags, auto-adding JIRA if any tag is a Jira key
tags=("$@")
has_jira_key=false
for tag in "${tags[@]}"; do
  [[ "$tag" =~ ^[A-Z]+-[0-9]+$ ]] && has_jira_key=true && break
done
$has_jira_key && tags+=("JIRA")

# Initialise file if needed
[[ -f "$LOG_FILE" ]] || echo "[]" > "$LOG_FILE"

tags_json=$(printf '%s\n' "${tags[@]}" | jq -Rs 'split("\n") | map(select(length > 0))')

jq --arg date "$date" \
   --argjson hours "$hours" \
   --argjson tags "$tags_json" \
   '. += [{"date": $date, "hours": $hours, "tags": $tags}]' \
   "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"

printf "Logged %sh on %s: %s\n" "$hours" "$date" "${tags[*]}"
