print ("core.lua | Starting up ...")
mqttPassword = "nikecondor"
mqttUsername = "aboss"
mqttBroker = "192.168.2.17"
wifiSSID="rmn"
wifiPassword="0722297326"
UUID=node.chipid()
wifiIpAddress=""
wifiMAC=""
STATE = 0
m=nil

wifi.setmode(wifi.STATION)
wifi.sta.config(wifiSSID,wifiPassword)
wifi.sta.connect()

function starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function state_machine()

   if STATE == 0 then  
       print ("STATE 0")
       if wifi.sta.getip()==nil then 
          print(" Wait to IP address!") 
       else 
          wifiIpAddress=wifi.sta.getip()
          print("New IP address is "..wifiIpAddress)                     
          wifiMAC=wifi.sta.getmac()
          print("MAC address is "..wifiMAC) 
          print("UUID is "..UUID) 
          STATE=10
       end
   
   elseif STATE==10 then
      print ("STATE 10")   
      STATE =-1
      m = mqtt.Client(UUID, 120, mqttUsername, mqttPassword)           
      m:on("connect", function(con)  print ("core.lua | connected") end)
      m:on("offline", function(con) print ("core.lua | offline") end)
      -- on publish message receive event
      m:on("message", function(conn, topic, data) 
     
        print("core.lua | recv: on "..topic .. ":" ..node.heap() ) 
        if data ~= nil then
          
          if starts(topic,"/private") and starts(data,"||restart||") then 
             print ("core.lua | recv: restart")
             node.restart()
          elseif starts(topic,"/private") and starts(data,"||gtg||") then 
             --m:close()
             --m=nil
             tmr.stop(2)
             print ("core.lua | recv: gtg")                         
             dofile("prog.lua")
          elseif starts(topic,"/private") and starts(data,"||md5||") then 
             tmr.stop(2)
             file.open("md5", "w")
             file.write(data)
             file.flush()
             file.close()
             file.open("prog.lua", "w")
             file.close()
             print ("core.lua | recv: md5")
          elseif starts(topic,"/private") and starts(data,"||wr||") then             
             file.open("prog.lua", "a")
             data=string.sub(data,7)
             file.write(data)
             file.close()
             print ("core.lua | recv: program")
          end       
        end
    
       
      end)
      m:connect(mqttBroker, 1883, 0, function(conn) 
          print("connected")     
          STATE=20 
      end)
             
   elseif STATE==20 then
      print ("STATE 20")
      STATE =-1
      m:subscribe("/public",2, function(conn) 
         print("core.lua | Subscribe success public") 
         STATE = 21
      end)       
      
   elseif STATE==21 then
       STATE =-1
        m:subscribe("/private"..UUID,0, function(conn) 
         print("core.lua | Subscribe success private") 
         STATE =22
       end)

   elseif STATE==22 then
      md5="00000" -- default inexisting md5
      l = file.list()      
      if l["md5"]~= nil then
         file.open("md5", "r")
         md5=file.read()
         file.close()
      end       
      
      m:publish("/public","hello|"..UUID.."|"..wifiMAC.."|"..md5,0,0, function(conn)           
          tmr.stop(1) 
          tmr.alarm(2,10*1000, 1, function() 
             print ("core.lua | Autoupdate server unreachable starting local prog.lua")
             tmr.stop(2)
             dofile("prog.lua")             
          end)

      end)  
      
   else 
      print("nothing to do") 
      print(node.heap())
   end
        
end 

tmr.alarm(1,1000, 1, function() 
    state_machine()
  end)
