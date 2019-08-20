Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event = require "ranalib_event"
Variables = require "Libs.Variables"
Constants = require "Libs.Constants"
SharedPosition = require "Libs.SharedPosition"
Map = require "ranalib_map"
Utilities = require "Libs.Utilities"
State = require "Libs.RobotState"
Inspect = require "Libs.inspect"

--parameters
Counter = 0
Group_ID = 0
TargetPosition = {PositionX, PositionY}
TargetOrientation = ""
BasePosition = {}
TotalMemory = Variables.S
UsedMemory = 0
Memory = {}
MyState = State.Base


function InitializeAgent()
    SharedPosition.StoreInformation(ID, {PositionX, PositionY})
    TargetPosition = {PositionX, PositionY}





end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
    
    if eventDescription == "init" and ID ~= sourceID then
        if (eventTable ~= nil) then
            Group_ID = eventTable["group"]
            BasePosition = eventTable["BasePosition"]
            l_print("Explorer: " .. ID .. " has Group_ID: " .. Group_ID)
        else
            l_print("ERROR: eventable empty.")
        end
    
    elseif eventDescription == "servingDeployPosition" and ID ~= sourceID then
        l_print("Explorer: " .. ID .. " has recieved a deploy position, from Base: " .. sourceID)
        TargetPosition = eventTable["position"]
        TargetOrientation = eventTable["orientation"]
        say(Inspect.inspect(TargetPosition))
        MyState = State.Deploying
    end
end

function TakeStep()
    
    if Counter == 0 then
        Event.emit{speed = 343, description = "deployPositionRequested", targetID = Group_ID}
    end
    
    if UsedMemory == TotalMemory then
        TargetPosition = BasePosition
    end
    
    Counter = Counter + 1
    
    
    
    --SharedPosition.StoreInformation(ID, {PositionX,PositionY})
    if PositionX ~= TargetPosition[1] or PositionY ~= TargetPosition[2] then
        Utilities.moveTorus(TargetPosition[1], TargetPosition[2])
    else
        if MyState == State.Deploying then
            MyState = State.Deployed
            
        end
        
        if MyState == State.Deployed then
            Search()
            getNextStep()
            
        end
    end
end

function Search()
    local table = Map.radialMapColorScan(Variables.P, Constants.ore_color[1], Constants.ore_color[2], Constants.ore_color[3])
    
    if table ~= nil then
        for i = 1, #table do
            Map.quantumModify(table[i].posX, table[i].posY, Constants.ore_color, Constants.ore_color_found)
            AddInfoToMemory({table[i].posX, table[i].posY})
        end
    
    end
end



function CleanUp()

end

function getNextStep()
    
    if TargetOrientation == "North" then
        
        TargetPosition = {PositionX, PositionY + 1}
        Agent.changeColor{r=0, g=255, b=0}
    
    elseif TargetOrientation == "South" then
        
        TargetPosition = {PositionX, PositionY - 1}
        Agent.changeColor{r=255, g=255, b=255}
    
    elseif TargetOrientation == "East" then
        
        TargetPosition = {PositionX + 1, PositionY}
        Agent.changeColor{r=0, g=0, b=255}
    
    elseif TargetOrientation == "West" then
        
        TargetPosition = {PositionX - 1, PositionY}
    
    elseif TargetOrientation == "NorthWest" then
        
        TargetPosition = {PositionX - 1, PositionY + 1}
    
    elseif TargetOrientation == "SouthWest" then
        
        TargetPosition = {PositionX - 1, PositionY - 1}

    elseif TargetOrientation == "NorthEast" then
        
        TargetPosition = {PositionX + 1, PositionY + 1}

    elseif TargetOrientation == "SouthEast" then
        
        TargetPosition = {PositionX + 1, PositionY - 1}
    end  
    
    if TargetPosition[1] >= ENV_WIDTH then
        TargetPosition[1] = TargetPosition[1] - ENV_WIDTH
    end

    if TargetPosition[1] < 0 then
        TargetPosition[1] =  ENV_WIDTH + TargetPosition[1]
    end
    
    if TargetPosition[2] >= ENV_HEIGHT then
        TargetPosition[2] = TargetPosition[2] - ENV_HEIGHT
    end

    if TargetPosition[2] < 0 then
        TargetPosition[2] =  ENV_HEIGHT + TargetPosition[2]
    end

end

function AddInfoToMemory(info)
    if UsedMemory ~= TotalMemory then
        table.insert(Memory, info)
        UsedMemory = UsedMemory + 1
    end
end

function RemoveInfoFromMemory(index)
    if Memory[index] ~= nil then
        table.remove(Memory, index)
        UsedMemory = UsedMemory - 1
    end
end

function AlterInfoFromMemory(info, index)
    if Memory[index] ~= nil then
        table.insert(Memory, index, info)
    else
        AddInfoToMemory(index, info)
    end
end

function GetMemory(index)
    return Memory[index]
end

function ClearMemory()
    Memory = {}
    UsedMemory = 0
end
