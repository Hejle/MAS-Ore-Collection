Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Variables"
Constants = require "Constants"
ShardePosition = require "SharedPosition"
Map = require "ranalib_map" 
Utilities = require "Utilities"

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
    Search()
    ShardePosition.StoreInformation(ID, {PositionX,PositionY})
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
     Utilities.moveTorus(10,10)
end

function HandleEvent(event)

end

function CleanUp()

end


