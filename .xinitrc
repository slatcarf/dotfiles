#!/bin/sh

# /etc/X11/xinit/xinitrc

# global xinitrc file, used by all X sessions started by xinit (startx)

# invoke global X session script
setxkbmap -option caps:super
setxkbmap -layout us,de
setxkbmap -option 'grp:alt_shift_toggle'
. /etc/X11/Xsession

exec i3 

