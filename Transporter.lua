Agent = require "ranalib_agent"
Collision = require "ranalib_collision"
Constants = require "Libs.Constants"
Event = require "ranalib_event"
Events = require "Libs.Events"
Inspect = require "Libs.inspect"
Map = require "ranalib_map"
Move = require "ranalib_movement"
SharedPosition = require "Libs.SharedPosition"
Stat = require "ranalib_statistic"
State = require "Libs.RobotState"
Utilities = require "Libs.Utilities"
Variables = require "Libs.Variables"

--parameters
Counter = 0
Group_ID = 0
TargetPosition = {}

BasePosition = {}
BaseExitPos = {}
BaseEntrancePos = {}

TotalMemory = Variables.S
UsedMemory = 0
Memory = {}

TotalEnergy = Variables.E
UsedEnergy = 0
MyState = State.Base

BackpackSize = Variables.W
Backpack = 0
TimeOut = 0


function InitializeAgent()
      SharedPosition.StoreInformation(ID, {PositionX,PositionY})
end


function TakeStep()
      local CurrentPosition = {PositionX, PositionY}
      local EnergyToGetHome = 0
      if BasePosition ~= nil then
            EnergyToGetHome = Utilities.GetEnergyNeeded(CurrentPosition, BasePosition)
      end
      local EnergyToGetHome = Utilities.GetEnergyNeeded(CurrentPosition, BasePosition)
      if MyState == State.Base and UsedEnergy == 0 and Backpack == 0 then
            if UsedEnergy == 0 and Backpack == 0 then
                  if TimeOut == 0 then
                        if UpdateEnergy(Variables.R) then
                              Event.emit{speed = 343, description = Events.RequestOrders, table = {transporterID = ID, energy=TotalEnergy, backPack=BackpackSize}, targetID = Group_ID}
                              TimeOut = 1000
                        end
                  end
                  TimeOut = TimeOut - 1
            end
            UpdateEnergy(-Variables.Q) --Recharging
      end
      
      if MyState ~= State.Returning and EnergyToGetHome + 15*Variables.Q < TotalEnergy - UsedEnergy then
            if  EnergyToGetHome > TotalEnergy - UsedEnergy then
                  MyState = State.GoingToDie
            end
            MyState = State.Returning
      end

      if MyState ~= State.Returning and MyState ~= State.Base and #Memory == 0 then
            MyState = State.NoOrders
      end

      if MyState == State.NoOrders then
            --Go Home or do something else?
            MyState = State.Returning
      end

      if MyState == State.Entering then
            if Utilities.comparePoints(CurrentPosition, BasePosition) then
                  MyState = State.Base
            else
                  if UpdateEnergy(Variables.Q) then
                        Utilities.moveTorus(BasePosition)
                  end
            end
      end

      if MyState == State.Returning then
            if Utilities.comparePoints(CurrentPosition, BaseEntrancePos) then
                  MyState = State.Entering
            else
                  if UpdateEnergy(Variables.Q) then
                        Utilities.moveTorus(BaseEntrancePos)
                  end
            end
      end

      if MyState == State.ExitBase then
            if Utilities.comparePoints(CurrentPosition, BaseExitPos) then
                  MyState = State.GatherMinerals
            else
                  if UpdateEnergy(Variables.Q) then
                        Utilities.moveTorus(BaseExitPos)
                  end
            end
      end

      if MyState == State.GatherMinerals then
            if #TargetPosition == 0 then
                  TargetPosition = GetTarget(CurrentPosition)
            else
                  if Utilities.comparePoints(CurrentPosition, TargetPosition) then
                        Mine(CurrentPosition)
                        RemoveInfoFromMemory(TargetPosition)
                        if Backpack == BackpackSize then
                              MyState = State.BackpackFull
                        end
                  else
                        if UpdateEnergy(Variables.Q) then
                              Utilities.moveTorus(TargetPosition)
                        end
                  end
            end
      end
end

function handleEvent(sourceX, sourceY, sourceID, eventDescription, eventTable)
      if eventDescription == "init" then
            if (eventTable ~= nil) then
                Group_ID = eventTable["group"]
                BasePosition = eventTable["BasePosition"]
                BaseExitPos = eventTable["BaseEntrance"]
                BaseEntrancePos = eventTable["BaseExit"]
            end
      end
      if eventDescription == Events.RetrieveOrders then
            say("Getting Orders: " .. sourceID)
            AddInfoListToMemory(eventTable)
            MyState = State.ExitBase
            TimeOut = 0
            if(UpdateEnergy(Variables.R)) then
                  Event.emit{speed = 343, description = Events.OrdersRecieved, table = {}, targetID = Group_ID}
            end
      end
end

function CleanUp()

end

function UpdateEnergy(e)
      if UsedEnergy + e > TotalEnergy then
            return false
      end

      UsedEnergy = UsedEnergy - e
      if UsedEnergy < 0 then
            UsedEnergy = 0
      end

      return true
end

function GetTarget(pos)
      local result = Utilities.GetValueWithSortestDistance(Memory, pos, 0, "GetTarget")
      if result == nil then
            return {}
      end
      return result[1]
end

function Mine(pos)
      Map.quantumModify(pos[1], pos[2], Constants.ore_color_found, Constants.background_color)
      Backpack = Backpack + 1
end


function AddInfoToMemory(info)
      if UsedMemory + 1 <= TotalMemory then
          table.insert(Memory, info)
          UsedMemory = UsedMemory + 1
          return true
      end
      return false
end

function AddInfoListToMemory(list)
      if #list > TotalMemory-UsedMemory then
            return false
      else
            for i=1, #list do
                  table.insert(Memory, list[1])
                  UsedMemory = UsedMemory - 1
            end
      end
end

function RemoveInfoFromMemory(info)
      for i=1, #Memory do
            if Utilities.comparePoints(info, Memory[i]) then
                  table.remove(Memory, i)
                  UsedMemory = UsedMemory - 1
            end
      end
end

function RemoveIndexFromMemory(index)
      if Memory[index] ~= nil then
          table.remove(Memory, index)
          UsedMemory = UsedMemory - 1
      end
end

function AlterInfoFromMemory(info, index)
      if Memory[index] ~= nil then
          table.insert(Memory, index, info)
          return true
      else
          return AddInfoToMemory(index, info)
      end
end

function GetMemory(index)
      return Memory[index]
end

function ClearMemory()
      Memory = {}
      UsedMemory = 0
end