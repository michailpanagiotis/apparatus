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

def get_interval_day:
  .start | parse_timestamp | strflocaltime("%Y-%m-%d")
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

def get_interval_list_min_timestamp:
  map(.end | parse_timestamp) | min
;

def get_interval_list_timestamp_span:
  { start: (map(.start | parse_timestamp) | min), end: (map(.end | parse_timestamp) | max) }
;

# TICKETS

def get_ticket:
  "(?<id>(?<project>[A-Z]+)-(?<number>[0-9]+)).*" as $ticketRegex
  | if test($ticketRegex) then (capture($ticketRegex) | .id) else null end
;

# TAGS

def get_tickets_of_tags:
  map(get_ticket) | unique | map(select(. != null))
;

def get_categories_of_tags:
  map(
    . as $tag
    | get_ticket as $ticket
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
        }[$tag] // ""
      )
      end
  ) | unique | map(select(. != ""))
;

def get_interval_category:
  .tags
  | get_categories_of_tags
  | join(", ")
;

def get_interval_month_and_category:
  . as $interval
  | ($interval | get_interval_month) as $month
  | ($interval | get_interval_category) as $category
  | $month + ":" + $category
;

def get_interval_list_categories:
  map(get_interval_category) | unique
;

# BILLING

def get_interval_list_grouped_billing(f):
  get_interval_list_duration_in_hours as $hours
  | get_interval_list_timestamp_span as $span
  | {
    group: first | f,
    startedOn: get_interval_list_min_timestamp | strftime("%Y-%m-%d"),
    deliveredOn: get_interval_list_max_timestamp | strftime("%Y-%m-%d"),
    tags: map(.tags) | add | unique,
    tickets: ((map(.tags) | add | unique) | get_tickets_of_tags),
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
  | map(get_interval_list_grouped_billing(f))
  | sort_by(.deliveredOn)
;

def get_interval_list_billing_in_tsv(f):
  get_interval_list_billing(f)
  | ["deliveredOn", "startedAt", "endedAt", "quantity", "unit", "description"] as $keys
  |  $keys, map([.[ $keys[] ]])[] | @csv
;
