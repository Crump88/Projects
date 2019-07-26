read -p   "Please enter the IP Address: " IP
read -p   "Please enter the Subnet Mask: " SUBNET
read -p   "Please enter the gateway: " GATE
read -p   "Please enter the DNS server IP Address: " DNS

sudo sed -i "s/address.*/address $IP/" /etc/network/interfaces
sudo sed -i "s/gateway.*/gateway $GATE/" /etc/network/interfaces
sudo sed -i "s/netmask.*/netmask $SUBNET/" /etc/network/interfaces
sudo sed -i "s/dns-nam.*/dns-nameservers $DNS/" /etc/network/interfaces



OCT="$(echo $IP | tail -c 4 | sed "s/\./""/")"

if [ "$OCT" -ge "0" -a "$OCT" -le "31" ]
then
	NET=".0"
	BROAD=".31"
else
	if [ "$OCT" -ge "32" -a "$OCT" -le "63" ] 
	then
		NET=".32"
		BROAD=".63"
	else
		if [ "$OCT" -ge "64" -a "$OCT" -le "95" ] 
		then
			NET=".64"
			BROAD=".95"
		else
	if [ "$OCT" -ge "96" -a "$OCT" -le "99" ]
	then
		NET=".96"
		BROAD=".127"
	else
		if [ "$OCT" -ge "100" -a "$OCT" -le "127" ] 
		then 
			NET=".96"
			BROAD=".127"
		else

if [ "$OCT" -ge "128" -a "$OCT" -le "159" ] 
then
	NET=".128"
	BROAD=".159"
else
	if [ "$OCT" -ge "160" -a "$OCT" -le "191" ] 

	then
		NET=".160"
		BROAD=".191"
	else
		if [ "$OCT" -ge "192" -a "$OCT" -le "223" ] 

		then
			NET=".192"
			BROAD=".223"
		else
			if [ "$OCT" -ge "224" -a "$OCT" -le "255" ] 

			then
				NET=".224"
				BROAD=".255"
			fi
		fi
	fi
fi
			fi
		fi
	fi
fi
			fi


NETWORK="$(echo $IP | sed "s/\.$OCT/""/")"

NETADDR=$NETWORK$NET
BROADADDR=$NETWORK$BROAD

sudo sed -i "s/network.*/network $NETADDR/" /etc/network/interfaces
sudo sed -i "s/broadcast.*/broadcast $BROADADDR/" /etc/network/interfaces

sudo ifup eth0
