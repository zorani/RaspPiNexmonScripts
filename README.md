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
    
    

RUN AS ROOT

For board revision history information, you might like to check the following link,

https://elinux.org/RPi_HardwareHistory#Board_Revision_History

#### To findout what raspberry pi hardware you are running using the bash command line

    cat /proc/cpuinfo | grep 'Revision' | cut -d : -f2 | xargs

xargs conveniently truncates the white spaces around the result.

#### QUICK START: TRY YOUR AWSOME SNIFFER IN JUST A FEW MOMENTS 

Here are some commands to get you going, to test if the new driver works.
	
 1) Install tcpdump if you have not already.
	
        sudo apt-get install tcpdump
	
 2) Set up monitor mode on your wireless card, wlan0.
	
        sudo iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor
	
 3) Activate monitor mode in the firmware.
 
        sudo ifconfig mon0 up
 
 4) Start sniffing WiFi packets.
	
        sudo tcpdump -i mon0
	
 
You should see a whole lot of wifi data streaming down your screen.
This is the very basic setup, you can now go and explore. Have fun!
	  
NOTE: To connect to regular access points you have to execute 

	nexutil -m0 first
	
NOTE: It is possible to connect to an access point or run your own access point in parallel to the monitor mode interface on the wlan0 interface


## Pre compiled drivers for kernel 4.14.79

Backup and replace the driver at the following location

    /lib/modules/4.14.79-v7+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko

### Raspberry Pi 3B+  

PI3BPLUS_K414_brcmfmac.ko   (Change name to just the brcmfmac.ko)


