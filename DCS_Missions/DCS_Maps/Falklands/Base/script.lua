
--0.1 - CONST
CONST = {
    RGB = {
        range = {1,.5,0},
        farp = {.5,.5,1},
        zone_red = {1, 0 ,0},
        zone_patrol = {1, 1, 0},
        zone_bvr = {1, .5, 1}
    }
}
HELPERS = {
    SOCKET_NOTAM = "custom_notam"
}
--1.1 - VARIABLES
FREQUENCIES = {
    AWACS = {
        darkstar = {249.00, "AWACS Darkstar UHF", "AM"},
--         wizard = {250.00, "AWACS @ DCS Wizard UHF", "AM"},
--         focus = {249.80, "ELINT @ DCS Focus UHF", "AM"},
    },
    AAR = {
--         shell_1 = {252.10, "Tanker Shell One UHF", "AM"},
--         shell_2 = {252.20, "Tanker Shell Two UHF", "AM"},
        texaco_1 = {251.00, "Tanker Texaco One UHF", "AM"},
--         arco = {252.50, "Tanker Arco UHF", "AM"}
    },
--     FLIGHTS = {
--         vfma212_1_u = {266.20, "SQUADRON VFMA-212 UHF", "AM"},
--         vfma212_2_u = {266.25, "SQUADRON VFMA-212 UHF", "AM"},
--         vfma212_3_u = {266.80, "SQUADRON VFMA-212 UHF", "AM"},
--         templar_u = {266.30, "TEMPLAR UHF", "AM"},
--         assasin_u = {266.35, "ASSASIN UHF", "AM"},
--         palladin_u = {266.40, "PALLADIN UHF", "AM"},
--         crusader_u = {266.70, "CRUSADER UHF", "AM"},
--         knight_u = {266.75, "KNIGHT UHF", "AM"},
--         viper = {270.10, "VIPER ONE UHF", "AM"},
--         viper = {270.20, "VIPER ONE UHF", "AM"},
--         viper_3 = {270.30, "VIPER ONE UHF", "AM"},
--         viper_4 = {270.40, "VIPER ONE UHF", "AM"}
--     },
--     CV = {
--         dcs_sc = {127.50, "DCS SC ATC VHF", "AM"},
--         btn1 = {260.00, "B-1 HUMAN Paddles/Tower C1 UHF", "AM"},
--         btn2 = {260.10, "B-2 HUMAN Departure C2/C3 UHF", "AM"},
--         btn3 = {249.10, "B-3 HUMAN Strike UHF", "AM"},
--         btn4 = {258.20, "B-4 HUMAN Red Crown UHF", "AM"},
--         btn15 = {260.20, "B-15 HUMAN CCA Fianal A", "AM"},
--         btn16 = {260.30, "B-16 AIRBOSS/HUMAN Marshal UHF", "AM"},
--         btn17 = {260.40, "B-17 HUMAN CCA Fianal B", "AM"},
--     },
--     LHA = {
--         dcs_sc = {127.8, "LHA-1 DCS VHF", "AM"},
--         tower = {267.00, "LHA-1 HUMAN Tower UHF", "AM"},
--         radar = {267.50, "LHA-1 AIRBOSS/HUMAN Marshal UHF", "AM"},
--     },
    GROUND = {
        twr_sawg_v = {339.85, "Tower SAWG UHF", "AM"},
    },
    SPECIAL = {
        guard_hi = {243.00, "Guard UHF", "AM"},
        guard_lo = {121.50, "Guard VHF", "AM"},
        ch_16 = {156.8, "Maritime Ch16 VHF", "FM"}
    },
--     RANGE = {
--         bluewater_con = {130.10, "Bluewater RANGE CONTROL VHF", "AM"},
--         bluewater_inst = {399.00, "Bluewater RANGE INSTRUCTOR VHF", "AM"}
--     }
}
-- ICLS = {
--     sc = {11, "CV", "ICLS CVN-75"},
--     lha = {6, "LH", "ICLS LHA-1"},
-- }
TACAN = {
--     sc = {74, "X", "CVN", "CVN-75"},
--     lha = {66, "X", "LHA", "LHA-1"},
--     arco = {1, "Y", "RCV", "Recovery Tanker CVN-75", false},
--     shell_1 = {51, "Y", "SH1", "Tanker Shell One", false},
--     shell_2 = {53, "Y", "SH2", "Tanker Shell Two", false},
    texaco_1 = {52, "Y", "TX1", "Tanker Texaco One", false},
    base_sawg = {33, "X", "TX1", "Tanker Texaco One", true},
}
-- YARDSTICKS = {
--     sting_1 = {"STING ONE", 37, 100, "Y"},
--     joker_1 = {"JOKER TWO", 38, 101, "Y"},
--     hawk_1 = {"HAWK ONE", 39, 102, "Y"},
--     devil_1 = {"DEVIL TWO", 40, 103, "Y"},
--     squid_1 = {"SQUID ONE", 41, 104, "Y"},
--     check_1 = {"CHECK TWO", 42, 105, "Y"},
--     viper_1 = {"VIPER ONE", 43, 106, "Y"},
--     venom_1 = {"VENOM TWO", 44, 107, "Y"},
--     jedi_1 = {"JEDI ONE", 45, 108, "Y"},
--     ninja_1 = {"NINJA TWO", 46, 109, "Y"},
-- }


--1.2 - COMMON
function save_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"w")
	if not f then
		local errmsg = "Error: IO"
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end

function append_to_file(filename, content)
	local fdir = lfs.writedir() .. [[Logs\]] .. filename .. timer.getTime() .. ".txt"
	local f,err = io.open(fdir,"a")
	if not f then
		local errmsg = "Error: IO"
		trigger.action.outText(errmsg, 10)
		return print(err)
	end
	f:write(content)
	f:close()
end

function random(x, y)
    if x ~= nil and y ~= nil then
		return math.floor(x +(math.random()*999999 %y))
    else
        return math.floor((math.random()*100))
    end
end

for i=1, random(100,1000) do
	random(1,3)
end

function sleep(n)  -- seconds
   local t0 = os.clock()
   while ((os.clock() - t0) <= n) do
   end
end

function has_value (tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
        return false
    end

function calculateCoordinateFromRoute(startCoordObject, course, distance)
	return startCoordObject:Translate(UTILS.NMToMeters(distance), course, false, false)
end

function tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function msgToAll(arg)
    MESSAGE:New(arg[1], arg[2]):ToAll()
end

--2.2 - CLIENT

ClientSet = SET_CLIENT:New():FilterOnce()

function SetEventHandler()
    ClientBirth = ClientSet:HandleEvent(EVENTS.PlayerEnterAircraft)
end

function ClientSet:OnEventPlayerEnterAircraft(event_data)
    local unit_name = event_data.IniUnitName
    local group = event_data.IniGroup
    local player_name = event_data.IniPlayerName
    local client = "Pilot " .. player_name .. " to " .. unit_name .. " Connected!"
    MESSAGE:New("Welcome, " .. player_name):ToGroup(group)
end

SetEventHandler()

--AW.1 - AW CHICO
ZONE_DARKSTAR_1_AWACS = ZONE:New("DARKSTAR_1_AWACS")
ZONE_DARKSTAR_1_PATROL_CAP = ZONE:New("DARKSTAR_1_PATROL_CAP"):DrawZone(2, CONST.RGB.zone_patrol, 1, CONST.RGB.zone_patrol, .5, 1, true)
ZONE_DARKSTAR_1_ENGAGE = ZONE:New("DARKSTAR_1_ENGAGE"):DrawZone(2, CONST.RGB.zone_bvr, 1, CONST.RGB.zone_bvr, .5, 1, true)

AW_SAWG = AIRWING:New("WH Chico", "Chico Air Wing")

AW_SAWG:SetMarker(false)
AW_SAWG:SetAirbase(AIRBASE:FindByName(AIRBASE.SouthAtlantic.Rio_Chico))
AW_SAWG:SetRespawnAfterDestroyed(600)
AW_SAWG:__Start(2)

AW_SAWG_AWACS = SQUADRON:New("ME AWACS E3", 2, "AWACS")
AW_SAWG_AWACS:AddMissionCapability({ AUFTRAG.Type.ORBIT }, 100)
AW_SAWG_AWACS:SetTakeoffType("Hot")
AW_SAWG_AWACS:SetFuelLowRefuel(true)
AW_SAWG_AWACS:SetFuelLowThreshold(0.4)
AW_SAWG_AWACS:SetTurnoverTime(30, 5)
AW_SAWG_AWACS:SetRadio(FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AW_SAWG:AddSquadron(AW_SAWG_AWACS)
AW_SAWG:NewPayload("ME AWACS E3", -1, { AUFTRAG.Type.ORBIT }, 100)

-- callsign, AW, coalition, base, station zone, fez, cap_zone, freq, modulation
local Darkstar_1_1_route = {ZONE_DARKSTAR_1_AWACS:GetCoordinate(), 35000, 450, 180, 80}

AWACS_DARKSTAR = AWACS:New("DARKSTAR", AW_SAWG, "blue", AIRBASE.SouthAtlantic.Rio_Chico, "DARKSTAR_1_AWACS", "DARKSTAR_1_ENGAGE", "DARKSTAR_1_PATROL_CAP", FREQUENCIES.AWACS.darkstar[1], radio.modulation.AM)
AWACS_DARKSTAR:SetBullsEyeAlias("BullsEye")
AWACS_DARKSTAR:SetAwacsDetails(CALLSIGN.AWACS.Darkstar, 1, Darkstar_1_1_route[2], Darkstar_1_1_route[3], Darkstar_1_1_route[4], Darkstar_1_1_route[5])
AWACS_DARKSTAR:SetSRS(SRS_PATH, "female", "en-GB", SRS_PORT)
AWACS_DARKSTAR:SetModernEraAggressive()

AWACS_DARKSTAR.PlayerGuidance = true -- allow missile warning call-outs.
AWACS_DARKSTAR.NoGroupTags = true -- use group tags like Alpha, Bravo .. etc in call outs.
AWACS_DARKSTAR.callsignshort = false -- use short callsigns, e.g. "Moose 1", not "Moose 1-1".
AWACS_DARKSTAR.DeclareRadius = 5 -- you need to be this close to the lead unit for declare/VID to work, in NM.
AWACS_DARKSTAR.MenuStrict = true -- Players need to check-in to see the menu; check-in still require to use the menu.
AWACS_DARKSTAR.maxassigndistance = 200 -- Don't assign targets further out than this, in NM.
AWACS_DARKSTAR.NoMissileCalls = false -- suppress missile callouts
AWACS_DARKSTAR.PlayerCapAssigment = false -- no task assignment for players
AWACS_DARKSTAR.invisible = true -- set AWACS to be invisible to hostiles
AWACS_DARKSTAR.immortal = true -- set AWACS to be immortal
AWACS_DARKSTAR.GoogleTTSPadding = 1 -- seconds
AWACS_DARKSTAR.WindowsTTSPadding = 2.5 -- seconds

AWACS_DARKSTAR:SuppressScreenMessages(false)
AWACS_DARKSTAR:__Start(2)

--TANKERS BLUE
Spawn_Texaco_One = SPAWN:New("SPAWN TX1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (texaco_11) texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1) end):InitRepeatOnLanding()