red_ewp_templates = { SPAWN:NewWithAlias("Red EWR 55G6", "EWR G6"),
                      SPAWN:NewWithAlias("Red EWR FPS117", "EWR FPS"),
                      SPAWN:NewWithAlias("Red SR P19", "EWR SR") }

red_aaa_templates = { SPAWN:NewWithAlias("Red ZU23 Ural", "AAA ZU23 Ural"),
                      SPAWN:NewWithAlias("Red ZU23 HL", "AAA ZU23 Toyota"),
                      SPAWN:NewWithAlias("Red ZU57 SP", "AAA ZU57 SP") }

--SAMs
if sam_ahmed then
    local red_sam_sa2_ahmed = SPAWN:NewWithAlias('Red SAM SA-2 "Ahmed"', "SAM AHMED")
    local red_sam_sa2_ahmed_generators = SPAWN:NewWithAlias('Red SAM SA-2 "Ahmed" Generators', "SAM AHMED GENERATORS")
    red_sam_sa2_ahmed:Spawn()
    local aaa_zones = { ZONE:New("Achmed AAA 1"), ZONE:New("Achmed AAA 2"), ZONE:New("Achmed AAA 3") }
    for i, v in pairs(aaa_zones) do
        red_aaa_templates[random(1, table.getn(red_aaa_templates))]:SpawnInZone(v, true)
    end
end

if sam_fakir then
    local red_sam_sa2_fakir = SPAWN:NewWithAlias('Red SAM SA-2 "Fakir"', "SAM FAKIR")
    local red_sam_sa2_fakir_generators = SPAWN:NewWithAlias('Red SAM SA-2 "Fakir" Generators', "SAM FAKIR GENERATORS")
    red_sam_sa2_fakir:Spawn()
    local aaa_zones = { ZONE:New("Fakir AAA 1"), ZONE:New("Fakir AAA 2"), ZONE:New("Fakir AAA 3") }
    for i, v in pairs(aaa_zones) do
        red_aaa_templates[random(1, table.getn(red_aaa_templates))]:SpawnInZone(v, true)
    end
end

if sam_shamir then
    local red_sam_sa2_shamir = SPAWN:NewWithAlias('Red SAM SA-2 "Shamir"', "SAM SHAMIR")
    local red_sam_sa2_shamir_generators = SPAWN:NewWithAlias('Red SAM SA-2 "Shamir" Generators', "SAM SHAMIR GENERATORS")
    red_sam_sa2_shamir:Spawn()
    local aaa_zones = { ZONE:New("Shamir AAA 1"), ZONE:New("Shamir AAA 2"), ZONE:New("Shamir AAA 3") }
    for i, v in pairs(aaa_zones) do
        red_aaa_templates[random(1, table.getn(red_aaa_templates))]:SpawnInZone(v, true)
    end
end
--EWRs
local ewr_zones = { ZONE:New("EWR 1"),
                    ZONE:New("EWR 2"),
                    ZONE:New("EWR 3") }

for i, v in pairs(ewr_zones) do
    red_ewp_templates[random(1, table.getn(red_aaa_templates))]:SpawnInZone(v, true)
end

