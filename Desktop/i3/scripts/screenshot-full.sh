#!/bin/bash

# Create Screenshots directory if it doesn't exist
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with date and time
FILENAME="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# See screenshot-selection.sh for why picom is paused here — same
# blur-gets-baked-into-the-capture issue (maim issue #290), applied
# here too in case something's still mid-fade/blur transition.
PICOM_WAS_RUNNING=false
if pgrep -x picom > /dev/null; then
    PICOM_WAS_RUNNING=true
    pkill -x picom
    sleep 0.2
fi

# Take fullscreen screenshot with maim
maim -u "$FILEPATH"

if $PICOM_WAS_RUNNING; then
    picom &
    disown
fi

# Copy to clipboard using xclip
xclip -selection clipboard -target image/png -i "$FILEPATH"

# Optional: Send notification
notify-send "Screenshot taken" "Full screenshot saved to $FILENAME and copied to clipboard" -t 2000
