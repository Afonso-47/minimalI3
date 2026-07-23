#!/bin/bash

# Create Screenshots directory if it doesn't exist
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with date and time
FILENAME="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# Take selection screenshot with maim
# -s for selection, -u to include cursor
maim -s -u "$FILEPATH"

# Check if a selection was made (maim returns non-zero if cancelled)
if [ $? -eq 0 ] && [ -f "$FILEPATH" ]; then
    # Copy to clipboard using xclip
    xclip -selection clipboard -target image/png -i "$FILEPATH"
    
    # Optional: Send notification
    notify-send "Screenshot taken" "Selection screenshot saved to $FILENAME and copied to clipboard" -t 2000
else
    # Clean up empty file if selection was cancelled
    [ -f "$FILEPATH" ] && rm "$FILEPATH"
    notify-send "Screenshot cancelled" "No screenshot was taken" -t 2000
fi
