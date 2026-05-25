#!/usr/bin/env bash
set -e

# Fetches Jira tickets for the period, updates the cache, then interactively
# prompts for hours per ticket and activity. Records are replaced in ~/.hours.json.
#
# Usage: sync.sh [week|month|N|Nm|START:END]  (default: week)

CACHE_FILE="${HOME}/.jira-tickets.json"
LOG_FILE="${HOME}/.hours.json"

SECTIONS=(
  "Meetings:meeting"
  "Reviews:review"
  "Documentation:documentation"
  "Ticket Support:ticket-support"
  "Reporting:reporting"
  "Designing:designing"
  "Administration:administration"
  "Incidents:incidents"
)

source "$(dirname "$0")/_period.sh"
setup_period "${1:-week}"

# ── Jira sync ────────────────────────────────────────────────────────────────

fetch_tickets() {
  local status_filter="$1"
  curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" \
    -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" \
    --json "{\"fields\": [\"key\",\"summary\"], \"maxResults\": 100, \"jql\":\"assignee changed TO currentUser() ${AFTER_CLAUSE}${BEFORE_PART} AND ${status_filter} AND project IN (BT, PAYM) ORDER BY updated DESC\"}" \
    | jq -r '(.issues // [])[] | "\(.key)\t\(.fields.summary // "")"'
}

fetch_history_tickets() {
  local status_filter="$1"
  curl -s --request POST "https://talentdesk.atlassian.net/rest/api/3/search/jql" \
    -u "${JIRA_API_USER}:${JIRA_API_TOKEN}" \
    --json "{\"fields\": [\"key\",\"summary\"], \"maxResults\": 100, \"jql\":\"issue in issueHistory() AND updated >= \\\"${PERIOD_START}\\\" AND ${status_filter} AND project IN (BT, PAYM) ORDER BY updated DESC\"}" \
    | jq -r '(.issues // [])[] | "\(.key)\t\(.fields.summary // "")"'
}

declare -A seen_keys
declare -a tickets
declare -a done_ticket_keys=()

add_tickets() {
  local is_done="$1"
  while IFS=$'\t' read -r key summary; do
    [[ -z "$key" ]] && continue
    [[ -n "${seen_keys[$key]}" ]] && continue
    seen_keys[$key]=1
    tickets+=("${key}"$'\t'"${summary}")
    if [[ "$is_done" == "true" ]]; then done_ticket_keys+=("$key"); fi
  done <<< "$2"
}

add_tickets "false" "$(fetch_tickets "status NOT IN (Done, Closed, 'QA Testing')")"
add_tickets "false" "$(fetch_tickets "status = 'QA Testing'")"
add_tickets "true"  "$(fetch_tickets "status IN (Done, Closed)")"
add_tickets "false" "$(fetch_history_tickets "status NOT IN (Done, Closed, 'QA Testing')")"
add_tickets "false" "$(fetch_history_tickets "status = 'QA Testing'")"
add_tickets "true"  "$(fetch_history_tickets "status IN (Done, Closed)")"

if [ ${#tickets[@]} -eq 0 ]; then
  echo "No tickets found for ${PERIOD_LABEL}."
  exit 0
fi

existing='{"summaries":{},"periods":{}}'
[[ -f "$CACHE_FILE" ]] && existing=$(cat "$CACHE_FILE")

period_key="${PERIOD_START}:${PERIOD_END}"

new_summaries=$(printf '%s\n' "${tickets[@]}" | jq -Rs '
  split("\n") | map(select(length > 0)) |
  map(split("\t") | {(.[0]): (.[1] // "")}) | add // {}
')
new_keys=$(printf '%s\n' "${tickets[@]}" | jq -Rs '
  split("\n") | map(select(length > 0)) | map(split("\t")[0])
')

if [ ${#done_ticket_keys[@]} -gt 0 ]; then
  done_keys_json=$(printf '%s\n' "${done_ticket_keys[@]}" | jq -Rs 'split("\n") | map(select(length>0))')
else
  done_keys_json='[]'
fi

echo "$existing" | jq \
  --argjson summaries "$new_summaries" \
  --argjson keys "$new_keys" \
  --argjson done_keys "$done_keys_json" \
  --arg period "$period_key" \
  '.summaries += $summaries | .periods[$period] = $keys | .done_periods[$period] = $done_keys' > "$CACHE_FILE"

echo "Synced ${#tickets[@]} ticket(s) for ${PERIOD_LABEL}."

# ── Interactive hours entry ───────────────────────────────────────────────────

[[ -f "$LOG_FILE" ]] || echo "[]" > "$LOG_FILE"
log_data=$(cat "$LOG_FILE")

# Date to record against: today if within period, else PERIOD_END
record_date=$(date +%Y-%m-%d)
[[ "$record_date" > "$PERIOD_END" ]] && record_date="$PERIOD_END"
[[ "$record_date" < "$PERIOD_START" ]] && record_date="$PERIOD_START"

parse_hours() {
  local raw="${1%h}"
  [[ "$raw" =~ ^[0-9]+(\.[0-9]+)?$ ]] && awk "BEGIN { printf \"%g\", $raw }" || echo ""
}

# Look up existing summed hours for a set of tags in the period
existing_hours() {
  local tags_json="$1"
  local is_ticket="$2"  # "true" or "false"
  echo "$log_data" | jq -r \
    --arg from "$PERIOD_START" --arg to "$PERIOD_END" \
    --argjson tags "$tags_json" \
    --argjson is_ticket "$is_ticket" '
    [.[] |
      select(.date >= $from and .date <= $to) |
      select(($tags - .tags | length) == 0) |
      if $is_ticket then select(.tags | contains(["JIRA"])) else select(.tags | contains(["JIRA"]) | not) end |
      .hours
    ] | if length == 0 then "" else (add | tostring) end'
}

# Remove existing records for a tag set in the period, then append new one
replace_hours() {
  local tags_json="$1"
  local is_ticket="$2"
  local hours="$3"
  local entry_date="${4:-$record_date}"
  log_data=$(echo "$log_data" | jq \
    --arg from "$PERIOD_START" --arg to "$PERIOD_END" \
    --argjson tags "$tags_json" \
    --argjson is_ticket "$is_ticket" \
    --argjson hours "$hours" \
    --arg date "$entry_date" '
    [.[] | select(
      (.date >= $from and .date <= $to and
       (($tags - .tags | length) == 0) and
       (if $is_ticket then .tags | contains(["JIRA"]) else (.tags | contains(["JIRA"]) | not) end)
      ) | not
    )] + [{"date": $date, "hours": $hours, "tags": $tags}]')
}

# Truncate a string to N chars with ellipsis
truncate() { local s="$1" n="$2"; (( ${#s} > n )) && echo "${s:0:$((n-1))}…" || echo "$s"; }

# ── Calendar sync ────────────────────────────────────────────────────────────

declare -a cal_summaries=()
declare -A cal_hours=()

if [[ -n "$CALENDAR_SECRET_ICAL" ]]; then
  ical_raw=$(curl -sf "$CALENDAR_SECRET_ICAL" 2>/dev/null) || ical_raw=""

  if [[ -n "$ical_raw" ]]; then
    period_from="${PERIOD_START//-/}"
    period_to="${PERIOD_END//-/}"

    while IFS=$'\t' read -r d s h; do
      [[ -z "$s" ]] && continue
      key="$d"$'\t'"$s"
      if [[ -z "${cal_hours[$key]+x}" ]]; then
        cal_summaries+=("$key")
        cal_hours[$key]="$h"
      else
        cal_hours[$key]=$(awk "BEGIN { printf \"%g\", ${cal_hours[$key]} + $h }")
      fi
    done < <(
      echo "$ical_raw" | tr -d '\r' \
        | awk '/^[ \t]/{printf "%s",substr($0,2); next} {print}' \
        | awk -v from="$period_from" -v to="$period_to" -v user="panos@talentdesk.io" '
          function jdn(y,m,d,  a) {
            a=int((14-m)/12); y+=4800-a; m+=12*a-3
            return d+int((153*m+2)/5)+365*y+int(y/4)-int(y/100)+int(y/400)-32045
          }
          function sjdn(s) { return jdn(substr(s,1,4)+0,substr(s,5,2)+0,substr(s,7,2)+0) }
          function jdn2date(J,  f,e,g,h,D,M,Y) {
            f=J+1401+int(int((4*J+274277)/146097)*3/4)-38
            e=4*f+3; g=int((e%1461)/4); h=5*g+2
            D=int((h%153)/5)+1; M=(int(h/153)+2)%12+1; Y=int(e/1461)-4716+int((14-M)/12)
            return sprintf("%04d-%02d-%02d",Y,M,D)
          }
          BEGIN {
            fj=sjdn(from); tj=sjdn(to)
            dm["MO"]=0;dm["TU"]=1;dm["WE"]=2;dm["TH"]=3;dm["FR"]=4;dm["SA"]=5;dm["SU"]=6
          }
          /^BEGIN:VEVENT/ { in_event=1; summary=""; dtstart=""; dtend=""; partstat=""; is_organizer=0; rrule="" }
          /^END:VEVENT/ {
            if (in_event && summary!="" && dtstart!="" && dtend!="" &&
                summary!="Out of office" && summary!~/^Programming Stint/ && partstat!="DECLINED") {
              ds8=substr(dtstart,1,8)
              inst_jdn=sjdn(ds8)
              in_p=(ds8>=from && ds8<=to)
              if (!in_p && rrule!="" && ds8<=to) {
                freq=""; until=""; intv=1; byday=""
                n=split(rrule,rp,";")
                for (i=1;i<=n;i++) {
                  if      (rp[i]~/^FREQ=/)     freq=substr(rp[i],6)
                  else if (rp[i]~/^UNTIL=/)    until=substr(rp[i],7,8)
                  else if (rp[i]~/^INTERVAL=/) intv=substr(rp[i],10)+0
                  else if (rp[i]~/^BYDAY=/)    byday=substr(rp[i],7)
                }
                if (intv<1) intv=1
                uj=(until!="") ? sjdn(until) : 2000000000
                if (uj>=fj) {
                  sj=sjdn(ds8)
                  if (freq=="DAILY") {
                    off=fj-sj; if(off<0)off=0
                    inst=sj+int(off/intv)*intv; if(inst<fj)inst+=intv
                    in_p=(inst<=tj && inst<=uj)
                    if (in_p) inst_jdn=inst
                  } else if (freq=="WEEKLY") {
                    if (byday=="") {
                      off=fj-sj; if(off<0)off=0
                      inst=sj+int(off/(7*intv))*7*intv; if(inst<fj)inst+=7*intv
                      in_p=(inst<=tj && inst<=uj)
                      if (in_p) inst_jdn=inst
                    } else {
                      nb=split(byday,bds,","); in_p=0; sdow=sj%7
                      for (b=1;b<=nb&&!in_p;b++) {
                        bd=bds[b]; gsub(/^[+-]?[0-9]*/,"",bd)
                        if (!(bd in dm)) continue
                        d2f=(dm[bd]-sdow+7)%7; fst=sj+d2f
                        if (fst<fj) { wk=int((fj-fst+intv*7-1)/(intv*7)); fst+=wk*intv*7 }
                        in_p=(fst>=fj && fst<=tj && fst<=uj)
                        if (in_p) inst_jdn=fst
                      }
                    }
                  }
                }
              }
              if (in_p) {
                sh=substr(dtstart,9,2)+0; sm=substr(dtstart,11,2)+0
                eh=substr(dtend,9,2)+0;   em=substr(dtend,11,2)+0
                mins=eh*60+em-sh*60-sm
                dur=int((mins+59)/60)
                edate=jdn2date(inst_jdn)
                if (dur>0) print edate "\t" summary "\t" dur
              }
            }
            in_event=0
          }
          in_event && /^SUMMARY:/  { summary=substr($0,9) }
          in_event && /^DTSTART/   { val=$0; sub(/^[^:]*:/,"",val); dtstart=substr(val,1,15) }
          in_event && /^DTEND/     { val=$0; sub(/^[^:]*:/,"",val); dtend=substr(val,1,15) }
          in_event && /^RRULE:/    { rrule=substr($0,7) }
          in_event && index($0,user) {
            if (/^ORGANIZER/) { is_organizer=1 }
            else if (/^ATTENDEE/ && /PARTSTAT=/) {
              ps=$0; sub(/.*PARTSTAT=/,"",ps); sub(/[;:].*/,"",ps); partstat=ps
            }
          }
        '
    )
  fi
fi

# ── Interactive hours entry ───────────────────────────────────────────────────

echo ""
echo "Hours for ${PERIOD_LABEL} (enter to accept default):"
echo ""
echo "── Tickets ──"

for t in "${tickets[@]}"; do
  key="${t%%$'\t'*}"
  summary=$(truncate "${t#*$'\t'}" 50)
  tags_json="[\"$key\", \"JIRA\"]"
  current=$(existing_hours "$tags_json" "true")
  [[ -n "$current" ]] && default=$(parse_hours "${current}h") || default="1"
  printf "  https://talentdesk.atlassian.net/browse/%s - %s [%sh]: " "$key" "$summary" "$default"
  read -r input
  hours=$(parse_hours "$input")
  [[ -z "$hours" ]] && hours="$default"
  replace_hours "$tags_json" "true" "$hours"
done

if [[ ${#cal_summaries[@]} -gt 0 ]]; then
  echo ""
  echo "── Meetings ──"

  for key in "${cal_summaries[@]}"; do
    cal_date="${key%%$'\t'*}"
    s="${key#*$'\t'}"
    tags_json=$(jq -cn --arg s "$s" '["meeting", $s]')
    current=$(existing_hours "$tags_json" "false")
    [[ -n "$current" ]] && default=$(parse_hours "${current}h") || default="${cal_hours[$key]}"
    printf "  [%s] %s [%sh]: " "$cal_date" "$(truncate "$s" 50)" "$default"
    read -r input
    hours=$(parse_hours "$input")
    [[ -z "$hours" ]] && hours="$default"
    replace_hours "$tags_json" "false" "$hours" "$cal_date"
  done
fi

echo ""
echo "── Activities ──"

for entry in "${SECTIONS[@]}"; do
  label="${entry%%:*}"
  tag="${entry##*:}"
  [[ "$tag" == "meeting" && ${#cal_summaries[@]} -gt 0 ]] && continue
  tags_json="[\"$tag\"]"
  current=$(existing_hours "$tags_json" "false")
  [[ -n "$current" ]] && default=$(parse_hours "${current}h") || default="1"
  printf "  %s [%sh]: " "$label" "$default"
  read -r input
  hours=$(parse_hours "$input")
  [[ -z "$hours" ]] && hours="$default"
  replace_hours "$tags_json" "false" "$hours"
done

echo "$log_data" > "$LOG_FILE"
echo ""
echo "Hours saved."
