Stat = require "ranalib_statistic"
Draw = require "ranalib_draw"
Map = require "ranalib_map"
Agent = require "ranalib_agent"
Variables = require "Variables"
Constants = require "Constants"
ShardePosition = require "SharedPosition"

Bases = {}

function InitializeAgent()

	MapInitialization()

	for i = 1, Variables.N do
		table.insert(Bases, Agent.addAgent("Base.lua"))
	end

	for k,v in pairs(Bases) do
		for i=1,Variables.X do
			local info = ShardePosition.GetInformation(v)
			Agent.addAgent("Explorer.lua", info[1], info[2], v)
		end
	end

	Agent.removeAgent(ID)

end


function CleanUp()
end

function MapInitialization()

	MapCleanUp()

	Ore_total = ENV_WIDTH * ENV_HEIGHT * Variables.D

	g = 0

	for j = 1, Ore_total do
		local x = Stat.randomInteger(0, ENV_WIDTH)
		local y = Stat.randomInteger(0, ENV_HEIGHT)

		if Draw.compareColor(Map.checkColor(x, y), Constants.background_color) then
			--say("succes")

			Map.modifyColor(x, y, Constants.ore_color)
		else
			j = j - 1
		end
		g = g + 1

		if g >= ENV_WIDTH * ENV_HEIGHT * 3 then
		--break
		end
	end
end

function MapCleanUp()
	-- Clean map:
	for i = 0, ENV_WIDTH do
		for j = 0, ENV_HEIGHT do
			Map.modifyColor(i, j, Constants.background_color)
		end
	end
end
