Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Variables"
Constants = require "Constants"
ShardePosition = require "SharedPosition"

--parameters
Counter = 0


function InitializeAgent()

    ShardePosition.StoreInformation(ID, {PositionX,PositionY})
    --[==[
    say("New Explorer")
    for i,v in ipairs(Agent.getMemberOfGroups(ID)) do
        say("Member of: " .. v)
    end
    --]==]
end


function TakeStep()

    -- Update Agent Information
    ShardePosition.StoreInformation(ID, {PositionX,PositionY})
end



function HandleEvent(event)

end

function CleanUp()

end