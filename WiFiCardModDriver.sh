#!/usr/bin/env bash

#WARNING
#This script could break your hardware permanently
#Please read further details at https://github.com/zorani/RaspPiNexmonScripts/blob/master/README.md

#If you understand the warnings above, please continue.

#PLEASE RUN THIS AS ROOT

evalpath=$(eval pwd)

declare -a arr_deps=("raspberrypi-kernel-headers" "git" "libgmp3-dev" "gawk" "qpdf" "bison" "flex" "make" "autoconf" "automake" "m4")

goto_nexmon_path(){

goto_command="cd $evalpath/nexmon/"
echo $goto_command
eval $goto_command
echo "RESETPATH TO: " + $(eval "pwd")

}


check_pi_version(){

	pi_version="NOT"
	pi_check_revision_cmd="cat /proc/cpuinfo | grep 'Revision' | cut -d : -f2 | xargs"
	revision=$(eval $pi_check_revision_cmd)

	if [ $revision == "a020d3" ] || [ $revision == "9000c1" ] || [ $revision == "a02082" ] || [ $revision == "a22082" ] || [ $revision == "a32082" ] ; then

        if [ $revision == "a020d3" ]; then
	
		pi_version="3BPLUS"
		echo "Raspberry pi $pi_version detected"
	
	fi

	if [ $revision == "9000c1" ] || [ $revision == "a02082" ] || [ $revision == "a22082" ] || [ $revision == "a32082" ]; then
		
		pi_version="ZEROW_OR_3B"
		echo "Raspberry pi $pi_version detected"
	
	fi

	else

		echo "NO COMPATABLE RASPBERY PI DETECTED, THIS SCRIPT WITH NOT RUN FURTHER"
                echo "PLEASE RUN ON PI-ZERO /W , PI3B or the model  PI-3B+"
	fi
	

}

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

clone_repo(){


	git clone https://github.com/seemoo-lab/nexmon.git
}

check_for_libisl(){

	if [ -d  "/usr/lib/arm-linux-gnueabihf/" ]; then

		echo "DIR /usr/lib/arm-linux-gnueabuhf exists"
		isl_count_command="ls /usr/lib/arm-linux-gnueabihf/ | egrep -c \"libisl.so.10$\" "
		
		islcheck=$(eval $isl_count_command)


		isl_name="libisl.so.10"

		if [ $islcheck -eq 0 ]; then

		goto_nexmon_path

		cd buildtools/isl-0.10/
		./configure
		make
		make install
		
		
		fi

			
			
			echo "Create soft link... libisl.so"
			isl_sl_command="ln -s /usr/local/lib/libisl.so  /usr/lib/arm-linux-gnueabihf/$isl_name"
			echo "ls command is $isl_sl_command"
			eval $isl_sl_command
			
		

	fi
}

setup_build_env(){

	goto_nexmon_path

	source setup_env.sh
	env
	make	


	if [ $pi_version == "3BPLUS" ]; then

		cd patches/bcm43455c0/7_45_154/nexmon/
		make
		make backup-firmware
		make install-firmware

	fi


	if [ $pi_version == "ZEROW_OR_3B" ]; then

		cd patches/bcm43430a1/7_45_41_46/nexmon/
		make
		make backup-firmware
		make install-firmware
	fi
}

install_nexutil(){

	goto_nexmon_path

        cd utilities/nexutil/
	make && make install

}

remove_wpasupplicant(){

	apt-get --allow-change-held-packages --yes purge wpasupplicant 
}

quick_start(){


	echo
	echo
	echo
	echo " QUICK START: TRY YOUR AWSOME SNIFFER IN JUST A FEW MOMENTS "
	echo " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-= "
	echo
	echo " Here are some commands to get you going, to test if the new driver works.


	1) Install tcpdump if you have not already.

	   sudo apt-get install tcpdump

        2) SKIP THIS STEP IF YOU HAVE NOT CONNECTED ANY EXTRA USB WIFI DONGLES
	
	   If you have connected an extra wifi USB dongle, the wlan0
	   interface name will randomly change. You can either keep and
	   eye out for the internal wifi chip by using iwconfig, or more 
	   conveniently set predictable network interface names using

	   sudo raspi-config

	   select networking, then select enable on predictive naming.
           WARNING: YOU WILL BE ASKED TO RESET.  DO THIS BEFORE CONTINUING.

   	3) Set up monitor mode on your wireless card, wlan0.

	   sudo iw phy \`iw dev wlan0 info | gawk '/wiphy/ {printf \"phy\" \$2}'\` interface add wlan0mon type monitor

	4) Activate monitor mode in the firmware.

           sudo ifconfig wlan0mon up

        5) Start snuiffing WiFi packets.

	   sudo tcpdump -i wlan0mon


	   
	   You should see a whole lot of wifi data streaming down your screen.
	   This is the very basic setup, you can now go and explore. Have fun!
	  
	   "


	 echo "NOTE: To connect to regular access points you have to execute nexutil -m0 first"
	 echo "NOTE: It is possible to connect to an access point or run your own access point in parallel to the monitor mode interface on the wlan0 interface"
         echo
	 echo "**Tips and donations**"
         echo "  =-=-=-=-=-=-=-=-=-  "
	 echo
	 echo " If this script has been convenient, and if you want to provide me with some beer money, please donate at the following address. "
	 echo " Thank you for using this script "

	 echo "BITCOIN:    1C1j4iPURFniAQEr5EkMCC8LA5Nn8o69VY"
	 echo "OMNI ASSET: 1C1j4iPURFniAQEr5EkMCC8LA5Nn8o69VY"
	 echo
 

echo "Recomend you reboot to fix wlan0 name assignment issue"
echo

 }

load_mod_driver_on_reboot(){

	goto_nexmon_path

	detect_kernel_version_command="uname -a | grep -c \"4.14\""
	is_414=$(eval $detect_kernel_version_command)

if [ $pi_version == "3BPLUS" ];then

mod_driver_ko="$evalpath/nexmon/patches/bcm43455c0/7_45_154/nexmon/brcmfmac_4.14.y-nexmon/brcmfmac.ko"

fi

if [ $pi_version == "ZEROW_OR_3B" ];then

mod_driver_ko="$evalpath/nexmon/patches/bcm43430a1/7_45_41_46/nexmon/brcmfmac_4.14.y-nexmon/brcmfmac.ko"
	
fi




		default_driver_path_command="modinfo brcmfmac | head -1 | cut -d : -f2 | xargs"
		default_driver_path=$(eval $default_driver_path_command)
		default_driver_path_bkp="$default_driver_path.bkp"

	if [ $is_414 -eq 1 ] && [ ! -e $default_driver_path_bkp  ] ; then

		bkp_driver_command="mv $default_driver_path $default_driver_path_bkp"
		eval $bkp_driver_command
		insert_new_driver_cmd="mv $mod_driver_ko $default_driver_path"
		eval $insert_new_driver_cmd

                depmod -a
	fi



}

stop_dhcpcd_managing_wlan0(){

	cat >>/etc/dhcpcd.conf<<EOL

#The following line was insterted by the WiFiCardModDriver.sh script
#from https://github.com/zorani/RaspPiNexmonScripts
#dhcpcd sometimes tried to manage wlan0 and switches it back to 
#managed mode from monitor mode.
#The following line should be placed at the end of /etc/dhcpcd.conf
#But above any other added interfaces.
#I am guessing this is a fresh pi install and there are none, so 
#am appending to the end of the file. Please move if not.
#Thank you.


interface wlan0

denyinterfaces wlan0
nohook wpa_supplicant

EOL

#Restart dhcpcd to pick up config changes.

systemctl restart dhcpcd

} 

stop_wlan0_power_management(){
#Another cause of airodump dropping wlan0 and wlan0mon

#first of all actually power down wlan0
iwconfig wlan0 power off

#Now create a script and a service that will 
#turn off wifi power management on wlan0 at bootup
touch /home/pi/wlan0_power_mgmt_off.sh

cat >/home/pi/wlan0_power_mgmt_off.sh<<EOL
#!/bin/bash
iwconfig wlan0 power off

EOL

cat >/lib/systemd/system/wlan0pwroff.service<<EOL
[Unit]
Description=Turn Off wlan0 power managment
After=multi-user.target
 
[Service]
Type=idle
ExecStart=/home/pi/wlan0_power_mgmt_off.sh
 
[Install]
WantedBy=multi-user.target
EOL

chmod 644 /lib/systemd/system/wlan0pwroff.service

sudo systemctl daemon-reload
sudo systemctl enable wlan0pwroff.service

}


check_pi_version

if [ $pi_version != "NOT" ]; then

install_dependencies
clone_repo
check_for_libisl
setup_build_env
install_nexutil
load_mod_driver_on_reboot
quick_start
stop_dhcpcd_managing_wlan0
stop_wlan0_power_management

####---------OPTIONAL-FUNCTIONS-------####### Remove hash to enable function

#remove_wpasupplicant



fi

apt-get --allow-change-held-packages --yes  autoremove
