function MosieNavigator:_Log(message)
  env.info("MOSIE_NAVIGATOR: " .. tostring(message))
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

  local declination = coordinate:GetMagneticDeclination() or 0
  return self:_FormatHeading(trueHeading - declination)
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

  return self:_FormatClock(waypoint.timeOnTargetSeconds + (rolexSeconds or 0))
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


