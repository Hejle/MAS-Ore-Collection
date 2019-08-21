local variables = {}

variables.C = 100 -- Base Capacity in ore Samples
variables.D = 0.1 -- Ore density as a percentage
variables.E = 100 -- Robot energy in units
variables.G = 200 -- Grid size
variables.I = 15 -- Fixed Communication scope
variables.M = 100 -- Coordination Mode (1 = Coop, 0 = Competitive)
variables.N = 2 -- Number of bases
variables.O = 2 -- Cost of perception
variables.P = 5 -- initial perception scope
variables.Q = 2 -- Cost of a movement action
variables.R = 2 -- Cost of sending a message
variables.S = 10 -- Memorysize of each robot
variables.T = 100 -- Maximum number of cycles
variables.W = 100 -- Maximum number of ore a robot can grab
variables.X = 20 -- Number of explorers per base
variables.Y = 0 -- Number of transporters per base
variables.W = variables.P-1 -- Separation distance between explorers when being deployed (x-axis)
variables.Z = variables.P-1 -- Separation distance between explorers when being deployed (y-axis)


return variables