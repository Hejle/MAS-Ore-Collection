Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Libs/Variables"
Constants = require "Libs/Constants"
SharedPosition = require "Libs/SharedPosition"
Map = require "ranalib_map" 
Utilities = require "Libs/Utilities"
Inspect = require "Libs/inspect"

--parameters
Counter = 0
Group_ID = 0
PosDeploy = {}


function InitializeAgent()
    SharedPosition.StoreInformation(ID, {PositionX,PositionY})
    PosDeploy = {PositionX,PositionY}
    
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)	

    if eventDescription == "init" and ID ~= sourceID then
       if(eventTable ~= nil) then
        Group_ID = eventTable["group"]
        l_print("Explorer: " .. ID .. " has Group_ID: " .. Group_ID )
       else
        l_print("ERROR: eventable empty." )
       end


	elseif eventDescription == "servingDeployPosition" and ID ~= sourceID then
        l_print("Explorer: " .. ID .. " has recieved a deploy position, from Base: " .. sourceID )
        PosDeploy  = eventTable
        say(Inspect.inspect(PosDeploy))
	end
end

function TakeStep()

    if Counter == 0 then
        Event.emit {speed = 343, description = "deployPositionRequested",targetID = Group_ID}	
    end

    Counter = Counter + 1
    
    --Search()
    --SharedPosition.StoreInformation(ID, {PositionX,PositionY})

    if PositionX ~= PosDeploy[1] or PositionY ~= PosDeploy[2] then
        --say("I am not ready yet " .. ID)
        Utilities.moveTorus(PosDeploy[1],PosDeploy[2])
    else
        say("I'm Ready")
    end
end

function Search()
	local table = Map.radialMapColorScan(Variables.P, Constants.ore_color[1],  Constants.ore_color[2],  Constants.ore_color[3])

    if table ~= nil then
        for i=1, #table do
            Map.quantumModify(table[i].posX, table[i].posY,Constants.ore_color, Constants.ore_color_found)
        end
        
	end
	--if no grass is found search a new area
	--direction = {
	--	PositionX + l_getRandomInteger(-Variables.P, Variables.P),
	--	PositionY + l_getRandomInteger(-Variables.P, Variables.P)
	--}
    --Move.to {x = 100, y = 100, speed = 10}
    

end



function CleanUp()

end