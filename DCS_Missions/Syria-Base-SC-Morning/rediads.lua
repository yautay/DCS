

local SamSet = SET_GROUP:New():FilterPrefixes("Red SAM SA-2"):FilterStart()   

local red_shorad = SHORAD:New("Red Shorad", "Red SHORAD", SamSet, 25000, 600, "red")

local red_mantis_sa2 = MANTIS:New("Red Mantis SA-2", "Red SAM SA-2", "Red EWR", Red_CC_SA2_Assad, "red", true, "Red AWACS")
local red_mantis_sa3 = MANTIS:New("Red Mantis SA-3", "Red SAM SA-3", "Red EWR", nil , "red", true, "Red AWACS")


red_mantis_sa2:SetSAMRadius(40000)
red_mantis_sa2:SetSAMRange(80)
red_mantis_sa2:AddShorad(red_shorad,300)
red_mantis_sa2:SetDetectInterval(15)
-- red_mantis_sa2:Debug(true)
red_mantis_sa2.verbose = true
red_mantis_sa2:Start()


red_mantis_sa3:SetSAMRadius(30000)
red_mantis_sa3:SetSAMRange(100)
red_mantis_sa3:SetDetectInterval(5)
-- red_mantis_sa3:Debug(true)
red_mantis_sa3.verbose = true
red_mantis_sa3:Start()
