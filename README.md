# ZumiWorld
Code and Howto's around our lab setup for Zumi Robots. **This project is under active construction** 

## Our Lab Setup

- details on the lab setup, Server, cams, zumis .... -

## Lab System
Details on the server, remote access and camera infrastructure.

### Web-Proxy for remote Zumi Access

### Zumi Dashboard

## Zumi Hacks
Hacks, workarrounds and solutions beyond the official Zumi documentation

### Official Zumi Docs and API
**NOTE:** this is an unofficial collection of things that we found usefull, but could not find in the official docs. This is not intended to be a complete documentation! Please consult the official docs:
* [Zumi API](https://www.piwheels.org/)
* [Zumi Code Examples](https://github.com/RobolinkInc/Zumi_Content)

### Undocumented API
We ran accross some funtions in the API which were not officially documented:
```
get_battery_percentage() - returns current battery status in percent
```

### Camera hacks 

### Network 
By default, Zumi starts two wifi networks: 
* It's own network ``AP0`` with the defualt IP ``192.168.10.1`` with ISSD ``zumiXXXX``
* `ẁlan0``, which connects to the internet via some host WIFI, using DHPC. 

**NOTE:** both WIFIs are depending on each other: 
* if ``wlan0`` fails to connect to the internet, ``ÀP0`` often times stalls, e.g. e fwew seconds after boot
* if you shut down ``AP0``, ``WLAN0``will fail

***Tech details of these observation are missing here***

#### SSH Access
Connect to the Zumi WIFI and
```
ssh pi@192.168.10.1
```
default password is *pi*. The user *pi* has *sudo*-rights.

#### WIFI power save mode
by default, the Zumi runs both WIFI adapters in power save mode. This can cause frequent network interruptions, especially when working via SSH. To turn of the power save mode:
```
sudo iwconfig wlan0 power off
sudo iwconfig AP0 power off
```
#### WIFI config
The wifi configuration can be found in
```
/etc/wpa_supplicant/wpa_supplicant.conf
```

### Zumi boot scripts
The the auto-start script is loacated in 
```
/etc/rc.local
```
By default, this calls the official Zumi DashBoard at boot time (locates in ``/home/pi/Dashboard/dashboard.py``). You can add your start-scripts her - make sure that ``rc.local`` will return ...


### Installing packages 
#### System packages  
Zumi runs on a [Rasbian](https://www.raspberrypi.org/) - a *Debian* based Linux distribution. As in all Debian derivates, it uses the *apt* packages manager. Install packages via:
```
apt-get install XXX
```

#### Python packages
*Rasbian* uses the [piwheels](https://www.piwheels.org/) repository with pre-build binaries of python packages. Install via:
```
pip3 install XXXX
```
 

### Clone SD Card
Make full backups of your Zum system or clone Zumis:

#### copy image
```
sudo dd if=/dev/mmcblk0p1 of=~/Vorlesung/SS_20/Projekt/ZumiLab/zumi_init_boot.img
sudo dd if=/dev/mmcblk0p2 of=~/Vorlesung/SS_20/Projekt/ZumiLab/zumi_init_image.img
```

#### write image
```
sudo dd if=~/Vorlesung/SS_20/Projekt/ZumiLab/zumi_v1.8_ of=/dev/mmcblk0p1
sudo dd if=~/Vorlesung/SS_20/Projekt/ZumiLab/zumi_v1.8_image.img of=/dev/mmcblk0p2
```
**Note:** SD devices might differ, just enter your SD and see where it is mouted (example here on Ubuntu)

## Algorithms and Applications
Here we list some of the (partial) solutions and algorithms tha run on our Zumis

