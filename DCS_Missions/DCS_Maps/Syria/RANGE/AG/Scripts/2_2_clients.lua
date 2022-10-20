CLIENTS = {
    "LOBO-1",
    "LOBO-2",
    "FAGOT-1",
    "FAGOT-2",
    "FARMER-1",
    "FARMER-2",
    "FISHBED-1",
    "FISHBED-2",
    "FULCRUM-1",
    "FULCRUM-2",
    "RED-16-S",
    "RED-16-N",
    "RED-27-N",
    "RED-27-S",
    "RED-29-N",
    "RED-29-S",
    "BLUE-16-N",
    "BLUE-16-S",
    "BLUE-27-N",
    "BLUE-27-S",
    "BLUE-29-N",
    "BLUE-29-S",
    "CASE 1 TRAINER A",
    "CASE 1 TRAINER B",
    "CASE 1 TRAINER C",
    "CASE 1 TRAINER D",
}
NAVY_CLIENTS = {
    "UZI-1",
    "UZI-2",
    "HORNET-1",
    "HORNET-2",
    "HORNET-212",
    "HORNET-237",
    "DEVIL-1",
    "DEVIL-2",
    "DEVIL-3",
    "DEVIL-4",
    "RED-18-N",
    "RED-18-S",
    "BLUE-18-N",
    "BLUE-18-S",
}

navy_in_air = {}

ClientSet = SET_CLIENT:New():FilterOnce()

function SetEventHandler()
    ClientBirth = ClientSet:HandleEvent(EVENTS.PlayerEnterAircraft)
end

function ClientSet:OnEventPlayerEnterAircraft(event_data)
    local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
    local unit_name = event_data.IniUnitName
    local group = event_data.IniGroup
    local player_name = event_data.IniPlayerName

    if has_value(NAVY_CLIENTS, unit_name) then
        env.info("Aviator Connected" .. unit_name)
        info_msg:SendText("Aviator " .. player_name .. " Connected!")
        table.insert(navy_in_air, unit_name)
    else
        info_msg:SendText("Pilot " .. player_name .. " Connected!")
        env.info("Pilot Connected" .. unit_name)
    end

    MESSAGE:New("Welcome, " .. player_name):ToGroup(group)
    --MESSAGE:New(GUAM_GENERAL_BRIEFING, 20):ToGroup(group)
end

SetEventHandler()

scheduler_cvn = SCHEDULER:New( cvn_75_airboss, recheck_activation_zone, self, 10, 60 )