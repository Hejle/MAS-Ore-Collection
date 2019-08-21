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


function InitializeAgent()
    BasePos = {PositionX, PositionY}
    BaseExitPos = {BasePos[1], BasePos[2] +1}
    BaseEntrancePos = {BasePos[1], BasePos[2] -1}
    SharedPosition.StoreInformation(ID, BasePos)
    Agent.changeColor{id=ID, r=128,g=0,b=128}
    DeployPositionsList = Utilities.GenerateDeployPositions(DeployPositionsList)
    KnownOres = {{2,4}, {25,4}, {15,4}, {1,4}, {10,4}}
    --say("list is: " .. Inspect.inspect(SendOre(20000)))
end

function TakeStep()
    if Counter == 0 then
        InitRobots()
    end
    if Utilities.IsNotEmpty(WaitingTransporters) then
        local id, value = next(WaitingTransporters)
        local list = SendOre(value[1], value[2])
        Event.emit{speed = 343, description = Events.RetrieveOrders, table = list, targetID = id}
        WaitingTransporters[id] = nil
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
        --UpdateOreList()
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


function StoreOre(list)
    for i=1,#list do
        table.insert(KnownOresBeingCollected, list[i])
    end
end

function SendOre(energy, size)
    local result = {}
    Utilities.SortUsingDistance(KnownOresBeingCollected, BasePos)
    return SendOresSorted(energy, BasePos, result, size)
end

function SendOresSorted(energy, comparePoint, resultList, size)
    local addedPoint = false
    local usedEnergy = 0
    local newPoint = {}
    local getHomeEnergy = 0

    if #resultList == size then
        return resultList
    end

    local point = Utilities.GetValueWithSortestDistance(KnownOres, comparePoint)
    if point ~= nil then
        usedEnergy = Utilities.GetEnergyNeeded(point[1], comparePoint)
        getHomeEnergy = Utilities.GetEnergyNeeded(point[1], BasePos)
        if usedEnergy + getHomeEnergy < energy then
            table.insert(resultList, point[1])
            table.insert(KnownOresBeingCollected, point[1])
            newPoint = point[1]
            table.remove( KnownOres, point[2])
            addedPoint = true
        end
    end
    if addedPoint then
        return SendOresSorted(energy - usedEnergy, newPoint, resultList, size)
    else
        return resultList
    end
end
