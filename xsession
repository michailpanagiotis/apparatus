#!/bin/sh

# Configure X
xrdb -merge ~/.Xdefaults &
xrdb -merge ~/.Xresources &
setxkbmap us,el -option "grp:alt_shift_toggle" &
# xrandr --auto --output HDMI1 --mode 1920x1080 --left-of VGA1 --primary --output VGA1 --mode 1920x1080

#feh --bg-scale /home/stathopa/Dropbox/cave-on-the-beach-wallpaper.jpg
#feh --bg-fill /home/stathopa/Pictures/bahamas_1600x1200.jpg
#feh --bg-scale /home/stathopa/Dropbox/light_paint.jpg

stalonetray -c ~/.xmonad/stalonetrayrc-single &

xscreensaver -nosplash &
#tomboy &
# gol &
# dropbox start
#pidgin &

exec ck-launch-session dbus-launch --sh-syntax --exit-with-session xmonad
