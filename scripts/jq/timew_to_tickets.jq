
map(.tags) | flatten
 | "(?<id>(?<project>[A-Z]+)-(?<number>[0-9]+)).*" as $regex
 | map(select(. | test($regex)) | capture($regex) | .id)
 | unique
 | sort_by(
   (. | capture($regex) | .number | tonumber) as $number
   | $number
 )
 | join(" ")
