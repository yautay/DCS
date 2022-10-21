range_bluewater = RANGE:New("Bluewater Range")
zone_bluewater = ZONE_POLYGON:NewFromGroupName("BLUEWATER_RANGE"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)

--RANGE:AddBombingTargets(targetnames: list->unit names, goodhitrange: number, randommove: bool)
local bombtargets={"ASuW-1", "ASuW-2", "ASuW-3"}
range_bluewater:AddBombingTargets(bombtargets, 50)

range_bluewater:SetSRS(SRS_PATH, 5002, 1, FREQUENCIES.RANGE.bluewater[1], FREQUENCIES.RANGE.bluewater[3], 1, nil, "female", "en-US")

--RANGE:SetSRSRangeControl(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_bluewater:SetSRSRangeControl(FREQUENCIES.RANGE.bluewater_con[1], FREQUENCIES.RANGE.bluewater_con[3], nil, nil, female, "RELAY-BLUEWATER-CON")

--RANGE:SetSRSRangeInstructor(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_bluewater:SetSRSRangeInstructor(FREQUENCIES.RANGE.bluewater_inst[1], FREQUENCIES.RANGE.bluewater_inst[3], nil, nil, female, "RELAY-BLUEWATER-INS")

-- Start range.
range_bluewater:TrackBombsON()
range_bluewater:Start()
range_bluewater:SetAutosave()
range_bluewater:SetFunkManOn()