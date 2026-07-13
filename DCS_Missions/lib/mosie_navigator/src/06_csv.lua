function MosieNavigator:_FormatDecimalMinutes(value, positiveHemisphere, negativeHemisphere, degreeWidth)
  local hemisphere = positiveHemisphere
  if value < 0 then
    hemisphere = negativeHemisphere
    value = -value
  end

  local degrees = math.floor(value)
  local minutes = (value - degrees) * 60

  if minutes >= 59.995 then
    degrees = degrees + 1
    minutes = 0
  end

  return string.format("%s%0" .. degreeWidth .. "d %05.2f", hemisphere, degrees, minutes)
end

function MosieNavigator:_FormatCoordinate(coordinate)
  local lat, lon = coordinate:GetLLDDM()
  return self:_FormatDecimalMinutes(lat, "N", "S", 2), self:_FormatDecimalMinutes(lon, "E", "W", 3)
end

function MosieNavigator:_FormatCoordinateForCsvDD(coordinate)
  local lat, lon = coordinate:GetLLDDM()
  return string.format("%.6f", lat), string.format("%.6f", lon)
end

function MosieNavigator:_FormatCsvField(value)
  if value == nil then
    return ""
  end

  local text = tostring(value)
  if string.find(text, "[,\"\n\r]") then
    return "\"" .. string.gsub(text, "\"", "\"\"") .. "\""
  end

  return text
end

function MosieNavigator:_FormatCsvRow(fields)
  local escaped = {}
  for index, value in ipairs(fields) do
    escaped[index] = self:_FormatCsvField(value)
  end
  return table.concat(escaped, ",")
end

function MosieNavigator:_FormatTotForCsv(waypoint)
  local seconds = waypoint and waypoint.timeOnTargetSeconds
  if not seconds then
    return ""
  end

  return self:_FormatDisplayEta(seconds)
end

function MosieNavigator:_FormatRadiusForCsv(waypoint)
  if not waypoint or waypoint.radiusM == nil then
    return ""
  end
  return string.format("%.0f", waypoint.radiusM)
end

function MosieNavigator:_BuildFlightPlanCsv(plan, groupName, rolexSeconds)
  local lines = {}

  table.insert(lines, "# PLAN," .. self:_FormatCsvField(plan.name))
  table.insert(lines, "ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT,PASS_RADIUS_M")

  for _, waypoint in ipairs(plan.waypoints or {}) do
    local lat, lon = self:_FormatCoordinateForCsvDD(waypoint.coordinate)
    local nameField   = waypoint.nameExplicit and waypoint.name or ""
    local altField    = waypoint.altitudeFt ~= nil and tostring(waypoint.altitudeFt) or ""
    local totField    = self:_FormatTotForCsv(waypoint)
    local speedField  = waypoint.speedKt ~= nil and string.format("%.0f", waypoint.speedKt) or ""
    local radiusField = self:_FormatRadiusForCsv(waypoint)

    table.insert(lines, self:_FormatCsvRow({
      waypoint.order,
      waypoint.type,
      nameField,
      lat,
      lon,
      altField,
      totField,
      speedField,
      radiusField,
    }))
  end

  return table.concat(lines, "\n") .. "\n"
end

function MosieNavigator:_BuildBeaconsCsv(beacons)
  local lines = {}

  table.insert(lines, "ID,FREQUENCY,POWER_NM,ALT_FT,LAT,LON")

  for _, beacon in ipairs(beacons) do
    local lat, lon = self:_FormatCoordinateForCsvDD(beacon.coordinate)
    local frequencyField = beacon.frequency or ""

    table.insert(lines, self:_FormatCsvRow({
      beacon.id,
      frequencyField,
      beacon.powerNm,
      beacon.altitudeFt,
      lat,
      lon,
    }))
  end

  return table.concat(lines, "\n") .. "\n"
end
