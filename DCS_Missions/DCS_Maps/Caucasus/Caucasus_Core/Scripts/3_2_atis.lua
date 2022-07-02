-- ###########################################################
-- ###                      ATIS                           ###
-- ###########################################################

AtisVaziani = ATIS:New(AIRBASE.Caucasus.Vaziani, FREQUENCIES.GROUND.atis_vaziani[1])
AtisVaziani:SetRadioRelayUnitName("RELAY-VAZIANI")
AtisVaziani:SetTACAN(22)
AtisVaziani:SetTowerFrequencies({269.00})
AtisVaziani:AddILS(108.75, "13")
AtisVaziani:AddILS(108.75, "31")
AtisVaziani:AddNDBinner(368.00)
AtisVaziani:SetSRS(SRS_PATH, "female", "en-US")
AtisVaziani:SetMapMarks()
AtisVaziani:Start()

AtisKutaisi = ATIS:New(AIRBASE.Caucasus.Kutaisi, FREQUENCIES.GROUND.atis_kutaisi[1])
AtisKutaisi:SetRadioRelayUnitName("RELAY-VAZIANI")
AtisKutaisi:SetTACAN(44)
AtisKutaisi:SetVOR(113.60)
AtisKutaisi:SetTowerFrequencies({263.00})
AtisKutaisi:AddILS(109.75, "07")
AtisKutaisi:SetSRS(SRS_PATH, "female", "en-US")
AtisKutaisi:SetMapMarks()
AtisKutaisi:__Start(5)
