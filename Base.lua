Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Libs/Variables"
Constants = require "Libs/Constants"
SharedPosition = require "Libs/SharedPosition"

--parameters
Counter = 0
DeployPositionsList = {}


function InitializeAgent()

    SharedPosition.StoreInformation(ID, {PositionX,PositionY})

end


function TakeStep()

end

function HandleEvent(event)


end

function CleanUp()

end

function  GenerateDeployPositions()
    
    for i=1, Variables.X do
        PosX = PositionX + 10
        PosExplorer = {PosX,PositionY}
        table.insert( DeployPositionsList,i,PosExplorer)
    end
end