include "lib/money";
include "lib/timewarrior";

($ENV.INVOICE_CURRENCY // "EUR") as $currency
| ($ENV.INVOICE_VAT_PERCENT // 0 | tonumber) as $vatPercent
| ($ENV.INVOICE_RATE_AMOUNT // 0 | tonumber) as $rate
# prepare invoice items
| .tickets as $tickets
| .items
| map(
  ($tickets[.description].summary) as $summary
  | . + {
    amounts: (.quantity | quantity_to_net_cost($currency;$rate)) | net_to_costs($currency;$vatPercent),
    description: (if $summary then "\(.description) \($summary)" else .description end)
  }
)
# group to invoice
| {
  items: .,
  amounts: (map(.amounts.net) | add_amounts($currency) | net_to_costs($currency;$vatPercent)),
  documentType: ($ENV.INVOICE_DOCUMENT_TYPE // "Timesheet"),
  number: ($ENV.INVOICE_NUMBER // 1 | tonumber),
  date: ($ENV.INVOICE_DATE | tostring),
  vatPercent: ($ENV.INVOICE_VAT_PERCENT // 0 | tonumber),
  sender: ($ENV.INVOICE_SENDER // "{}" | fromjson),
  recipient: ($ENV.INVOICE_RECIPIENT // "{}" | fromjson),
}
