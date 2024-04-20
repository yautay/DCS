ZONE_DARKSTAR_1_AWACS = ZONE:New("DARKSTAR_1_AWACS")
ZONE_PATROL = ZONE:New("DARKSTAR_1_PATROL_CAP"):DrawZone(2, CONST.RGB.zone_patrol, 1, CONST.RGB.zone_patrol, .5, 1, true)
ZONE_ENGAGE = ZONE:New("DARKSTAR_1_ENGAGE")



AW_Kutaisi = AIRWING:New("WH Kutaisi", "Kutaisi Air Wing")

AW_Kutaisi:SetMarker(false)
AW_Kutaisi:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
AW_Kutaisi:SetRespawnAfterDestroyed(600)
AW_Kutaisi:__Start(2)

AW_Kutaisi_AWACS = SQUADRON:New("ME AWACS E2", 2, "AWACS")
AW_Kutaisi_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_Kutaisi_AWACS:SetTakeoffType("Hot")
AW_Kutaisi_AWACS:SetFuelLowRefuel(false)
--AW_Kutaisi_AWACS:SetFuelLowThreshold(0.4)
AW_Kutaisi_AWACS:SetTurnoverTime(30, 5)
AW_Kutaisi_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AW_Kutaisi:AddSquadron(AW_Kutaisi_AWACS)
AW_Kutaisi:NewPayload("ME AWACS E2", -1, { AUFTRAG.Type.ORBIT }, 100)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
local Darkstar_1_1_route = {ZONE_DARKSTAR_1_AWACS:GetCoordinate(), 25000, 350, 45, 20}

GCI_SENAKI = AWACS:New("GCI Senaki",AW_Kutaisi,"blue",AIRBASE.Caucasus.Senaki_Kolkhi,nil,ZONE_ENGAGE,ZONE_PATROL,FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
GCI_SENAKI:SetAsGCI(GROUP:FindByName("EWR Senaki"),2)
GCI_SENAKI:SetBullsEyeAlias("BULLS")
GCI_SENAKI:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
GCI_SENAKI:SetModernEraAggressive()

GCI_SENAKI.PlayerGuidance = false -- allow missile warning call-outs.
GCI_SENAKI.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
GCI_SENAKI.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
GCI_SENAKI.DeclareRadius = 3 -- you need to be this close to the lead unit for declare/VID to work, in NM.
GCI_SENAKI.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
GCI_SENAKI.maxassigndistance = 200 -- Don't assign targets further out than this, in NM.
GCI_SENAKI.NoMissileCalls = true -- suppress missile callouts
GCI_SENAKI.PlayerCapAssigment = true -- no task assignment for players
GCI_SENAKI.invisible = true -- set AWACS to be invisible to hostiles
GCI_SENAKI.immortal = true -- set AWACS to be immortal
GCI_SENAKI.GoogleTTSPadding = 1 -- seconds
GCI_SENAKI.WindowsTTSPadding = 2.5 -- seconds

GCI_SENAKI:SuppressScreenMessages(false)
GCI_SENAKI:__Start(2)
