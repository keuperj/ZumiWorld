# Zumi Remote Access accross the internet
### Setting
Zumi is usually accesed via it's own Wifi network. Here, we show how to open it for remote access from anywhere in the internet...

### What you need
* your Zumi should be setup and connected to the internet
* a server were you have super user rights (we use a Debian/Ubuntu Linux machine in this document)

## Jupyter Proxy
Scenario: allow access to the Jupyter Notebooks running on one ore more Zumis via a fixed URL. 
In our example: ``https://myserver.com/zumi01``

### On the Zumi
Use ssh to get on the zumi console.

#### install screen
```
sudo apt-get install screen
```
#### generate SSH keys
```
ssh-keygen -b 4096
mv .ssh/key_rsa.pub .ssh/zumi01_cam_key_rsa.pub
ssh-copy-id -i .ssh/zumi01_id_rsa.pub zumicam@myserver.com
```
NOTE: the user *zumi01* must exist on your server -> see On the Server
NOTE2: rename the zumi if you have more than one

#### generate a *Jupyter* conig:
```
jupyter notebook --generate-config
```
and edit it:
```
sudo vim /home/pi/.jupyter/jupyter_notebook_config.py
```
add the following lines:
```
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.allow_remote_access = True
c.NotebookApp.token = ''
c.NotebookApp.base_url = '/zumi01/'
c.NotebookApp.webapp_settings = {'static_url_prefix':'/zumi01/static/'}

```
NOTE: if you use more than one Zumi, change the names (here *zumi01*) and the port (here 8888) for all other Zumis.

#### write a start script
```
vim /home/pi/startJupyter.sh
```
and add:
```
sudo iwconfig wlan0 power off
sudo -u pi /usr/local/bin/jupyter notebook --config /home/pi/.jupyter/jupyter_notebook_config.py --no-browser --notebook-dir=/home/pi/ &
screen -d -m sudo -u pi ssh -i /home/pi/.ssh/zumi01 -R 8888:localhost:8888 zumi01@myserver.com
```
NOTE: change zumi name and port according to your settings in the *Jupyter* config.

### On your Server

## SSH Port forwarding 
