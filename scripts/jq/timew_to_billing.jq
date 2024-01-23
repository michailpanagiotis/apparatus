include "common";

def categorize_non_tag:
  {
    "Meeting": "Meetings",
    "Deployment": "Releases",
    "Release": "Releases",
    "Candidate assessment": "Candidate assessments",
    "Research": "Research",
    "Incident": "Incidents"
  } as $categories
  | $categories[.] // "";

def categorize_tag:
  ([.] | get_tickets_from_tags) as $tickets
  | if ($tickets | length > 0)
    then ($tickets | join(", "))
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
      end: (map(.window.quantized_end) | max),
      hours: ((map(.window.minute_duration) | add) / 60),
      intervals: .
    }
  })
  | from_entries
;

def tocents($precision): . * ($precision | exp10) | round;

def aggregate_invoice_items_cents($precision;$vatPercent):
  (. | map(.cents) | add) as $netCents
  | ($netCents * (($vatPercent | tonumber) / 100) | round) as $vatCents
  | {
    net: $netCents,
    vat: $vatCents,
    due: ($netCents + $vatCents)
  }
;

def aggregate_invoice_items($precision;$vatPercent;$currencySymbol):
  .
  | aggregate_invoice_items_cents($precision;$vatPercent)
  | map_values(format_cents($precision))
  | {
    currencySymbol: $currencySymbol,
    vatPercent: ($vatPercent | tostring + "%")
  } + .
  | { amounts: . }
;

def interval_to_invoice_item($precision;$rate):
  ($precision | tonumber) as $precision
  | ($rate | tonumber) as $rate
  | {
    period: .month,
    description: .description,
    rateUnit: "h",
    perUnit: $rate,
    quantity: .hours,
    cents: (.hours * $rate | tocents($precision)),
    amount: (.hours * $rate | tocents($precision)) | format_cents($precision)
  }
;

def invoice_from_items:
  (last | .end) as $last_end
  | ($INVOICE_AMOUNTS_PRECISION | tonumber) as $precision
  | ($INVOICE_RATE_AMOUNT | tonumber) as $rate
  | ($INVOICE_VAT_PERCENT | tonumber) as $vatPercent
  | ($INVOICE_CURRENCY_SYMBOL) as $currencySymbol
  | ($vatPercent / 100) as $vatRatio
  | {
      date: ($last_end | strftime("%Y-%m-%d")),
      items: map(interval_to_invoice_item($precision;$rate)),
    }
  | . += (.items | aggregate_invoice_items($precision;$vatPercent;$currencySymbol))
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
  .analysis = (
    .intervals | sum_up(.category) | map_values(
      .hours
    )
  )
  | .description = (.analysis | to_entries | map(.key) | join(", "))
  | .month = (.intervals | first).window.month
  # | del(.intervals)
)
| to_entries
| map(.value)
| sort_by(.start)
| invoice_from_items
