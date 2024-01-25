include "lib/money";

($ENV.INVOICE_CURRENCY // "EUR") as $currency
| ($ENV.INVOICE_VAT_PERCENT // 0) as $vatPercent
| ($ENV.INVOICE_RATE_AMOUNT // 0) as $rate
| ($ENV.INVOICE_DATE) as $date
# prepare invoice items
| map(
  (.quantity | quantity_to_net_cost($currency;$rate)) as $netOfItems
  | . + {
    amounts: $netOfItems | net_to_costs($currency;$vatPercent),
    period: .timestamps.startedAt | strftime("%B %Y")
  }
)
# group to invoice
| {
  date: ($date // (map(.deliveredOn) | max)),
  items: .,
  amounts: (map(.amounts.net) | add_amounts($currency) | net_to_costs($currency;$vatPercent))
}
