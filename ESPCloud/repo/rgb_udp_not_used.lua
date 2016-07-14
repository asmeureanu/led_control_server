print("this is my very cool now program")


      -- pins of the RGB strip according to:
      -- https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
      redPin     = 5
      greenPin = 2
      bluePin   = 1
      -- PWM frequency - adjust if LED flickers or PWM doesn't look linear
      pwmFreq = 250
      -- set up pins as PWM pins
      pwm.setup(redPin, pwmFreq, 0)
      pwm.setup(greenPin, pwmFreq, 0)
      pwm.setup(bluePin, pwmFreq, 0)
      -- start PWM output on the pins (effectively no light yet)
      pwm.start(redPin)
      pwm.start(greenPin)
      pwm.start(bluePin)
      -- create UDP server to listen for our color changes
      srv = net.createServer(net.UDP);
      srv:on("receive",function(cu,msg) 
         -- we expect the packet in "R,G,B" format
         -- thus use the split function from our functions file (similar to php explode, returning an array)
         red, green, blue = msg:match("([^,]+),([^,]+),([^,]+)")
         print("color ".. red .." " .. green .. " " ..blue)
         print("color ".. redPin .." " .. greenPin .. " " ..bluePin)
         pwm.setduty(redPin, red*4);
         pwm.setduty(greenPin, green*4);
         pwm.setduty(bluePin, blue*4);
      end)
      srv:listen(4444)


