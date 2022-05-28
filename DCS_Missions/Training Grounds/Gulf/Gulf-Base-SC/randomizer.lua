math.randomseed = os.clock()*100000000000
local s300_random = math.random(1, 8)
local s200_random = math.random(1, 7)
env.info("SAMS SEED RANDOMIZED")
local s300zone = string.format("s300-%d", s300_random)
local s200zone = string.format("s200-%d", s200_random)
env.info("SAMS SEED RANDOMIZED")
env.info(s300zone)
env.info(s200zone)

mist.teleportInZone('red-sa20-1', s300zone, true, 300)
mist.teleportInZone('red-sa5-1', s200zone, true, 300)