

[inputs] | map(select(test("{"))) | join("") | "[" + . + "]" | fromjson
