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

def timewarrior_group_by(f): .
  | group_by(f)
  | map({
    start: (map(get_window_of_timewarrior_interval |.quantized_start) | min),
    end: (map(get_window_of_timewarrior_interval| .quantized_end) | max),
    hours: ((map(get_window_of_timewarrior_interval| .minute_duration) | add) / 60),
    key: (first | f),
    intervals: .
  })
;


def aggregate_invoice_items_cents($precision;$vatPercent):
  (. | map(.net | tocents($precision)) | add) as $netCents
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

def quantity_to_costs($precision; $rate; $vatPercent; $currencySymbol):
  ($precision | tonumber) as $precision
  | ($rate | tonumber) as $rate
  | (. * rate | tocents($precision)) as $netCents
  | ($netCents * (($vatPercent | tonumber) / 100) | round) as $vatCents
  | {
    vatPercent: ($vatPercent | tostring + "%"),
    currencySymbol: $currencySymbol,
    quantity: .,
    perUnit: $rate,
    net: $netCents | format_cents($precision),
    vat: $vatCents | format_cents($precision),
    due: ($netCents + $vatCents) | format_cents($precision)
  }
;

def interval_to_invoice_item($precision;$rate;$vatPercent;$currencySymbol):
  . + (.quantity | quantity_to_costs($precision;$rate;$vatPercent;$currencySymbol)) | .amount = .net
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
      items: map(interval_to_invoice_item($precision;$rate;$vatPercent;$currencySymbol)),
    }
  | . += (.items | aggregate_invoice_items($precision;$vatPercent;$currencySymbol))
;

.intervals
| timewarrior_group_by(get_window_of_timewarrior_interval | .month)
| map({
  start,
  end: .end,
  description: (.intervals | map(categorize_interval) | unique | join(", ")),
  period: .key,
  rateUnit: "h",
  quantity: .hours
})
| sort_by(.start)
| invoice_from_items
