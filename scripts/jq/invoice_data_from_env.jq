include "lib/money";
include "lib/timewarrior";


($ENV.INVOICE_LANGUAGE // "en" | tostring) as $language
| ({
  "en": {
    "NUMBER": "#",
    "DATE": "Date",
    "PERIOD": "Period",
    "AMOUNT": "Amount",
    "DESCRIPTION": "Description",
    "QUANTITY": "#",
    "TOWARDS": "Towards",
    "TOTAL_HOURS": "Total hours",
    "SUBTOTAL": "Subtotal",
    "TAX_WITHHOLDING": "Tax withholding",
    "VAT_AMOUNT": "Vat",
    "TOTAL_AMOUNT": "Σύνολο",
    "AMOUNT_DUE": "Amount due",
    "PAYMENT_DETAILS": "Payment details",
    "IBAN": "IBAN",
    "BENEFICIARY": "Beneficiary",
    "BIC_CODE": "BIC"
  },
  "el": {
    "NUMBER": "#",
    "DATE": "Ημερομηνία",
    "PERIOD": "Περίοδος",
    "AMOUNT": "Ποσό",
    "DESCRIPTION": "Περιγραφή",
    "QUANTITY": "#",
    "TOWARDS": "Προς",
    "TOTAL_HOURS": "Σύνολο ωρών",
    "SUBTOTAL": "Αξία",
    "TAX_WITHHOLDING": "Παρακράτηση φόρου",
    "VAT_AMOUNT": "ΦΠΑ",
    "TOTAL_AMOUNT": "Σύνολο",
    "AMOUNT_DUE": "Πληρωτέο",
    "PAYMENT_DETAILS": "Στοιχεία πληρωμής",
    "IBAN": "IBAN",
    "BENEFICIARY": "Δικαιούχος",
    "BIC_CODE": "BIC"
  }
}) as $i18n
| ($ENV.INVOICE_CURRENCY // "EUR") as $currency
| ($ENV.INVOICE_VAT_PERCENT // 0 | tonumber) as $vatPercent
| ($ENV.INVOICE_TAX_WITHHOLDING_PERCENT // 0 | tonumber) as $taxWithholdingPercent
| ($ENV.INVOICE_RATE_AMOUNT // 0 | tonumber) as $rate
# prepare invoice items
| map(
  . + {
    amounts: (.quantity | quantity_to_net_cost($currency;$rate)) | net_to_costs($currency;$vatPercent;$taxWithholdingPercent),
  }
)
# group to invoice
| (map(.timestamps.startedAt) | min) as $startedAt
| (map(.timestamps.endedAt) | max) as $endedAt
| "\($startedAt | strftime("%d %b %Y")) - \($endedAt | strftime("%d %b %Y"))" as $period
| {
  items: .,
  amounts: (map(.amounts.net) | add_amounts($currency) | net_to_costs($currency;$vatPercent;$taxWithholdingPercent)),
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
  language: $language,
  labels: $i18n[$language],
}
