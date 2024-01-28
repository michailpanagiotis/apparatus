include "lib/money";
include "lib/timewarrior";


($ENV.INVOICE_DOCUMENT_TYPE // "Timesheet") as $documentType
| ($ENV.INVOICE_NUMBER // 1) as $number
| ($ENV.INVOICE_DATE) as $date
| ($ENV.INVOICE_CURRENCY // "EUR") as $currency
| ($ENV.INVOICE_RATE_AMOUNT // 0) as $rate
| ($ENV.INVOICE_SENDER // "{}") as $sender
| ($ENV.INVOICE_RECIPIENT // "{}") as $recipient
# prepare invoice items
| map(
  (.quantity | quantity_to_net_cost($currency;$rate)) as $netOfItems
  | (.timestamps.startedAt | strftime("%d %b '%y")) as $startDate
  | (.timestamps.endedAt | strftime("%d %b '%y")) as $endDate
  | (.timestamps.endedAt | strftime("%d %b '%y")) as $ticket
  | . + {
    amounts: {
      currencySymbol: $currency | tosymbol,
      net: $netOfItems | format_amount($currency)
    },
    period: (if $startDate != $endDate then $startDate + " - " + $endDate else $startDate end),
    description: .tags | get_categories_of_tags | join(", "),
    tickets: .tickets
  }
)
# group to invoice
| {
  documentType: $documentType,
  number: $number,
  date: ($date // (map(.deliveredOn) | max)),
  sender: ($sender | fromjson),
  recipient: ($recipient | fromjson),
  items: .,
  amounts: {
    currencySymbol: $currency | tosymbol,
    net: (map(.amounts.net) | add_amounts($currency) | format_amount($currency))
  }
}
