# CURRENCIES

def tocurrency:
  {
    "EUR": { "symbol": "€", "precision": 2 }
  }[.]
  | if . == null then error("unknown currency \(.)") else . end;

def tosymbol: tocurrency | .symbol;
def toprecision: tocurrency | .precision | tonumber;

# AMOUNTS
def dehumanize: . | tostring | gsub(",";"");

def humanize:
  (. | dehumanize) as $input
  | ($input | split(".")) as $parts
  | ($parts[0] | split("")) as $full_digits
  | ($full_digits | reduce range($full_digits | length) as $item (
      [];
      if ($item != 0 and ($full_digits | length - $item) % 3 == 0)
        then . + [","]
        else .
      end + [$full_digits[$item]]
    ) | join("") ) as $full
  | $full + if $parts[1] then ".\($parts[1])" else "" end
;

def tocents($currency):
  ($currency | toprecision) as $precision
  | (. | dehumanize | tonumber) * ($precision | exp10)
  | round;

def format_cents($currency):
  ($currency | toprecision) as $precision
  | if $precision > 0 then (
    tonumber
    | round
    | tostring
    | .[:-$precision] + "." + .[-$precision:]
  ) else . end
  | humanize
;

def add_amounts($currency):
  if (. | length) == 0 then 0 else (
    map(. | tocents($currency))
    | add
    | format_cents($currency)
  ) end
;

def net_to_costs($currency;$vatPercent):
  (
    if (. | type) == "array"
      then add_amounts($currency)
      else .
    end
    | dehumanize | tocents($currency)
  ) as $netCents
  | ($vatPercent | tonumber) as $vatPercent
  | ($netCents * ($vatPercent / 100) | round) as $vatCents
  | {
    currencySymbol: $currency | tosymbol,
    vatPercent: ($vatPercent | tostring + "%"),
    net: $netCents | format_cents($currency),
    vat: $vatCents | format_cents($currency),
    due: ($netCents + $vatCents) | format_cents($currency),
  }
;

def quantity_to_costs($currency;$vatPercent;$rate):
  ($rate | tonumber) as $rate
  | ($vatPercent | tonumber) as $vatPercent
  | (. * $rate | tocents($currency)) as $netCents
  | ($netCents * ($vatPercent / 100) | round) as $vatCents
  | {
    amounts: {
      quantity: .,
      perUnit: $rate,
    }
  }
  | .amounts += ($netCents | format_cents($currency) | net_to_costs($currency;$vatPercent))
  | .amounts
;
