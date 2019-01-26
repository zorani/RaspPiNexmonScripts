Before we get to the point of all that packet sniffing goodness... a word of warning
from the people who actually did all the work.

# WARNING

The scripts in this repo may damage your hardware and may void your hardware’s warranty! 
You use these scripts and the tools from https://github.com/seemoo-lab/nexmon at your own risk and responsibility! 
If you don't like these terms, don't use nexmon!
If you don't like these terms, don't run any of the scripts in this repo.

# SECOND WARNING

Seriously, use of these scripts in this RaspPiNexmonScripts Repo could brick your raspberry pi and render it useless.
The scrits in this Repo automate the work done at https://github.com/seemoo-lab/nexmon who also warn that your hardware
could suffer irreperable and permenent damage.

Only carry on if you take full responsibility.

I have only automated the RasPi steps described in detail at https://github.com/seemoo-lab/nexmon


# RaspPiNexmonScripts for Kernel 4.14 only.

## Raspberry Pi, set built in chip to monitor mode. (Pi-Zero W, Pi-3B and Pi-3B+)

The good people at the following link, the nexmon project have instructions to 
compile a modified driver to unlock the onboard wifi chip on the raspberry pi.

https://github.com/seemoo-lab/nexmon

### Script:  WiFiCardModDriver.sh

run as root

	sudo ./WiFiCardModDriver.sh

I've automated that process with a script that you can run on the following RasPi models

-Pi Zero W (Hardware revision 9000c1)
 Note: You must have a second WiFi dongle attached to connect you to the internet.

-Pi Model 3B (Hardware revision a02082, a22082  & a32082)

-Pi Model 3B+ (Hardware revision a020d3)


The script will detect and build the modified driver for the above models.

The script will backup the origional hardware driver from location,

    /lib/modules/4.14.79-v7+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
    
to

    /lib/modules/4.14.79-v7+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko.bkp
   
You can confirm the location of the default hardware using the following command in a shell,
the first line of the output will confirm the location of the default reboot driver. The script
does this automatically.

	modinfo brcmfmac

For board revision history information, you might like to check the following link,

https://elinux.org/RPi_HardwareHistory#Board_Revision_History

#### To findout what raspberry pi hardware you are running using the bash command line

    cat /proc/cpuinfo | grep 'Revision' | cut -d : -f2 | xargs

xargs conveniently truncates the white spaces around the result.

#### QUICK START: TRY YOUR AWSOME SNIFFER IN JUST A FEW MOMENTS 

Here are some commands to get you going, to test if the new driver works.

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

	   sudo iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add wlan0mon type monitor

4) Activate monitor mode in the firmware.

           sudo ifconfig wlan0mon up

5) Start snuiffing WiFi packets.

	   sudo tcpdump -i wlan0mon
	
 
You should see a whole lot of wifi data streaming down your screen.
This is the very basic setup, you can now go and explore. Have fun!
	  
NOTE: To connect to regular access points you have to execute 

	nexutil -m0 first
	
NOTE: It is possible to connect to an access point or run your own access point in parallel to the monitor mode interface on the wlan0 interface

#### Airodump-ng not capturing any data, no output problems on wlan0mon mon0 or anyother name you used...

A well known symptom observed by users of airodump-ng is a sudden stop of packet capturing.

The DHCPCD service is known to occasionaly try and manage wlan0 again by setting it to managed mode.
This ofcourse stops airodump-ng or tcpdump from collecting data.  Airodump-ng will suddenly stop collecting data.
In an attempt to over come this problem the WiFi setup script runs the following methods:

stop_dhcpcd_managing_wlan0
stop_wpasupplicant_probing_wlan0
stop_wlan0_power_management

The following soureces helped me figure this out:

https://serverfault.com/questions/869857/systemd-how-to-selectively-disable-wpa-supplicant-for-a-specific-wlan-interface
https://github.com/raspberrypi-ui/dhcpcd-6.7.1/blob/master/dhcpcd-hooks/10-wpa_supplicant
https://serverfault.com/questions/869857/systemd-how-to-selectively-disable-wpa-supplicant-for-a-specific-wlan-interface
http://thelowercasew.com/disabling-wifi-power-management-permanently-for-raspberry-pi-3-with-raspbian-jessie


## Airsniffing Software

### Script:  AircrackNgFromSource.sh

run as root

	sudo ./AircrackNgFromSource.sh

This installs Aircrack-ng from a stable release at https://github.com/aircrack-ng/aircrack-ng/releases
You may change the URL in the script if a later version is available.

#### QUICK START: RUN A QUICK TEST OF YOUR AIRCRACK-NG

After you have run the install script AircrackNgFromSource.sh you can be up and running very quickly.

Here are some commands to get you going, to test if the new driver works.
		
							

												   
   1) SKIP THIS STEP IF YOU HAVE NOT CONNECTED ANY EXTRA USB WIFI DONGLES

	   If you have connected an extra wifi USB dongle, the wlan0 
	   interface name will randomly change. You can either keep an
	   eye out for the internal wifi chip by using iwconfig, or more
	   conveniently set predictable network interface names using

	   	sudo raspi-config

	   select networking, then select enable on predictive naming.
           WARNING: YOU WILL BE ASKED TO RESET.  DO THIS BEFORE CONTINUING.
	
   2)  Setup monitor mode on wlan0, or whatever name is pointing to your onboard chip.

	    There are two commands you can use,

	      the origional,

	       C1)  sudo iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add wlan0mon type monitor

	      but even better, aircrack-ng provides the following command.

	       C2) airmon-ng start wlan0
												   				 
   3) Activate monitor mode in the firmware.

  		sudo ifconfig wlan0mon up
	
   4) Start snuiffing WiFi packets.
			
	  	sudo airodump-ng -i wlan0mon
		
		
## WiFi Drivers, Community Support From The Famous MrEngman

If you are lucky wnough to have an ethernet cable point while you are packet sniffing,
you can use your hard wire connection to send back packet reports to your AWS instance... or where ever.

If.. you want a fully independed wifi only raspi sniffer, you're going to get a small headache, but it can be done.
It all depends on the manufacturer, compatibility and driver availabitliy of your usb.

The exact USB WiFi radio I got to work in this setup was the https://wikidevi.com/wiki/TP-LINK_TL-WN725N_v2
Carefull! Multiple revisions of this device, use caution. Check all the specs agains https://wikidevi.com/wiki/TP-LINK_TL-WN725N_v2

I bought this one from Amazon, https://www.amazon.co.uk/gp/product/B008IFXQFU/ , who knows if this changes in the future.


### Script: install-wifi

I had some external USB wifi adapters that needed the help from the famous Mr Engman. 
Anyone online looking for a USB driver will have come accross this generous member of the raspi community. 
Here is the thread I found him in https://www.raspberrypi.org/forums/viewtopic.php?t=62371&start=1225 and here is a link to the script text, http://www.fars-robotics.net/install-wifi

Further tips:  It does feel a bit hit and miss, but I have finally got packat listening on the onboard wifi, and internet
access on the usb wifi radio to send data elsewhere.

I tried rpi-update, but that failed.
I found two commands to fix my rpi-update mistake on the following thread,
https://github.com/Hexxeh/rpi-update/issues/222

Command 1) sudo apt-get install --reinstall raspberrypi-bootloader raspberrypi-kernel

Command 2) sudo BRANCH=stable rpi-update and it's all revert back nicely.

All of my Wifi Failed, and I used an ethernet cable to complete the above.

I found that my external USB wifi was completely missing!
So, I ran MrEngmans install-wifi script - perfect, connected to the internet straight away.

I then triend airmon-ng start wlan0... "Mode not supported"
Ofcourse, the driver was already written over.
So I re-ran - WiFiCardModDriver.sh
Then re-ran - AircrackNgFromSource.sh

I guess the lesson here is, completely uninstall USB WIFI drivers for your USB stick if you have issues, 
and use MrEngmans instead.

One last tip, if you have been setting up your pi with an ethernet cable... if you unplug it your wifi
will have issue routing webpages to your browser, you must restart your pi without the ethernet cable in.
Odd ah?!  

Anyway, happy packet sniffing.


al
