#!/bin/bash

set -euo pipefail

# Force '.' as the decimal separator for printf/awk regardless of the user's
# locale (e.g. it_IT uses ',', which would otherwise break float parsing).
export LC_NUMERIC=C

readonly VERSION="2.0.0"
readonly PROG_NAME="mimir"

# Standard deviation of the Gaussian speed variation applied to playback.
readonly STANDARD_DEVIATION=0.1

# Function to display help message, mirroring coreutils' `sleep --help`.
function show_help {
    echo "Usage: $PROG_NAME NUMBER[SUFFIX]..."
    echo "  or:  $PROG_NAME inf"
    echo "  or:  $PROG_NAME OPTION"
    echo "Pause for NUMBER seconds, playing sleep sounds while waiting, where NUMBER is"
    echo "an integer or floating-point number. SUFFIX may be 's', 'm', 'h', or 'd', for"
    echo "seconds, minutes, hours, or days. With multiple arguments, pause for the sum"
    echo "of their values. Use 'inf' on its own to pause indefinitely until interrupted."
    echo
    echo "      --help"
    echo "         display this help and exit"
    echo "      --version"
    echo "         output version information and exit"
    echo
    echo "Environment:"
    echo "  MIMIR_AUDIO_DIR   override the directory containing esleep1.wav/esleep2.wav"
    echo
    echo "Examples:"
    echo "  $PROG_NAME 60             Sleep for 60 seconds."
    echo "  $PROG_NAME 1m 30s         Sleep for 90 seconds."
    echo "  $PROG_NAME inf            Sleep indefinitely, interrupt with Ctrl+C."
    exit 0
}

# Function to display version information.
function show_version {
    echo "mimir $VERSION"
    exit 0
}

# Function to handle Ctrl+C / termination
function handle_interrupt {
    exit 1
}

# Trap SIGINT (Ctrl+C) and SIGTERM and call the handle_interrupt function
trap handle_interrupt SIGINT SIGTERM

# Check if help/version is requested
case "${1:-}" in
--help) show_help ;;
--version) show_version ;;
esac

# Check if an argument has been provided
if [ "$#" -lt 1 ]; then
    echo "Error: missing operand." >&2
    echo "Use --help for more information." >&2
    exit 1
fi

# 'inf' pauses indefinitely and cannot be combined with other arguments.
INFINITE_LOOP=false
DURATION=0
if [ "$1" = "inf" ]; then
    if [ "$#" -gt 1 ]; then
        echo "Error: 'inf' cannot be combined with other arguments." >&2
        exit 1
    fi
    INFINITE_LOOP=true
else
    # Sum every NUMBER[SUFFIX] argument, like coreutils' sleep.
    TOTAL=0
    for arg in "$@"; do
        if [[ "$arg" =~ ^([0-9]+(\.[0-9]+)?)([smhd]?)$ ]]; then
            NUMBER="${BASH_REMATCH[1]}"
            SUFFIX="${BASH_REMATCH[3]}"
            case "$SUFFIX" in
            "" | s) MULTIPLIER=1 ;;
            m) MULTIPLIER=60 ;;
            h) MULTIPLIER=3600 ;;
            d) MULTIPLIER=86400 ;;
            esac
            TOTAL=$(awk -v t="$TOTAL" -v n="$NUMBER" -v m="$MULTIPLIER" 'BEGIN { printf "%.6f", t + n * m }')
        else
            echo "Error: invalid time interval '$arg'." >&2
            echo "Use --help for more information." >&2
            exit 1
        fi
    done
    # Elapsed time is tracked in whole seconds, so round the total.
    DURATION=$(printf "%.0f" "$TOTAL")
fi

# Starting timestamp
START=$(date +%s)

# Locate the directory containing the audio files: an explicit override, the
# installed prefix layout (<prefix>/bin/../share/mimir), or a checkout run in
# place (this script's directory).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIO_DIR=""
for candidate in "${MIMIR_AUDIO_DIR:-}" "$SCRIPT_DIR/../share/mimir" "$SCRIPT_DIR/mimir"; do
    if [ -n "$candidate" ] && [ -f "$candidate/esleep1.wav" ] && [ -f "$candidate/esleep2.wav" ]; then
        AUDIO_DIR="$candidate"
        break
    fi
done

if [ -z "$AUDIO_DIR" ]; then
    echo "Error: could not locate esleep1.wav/esleep2.wav." >&2
    echo "Set MIMIR_AUDIO_DIR to the directory containing them." >&2
    exit 1
fi

FILE1="$AUDIO_DIR/esleep1.wav"
FILE2="$AUDIO_DIR/esleep2.wav"

# Parameters for Gaussian distribution
MEAN=1.0

# Set the maximum delay in seconds (adjust this as needed)
DELAY_SD=0.5

# Generate a random speed using a Gaussian distribution, retrying until a
# positive value is drawn. Seeded from bash's builtin $RANDOM so each call
# gets a fresh seed without spawning extra processes.
function generate_random_speed {
    awk -v mean="$MEAN" -v sd="$STANDARD_DEVIATION" -v seed="$RANDOM$RANDOM" 'BEGIN {
        srand(seed)
        pi = atan2(0, 1) * 2
        do {
            u1 = rand()
            u2 = rand()
            if (u1 == 0) u1 = 1e-9
            z0 = sqrt(-2 * log(u1)) * cos(2 * pi * u2)
            result = z0 * sd + mean
        } while (result <= 0)
        printf "%.6f", result
    }'
}

# Generate a random delay using the absolute value of a Gaussian distribution.
function generate_random_delay {
    awk -v sd="$DELAY_SD" -v seed="$RANDOM$RANDOM" 'BEGIN {
        srand(seed)
        pi = atan2(0, 1) * 2
        u1 = rand()
        u2 = rand()
        if (u1 == 0) u1 = 1e-9
        z0 = sqrt(-2 * log(u1)) * cos(2 * pi * u2)
        result = z0 * sd
        if (result < 0) result = -result
        printf "%.6f", result
    }'
}

# Play one audio file at a randomized speed, then sleep a randomized delay.
# Playback failures (e.g. no audio device available) are not fatal: mimir's
# job is to keep sleeping regardless.
function play_and_delay {
    local file="$1"
    local speed
    speed=$(awk -v s="$(generate_random_speed)" 'BEGIN { printf "%.2f", 1 / s }')
    sox "$file" -d speed "$speed" >/dev/null 2>&1 || true

    local delay
    delay=$(generate_random_delay)
    sleep "$delay"
}

# Loop to play the files until the time has elapsed
while true; do
    play_and_delay "$FILE1"

    if [ "$INFINITE_LOOP" = false ]; then
        NOW=$(date +%s)
        ELAPSED=$((NOW - START))
        if [ "$ELAPSED" -ge "$DURATION" ]; then
            break
        fi
    fi

    play_and_delay "$FILE2"

    if [ "$INFINITE_LOOP" = false ]; then
        NOW=$(date +%s)
        ELAPSED=$((NOW - START))
        if [ "$ELAPSED" -ge "$DURATION" ]; then
            break
        fi
    fi
done
