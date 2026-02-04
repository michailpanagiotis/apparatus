#!/bin/bash

jack_control stop
jack_control ds alsa
jack_control dps device hw:0
jack_control dps rate 48000
jack_control dps nperiods 3
jack_control dps period 128
jack_control start

a2j_control --ehw && a2j_control --start
