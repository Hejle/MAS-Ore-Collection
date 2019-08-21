Agent = require "ranalib_agent"
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



