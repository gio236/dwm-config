#!/bin/bash

xrandr --output HDMI-1 --mode 1400x1050 --rate 75
picom &

/home/gioele/scripts/./check_wall.sh /home/gioele/wallpapers/current/*
RETURN=$?

if [ $RETURN -eq 1 ]; then
    echo "L'immagine è più piccola!"
    feh --bg-center /home/gioele/wallpapers/current/*
else
    echo "L'immagine è ok!"
    feh --bg-fill /home/gioele/wallpapers/current/*
fi
