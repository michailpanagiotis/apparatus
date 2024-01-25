include "lib/money";

($ENV.INVOICE_AMOUNTS_CURRENCY // "EUR") as $currency
| ($ENV.INVOICE_VAT_PERCENT // 0) as $vatPercent
| ($ENV.INVOICE_RATE_AMOUNT // 0) as $rate
| ($ENV.INVOICE_DATE) as $date
# prepare invoice items
| map(. + {
  amounts: (.quantity | quantity_to_costs($currency;$vatPercent;$rate))
})
# group to invoice
| {
  date: ($date // (map(.deliveredOn) | max)),
  items: .,
  amounts: (map(.amounts.net) | net_to_costs($currency;$vatPercent))
}
