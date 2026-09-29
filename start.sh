#!/usr/bin/env bash
#
# Bring the suite up for development.
#
# Four processes, because there are four runtimes. They are started in dependency
# order and the whole group dies together — a stray engine holding port 4177 after
# a Ctrl-C is the single most common way to lose an afternoon on this project.
#
#   engine     127.0.0.1:4177   the WebSocket the courtroom talks to
#   courtroom  127.0.0.1:5173   Vite, React 18, the 3D hearing
#   classroom  127.0.0.1:3001   Next 14, React 18, the language room
#   lms        127.0.0.1:3000   Next 15, React 19, Converso itself
#
# The LMS is last on purpose: it is the one you open, and by the time it answers
# the two scenes it launches are already listening.
#
# Usage:  ./start.sh            everything
#         ./start.sh lms        just Converso
#         ./start.sh engine courtroom
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -d node_modules ]; then
  echo "No node_modules. Run: npm install" >&2
  exit 1
fi

# Every child goes into this process group so one signal reaches all of them.
pids=()

shutdown() {
  trap - INT TERM EXIT
  echo
  echo "stopping…"
  for pid in "${pids[@]:-}"; do
    kill "$pid" 2>/dev/null || true
  done
  wait 2>/dev/null || true
  exit 0
}
trap shutdown INT TERM EXIT

start() {
  local name=$1; shift
  printf '  %-10s %s\n' "$name" "$*"
  "$@" 2>&1 | sed "s/^/[$name] /" &
  pids+=($!)
}

want() {
  # No arguments means everything.
  [ $# -eq 0 ] && return 0
  local needle=$1; shift
  for arg in "$@"; do [ "$arg" = "$needle" ] && return 0; done
  return 1
}

requested=("$@")

echo "converso-suite"

if want engine "${requested[@]:-}"; then
  start engine npm start --workspace apps/courtroom-engine
  # The courtroom retries on a backoff if it connects first, so this is a
  # courtesy rather than a requirement.
  sleep 1
fi

want courtroom "${requested[@]:-}" && start courtroom npm run dev --workspace apps/courtroom
want classroom "${requested[@]:-}" && start classroom npm run dev --workspace apps/classroom
want lms       "${requested[@]:-}" && start lms       npm run dev --workspace apps/lms

echo
echo "  open http://localhost:3000    ·  Ctrl-C stops all of it"
echo

wait
