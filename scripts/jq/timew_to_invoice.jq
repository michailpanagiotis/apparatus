include "common";

def categorize_non_tag:
  {
    "Meeting": "Meetings",
    "Deployment": "Deployments",
    "Release": "Releases",
    "Candidate assessment": "Candidate assessments",
    "Research": "Research",
    "Incident": "Incidents"
  } as $categories
  | $categories[.] // "";

def categorize_tag:
  ([.] | get_tickets_from_tags) as $tickets
  | if ($tickets | length > 0)
    then "Tickets"
    else (. | categorize_non_tag)
    end
;

def categorize_interval: .tags | map(categorize_tag | select(. != "")) | join(", ");

def sum_up(f): .
  | group_by(f)
  | map({
    key: (first | f),
    value: {
      start: (map(.window.quantized_start) | min),
      hours: ((map(.window.minute_duration) | add) / 60),
      intervals: .
    }
  })
  | from_entries
;

.intervals
| map(
  .window = (
    [
      (.start | strptime("%Y%m%dT%H%M%SZ") | mktime),
      (.end | strptime("%Y%m%dT%H%M%SZ") | mktime)
    ]
    | get_window_of_timestamps
  )
  | .category = categorize_interval
  | .tickets = (.tags | get_tickets_from_tags | join(", "))
)
| sum_up(.window.month)
| map_values(
  .intervals = (.intervals | sum_up(.category)
  )
)
