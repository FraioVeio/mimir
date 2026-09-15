#!/bin/bash
set -euo pipefail

# audio-playback exposes the real host pulse socket, not the snap-private
# $XDG_RUNTIME_DIR snapd assigns inside the sandbox; point sox at it directly.
export PULSE_SERVER="unix:/run/user/$(id -u)/pulse/native"

exec "$SNAP/bin/mimir-core" "$@"
