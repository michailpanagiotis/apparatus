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
  # | del(.intervals)
)
| to_entries
| sort_by(.value.start)

# Invoice amounts calculations
| (last | .value.end) as $last_end
| ($INVOICE_AMOUNTS_PRECISION | tonumber) as $precision
| (reduce range(0; $precision) as $item (1; . * 10)) as $cent_factor
| ($INVOICE_VAT_PERCENT | tonumber) as $vatPercent
| ($vatPercent / $cent_factor) as $vatRatio
| {
    date: ($last_end | strftime("%Y-%m-%d")),
    items: map({
      period: .key,
      description: .value.description,
      rateUnit: "h",
      perUnit: ($INVOICE_RATE_AMOUNT | tonumber),
      quantity: .value.hours,
      cents: (.value.hours * ($INVOICE_RATE_AMOUNT | tonumber) * $cent_factor | round),
      amount: ((.value.hours * ($INVOICE_RATE_AMOUNT | tonumber) * $cent_factor | round) / $cent_factor) | format_amount($precision)
    }),
    amounts: {
      currencySymbol: $INVOICE_CURRENCY_SYMBOL,
      vatPercent: (($vatPercent | tostring) + "%")
    }
  }
| (.items | map(.cents) | add) as $netCents
| ($netCents * $vatRatio | round) as $vatCents
| .amounts.net = ($netCents | format_cents($precision))
| .amounts.vat = ($vatCents | format_cents($precision))
| .amounts.due = ($netCents + $vatCents | format_cents($precision))
