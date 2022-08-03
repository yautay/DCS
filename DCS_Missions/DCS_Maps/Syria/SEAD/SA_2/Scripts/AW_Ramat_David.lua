ZONE_DARKSTAR_AWACS = ZONE:New("ZONE_DARKSTAR_AWACS")
ZONE_SHELL_ONE_AAR = ZONE:New("ZONE_SHELL_ONE_AAR")
ZONE_SHELL_TWO_AAR = ZONE:New("ZONE_SHELL_TWO_AAR")
ZONE_SHELL_THREE_AAR = ZONE:New("ZONE_SHELL_THREE_AAR")
ZONE_PATROL = ZONE:New("PATROL")

AW_LLRD = AIRWING:New("WH Ramat David", "Ramat David Air Wing")

if (debug_aw_ramat_david) then
    function AW_LLRD:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
        local flightgroup = FlightGroup --Ops.FlightGroup#FLIGHTGROUP
        local mission = Mission         --Ops.Auftrag#AUFTRAG

        -- Info message.
        local text = string.format("Flight group %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
        env.info(text)
        MESSAGE:New(text, 300):ToAll()
    end
end

function add_tanker_mission(Airwing_object, Mission_object)
    local mission = AUFTRAG:NewTANKER(
            Mission_object.zone,
            Mission_object.alt,
            Mission_object.ias,
            Mission_object.hdg,
            Mission_object.leg,
            Mission_object.base)
    mission:AssignSquadrons({ Mission_object.squadron })
    mission:SetRadio(Mission_object.freq)
    mission:SetName(Mission_object.code_name)
    Airwing_object:AddMission(mission)
end

AW_LLRD:SetMarker(false)
AW_LLRD:SetAirbase(AIRBASE:FindByName(AIRBASE.Syria.Ramat_David))
AW_LLRD:SetRespawnAfterDestroyed(600)

AW_LLRD_AWACS = SQUADRON:New("ME AWACS RD", 3, "USAF AWACS")
AW_LLRD_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_LLRD_AWACS:SetTakeoffType("Hot")
AW_LLRD_AWACS:SetFuelLowRefuel(false)
AW_LLRD_AWACS:SetFuelLowThreshold(0.25)
AW_LLRD_AWACS:SetTurnoverTime(30, 5)
AW_LLRD_AWACS:SetCallsign(CALLSIGN.Aircraft.Darkstar, 1)
AW_LLRD_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AW_LLRD:AddSquadron(AW_LLRD_AWACS)
AW_LLRD:NewPayload("ME AWACS RD", -1, { AUFTRAG.Type.ORBIT }, 100)

AW_LLRD_AAR = SQUADRON:New("ME AAR RD", 2, "AAR Shell One")
AW_LLRD_AAR:AddMissionCapability({ AUFTRAG.Type.TANKER }, 100)
AW_LLRD_AAR:SetTakeoffType("Hot")
AW_LLRD_AAR:SetFuelLowRefuel(false)
AW_LLRD_AAR:SetFuelLowThreshold(0.2)
AW_LLRD_AAR:SetTurnoverTime(30, 5)
AW_LLRD_AAR:SetRadio(FREQUENCIES.AAR.common[1], radio.modulation.AM)
AW_LLRD:AddSquadron(AW_LLRD_AAR)
AW_LLRD:NewPayload("ME AAR RD", -1, { AUFTRAG.Type.TANKER, AUFTRAG.Type.ORBIT }, 100)

LLRD_TANERS = { {
                    ["squadron"] = AW_LLRD_AAR,
                    ["zone"] = ZONE_SHELL_ONE_AAR,
                    ["alt"] = 20000,
                    ["ias"] = 270,
                    ["hdg"] = 0,
                    ["leg"] = 20,
                    ["base"] = 0,
                    ["freq"] = FREQUENCIES.AAR.shell_1[1],
                    ["code_name"] = "Shell One"
                },
                {
                    ["squadron"] = AW_LLRD_AAR,
                    ["zone"] = ZONE_SHELL_TWO_AAR,
                    ["alt"] = 19000,
                    ["ias"] = 274,
                    ["hdg"] = 0,
                    ["leg"] = 20,
                    ["base"] = 0,
                    ["freq"] = FREQUENCIES.AAR.shell_2[1],
                    ["code_name"] = "Shell Two"
                },
                {
                    ["squadron"] = AW_LLRD_AAR,
                    ["zone"] = ZONE_SHELL_THREE_AAR,
                    ["alt"] = 18000,
                    ["ias"] = 278,
                    ["hdg"] = 0,
                    ["leg"] = 20,
                    ["base"] = 0,
                    ["freq"] = FREQUENCIES.AAR.shell_3[1],
                    ["code_name"] = "Shell Three"
                } }

for i, v in pairs(LLRD_TANERS) do
    add_tanker_mission(AW_LLRD, v)
end

AW_LLRD:__Start(2)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
AwacsOverlord = AWACS:New("DARKSTAR", AW_LLRD, "blue", AIRBASE.Syria.Ramat_David, "ZONE_DARKSTAR_AWACS", "ENGAGE", "PATROL", FREQUENCIES.AWACS.overlord[1], radio.modulation.AM)

AwacsOverlord:SetBullsEyeAlias("MIGHTY WOMBAT")
AwacsOverlord:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, 25000, 220, 020, 40)
AwacsOverlord:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AwacsOverlord:SetModernEraAgressive()

AwacsOverlord.PlayerGuidance = true -- allow missile warning call-outs.
AwacsOverlord.NoGroupTags = false -- use group tags like Alpha, Bravo .. etc in call outs.
AwacsOverlord.callsignshort = true -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AwacsOverlord.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AwacsOverlord.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AwacsOverlord.maxassigndistance = 100 -- Don't assign targets further out than this, in NM.
AwacsOverlord.NoMissileCalls = false -- suppress missile callouts
AwacsOverlord.PlayerCapAssigment = true -- no task assignment for players
AwacsOverlord.invisible = true -- set AWACS to be invisible to hostiles
AwacsOverlord.immortal = true -- set AWACS to be immortal
AwacsOverlord.GoogleTTSPadding = 1 -- seconds
AwacsOverlord.WindowsTTSPadding = 2.5 -- seconds

AwacsOverlord:SuppressScreenMessages(false)
AwacsOverlord:__Start(5)

if (debug_awacs) then
    AwacsOverlord.debug = true -- set to true to produce more log output.
else
    AwacsOverlord.debug = false
end