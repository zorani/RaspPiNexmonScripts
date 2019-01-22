#!/usr/bin/env bash


#PLEASE RUN THIS AS ROOT

evalpath=$(eval pwd)

goto_aircrack_ng_path(){

	goto_command="cd $evalpath/aircrack-ng/"
	echo $goto_command
	eval $goto_command
	echo "RESETPATH TO: " + $(eval "pwd")

}

declare -a arr_deps=("raspberrypi-kernel-headers" "build-essential" "gcc" "libnl-3-dev" "libnl-genl-3-dev" "ethtool" "rfkill" "libssl-dev" "pkg-config" "shtool" "libtool" "make" "autoconf" "automake" "m4" "libpcre3-dev")
declare -a arr_opt_deps=("libsqlite3-dev " "libpcap-dev" "zlib1g-dev" "libhwloc-dev" "libcmocka-dev")

install_dependencies(){

for dep in "${arr_deps[@]}"
do
	command="dpkg-query -W -f='\${Status}\\n' $dep 2>/dev/null | grep -c \"ok installed\" "
	installCheck=$(eval $command)

	if [ $installCheck -eq 0 ]; then
		echo "$dep Status:NOT INSTALLED."
		echo "     Attempting to install $dep ..."
		echo
                apt-get --allow-change-held-packages --yes install $dep
	else
		echo "$dep Status:INSTALLED"
		echo
	fi
done

}


install_opt_dependencies(){

for odep in "${arr_opt_deps[@]}"
do
	command="dpkg-query -W -f='\${Status}\\n' $odep 2>/dev/null | grep -c \"ok installed\" "
	installCheck=$(eval $command)

	if [ $installCheck -eq 0 ]; then
		echo "$odep Status:NOT INSTALLED."
		echo "     Attempting to install $odep ..."
		echo
                apt-get --allow-change-held-packages --yes install $odep
	else
		echo "$odep Status:INSTALLED"
		echo
	fi
done

}

clone_repo(){

	git clone https://github.com/aircrack-ng/aircrack-ng.git
}

get_release(){


	wget https://github.com/aircrack-ng/aircrack-ng/archive/1.5.2.tar.gz
	tar -zxvf 1.5.2.tar.gz
        mv aircrack-ng-1.5.2 aircrack-ng

}

install_ng(){


	goto_aircrack_ng_path
	autoreconf -i
	./configure --with-experimental --with-ext-scripts
	make
	make install
 	ldconfig
}


quick_start(){


	echo
	echo
	echo
	echo " QUICK START: RUN A QUICK TEST OF YOUR AIRCRACK-NG "
	echo " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=- "
	echo
	echo " Here are some commands to get you going, to test if the new driver works.
		
							
	1) Set up monitor mode on your wireless card, wlan0.
												   
        2) SKIP THIS STEP IF YOU HAVE NOT CONNECTED ANY EXTRA USB WIFI DONGLES

	   If you have connected an extra wifi USB dongle, the wlan0 
	   interface name will randomly change. You can either keep an
	   eye out for the internal wifi chip by using iwconfig, or more
	   conveniently set predictable network interface names using

	   sudo raspi-config

	   select networking, then select enable on predictive naming.
           WARNING: YOU WILL BE ASKED TO RESET.  DO THIS BEFORE CONTINUING.
	
	3)  Setup monitor mode on wlan0, or whatever name is pointing to your onboard chip.

	    There are two commands you can use,

	       the origional,

	       C1)  sudo iw phy \`iw dev wlan0 info | gawk '/wiphy/ {printf \"phy\" \$2}'\` interface add wlan0mon type monitor

	       but even better, aircrack-ng provides the following command.

	       C2) airmon-ng start wlan0
												   	
	4) Activate monitor mode in the firmware.

		sudo ifconfig wlan0mon up
	
	5) Start snuiffing WiFi packets.
			
		sudo airodump-ng -i wlan0mon


	
	**Tips and donations**
	  =-=-=-=-=-=-=-=-=- 

	  If this script has been convenient, and if you want to provide me with some beer money, please donate at the following address.
	  Thank you for using this script 

	  BITCOIN:    1C1j4iPURFniAQEr5EkMCC8LA5Nn8o69VY
	  OMNI ASSET: 1C1j4iPURFniAQEr5EkMCC8LA5Nn8o69VY


		"
}

install_dependencies
install_opt_dependencies
#clone_repo
get_release
install_ng
quick_start



