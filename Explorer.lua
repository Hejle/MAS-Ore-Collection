Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Variables"
Constants = require "Constants"

--parameters
Counter = 0


function InitializeAgent()
    --[==[
    say("New Explorer")
    for i,v in ipairs(Agent.getMemberOfGroups(ID)) do
        say("Member of: " .. v)
    end
    --]==]
end


function TakeStep()
end

function HandleEvent(event)

end

function CleanUp()

end