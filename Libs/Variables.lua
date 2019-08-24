local variables = {}

variables.C = 175 -- Base Capacity in ore Samples
variables.D = 0.04 -- Ore density as a percentage
variables.E = 960 -- Robot energy in units
variables.G = 225 -- Grid size
variables.I = 33 -- Fixed Communication scope
variables.J = 2 -- For the initial deploy formation, number of points on each half of the sides North/South 
variables.K = 2 -- For the initial deploy formation, number os points on each half of the sides East/West
variables.M = 1 -- Coordination Mode (1 = Coop, 0 = Competitive)
variables.N = 1-- Number of bases
variables.O = 2 -- Cost of perception
variables.P = 7 -- initial perception scope
variables.Q = 1.4 -- Cost of a movement action
variables.R = 1 -- Cost of sending a message
variables.Pick =  1 -- Cost of picking an ore sample
variables.S = 11-- Memorysize of each robot
variables.T = 77500 -- Maximum number of cycles
variables.W = 7 -- Maximum number of ore a robot can grab
variables.X = 6 -- Number of explorers per base
variables.Y = 7-- Number of transporters per base
variables.W = variables.P-1 -- Separation distance between explorers when being deployed (x-axis)
variables.Z = variables.P-1 -- Separation distance between explorers when being deployed (y-axis)
variables.Filename = "RatioTranporterExplorers_19_1"

return variables