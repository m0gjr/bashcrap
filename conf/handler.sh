#!/bin/sh

export XAUTHORITY="/root/.Xauthority"
export DISPLAY=":0"

case "$1" in
	button/power)
		case "$2" in
			PBTN|PWRF)
			init 0
			;;
		esac
		;;
	battery)
		acpi="$(acpi)"
		if [ "$(echo $acpi | cut -d' ' -f3)" != "Charging," ] && [ $(echo $acpi | cut -d' ' -f4 | cut -d'%' -f1) -lt 30 ]
		then
			beep
			xmessage -timeout 3 "$acpi"&
			beep
		fi
		;;
	button/lid)
	case "$3" in
		close)
			cat /sys/class/backlight/intel_backlight/brightness > /run/brightness
			echo mem > /sys/power/state
			;;
		open)
			cat /run/brightness > /sys/class/backlight/intel_backlight/brightness
			;;
	esac
	;;
esac
