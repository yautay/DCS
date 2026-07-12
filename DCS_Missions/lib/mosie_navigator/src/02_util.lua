function MosieNavigator:_Log(message)
  env.info("MOSIE_NAVIGATOR: " .. tostring(message))
end

function MosieNavigator:_IsTestMode()
  return TEST_MODE == true
end

function MosieNavigator:_Split(value, separator)
  local result = {}
  local pattern = string.format("([^%s]+)", separator)

  for part in string.gmatch(value, pattern) do
    table.insert(result, part)
  end

  return result
end

function MosieNavigator:_SplitPlain(value, delimiter)
  local result = {}
  local startIndex = 1

  while true do
    local delimiterStart, delimiterEnd = string.find(value, delimiter, startIndex, true)
    if not delimiterStart then
      table.insert(result, string.sub(value, startIndex))
      break
    end

    table.insert(result, string.sub(value, startIndex, delimiterStart - 1))
    startIndex = delimiterEnd + 1
  end

  return result
end

function MosieNavigator:_Join(tokens, startIndex, separator)
  local result = {}

  for index = startIndex, #tokens do
    table.insert(result, tokens[index])
  end

  return table.concat(result, separator)
end

function MosieNavigator:_FormatClock(seconds)
  seconds = seconds % SECONDS_PER_DAY

  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local clockSeconds = seconds % 60

  if clockSeconds == 0 then
    return string.format("%02d:%02d", hours, minutes)
  end

  return string.format("%02d:%02d:%02d", hours, minutes, clockSeconds)
end

function MosieNavigator:_FormatDisplayEta(seconds)
  local rounded = math.floor((seconds or 0) / 60 + 0.5) * 60
  return self:_FormatClock(rounded)
end

function MosieNavigator:_FormatWaypointTypeShort(waypointType)
  local shortcuts = {
    TAKE_OFF = "O",
    LANDING = "L",
    INGRESS = "I",
    TARGET = "T",
    EGRESS = "E",
    NAV = "N",
    HOLD = "H",
  }

  return shortcuts[waypointType] or string.sub(tostring(waypointType or "?"), 1, 1)
end

function MosieNavigator:_FuelGalToLb(gal)
  return (gal or 0) * self.Aircraft.fuel.fuelLbPerGal
end

function MosieNavigator:_FuelLbToGal(lb)
  return (lb or 0) / self.Aircraft.fuel.fuelLbPerGal
end

function MosieNavigator:_BuildDcsFuelRecommendation(requiredGal)
  local fuel = self.Aircraft.fuel
  local internalGal = self:_FuelLbToGal(fuel.internalFuelLb)
  local options = fuel.dropTankOptions or {{ label = "NONE", gal = 0 }}
  local selected = options[#options]

  for _, option in ipairs(options) do
    if requiredGal <= internalGal + option.gal then
      selected = option
      break
    end
  end

  local capacityGal = internalGal + selected.gal
  local internalPercent = 100
  if selected.gal == 0 then
    internalPercent = math.ceil(requiredGal / internalGal * 100) + (fuel.internalFuelBufferPercent or 0)
    if internalPercent > 100 then internalPercent = 100 end
  end

  local marginGal = capacityGal - requiredGal
  return {
    requiredGal = requiredGal,
    requiredLb = self:_FuelGalToLb(requiredGal),
    internalFuelGal = internalGal,
    internalFuelLb = fuel.internalFuelLb,
    internalPercent = internalPercent,
    dropTankLabel = selected.label,
    dropTankGal = selected.gal,
    capacityGal = capacityGal,
    capacityLb = self:_FuelGalToLb(capacityGal),
    marginGal = marginGal,
    marginLb = self:_FuelGalToLb(marginGal),
    marginPercent = capacityGal > 0 and (marginGal / capacityGal * 100) or 0,
    exceedsCapacity = requiredGal > capacityGal,
  }
end

function MosieNavigator:_FormatRolex(seconds)
  if not seconds or seconds == 0 then
    return "+00:00"
  end

  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local clockSeconds = seconds % 60

  if clockSeconds == 0 then
    return string.format("+%02d:%02d", hours, minutes)
  end

  return string.format("+%02d:%02d:%02d", hours, minutes, clockSeconds)
end

function MosieNavigator:_FormatSignedRolex(seconds)
  seconds = seconds or 0
  if seconds >= 0 then
    return self:_FormatRolex(seconds)
  end

  local text = self:_FormatRolex(-seconds)
  return "-" .. string.sub(text, 2)
end

function MosieNavigator:_GetPlanColor(planIndex)
  return self.PlanColors[((planIndex - 1) % #self.PlanColors) + 1]
end

function MosieNavigator:_CopyColor(color)
  return {color[1], color[2], color[3]}
end

function MosieNavigator:_SanitizeFilename(value)
  return string.gsub(tostring(value), "[^%w%-_]+", "_")
end

function MosieNavigator:_GetOutputDirectory()
  if self.Config.flightPlanOutputDirectory then
    return self.Config.flightPlanOutputDirectory
  end

  if lfs and lfs.writedir then
    return lfs.writedir() .. "Logs/"
  end

  return "./"
end

function MosieNavigator:_FormatHeading(heading)
  if not heading then
    return "---"
  end

  return string.format("%03d", math.floor(heading + 0.5) % 360)
end

function MosieNavigator:_FormatMagneticHeading(trueHeading, coordinate)
  if not trueHeading or not coordinate then
    return "---"
  end

  return self:_FormatHeading(trueHeading + self:_GetMagneticVariation(coordinate))
end

function MosieNavigator:_FormatMagneticHeadingWithVariation(trueHeading, magneticVariation)
  if trueHeading == nil or magneticVariation == nil then
    return "---"
  end

  return self:_FormatHeading(trueHeading + magneticVariation)
end

function MosieNavigator:_GetHeadingDelta(fromHeading, toHeading)
  if fromHeading == nil or toHeading == nil then
    return nil
  end

  return ((toHeading - fromHeading + 540) % 360) - 180
end

function MosieNavigator:_FormatSignedDegrees(value)
  if value == nil then
    return "---"
  end

  local rounded = value >= 0 and math.floor(value + 0.5) or math.ceil(value - 0.5)
  return string.format("%+03d", rounded)
end

function MosieNavigator:_GetMagneticVariation(coordinate)
  if not coordinate or not coordinate.GetMagneticDeclination then
    return 0
  end

  return -(coordinate:GetMagneticDeclination() or 0)
end

function MosieNavigator:_KnotsToMph(knots)
  if not knots then
    return nil
  end

  return knots * 1.15077945
end

function MosieNavigator:_FormatOptional(value)
  if value == nil then
    return "---"
  end

  return tostring(value)
end

function MosieNavigator:_FormatWaypointTot(waypoint, rolexSeconds)
  if not waypoint.timeOnTargetSeconds then
    return "---"
  end

  return self:_FormatDisplayEta(waypoint.timeOnTargetSeconds + (rolexSeconds or 0))
end

function MosieNavigator:_FormatSpeed(speedKt)
  if not speedKt then
    return "---"
  end

  return string.format("%.0f", speedKt)
end

function MosieNavigator:_NormalizeHeading(heading)
  return (heading % 360 + 360) % 360
end

function MosieNavigator:_Atan2(y, x)
  if math.atan2 then
    return math.atan2(y, x)
  end

  return math.atan(y, x)
end

function MosieNavigator:_FitText(value, width)
  value = tostring(value or "")

  if string.len(value) > width then
    return string.sub(value, 1, width)
  end

  return value
end


