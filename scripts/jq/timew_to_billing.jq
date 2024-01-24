include "common";

def invoice_from_items($currency;$vatPercent):
  {
    date: map(.date) | max,
    items: .,
    amounts: (map(.amounts.net) | net_to_costs($currency;$vatPercent))
  }
;

def toinvoiceitem(f):
  . as $intervals
  |($intervals | map(get_window_of_timewarrior_interval | .minute_duration / 60) | add) as $hours
  | {
    date: ($intervals | map(get_window_of_timewarrior_interval | .quantized_end) | max | strftime("%Y-%m-%d")),
    description: ($intervals | map(categorize_interval) | unique | join(", ")),
    period: ($intervals | first | f),
    rateUnit: "h",
    quantity: $hours,
    amounts: ($hours | quantity_to_costs($INVOICE_AMOUNTS_CURRENCY;$INVOICE_VAT_PERCENT;$INVOICE_RATE_AMOUNT))
  }
;

def by_month: get_window_of_timewarrior_interval | .month;

.intervals
# group by month
| group_by(by_month)
# map to invoice items
| map(toinvoiceitem(by_month))
| sort_by(.date)
# group invoice items to invoice
| invoice_from_items($INVOICE_AMOUNTS_CURRENCY;$INVOICE_VAT_PERCENT)
