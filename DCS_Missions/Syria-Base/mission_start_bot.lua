local frequencies = frequencies()

local flight = frequencies.freq_flight
local awacs = frequencies.freq_awacs
local aar = frequencies.freq_aar
local marshal = frequencies.freq_marshal 
local lso = frequencies.freq_lso

local msg_budy_call = string.format("FLIGHT: %.2f MHz AM", flight)
local msg_awacs = string.format("AWACS: %.2f MHz AM", awacs)
local msg_aar = string.format("AAR: %.2f MHz AM", aar)
local msg_marshal = string.format("MARSHAL: %.2f MHz AM", marshal)
local msg_lso = string.format("LSO: %.2f MHz AM", lso)

BotSay("Mission started!")
BotSay(msg_budy_call)
BotSay(msg_awacs)
BotSay(msg_aar)
BotSay(msg_marshal)
BotSay(msg_lso)