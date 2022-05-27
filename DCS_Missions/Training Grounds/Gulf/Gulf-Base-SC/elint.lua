HoundBlue = HoundElint:create(coalition.side.BLUE)
HoundBlue:addPlatform("ELINT Hormuz") -- Ground Station
HoundBlue:addPlatform("AWACS Hormuz") -- E-3
HoundBlue:addPlatform("USS Theodore Roosevelt AWACS") -- E-2D
HoundBlue:addPlatform("ELINT South") -- C17

HoundBlue:addSector("Hormuz")
-- HoundBlue:addSector("North Syria")
-- HoundBlue:addSector("South Syria")

local controller_args = {
    freq = "255.500,121.750,35.000",
    modulation = "AM,AM,FM",
    gender = "male"
}
local atis_args = {
    freq = "256.500,122.750",
    modulation = "AM,AM"
}
-- local guard = {
--     243.000AM and 121.500AM
-- }
HoundBlue:enableController("Hormuz",controller_args)
HoundBlue:enableAtis("Hormuz",atis_args)
HoundBlue:enableNotifier("default")

HoundBlue:setTransmitter("Hormuz","AWACS Hormuz")
HoundBlue:enableText("all")

HoundBlue:setZone("Hormuz","Sector Hormuz")

HoundBlue:setMarkerType(HOUND.MARKER.POLYGON)
HoundBlue:enableMarkers()
HoundBlue:enableBDA()
HoundBlue:systemOn()