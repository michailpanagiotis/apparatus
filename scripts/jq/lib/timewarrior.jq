# DATES

def parse_timestamp:
  . | strptime("%Y%m%dT%H%M%SZ") | mktime
;

def get_interval_duration:
  (.end | parse_timestamp) - (.start | parse_timestamp)
;

def get_interval_month:
  .start | parse_timestamp | strflocaltime("%B %Y")
;

def get_interval_list_duration:
  map(get_interval_duration) | add
;

def get_interval_list_duration_in_hours:
  (map(get_interval_duration) | add) / 3600
;

def get_interval_list_max_timestamp:
  map(.end | parse_timestamp) | max
;

def get_interval_list_timestamp_span:
  { start: (map(.start | parse_timestamp) | min), end: (map(.end | parse_timestamp) | max) }
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

def get_interval_list_categories:
  map(get_interval_category) | unique
;

# BILLING

def get_interval_list_grouped_billing:
  get_interval_list_duration_in_hours as $hours
  | get_interval_list_timestamp_span as $span
  | {
    deliveredOn: get_interval_list_max_timestamp | strftime("%Y-%m-%d"),
    description: get_interval_list_categories | join(", "),
    unit: "h",
    quantity: $hours,
    timestamps: {
      startedAt: $span.start,
      endedAt: $span.end
    }
  }
;

def get_interval_list_billing(f):
  group_by(f)
  # map to billing items
  | map(get_interval_list_grouped_billing)
  | sort_by(.deliveredOn)
;

def get_interval_list_billing_in_tsv(f):
  get_interval_list_billing(f)
  | ["deliveredOn", "startedAt", "endedAt", "quantity", "unit", "description"] as $keys
  |  $keys, map([.[ $keys[] ]])[] | @csv
;
