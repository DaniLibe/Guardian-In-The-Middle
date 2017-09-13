#!/bin/bash

if [ "$(cat /sys/class/net/enp2s0/carrier 2> /dev/null)" == "1" ]; then
	interface="enp2s0"
	else interface="wlp3s0"
fi

gw_ip=$(route -n | cut -c 17- | grep $interface | cut -c -16 | tr '\n' '\t' | cut -f 1)
gw_mac=$(arp -a $gw_ip | tr ' ' '\t' | cut -f 4)
local_ip=$(hostname -i)

while sleep 3; do
	curr_gw_mac=$(arp -a $gw_ip | tr ' ' '\t' | cut -f 4)

	if [ "$curr_gw_mac" != "$gw_mac" ]; then
		iptables -t filter -I OUTPUT -s $local_ip -j DROP
		su daniele -c "notify-send \"Attacco MITM bloccato!\" \"MAC attacker: $curr_gw_mac\""
		break
	fi
done
