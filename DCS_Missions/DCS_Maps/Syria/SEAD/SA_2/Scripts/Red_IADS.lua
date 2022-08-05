redIADS = SkynetIADS:create('Syria IADS')

red_ewr_templates = { SPAWN:NewWithAlias("Red EWR 55G6", "EWR G6"),
                      SPAWN:NewWithAlias("Red EWR FPS117", "EWR FPS"),
                      SPAWN:NewWithAlias("Red SR P19", "EWR SR"),
                      SPAWN:NewWithAlias("Red SR DE", "EWR DE") }

red_aaa_templates = { SPAWN:NewWithAlias("Red ZU23 Ural", "AAA ZU23 Ural"),
                      SPAWN:NewWithAlias("Red ZU23 HL", "AAA ZU23 Toyota"),
                      SPAWN:NewWithAlias("Red ZU57 SP", "AAA ZU57 SP") }

red_sam_sites_templates = {
    ["ahmed_site"] = {
        ["sam"] = {
            ["template_group"] = 'Red SAM SA-2 "Ahmed"',
            ["alias"] = "SAM AHMED" },
        ["generators"] = {
            ["template_group"] = 'Red SAM SA-2 "Ahmed" Generators',
            ["alias"] = "GENERATORS AHMED" },
        ["node"] = {
            ["template_static"] = 'Ahmed Radio Link',
            ["alias"] = "LINK AHMED" },
        ["zones_aaa"] = {ZONE:New("Achmed AAA 1"), ZONE:New("Achmed AAA 2"), ZONE:New("Achmed AAA 3")}
    }
}

function spawn_sa2_site(dict_templates)
    local group_name_sa2 = string
    local units_power_sources = table
    local units_links = table
    --@MOOSE PART
    --SAM GROUP
    SPAWN:NewWithAlias(dict_templates.sam.template_group, dict_templates.sam.alias)
            :OnSpawnGroup(
                function(SpawnGroup)
                group_name_sa2 = SpawnGroup:GetName()
                SpawnGroup:E(string.format("SAM Site -> ' %s ' spawned", group_name_sa2))
            end
            ):Spawn()
    --POWER SOURCES
    SPAWN:NewWithAlias(dict_templates.generators.template_group, dict_templates.generators.alias)
            :OnSpawnGroup(
                function(SpawnGroup)
                units_power_sources = SpawnGroup:GetDCSUnits()
                local units = SpawnGroup:GetUnits()
                for i, v in pairs(units) do
                    local unit_name = v:GetName()
                    SpawnGroup:E(string.format("Power Source -> ' %s ' spawned", unit_name))
                end
            end
            ):Spawn()
    --RADIO LINK
    SPAWN:NewWithAlias(dict_templates.node.template_static, dict_templates.node.alias)
            :OnSpawnGroup(
                function(SpawnGroup)
                units_links = SpawnGroup:GetDCSUnits()
                local units = SpawnGroup:GetUnits()
                for i, v in pairs(units) do
                    local unit_name = v:GetName()
                    SpawnGroup:E(string.format("Connection Node -> ' %s ' spawned", unit_name))
                end
            end
            ):Spawn()
    --AAA PROTECTION
    local list_zones = dict_templates.zones_aaa
    for i, v in pairs(list_zones) do
        red_aaa_templates[random(1, table.getn(red_aaa_templates))]:SpawnInZone(v, true)
    end
    --@SKYNET PART
    --add sam site
    local sam_site = redIADS:addSAMSite(group_name_sa2)
    --add power sources
    for i, v in pairs(units_power_sources) do
        sam_site:addPowerSource(v)
    end
    --add connection nodes
    for i, v in pairs(units_links) do
        sam_site:addConnectionNode(v)
    end
end

spawn_sa2_site(red_sam_sites_templates.ahmed_site)

--SAMs
if sam_ahmed then
    spawn_sa2_site(red_sam_sites_templates.ahmed_site)

end


if sam_fakir then
    red_sam_sa2_fakir = SPAWN:NewWithAlias('Red SAM SA-2 "Fakir"', "SAM FAKIR"):OnSpawnGroup(
            function(SpawnGroup)
                local group_name = SpawnGroup:GetName()
                redIADS:addSAMSite(group_name)
                SpawnGroup:E(string.format("%s - I am spawned", group_name))
            end
    )                        :Spawn()
    red_sam_sa2_fakir_generators = SPAWN:NewWithAlias('Red SAM SA-2 "Fakir" Generators', "GENERATORS FAKIR"):OnSpawnGroup(
            function(SpawnGroup)
                SpawnGroup:E("I am spawned")
            end
    )                                   :Spawn()
    red_sam_sa2_fakir_radio_link = SPAWN:NewWithAlias('Fakir Radio Link', "LINK FAKIR"):OnSpawnGroup(
            function(SpawnGroup)
                SpawnGroup:E("I am spawned")
            end
    )                                   :Spawn()
    local aaa_zones = { ZONE:New("Fakir AAA 1"), ZONE:New("Fakir AAA 2"), ZONE:New("Fakir AAA 3") }
    for i, v in pairs(aaa_zones) do
        --red_aaa_templates[random(1, table.getn(red_aaa_templates))]:SpawnInZone(v, true)
        red_aaa_templates[1]:SpawnInZone(v, true)
    end
end

if sam_shamir then
    local red_sam_sa2_shamir = SPAWN:NewWithAlias('Red SAM SA-2 "Shamir"', "SAM SHAMIR"):OnSpawnGroup(
            function(SpawnGroup)
                local group_name = SpawnGroup:GetName()
                redIADS:addSAMSite(group_name)
                SpawnGroup:E(string.format("%s - I am spawned", group_name))
            end
    )                               :Spawn()
    local red_sam_sa2_shamir_generators = SPAWN:NewWithAlias('Red SAM SA-2 "Shamir" Generators', "GENERATORS SHAMIR "):OnSpawnGroup(
            function(SpawnGroup)
                SpawnGroup:E("I am spawned")
            end
    )                                          :Spawn()
    red_sam_sa2_fakir_radio_link = SPAWN:NewWithAlias('Shamir Radio Link', "LINK SHAMIR"):OnSpawnGroup(
            function(SpawnGroup)
                SpawnGroup:E("I am spawned")
            end
    )                                   :Spawn()
    local aaa_zones = { ZONE:New("Shamir AAA 1"), ZONE:New("Shamir AAA 2"), ZONE:New("Shamir AAA 3") }
    for i, v in pairs(aaa_zones) do
        --red_aaa_templates[random(1, table.getn(red_aaa_templates))]:SpawnInZone(v, true)
        red_aaa_templates[1]:SpawnInZone(v, true)
    end
end
--EWRs
local ewr_zones = { ZONE:New("EWR 1"),
                    ZONE:New("EWR 2"),
                    ZONE:New("EWR 3") }
local mobile_ewr_zones = {
    ZONE:New("MOBILE EWR 1"),
    ZONE:New("MOBILE EWR 2"),
    ZONE:New("MOBILE EWR 3"),
    ZONE:New("MOBILE EWR 4"),
    ZONE:New("MOBILE EWR 5"),
    ZONE:New("MOBILE EWR 6"),
    ZONE:New("MOBILE EWR 7"), }

for i, v in pairs(ewr_zones) do
    red_ewr_templates[2]:SpawnInZone(v, true)
end

for i, v in pairs(mobile_ewr_zones) do
    red_ewr_templates[4]:SpawnInZone(v, true)
end


local commandCenter = StaticObject.getByName("Command Center")
redIADS:addCommandCenter(commandCenter)

redIADS:activate()

local iadsDebug = redIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.contacts = true
iadsDebug.jammerProbability = true

iadsDebug.addedEWRadar = true
iadsDebug.addedSAMSite = true
iadsDebug.warnings = true
iadsDebug.radarWentLive = true
iadsDebug.radarWentDark = true
iadsDebug.harmDefence = true

iadsDebug.samSiteStatusEnvOutput = true
iadsDebug.earlyWarningRadarStatusEnvOutput = true
iadsDebug.commandCenterStatusEnvOutput = true