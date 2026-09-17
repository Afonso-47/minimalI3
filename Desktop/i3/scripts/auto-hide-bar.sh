#!/bin/bash
bar_visible=false
while true; do
    # Check if i3 is still running
    if ! pgrep -x i3 > /dev/null; then
        exit 0
    fi
    
    MOUSE_Y=$(xdotool getmouselocation --shell | grep Y | cut -d'=' -f2)
    if $bar_visible; then
        if [ "$MOUSE_Y" -gt 20 ]; then
            i3-msg bar mode hide
            bar_visible=false
        fi
    else
        if [ "$MOUSE_Y" -le 5 ]; then
            i3-msg bar mode dock
            bar_visible=true
        fi
    fi
    sleep 0.1
done
