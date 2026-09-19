#!/bin/bash
if xrandr --query 2>/dev/null | grep -q "^DP-0 connected"; then
    xrandr --output DP-0 --mode 2560x1440 --primary --pos 0x0 \
           --output HDMI-0 --mode 1920x1080 --pos 2560x0
fi

$HOME/.fehbg
