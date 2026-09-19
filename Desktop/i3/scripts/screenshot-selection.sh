#!/bin/bash

# Create Screenshots directory if it doesn't exist
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with date and time
FILENAME="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# picom's blur/fade compositing gets baked directly into maim's capture —
# a window that's mid-transition (unfocused blur, fade-in/out) when the
# selection is grabbed shows up blurred/half-faded in the screenshot
# itself. This is a known, still-open maim/picom interaction (maim issue
# #290). Rather than killing picom (which would strip out the rice
# entirely — rounded corners, blur, everything — from the shot), just
# give any in-flight transition time to settle before maim grabs the
# frame. picom's transitions are quick, so this is enough in practice.
sleep 0.3

# Take selection screenshot with maim
# -s for selection, -u to include cursor
maim -s -u "$FILEPATH"
MAIM_STATUS=$?

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
