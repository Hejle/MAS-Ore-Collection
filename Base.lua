Agent = require "ranalib_agent"
Event = require "ranalib_event"
Events = require "Libs.Events"
Variables = require "Libs.Variables"
Constants = require "Libs.Constants"
Collision = require "ranalib_collision"
SharedPosition = require "Libs.SharedPosition"
Inspect = require "Libs.inspect"
Utilities = require "Libs.Utilities"

--parameters
Counter = 0
MineralCapacity = Variables.C
Minerals = 0
DeployPositionsList = {}
KnownOresUncollected = {}
ExplorerPose = {}
BasePos = {}
BaseExitPos = {}
BaseEntrancePos = {}
WaitingTransporters = {}
TotalMemory = Variables.S
LandingList = {}


function InitializeAgent()
    BasePos = {PositionX, PositionY}
    BaseExitPos = {BasePos[1], BasePos[2] + 1}
    BaseEntrancePos = {BasePos[1], BasePos[2] - 1}
    SharedPosition.StoreInformation(ID, BasePos)
    Agent.changeColor{id = ID, r = 128, g = 0, b = 128}
    --Utilities.PaintBase()
    DeployPositionsList = Utilities.GenerateDeployPositions(DeployPositionsList)
    SampleCounter = 0
end



function TakeStep()
    if Counter == 0 then
        InitRobots()
    end
    if Utilities.IsNotEmpty(LandingList) then
        local k, v = next(LandingList)
        Event.emit{speed = 0, description = Events.baseAccesGranted, table = {target=k}}
        LandingList[k] = nil
    end

    if Utilities.IsNotEmpty(WaitingTransporters) then
        local id, value = next(WaitingTransporters)
        if Utilities.IsNotEmpty(KnownOresUncollected) then
            local list = SendOre(value[1], value[2], id)
            if Utilities.IsNotEmpty(list) then
                Event.emit{speed = 343, description = Events.RetrieveOrders, table = {target=id, data=list}}
                WaitingTransporters[id] = nil
            end
        end
    end
    Counter = Counter + 1
end

function HandleEvent(event)
    local sourceX = event.X
    local sourceY = event.Y
    local sourceID = event.ID
    local eventDescription = event.description
    local eventTable = event.table
    if(Utilities.distance({sourceX, sourceY}, {PositionX, PositionY}) > Variables.I) then
        return
    end
    if eventDescription == Events.deployPositionRequested and ID == eventTable["target"] then
        --l_print("Base: " .. ID .. " , Explorer: " .. sourceID .. " has requested a deploy position.")
        ExplorerPose = table.remove(DeployPositionsList, 1)
        if ExplorerPose ~= nil and ((Utilities.IsPoint({ExplorerPose[1], ExplorerPose[2]}))) then
            Event.emit{speed = 343, description = Events.servingDeployPosition, table = {target=sourceID, position = {ExplorerPose[1], ExplorerPose[2]}, orientation = ExplorerPose[3]}}
        else
            ExplorerPose = GetNewDeploytPoint()
            Event.emit{speed = 343, description = Events.servingDeployPosition, table = {target=sourceID, position = {ExplorerPose[1], ExplorerPose[2]}, orientation = ExplorerPose[3]}}
        end
    elseif eventDescription == Events.updateDeployPositionsList and ID == eventTable["target"] then
        newDeployPosition = {eventTable["data"][1],eventTable["data"][2]}
        DistanceToDeploy = Utilities.distance(newDeployPosition, BasePos)
        
        if eventTable[3] == "nil" then
            say("Explorer " .. sourceID .. " didn't find any ore.")
        elseif DistanceToDeploy > 150 then -- Variables.G/2 then
            say("Explorer " .. sourceID .. " reached max distance " .. DistanceToDeploy)
        else
            table.insert(DeployPositionsList, eventTable)
        end
    elseif eventDescription == Events.updateOreList and ID == eventTable["target"] then
        if StoreOre(eventTable["data"]) then
            Event.emit{speed = 0, description = "explorer_mem_clear", table = {target=sourceID}}
        else
            --Do something if theres not space for ores
        end
    elseif eventDescription == Events.RequestOrders and ID == eventTable["target"] then
        table.insert(WaitingTransporters, eventTable["transporterID"],{eventTable["energy"], eventTable["backPack"]})
    elseif eventDescription == Events.ReturningMinerals and ID == eventTable["target"] then
        HandleReturningMinerals(eventTable["transporterID"], eventTable["minerals"], eventTable["memo"])
    elseif eventDescription == Events.baseAccesRequest and ID == eventTable["target"] then
        Event.emit{speed = 0, description = Events.baseAccesGranted, table = {target=sourceID}}
        --table.insert(LandingList, sourceID, sourceID)
    end
end

function GetNewDeploytPoint()
    DeployPositionsList = Utilities.SampleNewDeployPosiiton(DeployPositionsList, 10, SampleCounter)
    SampleCounter = SampleCounter + 1
    local Pose = table.remove(DeployPositionsList, 1)
    if Utilities.IsPoint({Pose[1], Pose[2]}) then
        return Pose
    else
        return GetNewDeploytPoint()
    end
end

function InitRobots()
    -- Broadcast the necessary informations for the Agents belonging to this base
    local initTable = {}
    initTable["group"] = ID
    initTable["BasePosition"] = BasePos
    initTable["BaseExit"] = BaseExitPos
    initTable["BaseEntrance"] = BaseEntrancePos
    Event.emit{speed = 343, description = "init", table = initTable}
end

function CleanUp()

end

function HandleReturningMinerals(robot, min, mem)
    --if Utilities.IsNotEmpty(mem) then
        --StoreOre(mem)
    --end
    local f = function(v1, v2)
        return (v1[2] == v2)
    end
    if (Minerals + min > MineralCapacity) then
        Minerals = MineralCapacity
    else
        Minerals = Minerals + min
    end

    Event.emit{speed = 343, description = Events.OreStored, table = {target=robot}}
end


function StoreOre(list)
    for i=1,#list do
        if Utilities.IsPoint(list[i]) then
            Map.quantumModify(list[i][1], list[i][2], Constants.ore_color, Constants.ore_color_found)
            table.insert(KnownOresUncollected, list[i])
        end
    end
    --if (#list + #KnownOresUncollected > TotalMemory) then
    --    if #list < #KnownOresUncollected then
    --        return false
    --    else
    --        KnownOresUncollected = {}
    --    end
    --else
    --    for i=1,#list do
    --        if Utilities.IsPoint(list[i]) then
    --            Map.quantumModify(list[i][1], list[i][2], Constants.ore_color, Constants.ore_color_found)
    --            table.insert(KnownOresUncollected, list[i])
    --        end
    --    end
    --end
    return true
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
            table.remove(KnownOresUncollected, point[2])
            newPoint = point[1]
            addedPoint = true
        end
    end
    if addedPoint then
        return SendOresSorted(energy - usedEnergy, newPoint, resultList, size,robot)
    else
        return resultList
    end
end
