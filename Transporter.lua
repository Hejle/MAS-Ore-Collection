Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Libs/Variables"
Constants = require "Libs/Constants"
SharedPosition = require "Libs/SharedPosition"

--parameters
Counter = 0


function InitializeAgent()

      SharedPosition.StoreInformation(ID, {PositionX,PositionY})
end


function TakeStep()
        -- Update Agent Information
        SharedPosition.StoreInformation(ID, {PositionX,PositionY})
end

function handleEvent(event)

end

function CleanUp()

end