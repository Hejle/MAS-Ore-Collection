Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Libs/Variables"
Constants = require "Libs/Constants"
SharedPosition = require "Libs/SharedPosition"
Inspect = require "Libs/inspect"

--parameters
Counter = 0
DeployPositionsList = {}


function InitializeAgent()

    SharedPosition.StoreInformation(ID, {PositionX,PositionY})
    GenerateDeployPositions()
    

end


function TakeStep()
    if Counter == 0 then
        InitRobots()
    end
    Counter = Counter + 1
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)	
    

    if eventDescription == "deployPositionRequested" and ID ~= sourceID then
        l_print("Base: " .. ID .. " , Explorer: " .. sourceID .. " has requested a deploy position." )
        PosExplorer  = table.remove( DeployPositionsList, 1)
        --say(Inspect.inspect(DeployPositionsList))
		Event.emit {speed = 343, description = "servingDeployPosition", table = PosExplorer, targetID = sourceID}	
	end

end

function InitRobots()
    Event.emit {speed = 343, description = "init", table = {group=ID}, groupID = ID}
end

function CleanUp()

end



function  GenerateDeployPositions()
    
    PosY = PositionY + Variables.P
    if PosY > ENV_HEIGHT then
    end
    PosExplorer = {PosX,}

    for i=1, Variables.X do
        PosX = PositionX + 10* i
        if PosX > ENV_WIDTH then
            PosX = PosX - ENV_WIDTH
        end
        PosExplorer = {PosX,PositionY + Variables.P}
        
        table.insert(DeployPositionsList,i,PosExplorer)
    end

end