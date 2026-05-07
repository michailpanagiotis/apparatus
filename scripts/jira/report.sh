#!/usr/bin/env bash
set -e

# Usage:
#   report.sh [week|month|N|Nm|START:END]  (default: week)
#
# Ticket list comes from the sync cache (sync.sh).
# Hours come from ~/.hours.json (log.sh).

CACHE_FILE="${HOME}/.jira-tickets.json"
LOG_FILE="${HOME}/.hours.json"

source "$(dirname "$0")/_period.sh"
setup_period "${1:-week}"

# Fixed sections: "Display Name:canonical_tag"
SECTIONS=(
  "Meetings:meeting"
  "Reviews:review"
  "Documentation:documentation"
  "Ticket Support:ticket-support"
  "Reporting:reporting"
  "Designing:designing"
  "Administration:administration"
)

# Load ticket cache
cache='{"summaries":{},"periods":{},"done_periods":{}}'
[[ -f "$CACHE_FILE" ]] && cache=$(cat "$CACHE_FILE")
period_key="${PERIOD_START}:${PERIOD_END}"

# Read hours.json and aggregate for the period
log_data="[]"
[[ -f "$LOG_FILE" ]] && log_data=$(cat "$LOG_FILE")

# Build set of known section tags for jq
section_tags=$(printf '%s\n' "${SECTIONS[@]}" | sed 's/.*://' | jq -Rs 'split("\n") | map(select(length > 0))')

log_agg=$(echo "$log_data" | jq -r --arg from "$PERIOD_START" --arg to "$PERIOD_END" \
  --argjson section_tags "$section_tags" '
  [.[] | select(.date >= $from and .date <= $to) |
   (.tags) as $tags |
   (.hours // 0) as $h |
   if ($tags | contains(["JIRA"])) then
     ($tags | map(select(test("^[A-Z]+-[0-9]+$")))) as $keys |
     if ($keys | length) > 0 then
       $keys[] | {type: "ticket", key: ., hours: $h}
     else empty end
   elif ($tags | contains(["meeting"]) and ([$tags[] | select(. != "meeting")] | length > 0)) then
     {type: "meeting_item", key: (.date + "|" + ([$tags[] | select(. != "meeting")] | first)), hours: $h}
   else
     ($tags | map(select(. as $t | $section_tags | contains([$t])))) as $matched |
     if ($matched | length) > 0 then
       $matched[] | {type: "section", key: ., hours: $h}
     else
       {type: "other", key: ($tags | join(" ")), hours: $h}
     end
   end
  ] | group_by(.key)[] |
  {type: .[0].type, key: .[0].key, hours: ([.[].hours] | add)} |
  "\(.type)\t\(.key)\t\(.hours)"
')

declare -A ticket_hours
declare -a ticket_keys
declare -A meeting_item_hours
declare -a meeting_item_keys
declare -A section_hours
declare -a other_rows

while read -r key; do
  [[ -z "$key" ]] && continue
  ticket_keys+=("$key")
done < <(echo "$cache" | jq -r --arg p "$period_key" '.periods[$p] // [] | .[]')

declare -A done_set
while read -r key; do
  [[ -n "$key" ]] && done_set[$key]=1
done < <(echo "$cache" | jq -r --arg p "$period_key" '.done_periods[$p] // [] | .[]')

while IFS=$'\t' read -r type key hours; do
  [[ -z "$key" ]] && continue
  case "$type" in
    ticket)       ticket_hours[$key]="$hours" ;;
    meeting_item) meeting_item_hours[$key]="$hours"; meeting_item_keys+=("$key") ;;
    section)      section_hours[$key]="$hours" ;;
    other)        other_rows+=("${key}"$'\t'"${hours}") ;;
  esac
done <<< "$log_agg"

fmt_hours() {
  local h="$1"
  [[ -z "$h" ]] && return
  awk "BEGIN { h=$h; printf (h == int(h)) ? \"%gh\" : \"%.2gh\", h }"
}

# Determine column widths
max_key=6
max_desc=5
max_hours=5
for entry in "${SECTIONS[@]}"; do
  label="${entry%%:*}"
  (( ${#label} > max_key )) && max_key=${#label}
done
for key in "${ticket_keys[@]}"; do
  summary=$(echo "$cache" | jq -r --arg k "$key" '.summaries[$k] // ""')
  (( ${#key} > max_key )) && max_key=${#key}
  (( ${#summary} > max_desc )) && max_desc=${#summary}
done
for key in "${meeting_item_keys[@]}"; do
  meeting_name="${key#*|}"
  (( 10 > max_key )) && max_key=10
  (( ${#meeting_name} > max_desc )) && max_desc=${#meeting_name}
done
for row in "${other_rows[@]}"; do
  tags="${row%%$'\t'*}"
  (( ${#tags} > max_desc )) && max_desc=${#tags}
done

sep_key=$(printf '%*s' "$max_key" '' | tr ' ' '-')
sep_desc=$(printf '%*s' "$max_desc" '' | tr ' ' '-')
sep_hours=$(printf '%*s' "$max_hours" '' | tr ' ' '-')

print_sep()     { printf "|-%s-|-%s-|-%s-|\n" "$sep_key" "$sep_desc" "$sep_hours"; }
print_section() { printf "| %-*s | %-*s | %-*s |\n" "$max_key" "$1" "$max_desc" "$2" "$max_hours" "$3"; }

declare -a in_progress_keys=()
declare -a done_keys_arr=()
for key in "${ticket_keys[@]}"; do
  if [[ -n "${done_set[$key]}" ]]; then
    done_keys_arr+=("$key")
  else
    in_progress_keys+=("$key")
  fi
done

printf "Report: %s\n\n" "$PERIOD_LABEL"
print_section "Ticket" "Title" "Hours"
print_sep

if [ ${#ticket_keys[@]} -eq 0 ]; then
  print_section "(none)" "" ""
else
  if [ ${#in_progress_keys[@]} -gt 0 ]; then
    print_section "Assigned" "" ""
    print_sep
    for key in "${in_progress_keys[@]}"; do
      summary=$(echo "$cache" | jq -r --arg k "$key" '.summaries[$k] // ""')
      print_section "$key" "$summary" "$(fmt_hours "${ticket_hours[$key]:-}")"
    done
  fi
  if [ ${#done_keys_arr[@]} -gt 0 ]; then
    [ ${#in_progress_keys[@]} -gt 0 ] && print_sep
    print_section "Delivered" "" ""
    print_sep
    for key in "${done_keys_arr[@]}"; do
      summary=$(echo "$cache" | jq -r --arg k "$key" '.summaries[$k] // ""')
      print_section "$key" "$summary" "$(fmt_hours "${ticket_hours[$key]:-}")"
    done
  fi
fi

if [ ${#meeting_item_keys[@]} -gt 0 ]; then
  print_sep
  print_section "Meeting" "" ""
  print_sep
  for key in "${meeting_item_keys[@]}"; do
    [[ "${meeting_item_hours[$key]:-0}" == "0" ]] && continue
    meeting_date="${key%%|*}"
    meeting_name="${key#*|}"
    print_section "$meeting_date" "$meeting_name" "$(fmt_hours "${meeting_item_hours[$key]:-}")"
  done
fi

print_sep

for entry in "${SECTIONS[@]}"; do
  label="${entry%%:*}"
  tag="${entry##*:}"
  [[ "$tag" == "meeting" && ${#meeting_item_keys[@]} -gt 0 ]] && continue
  print_section "$label" "" "$(fmt_hours "${section_hours[$tag]:-}")"
done

if [ ${#other_rows[@]} -gt 0 ]; then
  for row in "${other_rows[@]}"; do
    tags="${row%%$'\t'*}"
    print_section "$tags" "" "$(fmt_hours "${row#*$'\t'}")"
  done
fi

# Total
total=0
for key in "${ticket_keys[@]}"; do
  h="${ticket_hours[$key]:-0}"
  total=$(awk "BEGIN { printf \"%.4f\", $total + $h }")
done
for key in "${meeting_item_keys[@]}"; do
  h="${meeting_item_hours[$key]:-0}"
  total=$(awk "BEGIN { printf \"%.4f\", $total + $h }")
done
for entry in "${SECTIONS[@]}"; do
  tag="${entry##*:}"
  [[ "$tag" == "meeting" && ${#meeting_item_keys[@]} -gt 0 ]] && continue
  h="${section_hours[$tag]:-0}"
  total=$(awk "BEGIN { printf \"%.4f\", $total + $h }")
done
for row in "${other_rows[@]}"; do
  h="${row#*$'\t'}"
  total=$(awk "BEGIN { printf \"%.4f\", $total + $h }")
done

print_sep
print_section "Total" "" "$(fmt_hours "$total")"
print_sep
