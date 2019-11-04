#This script will configure the eth0 network card
#It is possible that you will receive an error when the script tries to bring up the eth0 network
#"sudo ifup eth0" - Just ensure that after the script has run that you can ping


#Getting local variables from the user to setup the network
read -p   "Please enter the IP Address: " IP #yep
read -p   "Please enter the Subnet Mask: " SUBNET
read -p   "Please enter the gateway: " GATE
read -p   "Please enter the DNS server IP Address: " DNS

#This set of commands adds the previously entered network information into the network config file
#which is located at /etc/network/interfaces
sudo sed -i "s/address.*/address $IP/" /etc/network/interfaces
sudo sed -i "s/gateway.*/gateway $GATE/" /etc/network/interfaces
sudo sed -i "s/netmask.*/netmask $SUBNET/" /etc/network/interfaces
sudo sed -i "s/dns-nam.*/dns-nameservers $DNS/" /etc/network/interfaces


#This variable retrieves the last octet of the IP address in order to determine the
#Network and Broadcast addresses
OCT="$(echo $IP | tail -c 4 | sed "s/\./""/")"

#Several nested IF loops utilized to determine which range the last octet of the Ip address falls
#into. Once this is calculated, it assings the proper network and broadcast address
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


			
#This variable grabs the first 3 octets of the IP address, allows the configuration of the 
#network and broadcast address			
NETWORK="$(echo $IP | sed "s/\.$OCT/""/")"

#Sets the Network address variable
NETADDR=$NETWORK$NET

#Sets the Broadcast address variable
BROADADDR=$NETWORK$BROAD

#These 2 commands write the network address and the broadcast address to the network
#configuration file which is located at /etc/network/interfaces
sudo sed -i "s/network.*/network $NETADDR/" /etc/network/interfaces
sudo sed -i "s/broadcast.*/broadcast $BROADADDR/" /etc/network/interfaces

#This brings the eth0 network up. If the network is already up, this will provide an error
#Ensure that you are able to ping after the script is completed.
sudo ifup eth0
