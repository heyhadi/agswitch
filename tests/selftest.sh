#!/bin/bash
# Self-test with dummy Keychain items; never touches the real "gemini" login.
set -u
S="$(cd "$(dirname "$0")/.." && pwd)/agswitch"
T=$(mktemp -d)
export AGSWITCH_TEST=1 AGSWITCH_SVC=agsw-selftest AGSWITCH_DIR=$T/store AGSWITCH_ACCOUNTS_JSON=$T/acc.json
fail=0
ok() { if eval "$1"; then echo "ok: $2"; else echo "FAIL: $2"; fail=1; fi; }
put() { local esc; esc=$(printf '%s' "$3" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf 'add-generic-password -U -s "%s" -a "%s" -w "%s"\n' "$1" "$2" "$esc" | security -i; }
get() { security find-generic-password -s agsw-selftest -w 2>/dev/null; }
cleanup() { for s in agsw-selftest agswitch:a agswitch:b; do security delete-generic-password -s "$s" >/dev/null 2>&1; done; rm -rf "$T"; }
trap cleanup EXIT

A='{"token":"AAA \"q\""}'; B='{"token":"BBB\\x"}'
put agsw-selftest a@test "$A"; echo '{"active":"a"}' > "$T/acc.json"
"$S" name a >/dev/null; "$S" new >/dev/null
ok '! security find-generic-password -s agsw-selftest >/dev/null 2>&1' "new clears the active login"
put agsw-selftest b@test "$B"; echo '{"active":"b"}' > "$T/acc.json"
"$S" name b >/dev/null
"$S" use a >/dev/null
ok '[ "$(get)" = "$A" ] && grep -q "\"a\"" "$T/acc.json"' "use a restores a"
"$S" use b >/dev/null
ok '[ "$(get)" = "$B" ] && grep -q "\"b\"" "$T/acc.json"' "use b restores b"
touch -t 202001010000 "$T/store/a.saved"; "$S" list >/dev/null
ok '! security find-generic-password -s agswitch:a >/dev/null 2>&1' "expired account is removed from Keychain"
ok '! "$S" use a >/dev/null 2>&1' "expired account cannot be used"
exit $fail
