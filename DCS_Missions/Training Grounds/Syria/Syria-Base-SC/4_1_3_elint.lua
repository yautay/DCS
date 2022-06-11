if (elint) then
    local function init_elint_elements(templates_table)
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

    local function setup_sectors(template_sectors)
        for i, v in pairs(template_sectors) do
            HoundBlue:addSector(v[1])
            HoundBlue:setZone(v[1],v[2])
            HoundBlue:setTransmitter(v[1],v[3])
            HoundBlue:enableController(v[1],v[4])
            HoundBlue:enableAlerts(v[1])
            if (atis) then
                HoundBlue:enableAtis(v[1],v[5])
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

    local me_elint_templates = {"ELINT-Allepo", "ELINT-Beirut"}


    -- TTS SETTINGS
    local allepo_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.allepo_hi[1],FREQUENCIES.ELINT.allepo_lo[1],FREQUENCIES.ELINT.allepo_fm[1])
    local atis_allepo_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.atis_allepo_hi[1],FREQUENCIES.ELINT.atis_allepo_lo[1],FREQUENCIES.ELINT.atis_allepo_fm[1])
    local beirut_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.beirut_hi[1],FREQUENCIES.ELINT.beirut_lo[1],FREQUENCIES.ELINT.beirut_fm[1])
    local atis_beirut_freq = string.format("%2f,%2f,%2f",FREQUENCIES.ELINT.atis_beirut_hi[1],FREQUENCIES.ELINT.atis_beirut_lo[1],FREQUENCIES.ELINT.atis_beirut_fm[1])
    local allepo_modulation = string.format("%s,%s,%s",FREQUENCIES.ELINT.allepo_hi[3],FREQUENCIES.ELINT.allepo_lo[3],FREQUENCIES.ELINT.allepo_fm[3])
    local beirut_modulation = string.format("%s,%s,%s",FREQUENCIES.ELINT.beirut_hi[3],FREQUENCIES.ELINT.beirut_lo[3],FREQUENCIES.ELINT.beirut_fm[3])

    local controler_args = {
        allepo = create_radio(allepo_freq, allepo_modulation, "male"),
        beirut = create_radio(beirut_freq, beirut_modulation, "male")

    }
    local atis_args = { 
        allepo = create_atis_radio(atis_allepo_freq, allepo_modulation),
        beirut = create_atis_radio(atis_beirut_freq, beirut_modulation)
    }

    local notifier_args = {
        freq = "242.000,243.000,128.500,41.500",
        modulation = "AM,AM,AM,FM",
        gender = "male"
    }

    local sector_templates = {
        {"Allepo", "Sector Allepo", "ELINT-Allepo", controler_args.allepo, atis_args.allepo},
        {"Beirut", "Sector Beirut", "ELINT-Beirut", controler_args.beirut, atis_args.beirut}
    }

    local zone_allepo = ZONE_POLYGON:New("Sector Allepo", GROUP:FindByName("ZONE-Sector Allepo")):DrawZone(2, {1,0.7,0.1}, 1, {1,0.7,0.1}, 0.2, 0, true)
    local zone_beirut = ZONE_POLYGON:New("Sector Beirut", GROUP:FindByName("ZONE-Sector Beirut")):DrawZone(2, {1,0,0}, 1, {1,0,0}, 0.2, 0, true)


    HoundBlue = HoundElint:create(coalition.side.BLUE)

    init_elint_elements(me_elint_templates)
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

    -- DEBUG
    local function dump(o)
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

    local function instance_data(table)
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

    local function debug_hound() 
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
end