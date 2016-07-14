import md5 
import mosquitto
import time
import telnetlib
import json

import settings


def single(topic, payload,qos):
  client = mosquitto.Mosquitto()
  client.username_pw_set(settings.MQTT_USER, settings.MQTT_PASS)
  client.connect(settings.MQTT_SERVER)
  client.publish(topic,payload,qos)
  client.loop()
  client.disconnect()


def split_by_n( seq, n ):
    """A generator to divide a sequence into chunks of n units."""
    while seq:
        yield seq[:n]
        seq = seq[n:]


def on_publish(mosq, userdata, mid):
  # Disconnect after our message has been sent.
  #mosq.disconnect()
  print "sent"
  pass

def on_message(mosq, obj, msg):
    print(msg.topic + " " + str(msg.qos) + " " + str(msg.payload))
    if msg.topic =="/public" and msg.payload.find("temperature")!=0:
        (cmd,uuid,mac,active_md5,)=msg.payload.replace("||md5||","").split("|")
        active_md5="||md5||"+active_md5

        #seding file 
        data =""
        try:
           f = open(uuid+"/prog.lua")
           data = f.read()
           byteArray = bytes(data)
        except:
           pass

        m = md5.new(data)
        candidate_md5="||md5||"+m.hexdigest()
        if candidate_md5 != active_md5 :
            print "sending udpate because md5 is diffrent"
            single("/private"+uuid, bytes(candidate_md5) ,0)
            time.sleep(0.5)
            datas=split_by_n(data,256)
            for i in datas:
                print(">>"+i)
                data="||wr||"+i
                single("/private"+uuid, bytes(data),0)
                time.sleep(0.5)

            single("/private"+uuid, bytes("||gtg||") ,0)

        else:
            print "no update needed"
            single("/private"+uuid, bytes("||gtg||") ,0)

    if msg.topic =="/public" and msg.payload.find("temperature")==0:
      params=msg.payload.split("|")
      publish_dht11_data(params[1],params[2])



### function to process the dht11 sensor data
def publish_dht11_data(node,data_json):
  print("node "+node+" "+data_json)
  try: 
    data_json=json.loads(data_json)
    temperature=data_json["temperature"]
    humidity=data_json["humidity"]

    tn = telnetlib.Telnet(settings.OPENTSDB_SERVER,settings.OPENTSDB_PORT)
    msg="put nodemcu.%s.temperature %s %s host=%s \n"%(node,str(int(time.time())),temperature,node)
    msg+="put nodemcu.%s.humidity %s %s host=%s \n"%(node,str(int(time.time())),humidity,node)
    tn.write(msg)
    tn.close()
  except:
    print("Error pushing data to OpenTSDB.")


# Specifying a client id here could lead to collisions if you have multiple
# clients sending. Either generate a random id, or use:
#client = mosquitto.Mosquitto()
client = mosquitto.Mosquitto()
client.on_publish = on_publish
client.on_message = on_message

client.username_pw_set(settings.MQTT_USER, settings.MQTT_PASS)
client.connect(settings.MQTT_SERVER)

# Start subscribe, with QoS level 2
client.subscribe("/public", 2)


# If the image is large, just calling publish() won't guarantee that all 
# of the message is sent. You should call one of the mosquitto.loop*()
# functions to ensure that happens. loop_forever() does this for you in a
# blocking call. It will automatically reconnect if disconnected by accident
# and will return after we call disconnect() above.
client.loop_forever()
