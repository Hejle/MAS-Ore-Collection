Stat = require "ranalib_statistic"
Draw = require "ranalib_draw"
Map = require "ranalib_map"
Agent = require "ranalib_agent"
Variables = require "Variables"
Constants = require "Constants"

background_color = {0, 0, 0}
ore_color = {0, 255, 255}

function InitializeAgent()

	MapInitialization()

	for i = 1, Variables.N do
		 Agent.addAgent("base.lua")
		 
	end

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

		if Draw.compareColor(Map.checkColor(x, y), background_color) then
			--say("succes")

			Map.modifyColor(x, y, ore_color)
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
			Map.modifyColor(i, j, {0, 0, 0})
		end
	end
end
