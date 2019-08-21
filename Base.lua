Agent = require "ranalib_agent"
<<<<<<< HEAD
Event =  require "ranalib_event"
Variables = require "Libs.Variables"
Constants = require "Libs.Constants"
SharedPosition = require "Libs.SharedPosition"
Inspect = require "Libs.inspect"
Utilities = require "Libs.Utilities"

--parameters
Counter = 0
DeployPositionsList = {}
KnownOresUncollected = {}
KnownOresBeingCollected = {}

function InitializeAgent()
    SharedPosition.StoreInformation(ID, {PositionX,PositionY})
    Agent.changeColor{id=ID, r=128,g=0,b=128}
    GenerateDeployPositions()
    KnownOres = {{2,4}, {25,4}, {15,4}, {1,4}, {10,4}}
    say("list is: " .. Inspect.inspect(SendOre(20000)))
=======
Collision = require "ranalib_collision"
Constants = require "Libs.Constants"
Event = require "ranalib_event"
Inspect = require "Libs.inspect"
Move = require "ranalib_movement"
SharedPosition = require "Libs.SharedPosition"
Utilities = require "Libs.Utilities"
Variables = require "Libs.Variables"


--parameters
Counter = 0
deployPositionsList = {}
ExplorerPose = {}

function InitializeAgent()
    SharedPosition.StoreInformation(ID, {PositionX, PositionY})
    Agent.changeColor{id = ID, r = 128, g = 0, b = 128}
    deployPositionsList = Utilities.GenerateDeployPositions(deployPositionsList)
>>>>>>> 80306899099db4015da04e270f91615e959c9427
end

function TakeStep()
    if Counter == 0 then
        InitRobots()
    end

    Counter = Counter + 1
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
    
    if eventDescription == "deployPositionRequested" and ID ~= sourceID then
        --l_print("Base: " .. ID .. " , Explorer: " .. sourceID .. " has requested a deploy position.")
        ExplorerPose = table.remove(deployPositionsList, 1)
        if ExplorerPose ~= nil then
            Event.emit{speed = 343, description = "servingDeployPosition", table = {position = {ExplorerPose[1], ExplorerPose[2]}, orientation = ExplorerPose[3]}, targetID = sourceID}
        else
            Event.emit{speed = 343, description = "servingDeployPosition", table = {position = {PositionX, PositionY}, orientation = "nil"}, targetID = sourceID}
        end
    elseif eventDescription == "updateDeployPositionsList" and ID ~= sourceID then
        --say("Update DeployPositionList " .. sourceID)
        table.insert(deployPositionsList, eventTable)
    elseif eventDescription == "updateOreList" and ID ~= sourceID then
        say("Update OreList: " .. sourceID)
    end

end

function InitRobots()
    -- Broadcast the necessary informations for the Agents belonging to this base
    Event.emit{speed = 343, description = "init", table = {group = ID, BasePosition = {PositionX, PositionY}}, groupID = ID}
end

function CleanUp()

end



<<<<<<< HEAD
function  GenerateDeployPositions()
    
    PosY = PositionY + Variables.P
    if PosY > ENV_HEIGHT then
        PosY = PosY - ENV_HEIGHT
    end
    PosExplorer = {PosX,}

    for i=1, Variables.X do
        if i % 2 == 0 then
            PosX = PositionX + 10* i
        else
            PosX = PositionX - 10* i
        end
        if PosX > ENV_WIDTH then
            PosX = PosX - ENV_WIDTH
        end
        PosExplorer = {PosX,PositionY + Variables.P}
        
        table.insert(DeployPositionsList,i,PosExplorer)
    end

end

function StoreCoordinates(list)
    for i=1,#list do
        table.insert( KnownOres, {list[i], Constants.NotBeingCollected} )
    end
end

function SendOre(energy)
    say("hi")
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
        say("Used Energy: " .. usedEnergy)
        say("Home Energy: " .. getHomeEnergy)
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
=======
>>>>>>> 80306899099db4015da04e270f91615e959c9427
