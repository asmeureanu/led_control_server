print("prog.lua | Led controller over mqtt")

redPin     = 5
greenPin = 2
bluePin   = 1
pwmFreq = 250

-- set up pins as PWM pins
pwm.setup(redPin, pwmFreq, 0)
pwm.setup(greenPin, pwmFreq, 0)
pwm.setup(bluePin, pwmFreq, 0)
-- start PWM output on the pins (effectively no light yet)
pwm.start(redPin)
pwm.start(greenPin)
pwm.start(bluePin)

m:on("message", function(conn, topic, data)     
        print("prog.lua | recv: on "..topic .. ":" ..node.heap() ) 
        if data ~= nil then
         
         if starts(topic,"/private") and starts(data,"||rgb||") then 
             -- we expect the packet in "R,G,B" format
             -- thus use the split function from our functions file (similar to php explode, returning an array)
             red, green, blue = data:match("||rgb||([^,]+),([^,]+),([^,]+)")
             print ("prog.lua | recv: rgb")
             print("color ".. red .." " .. green .. " " ..blue)
             print("color ".. redPin .." " .. greenPin .. " " ..bluePin)
             pwm.setduty(redPin, red*4);
             pwm.setduty(greenPin, green*4);
             pwm.setduty(bluePin, blue*4);      
         elseif starts(topic,"/private") and starts(data,"||restart||") then 
             print ("prog.lua | recv: restart")
             node.restart()      
            
         end
       end 
end)


print("prog.lua | dth11 temperature sensor  over mqtt")

tmr.alarm(3,30000, 1, function() 
  
pin = 6
status,temp,humi,temp_decimial,humi_decimial = dht.read11(pin)
if( status == dht.OK ) then
  -- Integer firmware using this example
  print(
    string.format(
      "DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
      math.floor(temp),
      temp_decimial,
      math.floor(humi),
      humi_decimial
    )
  )
  -- Float firmware using this example
  print("DHT Temperature:"..temp..";".."Humidity:"..humi)
m:publish("/public","temperature|"..UUID.."|".." {\"temperature\":"..temp..",".."\"humidity:\""..humi.."}",0,0, function(conn)  end)         
    
elseif( status == dht.ERROR_CHECKSUM ) then
  print( "DHT Checksum error." );
elseif( status == dht.ERROR_TIMEOUT ) then
  print( "DHT Time out." );
end
  
end)
  
