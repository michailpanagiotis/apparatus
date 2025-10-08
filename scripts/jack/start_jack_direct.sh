# /usr/bin/jackd -R -dalsa -p64 -n3 -D -i2 -o2 &
/usr/bin/jackd -R -dalsa -d $ALSA_DEFAULT -p512 -n3 -P -o2 &
sleep 2
a2jmidid -e &
sleep 1
mplayer -nolirc -ao jack plug.wav &
