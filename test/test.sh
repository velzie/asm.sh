N="[0m"
R="[1;31m"
# R="[38;5;208m$(printf "\x25\xCF" | iconv -f utf-16be)$N"
S="[38;5;208m$(printf "\x25\xBA" | iconv -f utf-16be)$N"
F="[38;5;167m$(printf "\x27\x18" | iconv -f utf-16be)$N"
P="[38;5;106m$(printf "\x27\x14" | iconv -f utf-16be)$N"



echo "--- [1;36m starting tests[0m ---"

for test in test/*-*.sh; do
  echo "$S $test"
  source "$test"

  $SHELL +x <<EOF >"/tmp/test.out"
. $test
run
exit 41
EOF
  exit=$?
  

  diff --color -U3 "/tmp/test.out" <(expect | xxd -p -r) >/tmp/diff
  diff=$?

  if [ "$exit" = "41" ] && [ "$diff" = "0" ]; then
    echo "$P $test passed!$N"
  else
    echo "$F $R$test failed with exit $exit!$N"
    cat /tmp/diff
    rm -f /tmp/diff
    echo "see /tmp/test.out for more information"
    exit
  fi
done


echo "--- [1;36m all tests passed![0m ---"
