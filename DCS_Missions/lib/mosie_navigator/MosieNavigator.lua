local SECONDS_PER_DAY = 86400
local SECONDS_PER_HALF_DAY = 43200

MosieNavigator = MosieNavigator or {}

MosieNavigator.Config = MosieNavigator.Config or {
  flightZonePrefix = "MN_",
  beaconZonePrefix = "MNB_",
  coalition = -1,
  readOnly = true,
  waypointLineAlpha = 0.95,
  waypointFillAlpha = 0.25,
  beaconLineAlpha = 0.85,
  beaconFillAlpha = 0.22,
  defaultBeaconPowerNm = 60,
  defaultBeaconAltitudeFt = 0,
  defaultWaypointRadiusM = 250,
  generateFlightPlanFiles = true,
  generateCsvFiles = true,
  flightPlanOutputDirectory = nil,
  groupPlanTagPattern = "%[MN:([%w%-]+)%]",
  menuName = "Mosie Navigator",
  flightPlanMessageDuration = 30,
  menuRefreshDelay = 5,
  menuRefreshInterval = 15,
  navigatorTickInterval = 5,
  navigatorReportIntervalDefault = 120,
  navigatorReportIntervals = {30, 60, 120, 300},
  navigatorMessageDuration = 20,
  navigatorCalloutSeconds = {60, 30},
  navigatorXteStepNm = 1,
}

MosieNavigator.WaypointTypes = {
  TAKE_OFF = true,
  LANDING = true,
  RENDEZVOUS = true,
  INGRESS = true,
  TARGET = true,
  EGRESS = true,
  NAV = true,
  HOLD = true,
}

MosieNavigator.PlanColors = {
  {0.20, 0.60, 1.00},
  {1.00, 0.55, 0.10},
  {0.30, 0.90, 0.35},
  {0.90, 0.30, 0.90},
  {1.00, 0.90, 0.20},
  {0.15, 0.90, 0.90},
  {1.00, 0.25, 0.25},
}

MosieNavigator.BeaconColor = {0.20, 0.80, 0.20}

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
  local hours = 0
  local minutes = 0
  local seconds = 0

  if #parts == 1 then
    minutes = tonumber(parts[1])
  elseif #parts == 2 then
    hours = tonumber(parts[1])
    minutes = tonumber(parts[2])
  elseif #parts == 3 then
    hours = tonumber(parts[1])
    minutes = tonumber(parts[2])
    seconds = tonumber(parts[3])
  else
    return nil
  end

  if not hours or not minutes or not seconds or minutes > 59 or seconds > 59 then
    return nil
  end

  return hours * 3600 + minutes * 60 + seconds
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

function MosieNavigator:_ParseWaypointMetadata(metadataTokens)
  local metadata = {}

  for _, token in ipairs(metadataTokens) do
    local upperToken = string.upper(token)
    local altitude = string.match(upperToken, "^A(%-?%d+)$")
      or string.match(upperToken, "^A(%-?%d+)FT$")
      or string.match(upperToken, "^ALT(%-?%d+)$")
      or string.match(upperToken, "^ALT(%-?%d+)FT$")
    local timeText = string.match(token, "^TOT(.+)$") or string.match(token, "^T(.+)$")

    if altitude then
      metadata.altitudeFt = tonumber(altitude)
    elseif timeText then
      metadata.timeOnTarget, metadata.timeOnTargetSeconds = self:_ParseTimeOnTarget(timeText)
      if not metadata.timeOnTarget then
        self:_Log("Ignoring invalid waypoint TOT token: " .. token)
      end
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

function MosieNavigator:_ConvertTasToIas(tasKt, altitudeFt)
  if not tasKt or not altitudeFt then
    return nil
  end

  local altitudeM = UTILS.FeetToMeters(altitudeFt)
  local temperatureRatio = 1 - (0.0065 * altitudeM / 288.15)
  if temperatureRatio <= 0 then
    return nil
  end

  local densityRatio = temperatureRatio ^ 4.25588
  return tasKt * math.sqrt(densityRatio)
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

function MosieNavigator:_CalculateWindCorrectedGuidance(groupCoordinate, waypoint, secondsToTot, altitudeFt)
  local distanceNm = UTILS.MetersToNM(groupCoordinate:Get2DDistance(waypoint.coordinate))
  local trackTrue = groupCoordinate:HeadingTo(waypoint.coordinate)

  if not secondsToTot or secondsToTot <= 0 then
    return trackTrue, nil, nil
  end

  local requiredGroundSpeedKt = distanceNm / (secondsToTot / 3600)
  local requiredGroundSpeedMps = UTILS.KnotsToMps(requiredGroundSpeedKt)
  local trackRadians = math.rad(trackTrue)
  local groundVectorX = math.sin(trackRadians) * requiredGroundSpeedMps
  local groundVectorZ = math.cos(trackRadians) * requiredGroundSpeedMps
  local windVector = groupCoordinate:GetWindVec3(UTILS.FeetToMeters(altitudeFt or 0)) or {x = 0, z = 0}
  local airVectorX = groundVectorX - (windVector.x or 0)
  local airVectorZ = groundVectorZ - (windVector.z or 0)
  local requiredTas = UTILS.MpsToKnots(math.sqrt(airVectorX * airVectorX + airVectorZ * airVectorZ))
  local headingTrue = self:_NormalizeHeading(math.deg(self:_Atan2(airVectorX, airVectorZ)))
  local requiredIas = self:_ConvertTasToIas(requiredTas, altitudeFt)

  return headingTrue, requiredTas, requiredIas
end

function MosieNavigator:_CalculateXte(previousWaypoint, waypoint, groupCoordinate)
  if not previousWaypoint or not waypoint then
    return nil, nil
  end

  local startVec = previousWaypoint.coordinate:GetVec3()
  local endVec = waypoint.coordinate:GetVec3()
  local currentVec = groupCoordinate:GetVec3()
  local legX = endVec.x - startVec.x
  local legZ = endVec.z - startVec.z
  local legLength = math.sqrt(legX * legX + legZ * legZ)

  if legLength <= 0 then
    return nil, nil
  end

  local currentX = currentVec.x - startVec.x
  local currentZ = currentVec.z - startVec.z
  local cross = legX * currentZ - legZ * currentX
  local xteNm = UTILS.MetersToNM(math.abs(cross / legLength))
  local side = cross > 0 and "port" or "stbd"

  return xteNm, side
end

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

  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local clockSeconds = seconds % 60

  if clockSeconds == 0 then
    return string.format("%02d:%02d", hours, minutes)
  end

  return string.format("%02d:%02d:%02d", hours, minutes, clockSeconds)
end

function MosieNavigator:_FitText(value, width)
  value = tostring(value or "")

  if string.len(value) > width then
    return string.sub(value, 1, width)
  end

  return value
end

function MosieNavigator:_CalculateLegSpeedKnots(previousWaypoint, waypoint, legDistanceNm)
  if not previousWaypoint or not previousWaypoint.timeOnTargetSeconds or not waypoint.timeOnTargetSeconds then
    return nil
  end

  local deltaSeconds = waypoint.timeOnTargetSeconds - previousWaypoint.timeOnTargetSeconds
  if deltaSeconds < 0 then
    deltaSeconds = deltaSeconds + SECONDS_PER_DAY
  end

  if deltaSeconds <= 0 then
    return nil
  end

  return legDistanceNm / (deltaSeconds / 3600)
end

function MosieNavigator:_ExtractPlanFromGroupName(groupName)
  return string.match(groupName, self.Config.groupPlanTagPattern)
end

function MosieNavigator:_ExtractRolexFromGroupName(groupName)
  local rolexText = string.match(groupName, "__[Rr]([%d:]+)")
  if not rolexText then
    return 0
  end

  local rolexSeconds = self:_ParseRolexDuration(rolexText)
  if not rolexSeconds then
    self:_Log("Ignoring invalid group ROLEX token: __R" .. rolexText)
    return 0
  end

  return rolexSeconds
end

function MosieNavigator:_DiscoverGroupAssignments(plans)
  local assignments = {}
  self.InactiveGroupLogs = self.InactiveGroupLogs or {}

  local groupSet = SET_GROUP:New():FilterStart()

  groupSet:ForEachGroup(function(group)
    local groupName = group:GetName()
    local planName = self:_ExtractPlanFromGroupName(groupName)
    local rolexSeconds = self:_ExtractRolexFromGroupName(groupName)

    if planName then
      if plans[planName] then
        if group:IsAlive() then
          table.insert(assignments, {
            groupName = groupName,
            group = group,
            planName = planName,
            plan = plans[planName],
            rolexSeconds = rolexSeconds,
          })
        else
          if not self.InactiveGroupLogs[groupName] then
            self:_Log(string.format("group %s references plan %s but is not active yet", groupName, planName))
            self.InactiveGroupLogs[groupName] = true
          end
        end
      else
        self:_Log(string.format("group %s references missing plan %s", groupName, planName))
      end
    end
  end)

  return assignments
end

function MosieNavigator:_AddMarker(markId)
  if markId then
    table.insert(self.MarkIds, markId)
  end
end

function MosieNavigator:_DiscoverZones()
  local plans = {}
  local beacons = {}
  local zoneSet = SET_ZONE:New():FilterPrefixes({self.Config.flightZonePrefix, self.Config.beaconZonePrefix}):FilterStart()

  zoneSet:ForEachZone(function(zone)
    local zoneName = zone:GetName()
    local waypoint = self:_ParseWaypointZoneName(zoneName)

    if waypoint then
      waypoint.zoneName = zoneName
      waypoint.zone = zone
      waypoint.coordinate = zone:GetCoordinate()
      plans[waypoint.plan] = plans[waypoint.plan] or {name = waypoint.plan, waypoints = {}}
      table.insert(plans[waypoint.plan].waypoints, waypoint)
      return
    end

    local beacon = self:_ParseBeaconZoneName(zoneName)
    if beacon then
      beacon.zoneName = zoneName
      beacon.zone = zone
      beacon.coordinate = zone:GetCoordinate()
      table.insert(beacons, beacon)
      return
    end

    self:_Log("Ignoring malformed navigator zone: " .. zoneName)
  end)

  for _, plan in pairs(plans) do
    local seenOrders = {}
    for _, waypoint in ipairs(plan.waypoints) do
      local existing = seenOrders[waypoint.order]
      if existing then
        self:_Log(string.format(
          "WARN: plan %s has duplicate order %d: %s vs %s",
          plan.name, waypoint.order, existing.zoneName, waypoint.zoneName
        ))
      end
      seenOrders[waypoint.order] = waypoint
    end

    table.sort(plan.waypoints, function(a, b)
      return a.order < b.order
    end)
  end

  return plans, beacons
end

function MosieNavigator:_DrawWaypoint(plan, waypoint, color)
  local label = string.format("MN %s %02d %s\n%s", waypoint.plan, waypoint.order, waypoint.type, waypoint.name)
  local radius = self.Config.defaultWaypointRadiusM

  if waypoint.zone.GetRadius then
    radius = waypoint.zone:GetRadius()
  end

  self:_AddMarker(waypoint.coordinate:CircleToAll(
    radius,
    self.Config.coalition,
    self:_CopyColor(color),
    self.Config.waypointLineAlpha,
    self:_CopyColor(color),
    self.Config.waypointFillAlpha,
    1,
    self.Config.readOnly,
    label
  ))

  self:_AddMarker(waypoint.coordinate:TextToAll(
    string.format("%s %02d %s", waypoint.plan, waypoint.order, waypoint.name),
    self.Config.coalition,
    self:_CopyColor(color),
    1,
    {0, 0, 0},
    0.0,
    12,
    self.Config.readOnly
  ))
end

function MosieNavigator:_DrawPlan(plan, color)
  for index, waypoint in ipairs(plan.waypoints) do
    self:_DrawWaypoint(plan, waypoint, color)

    local nextWaypoint = plan.waypoints[index + 1]
    if nextWaypoint then
      self:_AddMarker(waypoint.coordinate:LineToAll(
        nextWaypoint.coordinate,
        self.Config.coalition,
        self:_CopyColor(color),
        self.Config.waypointLineAlpha,
        1,
        self.Config.readOnly,
        string.format("MN %s %02d-%02d", plan.name, waypoint.order, nextWaypoint.order)
      ))
    end
  end
end

function MosieNavigator:_DrawBeacon(beacon)
  local radius = UTILS.NMToMeters(beacon.powerNm)
  local label = string.format("MNB %s", beacon.id)

  if beacon.frequency then
    label = label .. string.format("\n%s", beacon.frequency)
  end

  label = label .. string.format("\nRange %d NM", beacon.powerNm)

  if beacon.altitudeFt then
    label = label .. string.format("\nAlt %d ft", beacon.altitudeFt)
  end

  self:_AddMarker(beacon.coordinate:CircleToAll(
    radius,
    self.Config.coalition,
    self:_CopyColor(self.BeaconColor),
    self.Config.beaconLineAlpha,
    self:_CopyColor(self.BeaconColor),
    self.Config.beaconFillAlpha,
    2,
    self.Config.readOnly,
    label
  ))

  self:_AddMarker(beacon.coordinate:TextToAll(
    label,
    self.Config.coalition,
    self:_CopyColor(self.BeaconColor),
    1,
    {0, 0, 0},
    0.0,
    13,
    self.Config.readOnly
  ))
end

function MosieNavigator:_SendNavigatorMessage(group, text, duration)
  MESSAGE:New(text, duration or self.Config.navigatorMessageDuration, "Mosie Navigator"):ToGroup(group)
end

function MosieNavigator:_GetGroupKey(group)
  return group:GetName()
end

function MosieNavigator:_GetInitialNavigatorWpIndex(plan)
  for index, waypoint in ipairs(plan.waypoints) do
    if waypoint.type ~= "TAKE_OFF" then
      return index
    end
  end

  return 1
end

function MosieNavigator:_GetInitialNavigatorWpIndexByTot(plan, rolexSeconds)
  for index, waypoint in ipairs(plan.waypoints) do
    local secondsToTot = self:_GetSecondsToWaypointTot(waypoint, rolexSeconds or 0)
    if secondsToTot and secondsToTot > 0 and waypoint.type ~= "TAKE_OFF" then
      return index
    end
  end

  return self:_GetInitialNavigatorWpIndex(plan)
end

function MosieNavigator:_GetNavigatorState(group, plan, rolexSeconds)
  self.NavigatorStates = self.NavigatorStates or {}

  local groupKey = self:_GetGroupKey(group)
  local state = self.NavigatorStates[groupKey]

  if not state then
    state = {
      enabled = false,
      group = group,
      groupName = groupKey,
      plan = plan,
      rolexSeconds = rolexSeconds or 0,
      currentWpIndex = self:_GetInitialNavigatorWpIndex(plan),
      reportInterval = self.Config.navigatorReportIntervalDefault,
      lastReportTime = nil,
      callouts = {},
    }
    self.NavigatorStates[groupKey] = state
  end

  state.group = group
  state.plan = plan
  state.rolexSeconds = rolexSeconds or 0
  return state
end

function MosieNavigator:_GetAdjustedTotSeconds(waypoint, rolexSeconds)
  if not waypoint.timeOnTargetSeconds then
    return nil
  end

  return (waypoint.timeOnTargetSeconds + (rolexSeconds or 0)) % SECONDS_PER_DAY
end

function MosieNavigator:_GetSecondsToWaypointTot(waypoint, rolexSeconds)
  local adjustedTot = self:_GetAdjustedTotSeconds(waypoint, rolexSeconds)
  if not adjustedTot then
    return nil
  end

  local now = timer.getAbsTime() % SECONDS_PER_DAY
  local delta = adjustedTot - now

  if delta < -SECONDS_PER_HALF_DAY then
    delta = delta + SECONDS_PER_DAY
  elseif delta > SECONDS_PER_HALF_DAY then
    delta = delta - SECONDS_PER_DAY
  end

  return delta
end

function MosieNavigator:_FormatDuration(seconds)
  if not seconds then
    return "--"
  end

  local prefix = ""
  if seconds < 0 then
    prefix = "-"
    seconds = -seconds
  end

  local minutes = math.floor(seconds / 60)
  local remainingSeconds = seconds % 60
  return string.format("%s%d:%02d", prefix, minutes, remainingSeconds)
end

function MosieNavigator:_BuildNavigatorStatusMessage(state, reason)
  local group = state.group
  local plan = state.plan
  local waypoint = plan.waypoints[state.currentWpIndex]

  if not waypoint then
    return "NAV: no active waypoint"
  end

  local groupCoordinate = group:GetCoordinate()
  local distanceNm = UTILS.MetersToNM(groupCoordinate:Get2DDistance(waypoint.coordinate))
  local trueCourse = groupCoordinate:HeadingTo(waypoint.coordinate)
  local secondsToTot = self:_GetSecondsToWaypointTot(waypoint, state.rolexSeconds)
  local altitudeFt = UTILS.MetersToFeet(group:GetAltitude(false) or 0)
  local headingTrue, requiredTas, requiredIas = self:_CalculateWindCorrectedGuidance(groupCoordinate, waypoint, secondsToTot, altitudeFt)
  local headingMagnetic = self:_FormatMagneticHeading(headingTrue, groupCoordinate)
  local currentIas = self:_ConvertTasToIas(group:GetVelocityKNOTS(), altitudeFt)
  local speedText = "spd ---"
  local previousWaypoint = state.plan.waypoints[state.currentWpIndex - 1]
  local xteNm, xteSide = self:_CalculateXte(previousWaypoint, waypoint, groupCoordinate)
  local xteText = "XTE ---"

  if requiredIas and currentIas then
    local delta = currentIas - requiredIas
    if math.abs(delta) <= 5 then
      speedText = "on speed"
    elseif delta > 0 then
      speedText = string.format("fast %.0f", delta)
    else
      speedText = string.format("slow %.0f", -delta)
    end
  end

  if xteNm and xteNm >= self.Config.navigatorXteStepNm then
    xteText = string.format("XTE %.0f %s", math.floor(xteNm + 0.5), xteSide)
  end

  local prefix = reason and ("NAV " .. reason .. ": ") or "NAV: "
  return string.format(
    "%sWP%02d %s, T-%s, TRK %sT, HDG %sM, TAS %s kt, IAS %s kt, %s, %s, DIST %.1f NM",
    prefix,
    waypoint.order,
    waypoint.name,
    self:_FormatDuration(secondsToTot),
    self:_FormatHeading(trueCourse),
    headingMagnetic,
    self:_FormatSpeed(requiredTas),
    self:_FormatSpeed(requiredIas),
    speedText,
    xteText,
    distanceNm
  )
end

function MosieNavigator:_ResetNavigatorCallouts(state)
  state.callouts = {}
  for _, calloutSeconds in ipairs(self.Config.navigatorCalloutSeconds) do
    state.callouts[calloutSeconds] = false
  end
end

function MosieNavigator:_SetNavigatorWaypoint(state, index, reason)
  if index < 1 or index > #state.plan.waypoints then
    return
  end

  state.currentWpIndex = index
  state.lastReportTime = timer.getTime()
  self:_ResetNavigatorCallouts(state)
  self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, reason or "WP change"))
end

function MosieNavigator:_AdvanceNavigatorWaypoint(state, reason)
  if state.currentWpIndex < #state.plan.waypoints then
    self:_SetNavigatorWaypoint(state, state.currentWpIndex + 1, reason or "next WP")
  end
end

function MosieNavigator:_SetNavigatorEnabled(group, plan, rolexSeconds, enabled)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds)
  state.enabled = enabled

  if enabled then
    state.currentWpIndex = self:_GetInitialNavigatorWpIndexByTot(plan, rolexSeconds)
    self:_ResetNavigatorCallouts(state)
    self:_SendNavigatorMessage(group, self:_BuildNavigatorStatusMessage(state, "on"))
  else
    self:_SendNavigatorMessage(group, "NAV off")
  end
end

function MosieNavigator:_SetNavigatorReportInterval(group, plan, rolexSeconds, interval)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds)
  state.reportInterval = interval
  self:_SendNavigatorMessage(group, string.format("NAV report interval %d sec", interval))
end

function MosieNavigator:_NavigatorStatusNow(group, plan, rolexSeconds)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds)
  self:_SendNavigatorMessage(group, self:_BuildNavigatorStatusMessage(state, "status"))
end

function MosieNavigator:_TickNavigatorState(state)
  if not state.enabled or not state.group:IsAlive() then
    return
  end

  local waypoint = state.plan.waypoints[state.currentWpIndex]
  if not waypoint then
    return
  end

  local secondsToTot = self:_GetSecondsToWaypointTot(waypoint, state.rolexSeconds)
  local now = timer.getTime()

  if secondsToTot then
    for _, calloutSeconds in ipairs(self.Config.navigatorCalloutSeconds) do
      if secondsToTot <= calloutSeconds and secondsToTot > 0 and not state.callouts[calloutSeconds] then
        state.callouts[calloutSeconds] = true
        self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, string.format("%d sec", calloutSeconds)))
      end
    end

    if secondsToTot <= 0 and state.currentWpIndex < #state.plan.waypoints then
      self:_AdvanceNavigatorWaypoint(state, "new WP")
      return
    end
  end

  if not state.lastReportTime or now - state.lastReportTime >= state.reportInterval then
    state.lastReportTime = now
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, "report"))
  end
end

function MosieNavigator:_StartNavigatorScheduler()
  if self.NavigatorScheduler then
    return
  end

  self.NavigatorScheduler = SCHEDULER:New(nil, function()
    MosieNavigator:TickNavigators()
  end, {}, self.Config.navigatorTickInterval, self.Config.navigatorTickInterval)

  self:_Log(string.format("navigator tick scheduled every %d seconds", self.Config.navigatorTickInterval))
end

function MosieNavigator:TickNavigators()
  if not self.NavigatorStates then
    return
  end

  for _, state in pairs(self.NavigatorStates) do
    self:_TickNavigatorState(state)
  end
end

function MosieNavigator:_ComputeLegMetrics(plan, index)
  local waypoint = plan.waypoints[index]
  local previousWaypoint = plan.waypoints[index - 1]
  local nextWaypoint = plan.waypoints[index + 1]
  local metrics = {
    legDistanceNm = nil,
    legSpeedKnots = nil,
    legIasKnots = nil,
    trueCourse = nil,
  }

  if previousWaypoint then
    metrics.legDistanceNm = UTILS.MetersToNM(previousWaypoint.coordinate:Get2DDistance(waypoint.coordinate))
    metrics.legSpeedKnots = self:_CalculateLegSpeedKnots(previousWaypoint, waypoint, metrics.legDistanceNm)
    metrics.legIasKnots = self:_ConvertTasToIas(metrics.legSpeedKnots, waypoint.altitudeFt)
  end

  if nextWaypoint then
    metrics.trueCourse = waypoint.coordinate:HeadingTo(nextWaypoint.coordinate)
  end

  return metrics
end

function MosieNavigator:_BuildSimplifiedFlightPlanMessage(plan, groupName, rolexSeconds)
  local lines = {}
  local totalDistanceNm = 0
  rolexSeconds = rolexSeconds or 0

  table.insert(lines, "MOSIE NAVIGATOR")
  table.insert(lines, "PLAN  : " .. plan.name)
  table.insert(lines, "GROUP : " .. groupName)
  if rolexSeconds ~= 0 then
    table.insert(lines, "ROLEX : " .. self:_FormatRolex(rolexSeconds))
  end
  table.insert(lines, "")

  for index, waypoint in ipairs(plan.waypoints) do
    local metrics = self:_ComputeLegMetrics(plan, index)
    if metrics.legDistanceNm then
      totalDistanceNm = totalDistanceNm + metrics.legDistanceNm
    end

    table.insert(lines, string.format(
      "[%02d] %s %s: ALT %s ft, TOT %s, CRS %sT/%sM, LEG %s NM, TAS %s kt, IAS %s kt, DIST %.1f NM",
      waypoint.order,
      self:_FitText(waypoint.type, 10),
      self:_FitText(waypoint.name, 12),
      self:_FormatOptional(waypoint.altitudeFt),
      self:_FormatWaypointTot(waypoint, rolexSeconds),
      self:_FormatHeading(metrics.trueCourse),
      self:_FormatMagneticHeading(metrics.trueCourse, waypoint.coordinate),
      metrics.legDistanceNm and string.format("%.1f", metrics.legDistanceNm) or "---",
      self:_FormatSpeed(metrics.legSpeedKnots),
      self:_FormatSpeed(metrics.legIasKnots),
      totalDistanceNm
    ))
  end

  return table.concat(lines, "\n")
end

function MosieNavigator:_ShowFlightPlanForGroup(group, plan, rolexSeconds)
  if not group or not plan then
    return
  end

  local text = self:_BuildSimplifiedFlightPlanMessage(plan, group:GetName(), rolexSeconds)
  MESSAGE:New(text, self.Config.flightPlanMessageDuration, "Mosie Navigator"):ToGroup(group)
end

function MosieNavigator:_CreateGroupMenus(plans)
  self.MenusCreated = self.MenusCreated or {}

  local assignments = self:_DiscoverGroupAssignments(plans)
  local createdCount = 0

  for _, assignment in ipairs(assignments) do
    local group = assignment.group
    local plan = assignment.plan
    local menuKey = assignment.groupName .. "::" .. assignment.planName

    if not self.MenusCreated[menuKey] then
      local rootMenu = MENU_GROUP:New(group, self.Config.menuName)
      MENU_GROUP_COMMAND:New(group, "Show FP", rootMenu, function()
        MosieNavigator:_ShowFlightPlanForGroup(group, plan, assignment.rolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Navigator On", rootMenu, function()
        MosieNavigator:_SetNavigatorEnabled(group, plan, assignment.rolexSeconds, true)
      end)
      MENU_GROUP_COMMAND:New(group, "Navigator Off", rootMenu, function()
        MosieNavigator:_SetNavigatorEnabled(group, plan, assignment.rolexSeconds, false)
      end)
      MENU_GROUP_COMMAND:New(group, "Status Now", rootMenu, function()
        MosieNavigator:_NavigatorStatusNow(group, plan, assignment.rolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Next WP", rootMenu, function()
        local state = MosieNavigator:_GetNavigatorState(group, plan, assignment.rolexSeconds)
        MosieNavigator:_AdvanceNavigatorWaypoint(state, "manual WP")
      end)
      MENU_GROUP_COMMAND:New(group, "Prev WP", rootMenu, function()
        local state = MosieNavigator:_GetNavigatorState(group, plan, assignment.rolexSeconds)
        MosieNavigator:_SetNavigatorWaypoint(state, state.currentWpIndex - 1, "manual WP")
      end)

      local intervalMenu = MENU_GROUP:New(group, "Report Interval", rootMenu)
      for _, interval in ipairs(self.Config.navigatorReportIntervals) do
        MENU_GROUP_COMMAND:New(group, string.format("%d sec", interval), intervalMenu, function(reportInterval)
          MosieNavigator:_SetNavigatorReportInterval(group, plan, assignment.rolexSeconds, reportInterval)
        end, interval)
      end

      self.MenusCreated[menuKey] = true
      createdCount = createdCount + 1
    end
  end

  if createdCount > 0 then
    self:_Log(string.format("created navigation menu for %d assigned groups", createdCount))
  end
end

function MosieNavigator:RefreshMenus()
  if not self.Plans then
    return
  end

  self:_CreateGroupMenus(self.Plans)
end

function MosieNavigator:_StartMenuRefreshScheduler()
  if self.MenuRefreshScheduler then
    return
  end

  self.MenuRefreshScheduler = SCHEDULER:New(nil, function()
    MosieNavigator:RefreshMenus()
  end, {}, self.Config.menuRefreshDelay, self.Config.menuRefreshInterval)

  self:_Log(string.format(
    "menu refresh scheduled every %d seconds",
    self.Config.menuRefreshInterval
  ))
end

function MosieNavigator:_BuildFlightPlanTable(plan, groupName, rolexSeconds)
  local lines = {}
  local totalDistanceNm = 0
  rolexSeconds = rolexSeconds or 0

  table.insert(lines, "MOSIE NAVIGATOR FLIGHT PLAN")
  table.insert(lines, "PLAN: " .. plan.name)
  if groupName then
    table.insert(lines, "GROUP: " .. groupName)
  end
  if rolexSeconds ~= 0 then
    table.insert(lines, "ROLEX: " .. self:_FormatRolex(rolexSeconds))
  end
  table.insert(lines, "")
  table.insert(lines, string.format(
    "%-2s %-10s %-12s %10s %11s %5s %-5s %5s %5s %6s %6s %6s %6s",
    "NO",
    "TYPE",
    "NAME",
    "LAT",
    "LON",
    "ALTFT",
    "TOT",
    "CRS_T",
    "CRS_M",
    "LEG",
    "TAS",
    "IAS",
    "DIST"
  ))
  table.insert(lines, string.rep("-", 100))

  for index, waypoint in ipairs(plan.waypoints) do
    local metrics = self:_ComputeLegMetrics(plan, index)
    local legDistanceNm = metrics.legDistanceNm or 0
    totalDistanceNm = totalDistanceNm + legDistanceNm

    local lat, lon = self:_FormatCoordinate(waypoint.coordinate)

    table.insert(lines, string.format(
      "%02d %-10s %-12s %10s %11s %5s %-5s %5s %5s %6.1f %6s %6s %6.1f",
      waypoint.order,
      self:_FitText(waypoint.type, 10),
      self:_FitText(waypoint.name, 12),
      lat,
      lon,
      self:_FormatOptional(waypoint.altitudeFt),
      self:_FormatWaypointTot(waypoint, rolexSeconds),
      self:_FormatHeading(metrics.trueCourse),
      self:_FormatMagneticHeading(metrics.trueCourse, waypoint.coordinate),
      legDistanceNm,
      self:_FormatSpeed(metrics.legSpeedKnots),
      self:_FormatSpeed(metrics.legIasKnots),
      totalDistanceNm
    ))
  end

  table.insert(lines, "")
  table.insert(lines, string.format("TOTAL_DISTANCE_NM: %.1f", totalDistanceNm))

  return table.concat(lines, "\n") .. "\n"
end

function MosieNavigator:_BuildFlightPlanCsv(plan, groupName, rolexSeconds)
  local lines = {}
  rolexSeconds = rolexSeconds or 0

  table.insert(lines, "# PLAN," .. self:_FormatCsvField(plan.name))
  if groupName then
    table.insert(lines, "# GROUP," .. self:_FormatCsvField(groupName))
  end
  if rolexSeconds ~= 0 then
    table.insert(lines, "# ROLEX_SEC," .. tostring(rolexSeconds))
  end

  table.insert(lines, "ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT")

  for _, waypoint in ipairs(plan.waypoints) do
    local lat, lon = self:_FormatCoordinateForCsvDD(waypoint.coordinate)
    local nameField = waypoint.nameExplicit and waypoint.name or ""
    local altField = waypoint.altitudeFt ~= nil and tostring(waypoint.altitudeFt) or ""
    local totField = self:_FormatTotForCsv(waypoint)

    table.insert(lines, self:_FormatCsvRow({
      waypoint.order,
      waypoint.type,
      nameField,
      lat,
      lon,
      altField,
      totField,
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

function MosieNavigator:_WriteFlightPlanFile(plan, groupName, rolexSeconds)
  if not io then
    self:_Log("cannot write flight plan file: io is not available")
    return
  end

  local outputDirectory = self:_GetOutputDirectory()
  local filename = nil

  if groupName then
    filename = string.format("MosieNavigator_%s_%s.txt", self:_SanitizeFilename(groupName), self:_SanitizeFilename(plan.name))
  else
    filename = string.format("MosieNavigator_%s.txt", self:_SanitizeFilename(plan.name))
  end

  local path = outputDirectory .. filename
  local file = io.open(path, "w")

  if not file then
    self:_Log("cannot write flight plan file: " .. path)
    return
  end

  file:write(self:_BuildFlightPlanTable(plan, groupName, rolexSeconds))
  file:close()

  self:_Log("wrote flight plan file: " .. path)
end

function MosieNavigator:_WriteFlightPlanCsvFile(plan, groupName, rolexSeconds)
  if not io then
    self:_Log("cannot write flight plan CSV file: io is not available")
    return
  end

  local outputDirectory = self:_GetOutputDirectory()
  local filename = nil

  if groupName then
    filename = string.format("MosieNavigator_%s_%s.csv", self:_SanitizeFilename(groupName), self:_SanitizeFilename(plan.name))
  else
    filename = string.format("MosieNavigator_%s.csv", self:_SanitizeFilename(plan.name))
  end

  local path = outputDirectory .. filename
  local file = io.open(path, "w")

  if not file then
    self:_Log("cannot write flight plan CSV file: " .. path)
    return
  end

  file:write(self:_BuildFlightPlanCsv(plan, groupName, rolexSeconds))
  file:close()

  self:_Log("wrote flight plan CSV file: " .. path)
end

function MosieNavigator:_WriteBeaconsCsvFile(beacons)
  if not beacons or #beacons == 0 then
    return
  end

  if not io then
    self:_Log("cannot write beacons CSV file: io is not available")
    return
  end

  local path = self:_GetOutputDirectory() .. "MosieNavigator_Beacons.csv"
  local file = io.open(path, "w")

  if not file then
    self:_Log("cannot write beacons CSV file: " .. path)
    return
  end

  file:write(self:_BuildBeaconsCsv(beacons))
  file:close()

  self:_Log("wrote beacons CSV file: " .. path)
end

function MosieNavigator:_WriteFlightPlanFiles(plans)
  if not self.Config.generateFlightPlanFiles and not self.Config.generateCsvFiles then
    return
  end

  local assignments = self:_DiscoverGroupAssignments(plans)

  if #assignments > 0 then
    for _, assignment in ipairs(assignments) do
      if self.Config.generateFlightPlanFiles then
        self:_WriteFlightPlanFile(assignment.plan, assignment.groupName, assignment.rolexSeconds)
      end
      if self.Config.generateCsvFiles then
        self:_WriteFlightPlanCsvFile(assignment.plan, assignment.groupName, assignment.rolexSeconds)
      end
    end
    return
  end

  self:_Log("no group assignments found; writing one debug navlog per plan")

  for _, plan in pairs(plans) do
    if self.Config.generateFlightPlanFiles then
      self:_WriteFlightPlanFile(plan, nil)
    end
    if self.Config.generateCsvFiles then
      self:_WriteFlightPlanCsvFile(plan, nil)
    end
  end
end

function MosieNavigator:DrawDebug()
  self.MarkIds = self.MarkIds or {}

  local plans, beacons = self:_DiscoverZones()
  self.Plans = plans

  local planIndex = 0
  local waypointCount = 0

  for _, plan in pairs(plans) do
    planIndex = planIndex + 1
    waypointCount = waypointCount + #plan.waypoints
    self:_DrawPlan(plan, self:_GetPlanColor(planIndex))
  end

  for _, beacon in ipairs(beacons) do
    self:_DrawBeacon(beacon)
  end

  self:_CreateGroupMenus(plans)
  self:_WriteFlightPlanFiles(plans)
  if self.Config.generateCsvFiles then
    self:_WriteBeaconsCsvFile(beacons)
  end

  self:_Log(string.format(
    "debug draw complete: %d plans, %d waypoints, %d beacons",
    planIndex,
    waypointCount,
    #beacons
  ))
end

function MosieNavigator:Start()
  self.MarkIds = {}
  self.MenusCreated = {}
  self.InactiveGroupLogs = {}
  self.NavigatorStates = {}
  self:_Log("starting debug discovery")
  self:DrawDebug()
  self:_StartMenuRefreshScheduler()
  self:_StartNavigatorScheduler()
end

if MOSIE_NAVIGATOR_AUTO_START ~= false then
  MosieNavigator:Start()
end
