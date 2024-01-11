# https://stackoverflow.com/questions/30172253/cumulative-sum-in-jq
foreach .[] as $row
  (0;
   . + ($row | .[1]) ;
   . as $x | $row | (.[1] = $x))

# reduce .[1:][] as $row
#   ([.[0]];
#    . as $x
#    | $x + [ $row | (f = ($x | .[length-1] | f) + ($row|f)  ) ] );
