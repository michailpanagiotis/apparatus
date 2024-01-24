include "common";

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

def invoice_from_items($currency;$vatPercent):
  (map(.date) | max) as $last_date
  | (($vatPercent | tonumber) / 100) as $vatRatio
  | {
      date: $last_date,
      items: .,
      amounts: (map(.amounts.net) | net_to_costs($currency;$vatPercent))
    }
;

.intervals
# group by month
| timewarrior_group_by(get_window_of_timewarrior_interval | .month)
# map to invoice items
| map({
  date: .end | strftime("%Y-%m-%d"),
  description: (.intervals | map(categorize_interval) | unique | join(", ")),
  period: .key,
  rateUnit: "h",
  quantity: .hours,
  amounts: (.hours | quantity_to_costs($INVOICE_AMOUNTS_CURRENCY;$INVOICE_VAT_PERCENT;$INVOICE_RATE_AMOUNT))
})
| sort_by(.date)
# group invoice items to invoice
| invoice_from_items($INVOICE_AMOUNTS_CURRENCY;$INVOICE_VAT_PERCENT)
