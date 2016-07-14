# rgbled_control_server
##Led Control Server | Remote Control Web Application | Mqtt Server | Cloud Controller (ESPCloud)

This project is recommended only to users that have linux shell skills, programming skills and are familiar with 
flashing of the ESP8266 ESP-12E chips. This is not a commercial grade product but rather a neat hobby project I am running at home in the little spare time I have. 

###Cloud Controller (ESPCloud)  
I use this basic "Cloud" python application to be able to program over wifi already deployed and embedded NodeMCU devices. The aim being at eliminatting the need to open the electronics boxes.   
 
ESPCloud is responsible for auto-updating the running application on the ESP8622 chips and sensor data storage in an OpenTSDB database.

 - Each NodeMCU device needs to have its own folder named with the "chipid" in which the latest prog.lua for the particular application needs to sit
 
 - On bootup core.lua will automaticaly connect to the server and retrieve the MD5 of the current running prog.lua if is diffrent than the latest it will proceed to autoupdate

Configuration of the ESPCloud is done in the settings.py file
In /ESPCloud/opt/ sits a dummy service /etc/init.d/ file for ubuntu/debian like linux

On the client side the ESPCloud relies on the NodeMCU device to run a startup application called 'core.lua'.
This application will connect to the ESPCloud to perform version checking and update and also implement other basic functions as "restart".
To obtain the 'core.lua' along with diffrent applications see led_control_client project (upload pending) 

For easy graphing and storing solution of the data I recommend using the follwing docker image:

            https://hub.docker.com/r/bizhao/opentsdb-grafana/


---------------
###Remote Control Web Application 
 
   Part not yet submitted to the project will follow.
   Contains basic web application for controlling all the RGB LED lamps in my household.

---------------
###Mqtt Server (mosquitto)

For communication between the NodeMCU devices and the servers I am using an Mqtt server.
I my live setup I use mosquitto that runs on a RasberryPi:

```
apt-get install mosquitto
```
