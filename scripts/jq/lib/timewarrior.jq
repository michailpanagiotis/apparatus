include "lib/money";

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

def get_billing_formatted_period:
  (.timestamps.startedAt | strftime("%d %b '%y")) as $startDate
  | (.timestamps.endedAt | strftime("%d %b '%y")) as $endDate
  | if $startDate != $endDate then $startDate + " - " + $endDate else $startDate end
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

def get_interval_list_tags:
  map(.tags) | add | unique
;

# BILLING

def interval_group_to_billing_item(periodFormatFilter):
  {
    tags: get_interval_list_tags,
    tickets: get_interval_list_tags | get_tickets_of_tags,
    unit: "h",
    quantity: get_interval_list_duration_in_hours,
    timestamps: {
      startedAt: get_interval_list_min_timestamp,
      endedAt: get_interval_list_max_timestamp,
      # all: get_interval_list_timestamps,
    },
    description: get_interval_list_categories | join(", "),
  }
  | . += { period: periodFormatFilter }
;

def get_interval_list_billing(groupFilter;sortFilter;periodFormatFilter):
  group_by(groupFilter)
  # map to billing items
  | map(
    . as $interval_list
    | interval_group_to_billing_item(periodFormatFilter)
    | . += { group: $interval_list | first | groupFilter }
  )
  | sort_by(sortFilter)
;


def to_invoice_items:
  ($ENV.INVOICE_CURRENCY // "EUR") as $currency
  | ($ENV.INVOICE_VAT_PERCENT // 0 | tonumber) as $vatPercent
  | ($ENV.INVOICE_RATE_AMOUNT // 0 | tonumber) as $rate
  # prepare invoice items
  | map(
    (.quantity | quantity_to_net_cost($currency;$rate)) as $netOfItems
    | (.timestamps.endedAt | strftime("%d %b '%y")) as $ticket
    | . + {
      amounts: $netOfItems | net_to_costs($currency;$vatPercent),
    }
  )
  # group to invoice
  | {
    items: .,
    amounts: (map(.amounts.net) | add_amounts($currency) | net_to_costs($currency;$vatPercent))
  }
;


def invoice_data_from_env:
  to_invoice_items + {
    documentType: ($ENV.INVOICE_DOCUMENT_TYPE // "Timesheet")
,
    number: ($ENV.INVOICE_NUMBER // 1 | tonumber),
    date: ($ENV.INVOICE_DATE | tostring),
    vatPercent: ($ENV.INVOICE_VAT_PERCENT // 0 | tonumber),
    sender: ($ENV.INVOICE_SENDER // "{}" | fromjson),
    recipient: ($ENV.INVOICE_RECIPIENT // "{}" | fromjson),
  }
;
