xrdb -load ~/.Xdefaults
xrdb -merge ~/.urxvt.tango.theme
setxkbmap us,el -option "grp:alt_shift_toggle"
#xmodmap /home/stathopa/.Xmodmap
xrandr --auto --output HDMI1 --mode 1920x1080 --left-of VGA1 --primary --output VGA1 --mode 1920x1080
#feh --bg-scale /home/stathopa/Dropbox/cave-on-the-beach-wallpaper.jpg
#feh --bg-fill /home/stathopa/Pictures/bahamas_1600x1200.jpg
#feh --bg-scale /home/stathopa/Dropbox/light_paint.jpg
/home/mike/.bin/tray &
xscreensaver -nosplash &
#tomboy &
gol &
dropbox start
#pidgin &
exec xmonad
