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
**NOTE:** the user *zumi01* must exist on your server -> see On the Server

**NOTE2:** rename the zumi if you have more than one

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
**NOTE:** if you use more than one Zumi, change the names (here *zumi01*) and the port (here 8888) for all other Zumis.

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

#### start remote access
```
sh /home/pi/startJupyter.sh
```
from ssh or *Jupyter* Terminal. Add this line to ``/etc/rc.local`` to auto-start remote access.

### On your Server

#### add user
```
sudo useradd zumi01
```

#### Install Traefik Proxxy
**Note:** we use  the slighte out dated [*Traefik*](https://docs.traefik.io/) Version 1.7 -> config files need to be different for later versions

Get the *Traefik* binary release: 
```
wget https://github.com/containous/traefik/releases/download/v1.7.24/traefik_linux-amd64
```

#### Traefik config
Create a ``traefig.toml`` config file an enter the following config:
```
defaultEntryPoints = ["http", "https"]

[entryPoints]
    [entryPoints.http]
    address = "IP_OF_MY_SERVER"
    	[entryPoints.http.redirect]
    	entryPoint = "https"
    #this part redirects all http connections to https 
    [entryPoints.https]
    address = "IP_OF_MY_SERVE:443"
    [entryPoints.https.tls]
        #put your domain SSL cert + key in the folder SSL
      	[entryPoints.https.tls.certificates]]
      	CertFile = "SSL/cert.pem"
      	KeyFile = "SSL/key.pem"

#logging options               
[traefikLog]
filePath = "log/traefik.log"

[accessLog]
filePath = "log/log.txt"


[file]

[frontends]

#front end for one zumi
[frontends.zumi01]
backend = "zumi01"
passHostHeader = true
basicAuth = ["USER:HTTPPASSWD"]
[frontends.zumi01.headers]
[frontends.zumi01.routes.route_1]
rule = "PathPrefix:/zumi01"

[backends]

[backends.zumi01]
[backends.zumi01.servers.server1]
url = "http://127.0.0.1:8888"
```
This config will proxy a request to ```http://myserver.com/zumi01`` to the *Jupyter* Notebook on the Zumi.

*Security Note:* The first part of the connection *client->server* will be SSL encrypted, the second part *server->zumi* will be protected by the SSH tunnel. A basic password auth is provided. See *Traefik* docu for more complicated multi user auth.

#### Start Traefik 
```
./traefik_linux-amd64 -c traefik.toml &
```
For permanent proxy installtions, we use a *systemcttl* deamon for *traefik*


## SSH Port forwarding 
