mouse&
wifistart&

xsetroot -solid black

setxkbmap gb
setxkbmap -option ctrl:nocaps
xmodmap -e "keycode 108 = Alt_L"
xmodmap -e "keycode 135 = Super_L"
xmodmap -e "keycode 107 = Super_L"

xset s off
xset -dpms

xhost +SI:localuser:browser
xhost +SI:localuser:browsertor
