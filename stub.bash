BATS_MOCK_TMPDIR="${BATS_TMPDIR}"
BATS_MOCK_BINDIR="${BATS_MOCK_TMPDIR}/bin"

MKDIR=$(which mkdir)
LN=$(which ln)
RM=$(which rm)
PATH="$BATS_MOCK_BINDIR:$PATH"

stub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  shift

  export "${prefix}_STUB_PLAN"="${BATS_MOCK_TMPDIR}/${program}-stub-plan"
  export "${prefix}_STUB_RUN"="${BATS_MOCK_TMPDIR}/${program}-stub-run"
  export "${prefix}_STUB_END"=

  "$MKDIR" -p "${BATS_MOCK_BINDIR}"
  "$LN" -sf "${BASH_SOURCE[0]%stub.bash}binstub" "${BATS_MOCK_BINDIR}/${program}"

  touch "${BATS_MOCK_TMPDIR}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${BATS_MOCK_TMPDIR}/${program}-stub-plan"; done
}

unstub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  local path="${BATS_MOCK_BINDIR}/${program}"

  export "${prefix}_STUB_END"=1

  local STATUS=0
  "$path" || STATUS="$?"

  "$RM" -f "$path"
  "$RM" -f "${BATS_MOCK_TMPDIR}/${program}-stub-plan" "${BATS_MOCK_TMPDIR}/${program}-stub-run"
  return "$STATUS"
}
