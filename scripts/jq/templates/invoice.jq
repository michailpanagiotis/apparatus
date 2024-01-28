
($ENV.INVOICE_DOCUMENT_TYPE // "Invoice") as $documentType
| ($ENV.INVOICE_NUMBER // 1) as $number
| ($ENV.INVOICE_SENDER // "{}") as $sender
| ($ENV.INVOICE_RECIPIENT // "{}") as $recipient
| {
  documentType: $documentType,
  number: $number,
  sender: ($sender | fromjson),
  recipient: ($recipient | fromjson),
}
