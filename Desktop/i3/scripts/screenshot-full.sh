#!/bin/bash

# Create Screenshots directory if it doesn't exist
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with date and time
FILENAME="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# See screenshot-selection.sh for why this delay exists — same
# blur-gets-baked-into-the-capture issue (maim issue #290). Give any
# in-flight transition a moment to settle instead of killing picom,
# which would strip the rice out of the shot entirely.
sleep 0.3

# Take fullscreen screenshot with maim
maim -u "$FILEPATH"

# Copy to clipboard using xclip
xclip -selection clipboard -target image/png -i "$FILEPATH"

# Optional: Send notification
notify-send "Screenshot taken" "Full screenshot saved to $FILENAME and copied to clipboard" -t 2000
