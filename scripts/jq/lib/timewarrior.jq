# DATES

def parse_date:
  . | strptime("%Y%m%dT%H%M%SZ") | mktime
;

def get_interval_duration:
  (.end | parse_date) - (.start | parse_date)
;

# TICKETS

def get_ticket_regex:
  "(?<id>(?<project>[A-Z]+)-(?<number>[0-9]+)).*";

def is_ticket: test(get_ticket_regex);

def get_ticket: if is_ticket then (capture(get_ticket_regex) | .id) else null end;

# TAGS

def get_tag_category:
  get_ticket as $ticket
  | if ($ticket != null)
    then $ticket
    else (
      # non ticket
      {
        "Meeting": "Meetings",
        "Deployment": "Releases",
        "Release": "Releases",
        "Candidate assessment": "Candidate assessments",
        "Research": "Research",
        "Incident": "Incidents"
      }[.] // ""
    )
    end
;

def get_interval_category:
  .tags
  | map(
    get_tag_category | select(. != "")
  )
  | join(", ")
;
