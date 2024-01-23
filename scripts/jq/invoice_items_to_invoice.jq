50 as $rate
24 as $vat
| {
  items: map(
    .perUnit = $rate
    | .amount = ($rate * .quantity)
  )
}
| .items as $items
| .subtotal = (reduce $items[] as $item (0; . += $item.amount))
| .quantity = (reduce $items[] as $item (0; . += $item.quantity))
