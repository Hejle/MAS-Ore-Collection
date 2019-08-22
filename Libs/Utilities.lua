local Utilities = {}

Agent = require "ranalib_agent"
Collision = require "ranalib_collision"
Constants = require "Libs.Constants"
Event = require "ranalib_event"
Inspect = require "Libs.inspect"
Map = require "ranalib_map"
Move = require "ranalib_movement"
SharedPosition = require "Libs.SharedPosition"
Stat = require "ranalib_statistic"
Variables = require "Libs.Variables"

function randomWithStep(first, last, stepSize)
    local maxSteps = math.floor((last - first) / stepSize)
    return first + stepSize * Stat.randomInteger(0, maxSteps)
end

function Utilities.Tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function Utilities.IsNotEmpty(T)
    if next(T) == nil then
        return false
    end
    return true
end

function Utilities.RemoveAllValuesArray(T, Value)
    local Result = {}
    for i = 1, #T do
        if(not(T[i] == Value)) then
            table.insert(Result, T[i])
        end
    end
    return Result
end

function Utilities.RemoveAllValuesDictionary(T, Value)
    local Result = {}
    for k,v in pairs(T) do
        if(not(v == Value)) then
            table.insert(Result, k,v)
        end
    end
    return Result
end

function Utilities.RemoveAllValuesArrayFunction(T, F, value)
    local Result = {}
    for i = 1, #T do
        if (not (F(T[i], value))) then
            table.insert(Result, T[i])
        end
    end
    return Result
end

function Utilities.RemoveAllValuesDictionaryFunction(T, F, value)
    local Result = {}
    for k,v in pairs(T) do
        if(not (F(T[v], value))) then
            table.insert(Result, k,v)
        end
    end
    return Result
end

function Utilities.GetEnergyNeeded(point, from)
    local distance = Utilities.distance(point, from, 2)
    local energy = distance * Variables.Q
    return energy
end

function Utilities.GetValueWithSortestDistance(list, point)
    local shortesDist = Variables.G * 3 -- Higher number than any possible distance
    local newDist
    local result = nil
    for i = 1, #list do
        newDist = Utilities.distance(list[i], point, 1)
        if newDist < shortesDist then
            shortesDist = newDist
            result = {list[i], i, shortesDist}
        end
    end
    return result
end

function Utilities.SortUsingDistance(list, point)
    table.sort(list, function(a, b)
        return Utilities.distance(point, a, 0) < Utilities.distance(point, b, 0)
    end)
end

function Utilities.distance(pointFrom, pointTo, delta)
    delta = delta or 0
    local x1 = pointFrom[1]
    local y1 = pointFrom[2]
    local x2 = pointTo[1]
    local y2 = pointTo[2]
    local dx = x1 - x2
    local dy = y1 - y2
    local px1 = x1
    local py1 = y1
    local px2 = x1
    local py2 = y1
    local pos1
    local pos2
    local nottorusway = math.sqrt(dx * dx + dy * dy)
    if math.abs(dx) > Variables.G / 2 then
        px1 = 0
        px2 = Variables.G
    end
    
    if math.abs(dy) > Variables.G / 2 then
        py1 = 0
        py2 = Variables.G
    end
    dx = x1 - px1
    dy = y1 - py1
    pos1 = math.sqrt(dx * dx + dy * dy)
    dx = px2 - x2
    dy = py2 - y2
    pos2 = math.sqrt(dx * dx + dy * dy)
    return math.min(nottorusway, pos1 + pos2 + delta)
end

function Utilities.comparePoints(point1, point2)
    if #point1 == #point2 and #point1 == 2 then
        return (point1[1] == point2[1] and point1[2] == point2[2])
    end
    return false
end

function Utilities.ListContainsPoint(list, point)
    for i = 1, #list do
        if Utilities.comparePoints(point, Memory[i]) then
            return true, i
        end
    end
    return false, -1
end

function Utilities.moveTorus(targetPos, ignoreCollisionPos)
    ignoreCollisionPos = ignoreCollisionPos or {Variables.G + 2, Variables.G + 2}
    local destX = targetPos[1]
    local destY = targetPos[2]
    local directionX = destX - PositionX
    local directionY = destY - PositionY
    
    -- Changing direction to go through the edge of the map if path is shorter
    if math.abs(directionX) > Variables.G / 2 then directionX = -directionX end
    if math.abs(directionY) > Variables.G / 2 then directionY = -directionY end
    
    -- Determining destination point
    if directionX > 0 then destX = PositionX + 1
    elseif directionX < 0 then destX = PositionX - 1
    else destX = PositionX end
    
    if directionY > 0 then destY = PositionY + 1
    elseif directionY < 0 then destY = PositionY - 1
    else destY = PositionY end
    
    -- Determining destination point if direction is through the edge of the map
    if destX < 0 then
        destX = Variables.G - 1
    elseif destX >= Variables.G then
        destX = 0
    end
    
    if destY < 0 then
        destY = Variables.G - 1
    elseif destY >= Variables.G then
        destY = 0
    end
    -- If no other agent is at the destination or the destination is the base
    if (not Collision.checkCollision(destX, destY))
        or (destX == ignoreCollisionPos[1] and destY == ignoreCollisionPos[2])
        or (destX == ignoreCollisionPos[1] and destY == ignoreCollisionPos[2] + 1)
        or (destX == ignoreCollisionPos[1] and destY == ignoreCollisionPos[2] - 1)
        or (destX == ignoreCollisionPos[1] and destY == ignoreCollisionPos[2] + 2)
        or (destX == ignoreCollisionPos[1] and destY == ignoreCollisionPos[2] - 2)
        or (destX == ignoreCollisionPos[1] - 1 and destY == ignoreCollisionPos[2])
        or (destX == ignoreCollisionPos[1] + 1 and destY == ignoreCollisionPos[2])
        or (destX == ignoreCollisionPos[1] - 1 and destY == ignoreCollisionPos[2] + 1)
        or (destX == ignoreCollisionPos[1] + 1 and destY == ignoreCollisionPos[2] + 1)
        or (destX == ignoreCollisionPos[1] - 1 and destY == ignoreCollisionPos[2] - 1)
        or (destX == ignoreCollisionPos[1] + 1 and destY == ignoreCollisionPos[2] - 1)
        or (destX == ignoreCollisionPos[1] - 1 and destY == ignoreCollisionPos[2] + 2)
        or (destX == ignoreCollisionPos[1] + 1 and destY == ignoreCollisionPos[2] + 2)
        or (destX == ignoreCollisionPos[1] - 1 and destY == ignoreCollisionPos[2] - 2)
        or (destX == ignoreCollisionPos[1] + 1 and destY == ignoreCollisionPos[2] - 2)
        or (destX == ignoreCollisionPos[1] - 2 and destY == ignoreCollisionPos[2])
        or (destX == ignoreCollisionPos[1] + 2 and destY == ignoreCollisionPos[2]) then
        -- Moving the Agent
        Collision.updatePosition(destX, destY)
    -- If there is a collision
    else
        -- If destination is on the same y
        if destX ~= PositionX and destY == PositionY then
            -- Change y with either -1 or 1
            local randStep = randomWithStep(-1, 1, 2)
            destY = PositionY + randStep
            
            -- If still collision
            if Collision.checkCollision(destX, destY) then
                -- Change y with the opposite as before
                destY = PositionY - randStep
            end
            
            -- If still collision
            if Collision.checkCollision(destX, destY) then
                -- Stay
                destX = PositionX
                destY = PositionY
            end
        
        -- If destination is on the same x
        elseif destY ~= PositionY and destX == PositionX then
            -- Change x with either -1 or 1
            local randStep = randomWithStep(-1, 1, 2)
            destX = PositionX + randStep
            
            -- If still collision
            if Collision.checkCollision(destX, destY) then
                -- Change x with the opposite as before
                destX = PositionX - randStep
            end
            
            -- If still collision
            if Collision.checkCollision(destX, destY) then
                -- Stay
                destX = PositionX
                destY = PositionY
            end
        
        -- If destination is diagonal
        elseif destY ~= PositionY and destX ~= PositionX then
            local tempDestX = destX
            local tempDestY = destY
            -- Change either y or x destination to position
            local randNum = Stat.randomInteger(0, 1)
            if randNum == 0 then
                destY = PositionY
            else
                destX = PositionX
            end
            
            -- If still collision
            if Collision.checkCollision(destX, destY) then
                -- Change the opposite as before
                if randNum == 1 then
                    destY = PositionY
                    destX = tempDestX
                else
                    destY = tempDestY
                    destX = PositionX
                end
            end
            
            -- If still collision
            if Collision.checkCollision(destX, destY) then
                -- Stay
                destX = PositionX
                destY = PositionY
            end
        end
        
        -- Update position
        Collision.updatePosition(destX, destY)
    
    end
    
    DestinationX = destX
    DestinationY = destY

end


function Utilities.SampleNewDeployPosiiton(PoseTable, Range, SampleCounter)
    
    Sample = {}
    NumPointsTops = Variables.J
    NumPointsSides = Variables.K
    
    CycleNum = math.floor(SampleCounter / 4)
    CycleIt = (SampleCounter - CycleNum * 4) + 1
    
    
    Range = Range * (1 + CycleNum)
    
    if CycleIt == 1 then
        PosX = PositionX + NumPointsTops * Variables.W * Range
        PosY = PositionY + NumPointsSides * Variables.Z * Range
    elseif CycleIt == 2 then
        PosX = PositionX - NumPointsTops * Variables.W * Range
        PosY = PositionY + NumPointsSides * Variables.Z * Range
    elseif CycleIt == 3 then
        PosX = PositionX - NumPointsTops * Variables.W * Range
        PosY = PositionY - NumPointsSides * Variables.Z * Range
    elseif CycleIt == 4 then
        PosX = PositionX + NumPointsTops * Variables.W * Range
        PosY = PositionY - NumPointsSides * Variables.Z * Range
    end
    
    
    NewDeployPosition = {PosX, PosY, "Random"}
    PoseTable = addPose(PoseTable, NewDeployPosition)

    return PoseTable
end


function Utilities.CorrectPosition(position)
    if position[1] >= ENV_WIDTH then
        position[1] = position[1] - ENV_WIDTH
    end
    
    if position[1] < 0 then
        position[1] = ENV_WIDTH + position[1]
    end
    
    if position[2] >= ENV_HEIGHT then
        position[2] = position[2] - ENV_HEIGHT
    end
    
    if position[2] < 0 then
        position[2] = ENV_HEIGHT + position[2]
    end
    return position
end
-- Sorry for this  collection of fors
function Utilities.GenerateDeployPositions(PoseTable)
    
    NumPointsTops = Variables.J
    NumPointsSides = Variables.K
    
    offset = Variables.W * NumPointsSides * 2 + Variables.W * 2
    refX = PositionX
    refY = PositionY
    
    for i = 0, (NumPointsTops + 1) do
        PosX = refX + Variables.W * 2 * i
        PosY = refY + Variables.Z + offset
        ExplorerPose = {PosX, PosY, "North"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX - Variables.W
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY + Variables.Z * 2 + offset
        ExplorerPose = {PosX, PosY, "North"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX + Variables.W
    
    for i = 0, NumPointsTops do
        PosX = refX + Variables.W * 2 * i
        PosY = refY + Variables.Z * 2 + offset
        ExplorerPose = {PosX, PosY, "North"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX - 2 * Variables.W
    
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY + Variables.Z + offset
        ExplorerPose = {PosX, PosY, "North"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX
    refY = PositionY
    
    for i = 0, (NumPointsTops + 1) do
        PosX = refX + Variables.W * 2 * i
        PosY = refY - Variables.Z - offset
        ExplorerPose = {PosX, PosY, "South"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX - Variables.W
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY - Variables.Z * 2 - offset
        ExplorerPose = {PosX, PosY, "South"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX + Variables.W
    
    for i = 0, NumPointsTops do
        PosX = refX + Variables.W * 2 * i
        PosY = refY - Variables.Z * 2 - offset
        ExplorerPose = {PosX, PosY, "South"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX - 2 * Variables.W
    
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY - Variables.Z - offset
        ExplorerPose = {PosX, PosY, "South"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX
    refY = PositionY
    
    for i = 0, (NumPointsSides + 1) do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX + Variables.W
        ExplorerPose = {PosX, PosY, "East"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refY = PositionY - Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX + Variables.W * 2
        ExplorerPose = {PosX, PosY, "East"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refY = PositionY + Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX + Variables.W * 2
        ExplorerPose = {PosX, PosY, "East"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refY = PositionY - 2 * Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX + Variables.W
        ExplorerPose = {PosX, PosY, "East"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refX = PositionX
    refY = PositionY
    
    for i = 0, (NumPointsSides + 1) do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX - Variables.W
        ExplorerPose = {PosX, PosY, "West"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refY = PositionY - Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX - Variables.W * 2
        ExplorerPose = {PosX, PosY, "West"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refY = PositionY + Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX - Variables.W * 2
        ExplorerPose = {PosX, PosY, "West"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    refY = PositionY - 2 * Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX - Variables.W
        ExplorerPose = {PosX, PosY, "West"}
        PoseTable = addPose(PoseTable, ExplorerPose)
    end
    
    return PoseTable
end

function addPose(PoseTable, pose)
    
    if pose[1] > ENV_WIDTH then
        pose[1] = pose[1] - ENV_WIDTH
    end
    
    if pose[1] < 0 then
        pose[1] = ENV_WIDTH + pose[1]
    end
    
    if pose[2] > ENV_HEIGHT then
        pose[2] = pose[2] - ENV_HEIGHT
    end
    
    if pose[2] < 0 then
        pose[2] = ENV_HEIGHT + pose[2]
    end
    
    table.insert(PoseTable, pose)
    
    return PoseTable
end

return Utilities
