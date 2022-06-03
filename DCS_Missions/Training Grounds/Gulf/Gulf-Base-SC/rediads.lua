local debug_rediads = false

function add_sam_site(iads, site_name)
    if (not site) then
        iads:addSAMSite(site_name)
    end
end

function add_ewr_sites(iads, template)
    for k, v in pairs(template) do
        iads:addEarlyWarningRadar(v)
    end
end        

-- local con_cc = StaticObject.getByName("con-cc")
-- local red_cc = StaticObject.getByName("red-cc")

Merad = SkynetIADS:create("MERAD_iads")
Lorad = SkynetIADS:create("LORAD_iads")

add_ewr_sites(Merad, ewr_units)
add_ewr_sites(Merad, awacs_units)
add_ewr_sites(Lorad, ewr_units)
add_ewr_sites(Lorad, awacs_units)


local sa11 = false
local sa20b = false

for k, v in pairs(sam_groups) do
    if (string.find(v, "sa11")) then
      sa11 = true
    elseif (string.find(v, "sa20b")) then
      sa20b = true
    end
end

if (sa20b) then
    add_sam_site(Lorad, sams.sa20b:GetName())
end
if (sa11) then
    add_sam_site(Merad, sams.sa11:GetName())
end       

add_sam_site(Merad, sams.sa3:GetName())
add_sam_site(Merad, sams.sa9:GetName())
add_sam_site(Merad, sams.sa2:GetName())
add_sam_site(Lorad, sams.sa5:GetName())

Lorad:activate()
Merad:activate()

if (debug_rediads) then
    local MeradDebug = Merad:getDebugSettings()
    MeradDebug.IADSStatus = true
    MeradDebug.contacts = false
    MeradDebug.jammerProbability = true
    MeradDebug.addedEWRadar = true
    MeradDebug.addedSAMSite = true
    MeradDebug.warnings = true
    MeradDebug.radarWentLive = true
    MeradDebug.radarWentDark = true
    MeradDebug.harmDefence = true
    MeradDebug.samSiteStatusEnvOutput = true
    MeradDebug.earlyWarningRadarStatusEnvOutput = true
    MeradDebug.commandCenterStatusEnvOutput = true
    local LoradDebug = Lorad:getDebugSettings()
    LoradDebug.IADSStatus = true
    LoradDebug.contacts = false
    LoradDebug.jammerProbability = true
    LoradDebug.addedEWRadar = true
    LoradDebug.addedSAMSite = true
    LoradDebug.warnings = true
    LoradDebug.radarWentLive = true
    LoradDebug.radarWentDark = true
    LoradDebug.harmDefence = true
    LoradDebug.samSiteStatusEnvOutput = true
    LoradDebug.earlyWarningRadarStatusEnvOutput = true
    LoradDebug.commandCenterStatusEnvOutput = true
end
