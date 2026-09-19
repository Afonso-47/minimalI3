#!/bin/bash

# Create Screenshots directory if it doesn't exist
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with date and time
FILENAME="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# Take selection screenshot with maim (-s selection, -u include cursor)
maim -s -u "$FILEPATH"

if [ $? -eq 0 ] && [ -f "$FILEPATH" ]; then
    xclip -selection clipboard -target image/png -i "$FILEPATH"
    notify-send "Screenshot taken" "Selection screenshot saved to $FILENAME and copied to clipboard" -t 2000
else
    [ -f "$FILEPATH" ] && rm "$FILEPATH"
    notify-send "Screenshot cancelled" "No screenshot was taken" -t 2000
fi
