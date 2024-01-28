include "lib/money";
include "lib/timewarrior";

def invoice_from_items($currency;$vatPercent;$rate):
  # prepare invoice items
  map(. + {
    amounts: (.quantity | quantity_to_costs($currency;$vatPercent;$rate))
  })
  # group to invoice
  | {
    date: ($ENV.INVOICE_DATE // (map(.deliveryDate) | max)),
    items: .,
    amounts: (map(.amounts.net) | net_to_costs($currency;$vatPercent))
  }
;

.intervals
| get_interval_list_billing(get_interval_month)
# group invoice items to invoice
| invoice_from_items($ENV.INVOICE_AMOUNTS_CURRENCY;$ENV.INVOICE_VAT_PERCENT;$ENV.INVOICE_RATE_AMOUNT)
