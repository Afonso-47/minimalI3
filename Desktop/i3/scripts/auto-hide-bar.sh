#!/bin/bash

# Prevent duplicate instances (e.g. after an i3 restart or a stale
# process surviving a reboot) from fighting over bar mode.
lockfile="/tmp/auto-hide-bar.lock"
if ! mkdir "$lockfile" 2>/dev/null; then
    exit 0
fi
trap 'rmdir "$lockfile"' EXIT

pin_flag="/tmp/bar_pinned_flag"
bar_visible=false

while true; do
    # Reliable liveness check: talk to i3's actual IPC socket instead of
    # scanning the process table. If i3/X is gone this fails immediately
    # (command errors or hangs on a dead socket), instead of relying on
    # pgrep timing, which can miss the exit and leave this loop orphaned.
    if ! i3-msg -t get_version > /dev/null 2>&1; then
        exit 0
    fi

    # Pinned: force the bar to stay visible and skip hover logic entirely.
    if [ -f "$pin_flag" ] && [ "$(cat "$pin_flag" 2>/dev/null)" = "1" ]; then
        if ! $bar_visible; then
            i3-msg bar mode dock > /dev/null
            bar_visible=true
        fi
        sleep 0.2
        continue
    fi

    MOUSE_Y=$(xdotool getmouselocation --shell | grep Y | cut -d'=' -f2)
    if $bar_visible; then
        if [ "$MOUSE_Y" -gt 20 ]; then
            i3-msg bar mode hide > /dev/null
            bar_visible=false
        fi
    else
        if [ "$MOUSE_Y" -le 5 ]; then
            i3-msg bar mode dock > /dev/null
            bar_visible=true
        fi
    fi
    sleep 0.1
done
