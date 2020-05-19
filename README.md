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
* API
* Example Code

### Undocumented API

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
default password is *pi*

#### WFIF power save mode
by default, the Zumi runs both WIFI adapters in power save mode. This can cause frequent network interruptions, especially when working via SSH. To turn of the power save mode:
```
sudo iwconfig wlan0 power off
sudo iwconfig AP0 power off
```

### Zumi boot scripts

## Algorithms and Applications
Here we list some of the (partial) solutions and algorithms tha run on our Zumis

