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

Transporter = {}

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
MyState = State.NotInit

BackpackSize = Variables.W
Backpack = 0
TimeOut = 0

function InitializeAgent()
      SharedPosition.StoreInformation(ID, {PositionX, PositionY})
      MyState = State.NotInit
      Agent.changeColor{id=ID, r=0,g=0,b=255}
end

function HandleEvent(event)
      local sourceX = event.X
      local sourceY = event.Y
      local sourceID = event.ID
      local eventDescription = event.description
      local eventTable = event.table
      if(Utilities.distance({sourceX, sourceY}, {PositionX, PositionY}) > Variables.I) or MyState == State.Disable then
            return
      end
      if eventDescription == "init" and Group_ID == 0 then
            if (eventTable ~= nil) then
                Group_ID = eventTable["group"]
                BasePosition = eventTable["BasePosition"]
                BaseEntrancePos = eventTable["BaseEntrance"]
                BaseExitPos = eventTable["BaseExit"]
                MyState = State.Base
            else
                l_print("ERROR: eventable empty.")
            end
      elseif eventDescription == Events.Disable and eventTable["target"] == ID then
            MyState = State.Disable
      elseif eventDescription == Events.RetrieveOrders and eventTable["target"] == ID then
            Transporter.AddInfoListToMemory(eventTable["data"])
            MyState = State.ExitBase
            TimeOut = 0
      elseif eventDescription == Events.OreStored and eventTable["target"] == ID then
            Backpack = 0
            Memory = {}
            TimeOut = 0
      elseif eventDescription == Events.baseAccesGranted and eventTable["target"] == ID then
            MyState = State.PermissionToLand
      end
end

function TakeStep()
      local CurrentPosition = {PositionX, PositionY}
      local EnergyToGetHome = 0
      if Counter % 2000 then
            --say(Inspect.inspect(MyState))
      end

      if not #BasePosition == 2 then
            EnergyToGetHome = Utilities.GetEnergyNeeded(CurrentPosition, BasePosition)
      end
      if MyState == State.Base then
            UsedEnergy = 0
            if Backpack == 0 then
                  if TimeOut == 0 then
                        if Transporter.UpdateEnergy(Variables.R) then
                              Event.emit{speed = 343, description = Events.RequestOrders, table = {target=Group_ID, transporterID = ID, energy=TotalEnergy, backPack=BackpackSize}}
                              TimeOut = 500
                        end
                  end
                  TimeOut = TimeOut - 1
            end

            if Backpack > 0 then
                  if TimeOut == 0 then
                        if Transporter.UpdateEnergy(Variables.R) then
                              Event.emit{speed = 343, description = Events.ReturningMinerals, table = {target=Group_ID, transporterID = ID, minerals=Backpack, memo=Memory}}
                              TimeOut = 1000
                        end
                  end
                  TimeOut = TimeOut - 1
            end
      end

      if not ((MyState == State.NotInit)
      or (MyState == State.Base)
      or (MyState == State.WaitingToLand)
      or (MyState == State.Entering)
      or (MyState == State.Disable)
      or (MyState == State.PermissionToLand)
      or (MyState == State.Returning)) then
            if (EnergyToGetHome + 15*Variables.Q > TotalEnergy - UsedEnergy) then
                  if  EnergyToGetHome > TotalEnergy - UsedEnergy then
                        MyState = State.GoingToDie
                  end
                  MyState = State.Returning
            end
      end

      if MyState == State.BackpackFull and
      not ((MyState == State.Returning)
      or (MyState == State.Entering)
      or (MyState == State.WaitingToLand)
      or (MyState == State.PermissionToLand)
      or (MyState == State.Disable)
      or (MyState == State.NotInit)
      or (MyState == State.Base)) then
            --Could work as transmitter or go home, or go somewhere else
            MyState = State.Returning
      end

      if (not ((MyState == State.NotInit)
      or (MyState == State.Base)
      or (MyState == State.Disable)
      or (MyState == State.WaitingToLand)
      or (MyState == State.PermissionToLand)
      or (MyState == State.Entering)
      or (MyState == State.Returning))and #Memory <=0) then
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
                  if Transporter.UpdateEnergy(Variables.Q) then
                        Utilities.moveTorus(BasePosition, BasePosition)
                  end
            end
      end

      if MyState == Stat.WaitingToLand then
            if TimeOut == 0 then
                  if Transporter.UpdateEnergy(Variables.R) then
                        Event.emit{speed = 0, description = Events.baseAccesRequest, table = {target=Group_ID}}
                        TimeOut = 100
                  end
            end
            TimeOut = TimeOut - 1
      end

      if MyState == State.Returning then
            if Utilities.distance(CurrentPosition, BaseEntrancePos) < Variables.I/(4/3) then
                  Event.emit{speed = 0, description = Events.baseAccesRequest, table = {target=Group_ID}}
                  MyState = State.WaitingToLand
            else
                  if Transporter.UpdateEnergy(Variables.Q) then
                        Utilities.moveTorus(BaseEntrancePos)
                  end
            end
      end
      if MyState == State.PermissionToLand then
            if Utilities.comparePoints(CurrentPosition, BaseEntrancePos) then
                  MyState = State.Entering
            else
                  if Transporter.UpdateEnergy(Variables.Q) then
                        Utilities.moveTorus(BaseEntrancePos)
                  end
            end
      end

      if MyState == State.ExitBase then
            if Utilities.comparePoints(CurrentPosition, BaseExitPos) then
                  MyState = State.GatherMinerals
            else
                  if Transporter.UpdateEnergy(Variables.Q) then
                        Utilities.moveTorus(BaseExitPos, BasePosition)
                  end
            end
      end

      if MyState == State.GatherMinerals then
            if #TargetPosition == 0 then
                  TargetPosition = Transporter.GetTarget(CurrentPosition)
                  if not Utilities.IsPoint(TargetPosition) then
                        MyState = State.Returning
                  end
            else
                  if Utilities.comparePoints(CurrentPosition, TargetPosition) then
                        Transporter.Mine(CurrentPosition)
                        Transporter.RemoveInfoFromMemory(TargetPosition)
                        TargetPosition = {}
                        if Backpack == BackpackSize then
                              MyState = State.BackpackFull
                        end
                  else
                        if Transporter.UpdateEnergy(Variables.Q) then
                              Utilities.moveTorus(TargetPosition)
                        end
                  end
            end
      end
      Counter = Counter + 1
end

function CleanUp()

end

function Transporter.UpdateEnergy(e)
      if UsedEnergy + e > TotalEnergy then
            return false
      end

      UsedEnergy = UsedEnergy + e
      if UsedEnergy < 0 then
            UsedEnergy = 0
      end

      return true
end

function Transporter.GetTarget(pos)
      local result = Utilities.GetValueWithSortestDistance(Memory, pos, 0)
      if result == nil then
            return {}
      end
      return result[1]
end

function Transporter.Mine(pos)
      if Transporter.UpdateEnergy(Variables.Pick) then
            Map.quantumModify(pos[1], pos[2], Constants.ore_color_found, {r=255, 255, 255})
            Backpack = Backpack + 1
      end
end


function Transporter.AddInfoToMemory(info)
      if(Utilities.ListContainsPoint(Memory, info)) then
            return true --Already in memory
      end
      if UsedMemory + 1 <= TotalMemory then
          table.insert(Memory, info)
          UsedMemory = UsedMemory + 1
          return true
      end
      return false
end

function Transporter.AddInfoListToMemory(list)
      if #list > TotalMemory-UsedMemory then
            return false
      else
            for i=1, #list do
                  Transporter.AddInfoToMemory(list[i])
            end
      end
end

function Transporter.RemoveInfoFromMemory(info)
      for i=1, #Memory do
            if Utilities.comparePoints(info, Memory[i]) then
                  table.remove(Memory, i)
                  UsedMemory = UsedMemory - 1
                  return true
            end
      end
      return false
end

function Transporter.RemoveIndexFromMemory(index)
      if Memory[index] ~= nil then
          table.remove(Memory, index)
          UsedMemory = UsedMemory - 1
      end
end

function Transporter.AlterInfoFromMemory(info, index)
      if Memory[index] ~= nil then
          table.insert(Memory, index, info)
          return true
      else
          return Transporter.AddInfoToMemory(index, info)
      end
end

function Transporter.GetMemory(index)
      return Memory[index]
end

function Transporter.ClearMemory()
      Memory = {}
      UsedMemory = 0
end