local Utilities = {}

Agent = require "ranalib_agent"
Collision = require "ranalib_collision"
Constants = require "Libs.Constants"
Event = require "ranalib_event"
Inspect = require "Libs.inspect"
Map = require "ranalib_map" 
Move = require "ranalib_movement"
SharedPosition = require "Libs.SharedPosition"
Stat  = require"ranalib_statistic"
Variables = require "Libs.Variables"

function randomWithStep(first, last, stepSize)
    local maxSteps = math.floor((last-first)/stepSize)
    return first + stepSize * Stat.randomInteger(0, maxSteps)
end

function Utilities.compareTables(table1, table2)
	if #table1 == #table2 then
		for i=1, #table1 do
			if table1[i] ~= table2[i] then
				return false
			end
		end
		return true
	else
		return false
	end
end

function Utilities.moveTorus(targetPos,ignoreCollisionPos)
    ignoreCollisionPos = ignoreCollisionPos or {Variables.G+2, Variables.G+2}
    local destX = targetPos[1]
    local destY = targetPos[2]
    local directionX = destX-PositionX
    local directionY = destY-PositionY

    -- Changing direction to go through the edge of the map if path is shorter
    if math.abs(directionX) > Variables.G/2 	then directionX = -directionX end
    if math.abs(directionY) > Variables.G/2 	then directionY = -directionY end

    -- Determining destination point
    if	directionX > 0 then destX = PositionX+1
    elseif	directionX < 0 then destX = PositionX-1
    else	destX = PositionX	end

    if	directionY > 0 then destY = PositionY+1
    elseif	directionY < 0 then destY = PositionY-1
    else	destY = PositionY	end

    -- Determining destination point if direction is through the edge of the map
    if destX < 0 then
        destX = Variables.G-1
    elseif destX >= Variables.G then
        destX = 0
    end

    if destY < 0 then
        destY = Variables.G-1
    elseif destY >= Variables.G then
        destY = 0
    end

    -- If no other agent is at the destination or the destination is the base
    if (not Collision.checkCollision(destX,destY))  or (destX == ignoreCollisionPos[1] and destY == ignoreCollisionPos[2]) then
        -- Moving the Agent	
        Collision.updatePosition(destX,destY) 
    -- If there is a collision
    else
        -- If destination is on the same y
        if destX ~= PositionX and destY == PositionY then
            -- Change y with either -1 or 1
            local randStep = randomWithStep(-1,1,2)
            destY = PositionY+randStep

            -- If still collision
            if Collision.checkCollision(destX,destY) then
                -- Change y with the opposite as before
                destY = PositionY-randStep
            end
            
            -- If still collision
            if Collision.checkCollision(destX,destY) then
                -- Stay
                destX = PositionX
                destY = PositionY
            end
        
        -- If destination is on the same x
        elseif destY ~= PositionY and destX == PositionX then
            -- Change x with either -1 or 1
            local randStep = randomWithStep(-1,1,2)
            destX = PositionX+randStep
            
            -- If still collision
            if Collision.checkCollision(destX,destY) then
                -- Change x with the opposite as before
                destX = PositionX-randStep
            end
            
            -- If still collision
            if Collision.checkCollision(destX,destY) then
                -- Stay
                destX = PositionX
                destY = PositionY
            end
            
        -- If destination is diagonal
        elseif destY ~= PositionY and destX ~= PositionX then
            local tempDestX = destX
            local tempDestY = destY
            -- Change either y or x destination to position
            local randNum = Stat.randomInteger(0,1)
            if randNum == 0 then
                destY = PositionY
            else
                destX = PositionX
            end
            
            -- If still collision
            if Collision.checkCollision(destX,destY) then
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
            if Collision.checkCollision(destX,destY) then
                -- Stay
                destX = PositionX
                destY = PositionY
            end
        end
        
        -- Update position
        Collision.updatePosition(destX,destY)

    end

    DestinationX = destX
    DestinationY = destY

end

-- Sorry for this  collection of fors
function Utilities.GenerateDeployPositions(PoseTable)
    
    NumPointsTops = 4
    NumPointsSides = 2
    
    offset = Variables.W * NumPointsSides * 2 + Variables.W * 2
    
    refX = PositionX
    refY = PositionY
    
    for i = 0, (NumPointsTops + 1) do
        PosX = refX + Variables.W * 2 * i
        PosY = refY + Variables.Z + offset
        ExplorerPose = {PosX, PosY, "North"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX - Variables.W
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY + Variables.Z * 2 + offset
        ExplorerPose = {PosX, PosY, "North"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX + Variables.W
    
    for i = 0, NumPointsTops do
        PosX = refX + Variables.W * 2 * i
        PosY = refY + Variables.Z * 2 + offset
        ExplorerPose = {PosX, PosY, "North"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX - 2 * Variables.W
    
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY + Variables.Z + offset
        ExplorerPose = {PosX, PosY, "North"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX
    refY = PositionY
    
    for i = 0, (NumPointsTops + 1) do
        PosX = refX + Variables.W * 2 * i
        PosY = refY - Variables.Z - offset
        ExplorerPose = {PosX, PosY, "South"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX - Variables.W
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY - Variables.Z * 2 - offset
        ExplorerPose = {PosX, PosY, "South"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX + Variables.W
    
    for i = 0, NumPointsTops do
        PosX = refX + Variables.W * 2 * i
        PosY = refY - Variables.Z * 2 - offset
        ExplorerPose = {PosX, PosY, "South"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX - 2 * Variables.W
    
    for i = 0, NumPointsTops do
        PosX = refX - Variables.W * 2 * i
        PosY = refY - Variables.Z - offset
        ExplorerPose = {PosX, PosY, "South"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX
    refY = PositionY
    
    for i = 0, (NumPointsSides + 1) do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX + Variables.W
        ExplorerPose = {PosX, PosY, "East"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refY = PositionY - Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX + Variables.W * 2
        ExplorerPose = {PosX, PosY, "East"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refY = PositionY + Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX + Variables.W * 2
        ExplorerPose = {PosX, PosY, "East"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refY = PositionY - 2 * Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX + Variables.W
        ExplorerPose = {PosX, PosY, "East"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refX = PositionX
    refY = PositionY
    
    for i = 0, (NumPointsSides + 1) do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX - Variables.W
        ExplorerPose = {PosX, PosY, "West"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refY = PositionY - Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX - Variables.W * 2
        ExplorerPose = {PosX, PosY, "West"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refY = PositionY + Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY + Variables.Z * 2 * i
        PosX = refX - Variables.W * 2
        ExplorerPose = {PosX, PosY, "West"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end
    
    refY = PositionY - 2 * Variables.W
    
    for i = 0, NumPointsSides do
        PosY = refY - Variables.Z * 2 * i
        PosX = refX - Variables.W
        ExplorerPose = {PosX, PosY, "West"}
        PoseTable = addPose(PoseTable,ExplorerPose)
    end

    return PoseTable
end

function addPose(PoseTable,pose)
    
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