# ZumiWorld
Code and Howto's around our lab setup for Zumi Robots. **This project is under active construction** 

## Our Lab Setup

- details on the lab setup, Server, cams, zumis .... -

## Lab System
Details on the server, remote access and camera infrastructure.

### Web-Proxy for remote Zumi access to *Jupyter*
In the default setting, users have to connect to Zumi's Wifi and the connect via browser in order to run code on the Zumi. In our lab setting, we wanted to centralize the access to multiple Zumis via a single web-interface runnig on a lab server. This setting even allows remote live access to all of our Zumis from anywhere via browser - a feature we use for remote teaching in the lab during *Corona*... [***Details here***]()

### Remote Procedure Calls
Since the compute capacity of Zumi's *Rasberry Pi-Zero* is quite limited, it can be very usefull to only use the *Pi* as slave for sensors and actors and remote control the Zumi. This allows to run compute intesive algorithmens, like deep learning, on external compute ressources. See our [***Zumi-RPC***](https://github.com/keuperj/Zumi-rpc) sub-project.  

### Zumi Dashboard
In another sub-project, we are working on a custom web [***DashBoard***](https://github.com/keuperj/Zumi-rpc), wich allows interactive control and live sensor reads of the Zumis.

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

### Jupyter Notebooks

#### start Jupyter
To start Jupyter without the DashBoard, SSH on Zumi and
```
/usr/local/bin/jupyter notebook --config /home/pi/.jupyter/jupyter_notebook_config.py --no-browser --notebook-dir=/home/pi/Dashboard/user/USERNAME/ &
```

#### customize Jupyter
SSH on Zumi and crate a local conig file:
```
jupyter notebook --generate-config
```
and edit it:
```
sudo vim /home/pi/.jupyter/jupyter_notebook_config.py
```
See [Jupyter Config Docs](https://jupyter-notebook.readthedocs.io/en/stable/config.html) for details.
### Camera hacks 
Unfortunately, the Zumi camera API only provides very low resolution images at low framerates from the camra. Howver, the build in *picam* does have a much higher resolution and the *Pi-Zero* hardware pipeline (build in image encoders) even allow high framerates. All we we have to do, ist to bypass the Zumi API and acess the camera directly, using the ``picamera`` lib.

#### getting high resolution images

capture to file:
```
with picamera.PiCamera() as camera:
    camera.resolution = (1024, 768)   
    camera.rotation = 180
    camera.capture('out.jpg')
```
* (1024,768) is the max resolution, but you can also set it to (640,480) or (320,240)
* Zumi's cam is mounted upside down ->  need rotation by 180 degree 

or to an *Numpy* array:
```
with picamera.PiCamera() as camera:
    camera.resolution = (1024, 768)
    camera.rotation = 180
    output = np.empty((1024,768,3),dtype=np.uint8)
    camera.capture(output , 'rgb')

output
```

#### getting 30fps at high resolution
***NOTE:*** do NOT call te above cam code in a loop or short intervals (<= 1s) - it will cause the Zumi to stall. For image sequences at higher framerates, we need to use the hardware optimization (video port). Fortunately, [picamera](https://picamera.readthedocs.io/en/release-1.13/) provides all of this (and much more):
```
import time
import picamera

frames = 60

with picamera.PiCamera() as camera:
    camera.resolution = (1024, 768)
    camera.framerate = 30
    camera.start_preview()
    # Give the camera some warm-up time
    time.sleep(2)
    start = time.time()
    camera.capture_sequence([
        'image%02d.jpg' % i
        for i in range(frames)
        ], use_video_port=True)
    finish = time.time()
print('Captured %d frames at %.2ffps' % (
    frames,
    frames / (finish - start)))

```

#### Live camera stream
We are currently workin on a live >10 fps stream from the Zumi...

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
### get console (terminal) access
Use SSH or open a terminal (NEW button in top right corner) in Jupyter.

### Monitor Zumi CPU and memory usage
In the terminal (via SSH or Jupyter) type``top``

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

