Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event = require "ranalib_event"
Variables = require "Libs/Variables"
Constants = require "Libs/Constants"
SharedPosition = require "Libs/SharedPosition"
Inspect = require "Libs/inspect"

--parameters
Counter = 0
DeployPositionsList = {}
ExplorerPose = {}


function InitializeAgent()
    SharedPosition.StoreInformation(ID, {PositionX, PositionY})
    Agent.changeColor{id = ID, r = 128, g = 0, b = 128}
    GenerateDeployPositions()

end


function TakeStep()
    if Counter == 0 then
        InitRobots()
    
    end
    Counter = Counter + 1
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
    
    if eventDescription == "deployPositionRequested" and ID ~= sourceID then
        l_print("Base: " .. ID .. " , Explorer: " .. sourceID .. " has requested a deploy position.")
        ExplorerPose = table.remove(DeployPositionsList, 1)
        if ExplorerPose ~= nil then
        Event.emit{speed = 343, description = "servingDeployPosition", table = {position = {ExplorerPose[1], ExplorerPose[2]}, orientation = ExplorerPose[3]}, targetID = sourceID}
        else
        Event.emit{speed = 343, description = "servingDeployPosition", table = {position = {PositionX, PositionY}, orientation = "nil"}, targetID = sourceID}
        end
    end

end

function InitRobots()
    Event.emit{speed = 343, description = "init", table = {group = ID, BasePosition = {PositionX, PositionY}}, groupID = ID}
end

function CleanUp()

end


-- Sorry for this  collection of fors
function GenerateDeployPositions()
    
    NumPointsTops = 2
    NumPointsSides = 2

    offset = Variables.W*NumPointsSides*2 + Variables.W*2

    refX = PositionX
    refY = PositionY

    for i = 0, (NumPointsTops+1) do
        PosX = refX + Variables.W * 2 * i
        PosY = refY + Variables.Z + offset
        ExplorerPose = {PosX, PosY, "North"}
        addPose(ExplorerPose)
    end
    
    refX = PositionX - Variables.W
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY + Variables.Z*2 + offset
        ExplorerPose = {PosX, PosY, "North"}
        addPose(ExplorerPose)
    end

    refX = PositionX + Variables.W

    for i = 0, NumPointsTops do
        PosX = refX + Variables.W * 2 * i
        PosY = refY + Variables.Z*2 + offset
        ExplorerPose = {PosX, PosY, "North"}
        addPose(ExplorerPose)
    end

    refX = PositionX - 2*Variables.W

    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY + Variables.Z + offset
        ExplorerPose = {PosX, PosY, "North"}
        addPose(ExplorerPose)
    end

    refX = PositionX
    refY = PositionY

    for i = 0, (NumPointsTops+1) do
        PosX = refX + Variables.W * 2 * i
        PosY = refY - Variables.Z - offset
        ExplorerPose = {PosX, PosY, "South"}
        addPose(ExplorerPose)
    end
    
    refX = PositionX - Variables.W
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY - Variables.Z*2 - offset
        ExplorerPose = {PosX, PosY, "South"}
        addPose(ExplorerPose)
    end

    refX = PositionX + Variables.W

    for i = 0, NumPointsTops do
        PosX = refX + Variables.W * 2 * i
        PosY = refY - Variables.Z*2 - offset
        ExplorerPose = {PosX, PosY, "South"}
        addPose(ExplorerPose)
    end

    refX = PositionX - 2*Variables.W

    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY - Variables.Z - offset
        ExplorerPose = {PosX, PosY, "South"}
        addPose(ExplorerPose)
    end

    refX = PositionX
    refY = PositionY

    for i = 0, (NumPointsSides+1) do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX + Variables.W 
        ExplorerPose = {PosX, PosY, "East"}
        addPose(ExplorerPose)
    end
    
    refY = PositionY - Variables.W

    for i = 0, NumPointsTops do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX + Variables.W*2 
        ExplorerPose = {PosX, PosY, "East"}
        addPose(ExplorerPose)
    end

    refY = PositionY + Variables.W

    for i = 0, NumPointsTops do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX + Variables.W*2 
        ExplorerPose = {PosX, PosY, "East"}
        addPose(ExplorerPose)
    end

    refY = PositionY - 2*Variables.W

    for i = 0, NumPointsTops do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX + Variables.W 
        ExplorerPose = {PosX, PosY, "East"}
        addPose(ExplorerPose)
    end

    refX = PositionX
    refY = PositionY

    for i = 0, (NumPointsTops+1) do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX - Variables.W 
        ExplorerPose = {PosX, PosY, "West"}
        addPose(ExplorerPose)
    end
    
    refY = PositionY - Variables.W

    for i = 0, NumPointsTops do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX - Variables.W*2 
        ExplorerPose = {PosX, PosY, "West"}
        addPose(ExplorerPose)
    end

    refY = PositionY + Variables.W

    for i = 0, NumPointsTops do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX - Variables.W*2 
        ExplorerPose = {PosX, PosY, "West"}
        addPose(ExplorerPose)
    end

    refY = PositionY - 2*Variables.W

    for i = 0, NumPointsTops do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX - Variables.W 
        ExplorerPose = {PosX, PosY, "West"}
        addPose(ExplorerPose)
    end
   
end

function addPose(pose)
    
    if pose[1] > ENV_WIDTH then
        pose[1] = pose[1] - ENV_WIDTH
    end

    if pose[1] < 0 then
        pose[1] =  ENV_WIDTH + pose[1]
    end
    
    if pose[2] > ENV_HEIGHT then
        pose[2] = pose[2] - ENV_HEIGHT
    end

    if pose[2] < 0 then
        pose[2] =  ENV_HEIGHT + pose[2]
    end
   
    table.insert(DeployPositionsList, ExplorerPose)
end
