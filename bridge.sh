echo
echo "Network Bridge Setup Script"
echo
read -e -p "Bridge Adapter #1: " bridge1
read -e -p "Bridge Adapter #2: " bridge2
read -e -p "IP Address Of Bridge: " ip
read -e -p "Netmask: " netmask
read -e -p "Gateway: " gateway
echo
echo "All Done Review Settings"
echo
echo "+===================================+"
echo "| Bridging: $bridge1 $bridge2 "
echo "| IP: $ip "
echo "| Netmask: $netmask "
echo "| Gateway: $gateway "
echo "+===================================+"
echo
read -e -p "Press Enter To Continue..." enter
# Make Bridge
sudo brctl addbr br0
# Add To Bridge
sudo brctl addif br0 $bridge1
sudo brctl addif br0 $bridge2
# Bring Up Network
sudo ifconfig $bridge1 0.0.0.0 promisc up
sudo ifconfig $bridge2 0.0.0.0 promisc up
# Give Your Bridge An IP Address
sudo ifconfig br0 $ip netmask $netmask
# Bring Up The Bridge
sudo ifconfig br0 up
# Setup The Route
sudo route add default gw $gateway
