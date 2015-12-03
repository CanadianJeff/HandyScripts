firmware="/tmp/"

function control_C(){
echo "Flashing Router"
echo -en "binary\nput $firmware\nquit\n" | tftp 192.168.1.1
exit 0
}
trap control_C INT
while true;
do
echo "Restarting Network.."
ifconfig eth0 down
ifconfig eth0 up
ifconfig eth0 192.168.1.2 netmask 255.255.0.0
route add default gw 192.168.1.1
echo "Checking Address Setting"
ifconfig eth0 | awk '/Bcast/ {print $2}' | cut -f2 -d ':'
echo "Plug In Router!!!"
sleep 5
ifconfig eth0 | awk '/Bcast/ {print $2}' | cut -f2 -d ':'
echo "Pinging Router Now.."
echo "Press CTRL+C To Flash"
ping 192.168.1.1 -c 20 -i 1
done
