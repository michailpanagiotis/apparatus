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

def get_interval_list_timestamps:
  map({ from: (.start | parse_timestamp), to: (.end |parse_timestamp)})
;

def get_interval_list_min_timestamp:
  map(.start | parse_timestamp) | min
;

def get_interval_list_max_timestamp:
  map(.end | parse_timestamp) | max
;

def get_interval_list_timestamp_span:
  { start: (map(.start | parse_timestamp) | min), end: (map(.end | parse_timestamp) | max) }
;

def get_formatted_period:
  (.startedAt | strftime("%b %Y")) as $startMonth
  | (.endedAt | strftime("%b %Y")) as $endMonth
  | (.startedAt | strftime("%d")) as $startDay
  | (.endedAt | strftime("%d")) as $endDay
  | (.startedAt | strftime("%d/%m/%Y")) as $startDate
  | (.endedAt | strftime("%d/%m/%Y")) as $endDate
  | if $startDate != $endDate then (if $startMonth != $endMonth then $startDate + " - " + $endDate else $startDay + "-" + $endDay + " " + $startMonth end) else $startDate end
;

# TICKETS
def get_ticket:
  "(?<key>(?<project>[A-Z]+)-(?<number>[0-9]+)).*" as $ticketRegex
  | if test($ticketRegex) then (capture($ticketRegex)) else null end
  | if . != null then { project: .project, key: .key, number: (.number | tonumber) } else null end
;

def get_ticket_key:
  get_ticket | .key
;

# TAGS
def get_tickets_of_tags:
  map(get_ticket) | unique | map(select(. != null))
;

def get_categories_of_tags:
  map(
    . as $tag
    | get_ticket_key as $ticket
    | if ($ticket != null)
      then $ticket
      else (
        # non ticket
        {
          "Meeting": "Meetings",
          "Deployment": "Releases",
          "Release": "Releases",
          "Candidate assessment": "Assessments",
          "Assessment": "Assessments",
          "Multi-tenancy": "Multi-tenancy",
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

def get_interval_list_tags:
  map(.tags) | add | unique
;

# BILLING

def interval_group_to_billing_item(groupFilter):
  {
    startedAt: get_interval_list_min_timestamp,
    endedAt: get_interval_list_max_timestamp,
  } as $timestamps
  | (first | groupFilter) as $groupKey
  | {
    tags: get_interval_list_tags,
    tickets: get_interval_list_tags | get_tickets_of_tags,
    unit: "h",
    quantity: get_interval_list_duration_in_hours,
    timestamps: $timestamps,
    description: get_interval_list_categories | join(", "),
    group: $groupKey,
    period: ($timestamps | get_formatted_period),
  }
;

def get_interval_list_billing(groupFilter;sortFilter):
  group_by(groupFilter)
  # map to billing items
  | map(
    . as $interval_list
    | ($interval_list | first | groupFilter) as $groupKey
    | interval_group_to_billing_item(groupFilter)
  )
  | sort_by(sortFilter)
;
