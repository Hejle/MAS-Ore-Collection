Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Events = require "Libs.Events"
Variables = require "Libs.Variables"
Constants = require "Libs.Constants"
Collision = require "ranalib_collision"
SharedPosition = require "Libs.SharedPosition"
Inspect = require "Libs.inspect"
Utilities = require "Libs.Utilities"

--parameters
Counter = 0
DeployPositionsList = {}
KnownOresUncollected = {}
KnownOresBeingCollected = {}
ExplorerPose = {}
BasePos = {}
BaseExitPos = {}
BaseEntrancePos = {}
WaitingTransporters = {}
TotalMemory = Variables.S


function InitializeAgent()
    BasePos = {PositionX, PositionY}
    BaseExitPos = {BasePos[1], BasePos[2] +1}
    BaseEntrancePos = {BasePos[1], BasePos[2] -1}
    SharedPosition.StoreInformation(ID, BasePos)
    Agent.changeColor{id=ID, r=128,g=0,b=128}
    DeployPositionsList = Utilities.GenerateDeployPositions(DeployPositionsList)
    --say("list is: " .. Inspect.inspect(SendOre(20000)))
end

function TakeStep()
    if Counter == 0 then
        InitRobots()
    end
    if Utilities.IsNotEmpty(WaitingTransporters) then
        local id, value = next(WaitingTransporters)
        local list = SendOre(value[1], value[2], id)
        if Utilities.IsNotEmpty(list) then
            Event.emit{speed = 343, description = Events.RetrieveOrders, table = list, targetID = id}
            WaitingTransporters[id] = nil
        end
    end
    Counter = Counter + 1
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
    if eventDescription == "deployPositionRequested" and ID ~= sourceID then
        --l_print("Base: " .. ID .. " , Explorer: " .. sourceID .. " has requested a deploy position.")
        ExplorerPose = table.remove(DeployPositionsList, 1)
        if ExplorerPose ~= nil then
            Event.emit{speed = 343, description = "servingDeployPosition", table = {position = {ExplorerPose[1], ExplorerPose[2]}, orientation = ExplorerPose[3]}, targetID = sourceID}
        else
            Event.emit{speed = 343, description = "servingDeployPosition", table = {position = BasePos, orientation = "nil"}, targetID = sourceID}
        end
    elseif eventDescription == "updateDeployPositionsList" and ID ~= sourceID then
        table.insert(DeployPositionsList, eventTable)
    elseif eventDescription == "updateOreList" and ID ~= sourceID then
        say("Update OreList: " .. sourceID)
        StoreOre(eventTable)
    elseif eventDescription == Events.RequestOrders then
        table.insert(WaitingTransporters, eventTable["transporterID"],{eventTable["energy"], eventTable["backPack"]})
    elseif eventDescription == Events.ReturningMinerals then
        HandleReturningMinerals(eventTable["transporterID"], eventTable["minerals"], eventTable["memo"])
    elseif eventDescription == "baseAccesRequest" and ID  ~= sourceID then
        Event.emit{speed = 0, description = "baseAccesGranted", targetID = sourceID}
    end

end

function InitRobots()
    -- Broadcast the necessary informations for the Agents belonging to this base
    local initTable = {}
    initTable["group"] = ID
    initTable["BasePosition"] = BasePos
    initTable["BaseExit"] = BaseExitPos
    initTable["BaseEntrance"] = BaseEntrancePos
    Event.emit{speed = 343, description = "init", table = initTable, groupID = ID}
end

function CleanUp()

end

function HandleReturningMinerals(robot, Minerals, Memory)
    say("getting ore")
    if Utilities.IsNotEmpty(Memory) then
        StoreOre(Memory)
    end
    local f = function(v1, v2)
        return (v1[2] == v2)
    end
    KnownOresBeingCollected = Utilities.RemoveAllValuesArrayFunction(KnownOresBeingCollected, f, robot)
    Event.emit{speed = 343, description = Events.OreStored, table = {}, targetID = robot}
end


function StoreOre(list)
    if(#list + #KnownOresUncollected + #KnownOresBeingCollected > TotalMemory) then
        --NoMemory
    else
        for i=1,#list do
            table.insert(KnownOresUncollected, list[i])
        end
    end
end

function SendOre(energy, size, robot)
    local result = {}
    Utilities.SortUsingDistance(KnownOresUncollected, BasePos)
    return SendOresSorted(energy, BasePos, result, size, robot)
end

function SendOresSorted(energy, comparePoint, resultList, size, robot)
    local addedPoint = false
    local usedEnergy = 0
    local newPoint = {}
    local getHomeEnergy = 0

    if #resultList == size then
        return resultList
    end

    local point = Utilities.GetValueWithSortestDistance(KnownOresUncollected, comparePoint)
    if point ~= nil then
        usedEnergy = Utilities.GetEnergyNeeded(point[1], comparePoint)
        getHomeEnergy = Utilities.GetEnergyNeeded(point[1], BasePos)
        if usedEnergy + getHomeEnergy < energy then
            table.insert(resultList, point[1])
            table.insert(KnownOresBeingCollected, {point[1], robot})
            newPoint = point[1]
            table.remove( KnownOresUncollected, point[2])
            addedPoint = true
        end
    end
    if addedPoint then
        return SendOresSorted(energy - usedEnergy, newPoint, resultList, size,robot)
    else
        return resultList
    end
end
