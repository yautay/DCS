local debug_elint = false

local me_elint_templates = {"ELINT South", "ELINT West", "ELINT East"}

-- TTS SETTINGS
local hormuz_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.hormuz_hi[1],FREQUENCIES.ELINT.hormuz_lo[1],FREQUENCIES.ELINT.hormuz_fm[1])
local atis_hormuz_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.atis_hormuz_hi[1],FREQUENCIES.ELINT.atis_hormuz_lo[1],FREQUENCIES.ELINT.atis_hormuz_fm[1])
local kish_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.kish_hi[1],FREQUENCIES.ELINT.kish_lo[1],FREQUENCIES.ELINT.kish_fm[1])
local atis_kish_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.atis_kish_hi[1],FREQUENCIES.ELINT.atis_kish_lo[1],FREQUENCIES.ELINT.atis_kish_fm[1])
local hormuz_modulation = string.format("%s,%s,%s",FREQUENCIES.ELINT.hormuz_hi[3],FREQUENCIES.ELINT.hormuz_lo[3],FREQUENCIES.ELINT.hormuz_fm[3])
local kish_modulation = string.format("%s,%s,%s",FREQUENCIES.ELINT.hormuz_hi[3],FREQUENCIES.ELINT.hormuz_lo[3],FREQUENCIES.ELINT.hormuz_fm[3])

env.info(hormuz_freq)
env.info(atis_hormuz_freq)
env.info(kish_freq)
env.info(atis_kish_freq)
env.info(hormuz_modulation)
env.info(kish_modulation)

local controler_args = {
    hormuz = {
        freq = hormuz_freq,
        modulation = hormuz_modulation,
        gender = "male"},
    kish = {
        freq = kish_freq,
        modulation = kish_modulation,
        gender = "male"},

}
local atis_args = { 
    hormuz = {
        freq = atis_hormuz_freq,
        modulation = hormuz_modulation},
    kish = {
        freq = atis_kish_freq,
        modulation = kish_modulation},
}

local notifier_args = {
    freq = "242.000,243.000,128.500",
    modulation = "AM,AM,AM",
    gender = "male"
}

local sector_templates = {
    {"Hormuz", "Sector Hormuz", "AWACS Hormuz", controler_args.hormuz, atis_args.hormuz},
    {"Kish", "Sector Kish", "AWACS Hormuz", controler_args.kish, atis_args.kish}
}

HoundBlue = HoundElint:create(coalition.side.BLUE)

function init_elint_elements(templates_table)
    for i, v in pairs(templates_table) do
        SPAWN:New(v):InitKeepUnitNames():InitLimit(1, 0):SpawnScheduled(5, .1):OnSpawnGroup(
            function(element_spawned)
                local unit_name = element_spawned:GetFirstUnitAlive():GetName()
                env.info(string.format("SPAWNED %s\n", unit_name))
                HoundBlue:addPlatform(unit_name)
            end
        ):InitRepeatOnLanding()
    end
end

function setup_sectors(template_sectors)
    for i, v in pairs(template_sectors) do
        HoundBlue:addSector(v[1])
        HoundBlue:setZone(v[1],v[2])
        HoundBlue:setTransmitter(v[1],v[3])
        HoundBlue:enableController(v[1],v[4])
        HoundBlue:enableAlerts(v[1])
        HoundBlue:enableAtis(v[1],v[5])
        HoundBlue:reportEWR(v[1],true)
    end
end

init_elint_elements(me_elint_templates)
setup_sectors(sector_templates)

-- MISC
HOUND.setMgrsPresicion(3)
HOUND.showExtendedInfo(false)
HoundBlue:setTimerInterval("scan",5)
HoundBlue:setTimerInterval("process",10)
HoundBlue:setTimerInterval("menus",10)
HoundBlue:setTimerInterval("markers",10)
HoundBlue:setTimerInterval("display",10)

-- ATIS
HoundBlue:setAtisUpdateInterval(1*60)

-- NOTIFIER
HoundBlue:enableNotifier()

-- FUNCTIONAL CONFIG
HoundBlue:setMarkerType(HOUND.MARKER.OCTAGON)
HoundBlue:enableMarkers()
HoundBlue:enableBDA()
HoundBlue:enableText("all")

-- PRE BRIEFED

-- HoundBlue:preBriefedContact("red-sa5-1-sr")
-- HoundBlue:preBriefedContact("red-sa5-1-tr")
-- HoundBlue:preBriefedContact("red-sa2-1-tr")
-- HoundBlue:preBriefedContact("red-sa2-1-sr")

-- ON
HoundBlue:systemOn()

-- DEBUG
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for i, v in pairs(o) do
            s = s .. v .. ", "
        end
        return s .. '}'
    else
        return "no data"
    end
end

function instance_data(table)
    local tmp_data = string.format("\n\nELINT CONTACTS ---> %f\n", timer.getTime())  
    for i, v in pairs(table) do
        local name = v.typeName
        local dcs_name = v.DCSunitName
        local max_wpn_range = v.maxWeaponsRange
        local last_seen = v.last_seen
        local detected_by_table = v.detected_by
        local detected_by = dump(detected_by_table)     
        local info = string.format("name: %s last seen: %f detected by: %s \n", name, last_seen , detected_by)
        tmp_data = tmp_data .. info
    end
    return tmp_data .. "<--- ELINT CONTACTS\n"
end

function debug_hound() 
    env.info("==================HOUND START DEBUG==================")
    env.info(dump(debug_elint_elements))
    local contacts = HoundBlue:getContacts()
    local contacts_ewr_no = contacts.ewr.count
    local contacts_sam_no = contacts.sam.count
    local contacts_ewr_tbl = contacts.ewr.contacts
    local contacts_sam_tbl = contacts.sam.contacts
    env.info(string.format("EWR NO -> %d", contacts_ewr_no))
    env.info(string.format("SAM NO -> %d", contacts_sam_no))
    env.info(instance_data(contacts_ewr_tbl))
    env.info(instance_data(contacts_sam_tbl))
    HoundBlue:dumpIntelBrief()
    env.info("==================HOUND END DEBUG==================")
end

if (debug_elint) then
    BASE:E(HoundBlue)
    mist.scheduleFunction(debug_hound ,{} ,timer.getTime(), 15, timer.getTime() + 36000)
end
