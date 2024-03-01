include "lib/money";
include "lib/timewarrior";

($ENV.INVOICE_CURRENCY // "EUR") as $currency
| ($ENV.INVOICE_VAT_PERCENT // 0 | tonumber) as $vatPercent
| ($ENV.INVOICE_RATE_AMOUNT // 0 | tonumber) as $rate
# prepare invoice items
| map(
  . + {
    amounts: (.quantity | quantity_to_net_cost($currency;$rate)) | net_to_costs($currency;$vatPercent),
  }
)
# group to invoice
| (map(.timestamps.startedAt) | min) as $startedAt
| (map(.timestamps.endedAt) | max) as $endedAt
| "\($startedAt | strftime("%d %b %Y")) - \($endedAt | strftime("%d %b %Y"))" as $period
| {
  items: .,
  amounts: (map(.amounts.net) | add_amounts($currency) | net_to_costs($currency;$vatPercent)),
  quantity: (map(.quantity) | add),
  startedAt: (map(.timestamps.startedAt) | min),
  endedAt: (map(.timestamps.endedAt) | max),
  period: $period,
  documentType: ($ENV.INVOICE_DOCUMENT_TYPE // "Timesheet"),
  number: ($ENV.INVOICE_NUMBER // 1 | tonumber),
  date: ($ENV.INVOICE_DATE | tostring),
  vatPercent: ($ENV.INVOICE_VAT_PERCENT // 0 | tonumber),
  sender: ($ENV.INVOICE_SENDER // "{}" | fromjson),
  recipient: ($ENV.INVOICE_RECIPIENT // "{}" | fromjson),
  language: ($ENV.INVOICE_LANGUAGE // "en" | tostring),
}
