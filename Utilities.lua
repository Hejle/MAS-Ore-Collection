local Utilities = {}

Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Variables"
Constants = require "Constants"
ShardePosition = require "SharedPosition"
Map = require "ranalib_map"  

function Utilities.moveTorus(x,y)

local destX = x
local destY = y
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
if (not Collision.checkCollision(destX,destY)) or (destX == basePosX and destY == basePosY)  then
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



return Utilities