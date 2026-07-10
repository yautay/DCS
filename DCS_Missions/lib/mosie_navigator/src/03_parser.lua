function MosieNavigator:_ParseTimeOnTarget(value)
  local hours, minutes, seconds = string.match(value or "", "^(%d%d?):(%d%d):(%d%d)$")

  if not hours then
    hours, minutes = string.match(value or "", "^(%d%d?):(%d%d)$")
    seconds = "0"
  end

  if not hours or not minutes then
    return nil
  end

  hours = tonumber(hours)
  minutes = tonumber(minutes)
  seconds = tonumber(seconds ~= "" and seconds or "0")

  if hours > 23 or minutes > 59 or seconds > 59 then
    return nil
  end

  return string.format("%02d:%02d", hours, minutes), hours * 3600 + minutes * 60 + seconds
end

function MosieNavigator:_ParseRolexDuration(value)
  local parts = self:_Split(value or "", ":")

  if #parts == 1 then
    local minutes = tonumber(parts[1])
    if not minutes or minutes < 0 then return nil end
    return minutes * 60
  elseif #parts == 2 then
    local hours = tonumber(parts[1])
    local minutes = tonumber(parts[2])
    if not hours or not minutes or hours < 0 or minutes < 0 or minutes > 59 then
      return nil
    end
    return hours * 3600 + minutes * 60
  elseif #parts == 3 then
    local hours = tonumber(parts[1])
    local minutes = tonumber(parts[2])
    local seconds = tonumber(parts[3])
    if not hours or not minutes or not seconds
       or hours < 0 or minutes < 0 or seconds < 0
       or minutes > 59 or seconds > 59 then
      return nil
    end
    return hours * 3600 + minutes * 60 + seconds
  end

  return nil
end

function MosieNavigator:_ParseWaypointMetadata(metadataTokens)
  local metadata = {}

  for _, token in ipairs(metadataTokens) do
    local upperToken = string.upper(token)
    local altitude = string.match(upperToken, "^A(%-?%d+)$")
      or string.match(upperToken, "^A(%-?%d+)FT$")
    local timeText = string.match(token, "^T(.+)$")
    local speed = string.match(upperToken, "^S(%d+)$")
      or string.match(upperToken, "^S(%d+)KT$")

    if altitude then
      metadata.altitudeFt = tonumber(altitude)
    elseif timeText then
      metadata.timeOnTarget, metadata.timeOnTargetSeconds = self:_ParseTimeOnTarget(timeText)
      if not metadata.timeOnTarget then
        self:_Log("Ignoring invalid waypoint T token: " .. token)
      end
    elseif speed then
      metadata.speedKt = tonumber(speed)
    else
      self:_Log("Ignoring unknown waypoint metadata token: " .. token)
    end
  end

  return metadata
end

function MosieNavigator:_ParseWaypointZoneName(zoneName)
  local zoneParts = self:_SplitPlain(zoneName, "__")
  local tokens = self:_SplitPlain(zoneParts[1], "_")

  if tokens[1] ~= "MN" then
    return nil
  end

  for _, token in ipairs(tokens) do
    if token == "" then
      self:_Log("WARN: empty token in waypoint zone name: " .. zoneName)
      return nil
    end
  end

  local plan = tokens[2]
  local order = tonumber(tokens[3])
  local waypointType = tokens[4]
  local nameStartIndex = 5

  if waypointType == "TAKE" and tokens[5] == "OFF" then
    waypointType = "TAKE_OFF"
    nameStartIndex = 6
  end

  if not plan or not order or not waypointType or not self.WaypointTypes[waypointType] then
    return nil
  end

  local rawName = self:_Join(tokens, nameStartIndex, "_")
  local nameExplicit = rawName ~= ""
  local name = nameExplicit and rawName or waypointType

  local metadataTokens = {}
  for index = 2, #zoneParts do
    table.insert(metadataTokens, zoneParts[index])
  end

  local metadata = self:_ParseWaypointMetadata(metadataTokens)

  return {
    plan = plan,
    order = order,
    type = waypointType,
    name = name,
    nameExplicit = nameExplicit,
    altitudeFt = metadata.altitudeFt,
    speedKt = metadata.speedKt,
    timeOnTarget = metadata.timeOnTarget,
    timeOnTargetSeconds = metadata.timeOnTargetSeconds,
  }
end

function MosieNavigator:_ParseBeaconZoneName(zoneName)
  local tokens = self:_SplitPlain(zoneName, "_")

  if tokens[1] ~= "MNB" or not tokens[2] then
    return nil
  end

  for _, token in ipairs(tokens) do
    if token == "" then
      self:_Log("WARN: empty token in beacon zone name: " .. zoneName)
      return nil
    end
  end

  return {
    id = tokens[2],
    frequency = tokens[3],
    powerNm = self:_ParseNumberWithSuffix(tokens[4], "NM") or self.Config.defaultBeaconPowerNm,
    altitudeFt = self:_ParseNumberWithSuffix(tokens[5], "FT") or self.Config.defaultBeaconAltitudeFt,
  }
end

function MosieNavigator:_ParseNumberWithSuffix(value, suffix)
  if not value then
    return nil
  end

  local numberText = string.match(string.upper(value), "^(%-?%d+%.?%d*)" .. suffix .. "$")
  if not numberText then
    return nil
  end

  return tonumber(numberText)
end
