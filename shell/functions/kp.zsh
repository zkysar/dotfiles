# kp: fuzzy-pick a Keeper record and copy a secret to the clipboard.
# Login records copy the password; records without one (cards, etc.) open a
# field picker (card number, expiration, CVC, PIN, ...). Values never pass
# through fzf. Clipboard clears after 30s.
#
# Security comes from Keeper, not this function: persistent login is OFF and
# biometric login is registered, so every `keeper` process needs Touch ID.
# To keep it to one tap per copy, the record list (uid, title, type only, no
# secrets) is cached. `kp -r` refreshes it (one extra tap).
kp() {
  [[ $OSTYPE == darwin* ]] || { echo "kp: macOS only" >&2; return 1; }

  local cache="$HOME/.cache/kp/records.tsv"
  if [[ $1 == -r || ! -s $cache ]]; then
    mkdir -p "${cache:h}"
    # stderr stays on the terminal so Touch ID / login prompts are visible.
    # Keeper can print noise before the JSON; drop lines before the first '['.
    keeper list --format json | sed -n '/^\[/,$p' \
      | jq -r '.[] | "\(.record_uid)\t\(.title)\t[\(.type // "legacy")]"' >"$cache.tmp" \
      && [[ -s $cache.tmp ]] && mv "$cache.tmp" "$cache" \
      || { rm -f "$cache.tmp"; echo "kp: could not list records (try: keeper login)" >&2; return 1; }
  fi

  local pick uid title
  pick=$(fzf --with-nth=2.. --delimiter='\t' --prompt='keeper> ' <"$cache") || return 0
  uid=${pick%%$'\t'*}
  title=${${pick#*$'\t'}%%$'\t'*}

  local json
  json=$(keeper get "$uid" --format json | sed -n '/^{/,$p')
  [[ -n $json ]] || { echo "kp: keeper get failed (record gone? run kp -r)" >&2; return 1; }

  # Flatten the record into [{name, value}] of copyable scalars.
  # v3 records: fields + custom; paymentCard expands into its sub-fields.
  # Legacy (v2) records: top-level login/password.
  local items='
    def nice: {cardNumber: "card number", cardExpirationDate: "expiration",
               cardSecurityCode: "cvc"}[.] // .;
    if has("fields") then
      [ (.fields + (.custom // []))[]
        | select((.value | length) > 0)
        | select(.type | IN("fileRef", "addressRef", "cardRef", "oneTimeCode") | not)
        | (if (.label // "") == "" then .type else .label end) as $name
        | if .type == "paymentCard" then
            .value[0] | to_entries[] | select(.value != "")
            | {name: (.key | nice), value: (.value | tostring)}
          elif (.value[0] | type) == "string" or (.value[0] | type) == "number" then
            {name: $name, value: (.value[0] | tostring)}
          else empty end ]
    else
      [ {name: "password", value: .password}, {name: "login", value: .login} ]
      | map(select(.value != null and .value != ""))
    end'

  local idx
  idx=$(print -r -- "$json" | jq -r "$items | map(.name) | index(\"password\") // empty")
  if [[ -z $idx ]]; then
    idx=$(print -r -- "$json" \
      | jq -r "$items | to_entries[] | \"\(.key)\t\(.value.name)\"" \
      | fzf --with-nth=2 --delimiter='\t' --prompt="$title> " | cut -f1)
    [[ -n $idx ]] || return 0
  fi

  local name val
  name=$(print -r -- "$json" | jq -r "$items | .[$idx].name")
  val=$(print -r -- "$json" | jq -r "$items | .[$idx].value")
  [[ -n $val ]] || { echo "kp: nothing to copy" >&2; return 1; }

  print -rn -- "$val" | pbcopy
  echo "kp: copied $name from \"$title\" (clears in 30s)"
  # Clear only if the clipboard still holds this secret.
  ( sleep 30; [[ "$(pbpaste)" == "$val" ]] && print -n | pbcopy ) &!
}
