#! /bin/bash

function usage() {
  cat << EOS
    Usage:
      reflog [-d <since-days-back>]

    Examples:
      reflog -d 1
EOS
  exit 1;
}

DAYS_AGO=7

while getopts ":d:h" o; do
    case "${o}" in
        d)
            DAYS_AGO=${OPTARG}
            ;;
        h)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

SINCE=$(date -d "-${DAYS_AGO} days" --rfc-3339=s)
TAB="%x09"

# echo Commits since ${SINCE}

git \
  --no-pager reflog \
  --abbrev=40 \
  --no-abbrev-commit \
  --author="$(git config user.name)" \
  --pretty="format:%Cred%h%Creset %Cgreen@ %cI%Creset %C(bold blue)%gd%Creset %s" \
  --since="${SINCE}" \
  --exclude="HEAD" \
  --branches="*" \
  --format="%h${TAB}%an${TAB}%cI${TAB}%s${TAB}%gd" | tr "\"" "\`" \
  | awk -F '\t' '{printf "{\"commit\":\"%s\",\"author\":\"%s\",\"date\":\"%s\",\"message\":\"%s\",\"revision\":\"%s\"}\n", $1, $2 ,$3, $4, $5}' \
  | jq --slurp 'map(.)'
