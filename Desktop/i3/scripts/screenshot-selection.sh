#!/bin/bash

# Create Screenshots directory if it doesn't exist
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with date and time
FILENAME="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# picom's blur/fade compositing gets baked directly into maim's capture —
# a window that's mid-transition (unfocused blur, fade-in/out) when the
# selection is grabbed shows up blurred in the screenshot itself. This is
# a known, still-open maim/picom interaction (maim issue #290), not
# something fixable from maim's side. Work around it by briefly pausing
# picom for the selection, then restarting it right after.
PICOM_WAS_RUNNING=false
if pgrep -x picom > /dev/null; then
    PICOM_WAS_RUNNING=true
    pkill -x picom
    # give X a moment to repaint the now-uncomposited frame before maim grabs it
    sleep 0.2
fi

# Take selection screenshot with maim
# -s for selection, -u to include cursor
maim -s -u "$FILEPATH"
MAIM_STATUS=$?

# Restart picom if it was running before
if $PICOM_WAS_RUNNING; then
    picom &
    disown
fi

# Check if a selection was made (maim returns non-zero if cancelled)
if [ $MAIM_STATUS -eq 0 ] && [ -f "$FILEPATH" ]; then
    # Copy to clipboard using xclip
    xclip -selection clipboard -target image/png -i "$FILEPATH"
    
    # Optional: Send notification
    notify-send "Screenshot taken" "Selection screenshot saved to $FILENAME and copied to clipboard" -t 2000
else
    # Clean up empty file if selection was cancelled
    [ -f "$FILEPATH" ] && rm "$FILEPATH"
    notify-send "Screenshot cancelled" "No screenshot was taken" -t 2000
fi
