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

 
