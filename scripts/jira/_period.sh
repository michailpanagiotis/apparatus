# Sourced by report.sh and sync.sh. Sets PERIOD_START, PERIOD_END, AFTER_CLAUSE, BEFORE_CLAUSE, BEFORE_PART, PERIOD_LABEL.

resolve_period() {
  local input="$1"

  if [[ "$input" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}):([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
    PERIOD_START="${BASH_REMATCH[1]}"
    PERIOD_END="${BASH_REMATCH[2]}"
    return
  fi

  if [[ "$input" =~ ^([0-9]+)m$ ]]; then
    local offset="${BASH_REMATCH[1]}"
    if [ "$offset" -eq 0 ]; then
      PERIOD_START=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
      PERIOD_END=$(date +%Y-%m-%d)
    else
      local before_end=$(( offset - 1 ))
      PERIOD_START=$(date -d "$(date +%Y-%m-01) - ${offset} month" +%Y-%m-%d)
      PERIOD_END=$(date -d "$(date +%Y-%m-01) - 1 day" +%Y-%m-%d)
      [ "$before_end" -gt 0 ] && PERIOD_END=$(date -d "$(date +%Y-%m-01) - ${before_end} month - 1 day" +%Y-%m-%d)
    fi
    return
  fi

  if [[ "$input" == "month" ]]; then
    PERIOD_START=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
    PERIOD_END=$(date +%Y-%m-%d)
    return
  fi

  local offset=0
  [[ "$input" =~ ^[0-9]+$ ]] && offset="$input"

  local dow=$(date +%u)
  local this_monday=$(date -d "- $(( dow - 1 )) days" +%Y-%m-%d)
  if [ "$offset" -eq 0 ]; then
    PERIOD_START="${this_monday}"
    PERIOD_END=$(date +%Y-%m-%d)
  else
    PERIOD_START=$(date -d "${this_monday} - ${offset} weeks" +%Y-%m-%d)
    PERIOD_END=$(date -d "${PERIOD_START} + 6 days" +%Y-%m-%d)
  fi
}

setup_period() {
  local arg="${1:-week}"
  resolve_period "$arg"
  AFTER_CLAUSE="AFTER $(date -d "${PERIOD_START} - 1 day" +%Y-%m-%d)"
  BEFORE_CLAUSE=""
  [[ "$PERIOD_END" != "$(date +%Y-%m-%d)" ]] && BEFORE_CLAUSE="BEFORE $(date -d "${PERIOD_END} + 1 day" +%Y-%m-%d)"
  BEFORE_PART="${BEFORE_CLAUSE:+ ${BEFORE_CLAUSE}}"
  PERIOD_LABEL="${PERIOD_START} to ${PERIOD_END}"
}
