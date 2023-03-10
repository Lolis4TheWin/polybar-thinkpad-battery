#!/bin/bash

# Get the current battery levels
bat1=$(cat /sys/class/power_supply/BAT0/capacity)
bat2=$(cat /sys/class/power_supply/BAT1/capacity)

# Calculate the average battery level
average=$(( ($bat1 + $bat2) / 2 ))

# Get the charging status of each battery
status1=$(cat /sys/class/power_supply/BAT0/status)
status2=$(cat /sys/class/power_supply/BAT1/status)

# Check if any of the batteries is charging
charging=false
if [ "$status1" == "Charging" ] || [ "$status2" == "Charging" ]; then
  charging=true
fi

# Battery current watt usage
if [ $(cat /sys/class/power_supply/BAT1/power_now)  == 0 ]; then
  bat_watt=$(awk '{print $1*10^-6 "W"}' /sys/class/power_supply/BAT0/power_now)
else
  bat_watt=$(awk '{print $1*10^-6 "W"}' /sys/class/power_supply/BAT1/power_now)
fi

# Get the AC adapter status
ac_status=$(cat /sys/class/power_supply/AC/online)

# Output the battery levels, charging status, and AC adapter status
if [ "$charging" == true ] && [ "$ac_status" == 1 ]; then
  echo "%{F#00ff00}↑%{F-}%{F#00ff00}%{F-}  $average% $bat_watt AC" # charging, green color 
elif [ "$charging" == true ] && [ "$ac_status" == 0 ]; then
  echo "Average battery level: $average%, charging, AC unplugged"
elif [ "$charging" == false ] && [ "$ac_status" == 1 ]; then
  echo "%{F#FFFFFF}%{F-} $average% $bat_watt AC" # bat is at max 
else
  echo "%{F#FFAA00}%{F-} $average% $bat_watt" # discharging 
fi
