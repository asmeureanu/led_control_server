tmr.alarm(6,5000, 1, function() 
    dofile("core.lua");
    tmr.stop(6)
end)
