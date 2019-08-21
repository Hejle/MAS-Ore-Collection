Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Libs.Variables"
Constants = require "Libs.Constants"
Collision = require "ranalib_collision"
SharedPosition = require "Libs.SharedPosition"
Inspect = require "Libs.inspect"
Utilities = require "Libs.Utilities"

--parameters
Counter = 0
deployPositionsList = {}
KnownOresUncollected = {}
KnownOresBeingCollected = {}
ExplorerPose = {}

function InitializeAgent()
    SharedPosition.StoreInformation(ID, {PositionX,PositionY})
    Agent.changeColor{id=ID, r=128,g=0,b=128}
    deployPositionsList = Utilities.GenerateDeployPositions(deployPositionsList)
    KnownOres = {{2,4}, {25,4}, {15,4}, {1,4}, {10,4}}
    --say("list is: " .. Inspect.inspect(SendOre(20000)))
end

function TakeStep()
    if Counter == 0 then
        InitRobots()
    end

    Counter = Counter + 1
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
    if eventDescription == "deployPositionRequested" and ID ~= sourceID then
        ExplorerPose = table.remove(deployPositionsList, 1)
        if ExplorerPose ~= nil then
            Event.emit{speed = 343, description = "servingDeployPosition", table = {position = {ExplorerPose[1], ExplorerPose[2]}, orientation = ExplorerPose[3]}, targetID = sourceID}
        else
            Event.emit{speed = 343, description = "servingDeployPosition", table = {position = {PositionX, PositionY}, orientation = "nil"}, targetID = sourceID}
        end
    elseif eventDescription == "updateDeployPositionsList" and ID ~= sourceID then
        table.insert(deployPositionsList, eventTable)
    elseif eventDescription == "updateOreList" and ID ~= sourceID then
        --UpdateOreList()
    elseif eventDescription == "baseAccesRequest" and ID  ~= sourceID then
        Event.emit{speed = 0, description = "baseAccesGranted", targetID = sourceID}
    end

end

function InitRobots()
    -- Broadcast the necessary informations for the Agents belonging to this base
    Event.emit{speed = 343, description = "init", table = {group = ID, BasePosition = {PositionX, PositionY}}, groupID = ID}
end

function CleanUp()

end


function StoreCoordinates(list)
    for i=1,#list do
        table.insert(KnownOres, list[i])
    end
end

function SendOre(energy)
    local result = {}
    Utilities.SortUsingDistance(KnownOres, {PositionX, PositionY})    
    return SendOresSorted(energy, {PositionX, PositionY}, result)
end

function SendOresSorted(energy, comparePoint, resultList)
    local addedPoint = false
    local usedEnergy = 0
    local newPoint = {}
    local getHomeEnergy = 0

    local point = Utilities.GetValueWithSortestDistance(KnownOres, comparePoint)
    if point ~= nil then 
        usedEnergy = Utilities.GetEnergyNeeded(point[1], comparePoint)
        getHomeEnergy = Utilities.GetEnergyNeeded(point[1], {PositionX, PositionY})
        if usedEnergy + getHomeEnergy < energy then
            table.insert(resultList, point[1])
            table.insert(KnownOresBeingCollected, point[1])
            newPoint = point[1]
            table.remove( KnownOres, point[2])
            addedPoint = true
        end
    end
    if addedPoint then
        return SendOresSorted(energy - usedEnergy, newPoint, resultList)
    else
        return resultList
    end
end
