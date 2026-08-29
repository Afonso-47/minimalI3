#!/bin/bash

# Create Screenshots directory if it doesn't exist
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with date and time
FILENAME="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# Take fullscreen screenshot with maim
maim -u "$FILEPATH"

# Copy to clipboard using xclip
xclip -selection clipboard -target image/png -i "$FILEPATH"

notify-send "Screenshot taken" "Full screenshot saved to $FILENAME and copied to clipboard" -t 2000
