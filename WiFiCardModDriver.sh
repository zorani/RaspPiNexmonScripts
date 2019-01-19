#!/usr/bin/env bash

#WARNING
#This script could break your hardware permanently
#Please read further details at https://github.com/zorani/RaspPiNexmonScripts/blob/master/README.md

#If you understand the warnings above, please continue.

#PLEASE RUN THIS AS ROOT

evalpath=$(eval pwd)

declare -a arr_deps=("raspberrypi-kernel-headers" "git" "libgmp3-dev" "gawk" "qpdf" "bison" "flex" "make")
declare -a arr_purge=("raspberrypi-kernel-headers" "libgmp3-dev" "gawk" "qpdf" "bison" "flex")


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

purge_packages(){

for rdep in "${arr_purge[@]}"
do

 	command="apt-get --allow-change-held-packages --yes purge $rdep"
        eval $command
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

	apt-get --allow-change-held-packages --yes remove wpasupplicant 
}

final_notes(){

	echo " Note: To connect to regular access points you have to execute nexutil -m0 first "
	echo
	echo
	echo " USING THE MONITOR MODE PATCH "
	echo " ============================ "
	echo
	echo " Thanks to the prior work of Mame82, you can setup a new monitor mode interface by executing: iw phy \`iw dev wlan0 info | gawk '/wiphy/ {printf \"phy\" \$2}'\` interface add mon0 type monitor
	To activate monitor mode in the firmware, simply set the interface up: ifconfig mon0 up.
	At this point, monitor mode is active. There is no need to call airmon-ng.
	The interface already set the Radiotap header, therefore, tools like tcpdump or airodump-ng can be used out of the box: tcpdump -i mon0
	Optional: To make the RPI3 load the modified driver after reboot:
	Find the path of the default driver at reboot: modinfo brcmfmac #the first line should be the full path
	Backup the original driver: mv \"<PATH TO THE DRIVER>/brcmfmac.ko\" \"<PATH TO THE DRIVER>/brcmfmac.ko.orig\"
	Copy the modified driver (Kernel 4.9): cp /home/pi/nexmon/patches/bcm43430a1/7_45_41_46/nexmon/brcmfmac_kernel49/brcmfmac.ko \"<PATH TO THE DRIVER>/\"
	Copy the modified driver (Kernel 4.14): cp /home/pi/nexmon/patches/bcm43430a1/7_45_41_46/nexmon/brcmfmac_4.14.y-nexmon/brcmfmac.ko \"<PATH TO THE DRIVER>/\"
	Probe all modules and generate new dependency: depmod -a
	The new driver should be loaded by default after reboot: reboot  * Note: It is possible to connect to an access point or run your own access point in parallel to the monitor mode interface on the wlan0 interface. "


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
		insert_new_driver_cmd="mv $mod_driver_ko $default_driver_path"


	fi



}


check_pi_version

if [ $pi_version != "NOT" ]; then

install_dependencies
#purge_packages
clone_repo
check_for_libisl
setup_build_env
install_nexutil
remove_wpasupplicant
load_mod_driver_on_reboot
final_notes

fi
