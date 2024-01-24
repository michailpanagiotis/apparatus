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

def aggregate_invoice_items($precision;$vatPercent;$currencySymbol):
  ($precision | tonumber) as $precision
  | {
    amounts: (
      map(.amounts.net) | add_amounts($precision) as $net
      | $net | net_to_costs($precision;$vatPercent;$currencySymbol)
    )
  }
;

def interval_to_invoice_item($precision;$rate;$vatPercent;$currencySymbol):
  . + (.quantity | quantity_to_costs($precision;$vatPercent;$currencySymbol;$rate))
;

def invoice_from_items($precision;$rate;$vatPercent;$currencySymbol):
  (last | .end) as $last_end
  | (($vatPercent | tonumber) / 100) as $vatRatio
  | {
      date: ($last_end | strftime("%Y-%m-%d")),
      items: .,
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
| map(interval_to_invoice_item($INVOICE_AMOUNTS_PRECISION;$INVOICE_RATE_AMOUNT;$INVOICE_VAT_PERCENT;$INVOICE_CURRENCY_SYMBOL))
| sort_by(.start)
| invoice_from_items($INVOICE_AMOUNTS_PRECISION;$INVOICE_RATE_AMOUNT;$INVOICE_VAT_PERCENT;$INVOICE_CURRENCY_SYMBOL)
