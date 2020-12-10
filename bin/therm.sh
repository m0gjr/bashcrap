#!/bin/bash

settemp=60
therm='/sys/devices/virtual/thermal/thermal_zone*/temp'
cpus='/sys/devices/system/cpu/cpu'

while true
do

	temp=$(cat $therm | sort | tail -n1)00

	freqcur=$(cat ${cpus}0/cpufreq/scaling_max_freq)
	freqmax=$(cat ${cpus}0/cpufreq/cpuinfo_max_freq)
	freqmin=$(cat ${cpus}0/cpufreq/cpuinfo_min_freq)

	freqnew=$(($freqcur + ${settemp}00000 - $temp))

	[ $freqnew -gt $freqmax ] && freqnew=$freqmax
	[ $freqnew -lt $freqmin ] && freqnew=$freqmin

	echo $freqnew

	for cpu in $cpus*
	do
		echo $cpu | grep -e "${cpus}[0-9]" > /dev/null || continue
		echo $freqnew > $cpu/cpufreq/scaling_max_freq
	done

	sleep 2

done
