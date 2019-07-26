#This script will remove all pertinent information allowing to templatize a Ubuntu server

#This is based on the webpage - virtxpert.com/preparing-ubuntu-template-virtual-machines/

#Not all commands on this web page have been utilized, and I have added some commands as well
#clearing on the network information

#Cleans out the .deb packages from /var/cache/apt/archive (Does not remove installed applications) 

read -p "$(tput setaf 2)Running this script will cause this server to become a template. It will 
remove various logs, get rid of the command history, and remove the network and hostname 
configuration. Are you sure you want to proceed? [Y/n]?: $(tput sgr0)" Answer

if [[ $Answer = [Yy] ]]
then

	sudo apt-get clean
	echo "$(tput setaf 6)Cleaning apt-get...$(tput sgr0)"
	sleep 3

	#Waiting for apt-get to clean logs
	wait

	#Check to ensure the log rotate config exists and if so, rotate and clean out logs
	if [ -f /etc/logrotate.conf ]
		then
		sudo logrotate -f /etc/logrotate.conf

		sudo find /var/log -name "*.gz" -type f -delete

		echo "$(tput setaf 6)Rotating/Clearing logs...$(tput sgr 0)"
		sleep 3
	fi

	#Clears auditing logs/wtmp logs and lastlogin logs (if they exist)
	if [ -f /var/log/audit/audit.log ]
		then
		cat /dev/null > sudo /var/log/audit/audit.log
	fi

	#WTMP log clear
	if [ -f /var/log/wtmp ]
		then
		cat /dev/null > sudo /var/log/wtmp
	fi

	#Last Login cleared
	if [ -f /var/log/lastlog ]
		then
		cat /dev/null > sudo /var/log/lastlog
	fi

	echo "$(tput setaf 6)Logs have been cleared.$(tput sgr0)"
	echo "$(tput setaf 6)Looking for persistent net rules...$(tput sgr0)"
	sleep 3

	#Clear persistent net rules if exists - this removes cached mac address
	if [ -f /etc/udev/rules.d/70-persistent-net.rules ]
		then
		sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
	fi

	echo "$(tput setaf 6)Cleaning out temp files from /tmp/ and /var/tmp/...$(tput sgr 0)"
	sudo rm -rf /tmp/*
	sudo rm -rf /var/tmp/*
	sleep 3

	echo "$(tput setaf 6)Checking for SSH Keys...$(tput sgr0)"
	#Clear any stored ssh keys
	if [ -f /etc/ssh/.*key.* ]
		then
		sudo rm -rf /etc/ssh/*key*
	fi

	#Clear any stored ssh keys
	if [ -f ~/.ssh/authorized_keys ]
		then
		sudo rm -rf ~/.ssh/authorized_keys 
	fi
	sleep 3

	#Remove the hostname
	echo "$(tput setaf 6)Removing hostname configuration...$(tput sgr0)"
	sudo sed -i "s/.*//" /etc/hostname
	sleep 3

	#Remove the command history for current user
	echo "$(tput setaf 6)Clearing shell command history...$(tput sgr 0)"
	history -c
	history -w
	sleep 1

	#Bring eth0 down
	echo "$(tput setaf 6)Stopping the eth0 network...$(tput sgr0)"
	sudo ifdown eth0
	sleep 1

	#Remove the IP settings
	echo "$(tput setaf 6)Remove the IP, Subnet, and Gateway configuration..$(tput sgr0)"
	sudo sed -i "s/address.*/address /" /etc/network/interfaces
	sudo sed -i "s/netmask.*/netmask /" /etc/network/interfaces
	sudo sed -i "s/network.*/network /" /etc/network/interfaces
	sudo sed -i "s/broadcast.*/broadcast /" /etc/network/interfaces
	sudo sed -i "s/gateway.*/gateway /" /etc/network/interfaces
	sleep 3	

	#Remove the DNS settings
	echo "$(tput setaf 6)Removing the DNS configuration...$(tput sgr0)"	
	sudo sed -i "s/dns-nameservers.*/dns-nameservers /" /etc/network/interfaces
	sleep 3

	#Let the user know the server is now ready to templatize
	echo "$(tput setaf 2)This server has been cleared! Please shut down the server and create 
the clone.$(tput sgr0)"	


else
	echo "$(tput setaf 1)The script did not run.$(tput sgr 0)"
fi	




