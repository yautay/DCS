-- ###########################################################
-- ###                      ELINT                          ###
-- ###########################################################

local function setup_sectors(template_sectors)
    for i, v in pairs(template_sectors) do
        HoundBlue:addSector(v[1])
        HoundBlue:setZone(v[1],v[2])
        HoundBlue:enableController(v[1],v[3])
        HoundBlue:enableAlerts(v[1])
        if (atis) then
            HoundBlue:enableAtis(v[1],v[4])
        end
        HoundBlue:reportEWR(v[1],true)
    end
end

local function create_radio(freq, mod, gender)
    local radio = {
        freq = freq,
        modulation = mod,
        gender = gender
    }
    return radio
end

local function create_atis_radio(freq, mod)
    local radio = {
        freq = freq,
        modulation = mod
    }
    return radio
end

  -- TTS SETTINGS
-- local vaziani_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.vaziani_hi[1],FREQUENCIES.ELINT.vaziani_lo[1],FREQUENCIES.ELINT.vaziani_fm[1])
-- local atis_vaziani_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.atis_vaziani_hi[1],FREQUENCIES.ELINT.atis_vaziani_lo[1],FREQUENCIES.ELINT.atis_vaziani_fm[1])
-- local kutaisi_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.kutaisi_hi[1],FREQUENCIES.ELINT.kutaisi_lo[1],FREQUENCIES.ELINT.kutaisi_fm[1])
-- local atis_kutaisi_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.atis_kutaisi_hi[1],FREQUENCIES.ELINT.atis_kutaisi_lo[1],FREQUENCIES.ELINT.atis_kutaisi_fm[1])
-- local vaziani_modulation = string.format("%s,%s,%s",FREQUENCIES.ELINT.vaziani_hi[3],FREQUENCIES.ELINT.vaziani_lo[3],FREQUENCIES.ELINT.vaziani_fm[3])
-- local kutaisi_modulation = string.format("%s,%s,%s",FREQUENCIES.ELINT.kutaisi_hi[3],FREQUENCIES.ELINT.kutaisi_lo[3],FREQUENCIES.ELINT.kutaisi_fm[3])

local vaziani_freq = string.format("%2f,%2f",FREQUENCIES.ELINT.vaziani_hi[1],FREQUENCIES.ELINT.vaziani_lo[1])
local atis_vaziani_freq = string.format("%2f,%2f",FREQUENCIES.ELINT.atis_vaziani_hi[1],FREQUENCIES.ELINT.atis_vaziani_lo[1])
local kutaisi_freq = string.format("%2f,%2f",FREQUENCIES.ELINT.kutaisi_hi[1],FREQUENCIES.ELINT.kutaisi_lo[1])
local atis_kutaisi_freq = string.format("%2f,%2f",FREQUENCIES.ELINT.atis_kutaisi_hi[1],FREQUENCIES.ELINT.atis_kutaisi_lo[1])
local vaziani_modulation = string.format("%s,%s",FREQUENCIES.ELINT.vaziani_hi[3],FREQUENCIES.ELINT.vaziani_hi[3])
local kutaisi_modulation = string.format("%s,%s",FREQUENCIES.ELINT.kutaisi_hi[3],FREQUENCIES.ELINT.vaziani_hi[3])

local notifier_freq = string.format("%2f,%2f",FREQUENCIES.SPECIAL.guard_hi[1], FREQUENCIES.SPECIAL.guard_lo[1])
local notifier_modulation = string.format("%s,%s",FREQUENCIES.SPECIAL.guard_hi[3], FREQUENCIES.SPECIAL.guard_lo[3])

local controler_args = {
    vaziani = create_radio(vaziani_freq, vaziani_modulation, "male"),
    kutaisi = create_radio(kutaisi_freq, kutaisi_modulation, "male")

}
local atis_args = { 
    vaziani = create_atis_radio(atis_vaziani_freq, vaziani_modulation),
    kutaisi = create_atis_radio(atis_kutaisi_freq, kutaisi_modulation)
}

local notifier_args = {
    freq = notifier_freq,
    modulation = notifier_modulation,
    gender = "male"
}

local sector_templates = {
    {"Vaziani", "Sector Vaziani", controler_args.vaziani, atis_args.vaziani},
    {"Kutaisi", "Sector Kutaisi", controler_args.kutaisi, atis_args.kutaisi}
}

local zone_vaziani = ZONE_POLYGON:New("Sector Vaziani", GROUP:FindByName("ELINT VAZIANI")):DrawZone(2, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.2, 0, true)
local zone_kutaisi = ZONE_POLYGON:New("Sector Kutaisi", GROUP:FindByName("ELINT KUTAISI")):DrawZone(2, {1,0,0}, 1, {1,0,0}, 0.2, 0, true)


HoundBlue = HoundElint:create(coalition.side.BLUE)

setup_sectors(sector_templates)

-- MISC
HOUND.setMgrsPresicion(3)
HOUND.showExtendedInfo(false)
HoundBlue:setTimerInterval("scan",10)
HoundBlue:setTimerInterval("process",10)
HoundBlue:setTimerInterval("menus",20)
HoundBlue:setTimerInterval("markers",20)
HoundBlue:setTimerInterval("display",20)

-- ATIS
HoundBlue:setAtisUpdateInterval(2*60)

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

if (debug_elint) then
    HoundBlue:onScreenDebug (true)
end