include "lib/money";
include "lib/timewarrior";


($ENV.INVOICE_DOCUMENT_TYPE // "Invoice") as $documentType
| ($ENV.INVOICE_NUMBER // 1) as $number
| ($ENV.INVOICE_DATE) as $date
| ($ENV.INVOICE_CURRENCY // "EUR") as $currency
| ($ENV.INVOICE_VAT_PERCENT // 0) as $vatPercent
| ($ENV.INVOICE_RATE_AMOUNT // 0) as $rate
| ($ENV.INVOICE_SENDER // "{}") as $sender
| ($ENV.INVOICE_RECIPIENT // "{}") as $recipient
# prepare invoice items
| map(
  (.quantity | quantity_to_net_cost($currency;$rate)) as $netOfItems
  | . + {
    amounts: $netOfItems | net_to_costs($currency;$vatPercent),
    period: .timestamps.startedAt | strftime("%B %Y"),
    description: .tags | get_categories_of_tags | join(", ")
  }
)
# group to invoice
| {
  documentType: $documentType,
  number: $number,
  date: ($date // (map(.deliveredOn) | max)),
  vatPercent: $vatPercent,
  sender: ($sender | fromjson),
  recipient: ($recipient | fromjson),
  items: .,
  amounts: (map(.amounts.net) | add_amounts($currency) | net_to_costs($currency;$vatPercent))
}
