include "common";
include "lib/money";
include "lib/timewarrior";

def to_invoice_item(filter):
  (map(get_interval_duration / 3600) | add) as $hours
  | {
    date: (map(.end | parse_date) | max | strftime("%Y-%m-%d")),
    description: (map(get_interval_category) | unique | join(", ")),
    period: (first | filter),
    rateUnit: "h",
    quantity: $hours,
    amounts: ($hours | quantity_to_costs($INVOICE_AMOUNTS_CURRENCY;$INVOICE_VAT_PERCENT;$INVOICE_RATE_AMOUNT))
  }
;

def invoice_from_items($currency;$vatPercent):
  {
    date: map(.date) | max,
    items: .,
    amounts: (map(.amounts.net) | net_to_costs($currency;$vatPercent))
  }
;

def by_month: .start | parse_date | strflocaltime("%B %Y");

.intervals
# group by month
| group_by(by_month)
# # map to invoice items
| map(to_invoice_item(by_month))
| sort_by(.date)
# # group invoice items to invoice
| invoice_from_items($INVOICE_AMOUNTS_CURRENCY;$INVOICE_VAT_PERCENT)
