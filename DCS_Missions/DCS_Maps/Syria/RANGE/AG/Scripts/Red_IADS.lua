redIADS = SkynetIADS:create('Syria IADS')

red_ewr_templates = { SPAWN:NewWithAlias("Red EWR 55G6", "EWR G6"),
                      SPAWN:NewWithAlias("Red EWR 1L13", "EWR L13"),
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
    },
    ["fakir_site"] = {
        ["sam"] = {
            ["template_group"] = 'Red SAM SA-2 "Fakir"',
            ["alias"] = "SAM FAKIR" },
        ["generators"] = {
            ["template_group"] = 'Red SAM SA-2 "Fakir" Generators',
            ["alias"] = "GENERATORS FAKIR" },
        ["node"] = {
            ["template_static"] = 'Fakir Radio Link',
            ["alias"] = "LINK FAKIR" },
        ["zones_aaa"] = {ZONE:New("Fakir AAA 1"), ZONE:New("Fakir AAA 2"), ZONE:New("Fakir AAA 3")}
    },
    ["shamir_site"] = {
        ["sam"] = {
            ["template_group"] = 'Red SAM SA-2 "Shamir"',
            ["alias"] = "SAM SHAMIR" },
        ["generators"] = {
            ["template_group"] = 'Red SAM SA-2 "Shamir" Generators',
            ["alias"] = "GENERATORS SHAMIR" },
        ["node"] = {
            ["template_static"] = 'Shamir Radio Link',
            ["alias"] = "LINK SHAMIR" },
        ["zones_aaa"] = {ZONE:New("Shamir AAA 1"), ZONE:New("Shamir AAA 2"), ZONE:New("Shamir AAA 3")}
    }
}

sam_alive_data = {}

function spawn_sa2_site(dict_templates)
    sam_alive_data[dict_templates.sam.alias] = {}
    --SAM GROUP
    local sam_group_object = SPAWN:NewWithAlias(dict_templates.sam.template_group, dict_templates.sam.alias)
            :OnSpawnGroup(
                function(SpawnGroup)
                    local sam_name = SpawnGroup:GetName()
                    env.info(string.format("SAM Site -> ' %s ' spawned", sam_name))
                    sam_alive_data[dict_templates.sam.alias]["sam_name"] = sam_name
                end):Spawn()
    --POWER SOURCES
    local sam_generators_group_object = SPAWN:NewWithAlias(dict_templates.generators.template_group, dict_templates.generators.alias)
            :OnSpawnGroup(
                function(SpawnGroup)
                    local generators = SpawnGroup:GetUnits()
                    for i, v in pairs(generators) do
                        local unit_name = v:GetName()
                        env.info(string.format("Power Source -> ' %s ' spawned", unit_name))
                    end
                    sam_alive_data[dict_templates.sam.alias]["generators"] = generators
                end):Spawn()
    --RADIO LINK
    local sam_link_static_object = SPAWN:NewWithAlias(dict_templates.node.template_static, dict_templates.node.alias)
            :OnSpawnGroup(
                function(SpawnGroup)
                    local links = SpawnGroup:GetUnits()
                    for i, v in pairs(links) do
                        local unit_name = v:GetName()
                        env.info(string.format("Connection Node -> ' %s ' spawned", unit_name))
                    end
                    sam_alive_data[dict_templates.sam.alias]["links"] = links
                end):Spawn()
    --AAA PROTECTION
    local list_zones = dict_templates.zones_aaa
    for i, v in pairs(list_zones) do
        local index = random(1, table.getn(red_aaa_templates))
        env.info(string.format("AAA Template index: %d", index))
        red_aaa_templates[index]:SpawnInZone(v, true)
    end
end

--SAMs
if sam_ahmed then
    spawn_sa2_site(red_sam_sites_templates.ahmed_site)
end

if sam_fakir then
    spawn_sa2_site(red_sam_sites_templates.fakir_site)
end

if sam_shamir then
    spawn_sa2_site(red_sam_sites_templates.shamir_site)
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
    local index = random(1, 2)
    red_ewr_templates[index]:SpawnInZone(v, true)
end

for i, v in pairs(mobile_ewr_zones) do
    red_ewr_templates[3]:SpawnInZone(v, true)
end