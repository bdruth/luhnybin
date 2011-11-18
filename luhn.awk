# luhn - checks if a string of digits is a valid credit card number
# unlike other right-to-left scanning toggle and calculate
# implementations, this one does less than half the work
# author: ozan s. yigit
# insert bsd copyright here

BEGIN {
  # generate all two digit sequences, with appropriate
  # luhn translation of the first digit.

  for (i = 0; i < 10; i++)
    for (n = 0; n < 10; n++) {
      t = i * 2;
      if (t > 9)
        t = t - 9
      pairmap[i n] = t + n
    }
}

function luhn(digits,    sum, n, i)
{
  i = 1           # index
  sum = 0
  n = length(digits)
  # if the length is odd, save+skip the first char
  if ((n % 2) > 0)
    sum = substr(digits, i++, 1)

  while (i <= n) {
    pair = substr(digits, i, 2)
    ## print i ": ", pair, "->", pairmap[pair]
    sum += pairmap[pair]
    i += 2
  }
  ## print sum
  return sum % 10 == 0
}

function get_matches(search_string) {
  match(search_string, /([0-9]{14,16})/, arr)
  if (length(arr) < 1) {
    match(search_string, /([0-9]{4} [0-9]{4} [0-9]{4} [0-9]{2,4})/, arr)
    if (length(arr) < 1) {
      match(search_string, /([0-9]{4}\-[0-9]{4}\-[0-9]{4}\-[0-9]{2,4})/, arr)
    }
  }
}

function check_last_X(x) {
  if (length(arr) > 1) {
    last_x = arr[1]
    if (luhn(last_x)) {
      result = substr(result, 1, length(result) - x) gensub(/[0-9]/, "X", "g", last_x)
    }
  }
}

{
  if ($0 ~ /[0-9]{4}/) {
    result = $0
    line_remainder = result
    get_matches(result)
    #print "Matches: " length(arr)
    while (length(arr) > 1) {
      longest_match = arr[1]
      longest_match = gensub(/\-| /, "", "g", longest_match)
      if (luhn(longest_match)) {
        match_string = substr(line_remainder, RSTART, RLENGTH)
        mask = gensub(/[0-9]/, "X", "g", match_string)
        result = gensub(arr[1], mask, "g", result)
      }
      if (length(line_remainder) > (RSTART + RLENGTH)) {
        line_remainder = substr(line_remainder, (RSTART + 1))
        get_matches(line_remainder)
      } else {
        # check the end ... 
        match($0, /([0-9]{14})[^0-9]*$/, arr)
        check_last_X(14)
        match($0, /([0-9]{15})[^0-9]*$/, arr)
        check_last_X(15)
        match($0, /([0-9]{16})[^0-9]*$/, arr)
        check_last_X(16)
        delete arr
      }
    }
    print result
  }
  else {
    print $0
  }
}