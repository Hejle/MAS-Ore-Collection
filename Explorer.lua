Agent = require "ranalib_agent"
Collision = require "ranalib_collision"
Constants = require "Libs.Constants"
Event = require "ranalib_event"
Events = require "Libs.Events"
Inspect = require "Libs.inspect"
Map = require "ranalib_map"
Move = require "ranalib_movement"
SharedPosition = require "Libs.SharedPosition"
Stat = require "ranalib_statistic"
State = require "Libs.RobotState"
Utilities = require "Libs.Utilities"
Variables = require "Libs.Variables"

--parameters
Counter = 0
Group_ID = 0
DeployPosition = {}
CurrentPosition = {}
LastPosition = {}
DeployOrientation = ""
BasePosition = {}
BaseEntrancePosition = {}
BaseExitPosition = {}
TotalMemory = Variables.S
TotalEnergy = Variables.E
UsedEnergy = 0
UsedMemory = 0
Memory = {}
MyState = State.NotInit
ExTimeOut = 0


function InitializeAgent()
    SharedPosition.StoreInformation(ID, {PositionX, PositionY})
    CurrentPosition = {PositionX, PositionY}
end

function HandleEvent(event)
    local sourceX = event.X
    local sourceY = event.Y
    local sourceID = event.ID
    local eventDescription = event.description
    local eventTable = event.table
    if eventDescription == "init" and Group_ID == 0 then
        if (eventTable ~= nil) then
            Group_ID = eventTable["group"]
            BasePosition = eventTable["BasePosition"]
            BaseEntrancePosition = eventTable["BaseEntrance"]
            BaseExitPosition = eventTable["BaseExit"]
            MyState = State.Base
        --l_print("Explorer: " .. ID .. " has Group_ID: " .. Group_ID)
        else
            l_print("ERROR: eventable empty.")
        end
    
    elseif eventDescription == Events.servingDeployPosition and eventTable["target"] == ID then
        --l_print("Explorer: " .. ID .. " has recieved a deploy position, from Base: " .. sourceID .. " , " .. Inspect.inspect(eventTable))
        DeployPosition = eventTable["position"]
        DeployOrientation = eventTable["orientation"]
        MyState = State.ExitBase
    elseif eventDescription == Events.baseAccesGranted and eventTable["target"] == ID then
        MyState = State.PermissionToLand
    elseif eventDescription == "explorer_mem_clear" and eventTable["target"] == ID then
        ClearMemory()
    end

    
end

function TakeStep()
    if Counter % 1000 then
        --say(Inspect.inspect(MyState))
    end
    if MyState == State.Deploying then
        if Utilities.comparePoints(CurrentPosition, DeployPosition) then
            MyState = State.Exploring
        else
            Utilities.moveTorus(DeployPosition)
        end
        CheckEnergyStatus()
    
    elseif MyState == State.Exploring then
        -- Remeber to set the distance between steps properly, right now is only 1 pixel at a time
        NextPosition = GetNextStep(DeployOrientation, 1)
        Utilities.moveTorus(NextPosition)

            if DeployOrientation == Constants.RandomDir then
                DeployOrientation = Search()
            else
                Search()
            end

        CheckEnergyStatus()
        CheckMemoryStatus()

        if Utilities.comparePoints(DeployOrientation, CurrentPosition) then
            MyState = State.ReturningLoopComplete
        end
    
    elseif MyState == State.ReturningMemoryFull or MyState == State.ReturningBatteryLow or MyState == State.ReturningLoopComplete then
        if Utilities.distance(CurrentPosition, BasePosition) <= Variables.I/(4/3) then
            Event.emit{speed = 0, description = Events.baseAccesRequest, table = {target=Group_ID}}
            MyState = State.WaitingToLand
        else
            Utilities.moveTorus(BaseEntrancePosition)
        end
    elseif MyState == State.PermissionToLand then
        if Utilities.comparePoints(CurrentPosition, BaseEntrancePosition) then
            MyState = State.EnterBase
            LastPosition[3] = "nil"
            Event.emit{speed = 343, description = Events.updateDeployPositionsList, table = {target = Group_ID, data=LastPosition}}
        else
            Utilities.moveTorus(BaseEntrancePosition, BasePosition)
        end
    elseif MyState == State.EnterBase then
        if Utilities.comparePoints(CurrentPosition, BasePosition) then
            MyState = State.Base
        else
            Utilities.moveTorus(BasePosition, BasePosition)
        end
    elseif MyState == State.Base then
        if Utilities.IsNotEmpty(Memory) then
            SendMemoryToBase()
        elseif UsedEnergy == 0 then
            Event.emit{speed = 343, description = Events.deployPositionRequested, table = {target = Group_ID}}
            MyState = State.WaitForOrders
        else
            -- stay in the base until the battery has been charged
            end
    elseif MyState == State.ExitBase then
        if Utilities.comparePoints(CurrentPosition, BaseExitPosition) then
            MyState = State.Deploying
        else
            Utilities.moveTorus(BaseExitPosition, BasePosition)
        end
    elseif MyState == State.WaitForOrders then
        -- Do nothing
    elseif MyState == State.WaitingToLand then
        -- Do nothing
    end

    if not (MyState == State.NotInit) then
        UpdateEnergy()
        CurrentPosition = {PositionX, PositionY}
    end
    Counter = Counter + 1

end

function SendMemoryToBase()
    if ExTimeOut == 0 then
        Event.emit{speed = 343, description = Events.updateOreList, table = {target = Group_ID, data=Memory}}
        ExTimeOut = 200
    end
    ExTimeOut = ExTimeOut - 1
end

function CheckEnergyStatus()
    if (Utilities.GetEnergyNeeded({PositionX, PositionY}, BasePosition) + Variables.Q * 5 > TotalEnergy - UsedEnergy) then
        MyState = State.ReturningBatteryLow
        LastPosition = GetNextStep(DeployOrientation,Variables.P)
    end
end

function CheckMemoryStatus()
    if UsedMemory >= TotalMemory then
        MyState = State.ReturningMemoryFull
        LastPosition = GetNextStep(DeployOrientation,Variables.P)
    end
end


function UpdateEnergy()
    StateEnergyCost = 0
    if MyState == State.Deploying or MyState == State.ReturningMemoryFull or MyState == State.ReturningBatteryLow then
        StateEnergyCost = Variables.Q
    elseif MyState == State.Exploring then
        StateEnergyCost = Variables.Q + Variables.O
    elseif MyState == State.Base then
        if UsedEnergy > 0 then
            StateEnergyCost = -1
        end
    end
    UsedEnergy = UsedEnergy + StateEnergyCost
    if UsedEnergy >= TotalEnergy then
        MyState = State.Dead
        say("I died: " .. ID)
    end
end

function Search()
    local table = Map.radialMapColorScan(Variables.P, Constants.ore_color[1], Constants.ore_color[2], Constants.ore_color[3])
    table = Utilities.TableConcat(table, Map.radialMapColorScan(Variables.P, Constants.ore_color_found[1], Constants.ore_color_found[2], Constants.ore_color_found[3]))
    VotesForDirections = {0, 0, 0, 0}
    if table ~= nil then
        for i = 1, #table do
            OreX = table[i].posX
            OreY = table[i].posY
            
            if AddInfoToMemory({OreX, OreY}) then
                
                --Map.quantumModify(OreX, OreY, Constants.ore_color, Constants.ore_color_found)
                
                -- Check for direction with more ores
                dx = OreX - PositionX
                dy = OreY - PositionY
                
                if (dx < 0 and dy < 0) then
                    VotesForDirections[3] = VotesForDirections[3] + 1
                elseif (dx < 0 and dy > 0) then
                    VotesForDirections[2] = VotesForDirections[2] + 1
                elseif (dx > 0 and dy < 0) then
                    VotesForDirections[4] = VotesForDirections[4] + 1
                elseif (dx > 0 and dy > 0) then
                    VotesForDirections[1] = VotesForDirections[1] + 1
                end
            else
                break
            end
        end
    end
    
    local maxVotes = math.max(VotesForDirections[1], VotesForDirections[2], VotesForDirections[3], VotesForDirections[4])
    local selectedQuadrant = 0
    if maxVotes == 0 then
        selectedQuadrant = math.random(4)
    else
        for i = 1, #VotesForDirections do
            if VotesForDirections[i] == maxVotes then
                selectedQuadrant = i
                break
            end
        end
    end
    if selectedQuadrant == 1 then
        direction = Constants.NorthEast
    elseif selectedQuadrant == 2 then
        direction = Constants.NortWest
    elseif selectedQuadrant == 3 then
        direction = Constants.SouthWest
    elseif selectedQuadrant == 4 then
        direction = Constants.SouthEast
    end
    
    
    return direction
end


function CleanUp()

end

function GetNextStep(orientation, stepsize)
    position = {0, 0}
    if orientation == Constants.North then
        position = {PositionX, PositionY + stepsize}
    elseif orientation == Constants.South then
        position = {PositionX, PositionY - stepsize}
    elseif orientation == Constants.East then
        position = {PositionX + stepsize, PositionY}
    elseif orientation == Constants.West then
        position = {PositionX - stepsize, PositionY}
    elseif orientation == Constants.NorthEast then
        position = {PositionX + stepsize, PositionY + stepsize}
    elseif orientation == Constants.NorthWest then
        position = {PositionX - stepsize, PositionY + stepsize}
    elseif orientation == Constants.SouthWest then
        position = {PositionX - stepsize, PositionY - stepsize}
    elseif orientation == Constants.SouthEast then
        position = {PositionX + stepsize, PositionY - stepsize}
    end
    
    position = Utilities.CorrectPosition(position)
    return position
end

function AddInfoToMemory(info)
    if UsedMemory + 1 <= TotalMemory then
        table.insert(Memory, info)
        UsedMemory = UsedMemory + 1
        return true
    end
    return false
end

function AddInfoListToMemory(list)
    if #list > TotalMemory - UsedMemory then
        return false
    else
        for i = 1, #list do
            table.insert(Memory, list[1])
            UsedMemory = UsedMemory - 1
        end
    end
end

function RemoveInfoFromMemory(info)
    for i = 1, #Memory do
        if Utilities.comparePoints(info, Memory[i]) then
            table.remove(Memory, i)
            UsedMemory = UsedMemory - 1
        end
    end
end

function RemoveIndexFromMemory(index)
    if Memory[index] ~= nil then
        table.remove(Memory, index)
        UsedMemory = UsedMemory - 1
    end
end

function AlterInfoFromMemory(info, index)
    if Memory[index] ~= nil then
        table.insert(Memory, index, info)
        return true
    else
        return AddInfoToMemory(index, info)
    end
end

function GetMemory(index)
    return Memory[index]
end

function ClearMemory()
    Memory = {}
    UsedMemory = 0
end
