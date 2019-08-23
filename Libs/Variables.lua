local variables = {}

variables.C = 300 -- Base Capacity in ore Samples
variables.D = 0.02 -- Ore density as a percentage
variables.E = 500 -- Robot energy in units
variables.G = 200 -- Grid size
variables.I = 15 -- Fixed Communication scope
variables.J = 2 -- For the initial deploy formation, number of points on each half of the sides North/South 
variables.K = 2 -- For the initial deploy formation, number os points on each half of the sides East/West
variables.M = 1 -- Coordination Mode (1 = Coop, 0 = Competitive)
variables.N = 1-- Number of bases
variables.O = 2 -- Cost of perception
variables.P = 5 -- initial perception scope
variables.Q = 2 -- Cost of a movement action
variables.R = 1 -- Cost of sending a message
variables.Pick =  1 -- Cost of picking an ore sample
variables.S = 10-- Memorysize of each robot
variables.T = 100 -- Maximum number of cycles
variables.W = 5 -- Maximum number of ore a robot can grab




variables.X = 19 -- Number of explorers per base
variables.Y = 1-- Number of transporters per base
variables.W = variables.P-1 -- Separation distance between explorers when being deployed (x-axis)
variables.Z = variables.P-1 -- Separation distance between explorers when being deployed (y-axis)
variables.Filename = "RatioTranporterExplorers_19_1"

return variables