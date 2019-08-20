Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Agent = require "ranalib_agent"
Event =  require "ranalib_event"
Variables = require "Libs/Variables"
Constants = require "Libs/Constants"
SharedPosition = require "Libs/SharedPosition"

--parameters
Counter = 0
TotalMemory = Variables.S
UsedMemory = 0
Memory = {}



function InitializeAgent()

      SharedPosition.StoreInformation(ID, {PositionX,PositionY})
end


function TakeStep()
      -- Update Agent Information
      SharedPosition.StoreInformation(ID, {PositionX,PositionY})
      
end

function HandleEvent(event)
end

function CleanUp()

end


function AddInfoToMemory(info)
      
      if UsedMemory ~= TotalMemory then
            table.insert(Memory, info)
            UsedMemory = UsedMemory + 1
      end
end

function RemoveInfoFromMemory(index)
      if Memory[index] ~= nil then
            table.remove(Memory, index)
            UsedMemory = UsedMemory - 1
      end
end

function AlterInfoFromMemory(info, index)
      if Memory[index] ~= nil then
            table.insert(Memory, index, info)
      else
            AddInfoToMemory(index, info)
      end
end

function GetMemory(index)
      return Memory[index]
end

function ClearMemory()
      Memory = {}
      UsedMemory = 0
end