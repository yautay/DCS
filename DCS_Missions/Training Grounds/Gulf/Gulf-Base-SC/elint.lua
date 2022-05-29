HoundBlue = HoundElint:create(coalition.side.BLUE)

-- PLATFORMS
HoundBlue:addPlatform("ELINT Hormuz") -- Ground Station
-- HoundBlue:addPlatform("AWACS Hormuz") -- E-3
-- HoundBlue:addPlatform("USS Theodore Roosevelt AWACS") -- E-2D
HoundBlue:addPlatform("ELINT South") -- C17
HoundBlue:addPlatform("ELINT West") -- C17
HoundBlue:addPlatform("ELINT East") -- C17

-- SECTORS
HoundBlue:addSector("Hormuz")
HoundBlue:setZone("Hormuz","Sector Hormuz")

-- TTS SETTINGS
local controller_args = {
    freq = "255.500,121.750,35.000",
    modulation = "AM,AM,FM",
    gender = "male"
}
local atis_args = {
    freq = "256.500,122.750,34.500",
    modulation = "AM,AM,FM"
}
local notifier_args = {
    freq = "242.000,254.000,128.500",
    modulation = "AM,AM,AM",
    gender = "female"
}

HoundBlue:setTransmitter("Hormuz","AWACS Hormuz")

-- SAM CONTROLER
HoundBlue:enableController("Hormuz",controller_args)
HoundBlue:enableAlerts("Hormuz")
HOUND.setMgrsPresicion(3)
-- HOUND.showExtendedInfo(false)

-- ATIS
HoundBlue:enableAtis("Hormuz",atis_args)
HoundBlue:reportEWR("all",true)
-- HoundBlue:reportEWR("Hormuz",true)
HoundBlue:setAtisUpdateInterval(1*60)

-- NOTIFIER
HoundBlue:enableNotifier("Hormuz", notifier_args)

-- FUNCTIONAL CONFIG
HoundBlue:setMarkerType(HOUND.MARKER.DIAMOND)
HoundBlue:enableMarkers()
HoundBlue:enableBDA()
HoundBlue:enableText("all")

-- PRE BRIEFED
HoundBlue:preBriefedContact("red-sa5-1-sr")
HoundBlue:preBriefedContact("red-sa5-1-tr")

-- ON
HoundBlue:systemOn()

HoundBlue:setTimerInterval("scan",5)
HoundBlue:setTimerInterval("process",15)
HoundBlue:setTimerInterval("menus",15)
HoundBlue:setTimerInterval("markers",30)
HoundBlue:setTimerInterval("display",30)
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

mist.scheduleFunction(debug_hound ,{} ,timer.getTime(), 15, timer.getTime() + 36000)
