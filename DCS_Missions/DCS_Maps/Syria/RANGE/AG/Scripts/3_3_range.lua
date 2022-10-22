range_bluewater = RANGE:New("Bluewater Range")
zone_bluewater = ZONE_POLYGON:NewFromGroupName("BLUEWATER_RANGE"):DrawZone(2, CONST.RGB.zone_red, 1, CONST.RGB.zone_red, .3, 1, true)
range_bluewater:SetRangeZone( zone_bluewater )

local bombtargets={"ASuW-1", "ASuW-2", "ASuW-3"}
range_bluewater:AddBombingTargets(bombtargets, 50, false)

range_bluewater:SetSRS(
        SRS_PATH,
        SRS_PORT,
        coalition.side.BLU,
        FREQUENCIES.RANGE.bluewater_con[1],
        FREQUENCIES.RANGE.bluewater_con[3],
        1
)

--RANGE:SetSRSRangeControl(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_bluewater:SetSRSRangeControl(
        FREQUENCIES.RANGE.bluewater_con[1],
        FREQUENCIES.RANGE.bluewater_con[3],
        nil,
        "en-US",
        "female",
        "RELAY-BLUEWATER-CON"
)

--RANGE:SetSRSRangeInstructor(frequency: number, modulation: modulation, voice:string, culture:string, gender:string, relayunitname:string)
range_bluewater:SetSRSRangeInstructor(
        FREQUENCIES.RANGE.bluewater_inst[1],
        FREQUENCIES.RANGE.bluewater_inst[3],
        nil,
        "en-US",
        "male",
        "RELAY-BLUEWATER-INS"
)

-- Start range.
range_bluewater:SetDefaultPlayerSmokeBomb(false)
range_bluewater:SetTargetSheet( SHEET_PATH, "RANGE-" )
range_bluewater:SetAutosaveOn()
range_bluewater:SetMessageTimeDuration(10)
range_bluewater:SetFunkManOn()
range_bluewater:Start()
