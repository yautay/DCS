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
  generateFlightPlanFiles = true,
  flightPlanOutputDirectory = nil,
  groupPlanTagPattern = "%[MN:([%w%-]+)%]",
  menuName = "Mosie Navigator",
  flightPlanMessageDuration = 30,
  menuRefreshDelay = 5,
  menuRefreshInterval = 15,
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
  seconds = seconds % 86400

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
  local tokens = self:_Split(zoneParts[1], "_")

  if tokens[1] ~= "MN" then
    return nil
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

  local name = self:_Join(tokens, nameStartIndex, "_")
  if name == "" then
    name = waypointType
  end

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
    altitudeFt = metadata.altitudeFt,
    timeOnTarget = metadata.timeOnTarget,
    timeOnTargetSeconds = metadata.timeOnTargetSeconds,
  }
end

function MosieNavigator:_ParseBeaconZoneName(zoneName)
  local tokens = self:_Split(zoneName, "_")

  if tokens[1] ~= "MNB" or not tokens[2] then
    return nil
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
    return lfs.writedir() .. "Logs\\"
  end

  return ".\\"
end

function MosieNavigator:_FormatHeading(heading)
  if not heading then
    return "---"
  end

  return string.format("%03d", math.floor(heading + 0.5) % 360)
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
    deltaSeconds = deltaSeconds + 86400
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
    table.sort(plan.waypoints, function(a, b)
      return a.order < b.order
    end)
  end

  return plans, beacons
end

function MosieNavigator:_DrawWaypoint(plan, waypoint, color)
  local label = string.format("MN %s %02d %s\n%s", waypoint.plan, waypoint.order, waypoint.type, waypoint.name)
  local radius = 250

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
    local previousWaypoint = plan.waypoints[index - 1]
    local nextWaypoint = plan.waypoints[index + 1]
    local trueCourse = nil
    local legDistanceNm = nil
    local legSpeedKnots = nil

    if previousWaypoint then
      legDistanceNm = UTILS.MetersToNM(previousWaypoint.coordinate:Get2DDistance(waypoint.coordinate))
      totalDistanceNm = totalDistanceNm + legDistanceNm
      legSpeedKnots = self:_CalculateLegSpeedKnots(previousWaypoint, waypoint, legDistanceNm)
    end

    if nextWaypoint then
      trueCourse = waypoint.coordinate:HeadingTo(nextWaypoint.coordinate)
    end

    table.insert(lines, string.format(
      "[%02d] %s %s: ALT %s ft, TOT %s, CRS %s, LEG %s NM, TAS %s kt, DIST %.1f NM",
      waypoint.order,
      self:_FitText(waypoint.type, 10),
      self:_FitText(waypoint.name, 12),
      self:_FormatOptional(waypoint.altitudeFt),
      self:_FormatWaypointTot(waypoint, rolexSeconds),
      self:_FormatHeading(trueCourse),
      legDistanceNm and string.format("%.1f", legDistanceNm) or "---",
      legSpeedKnots and string.format("%.0f", legSpeedKnots) or "---",
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
    "%-2s %-10s %-12s %10s %11s %5s %-5s %3s %6s %6s %6s",
    "NO",
    "TYPE",
    "NAME",
    "LAT",
    "LON",
    "ALTFT",
    "TOT",
    "CRS",
    "LEG",
    "TAS",
    "DIST"
  ))
  table.insert(lines, string.rep("-", 86))

  for index, waypoint in ipairs(plan.waypoints) do
    local previousWaypoint = plan.waypoints[index - 1]
    local nextWaypoint = plan.waypoints[index + 1]
    local legDistanceNm = 0
    local legSpeedKnots = nil

    if previousWaypoint then
      legDistanceNm = UTILS.MetersToNM(previousWaypoint.coordinate:Get2DDistance(waypoint.coordinate))
      totalDistanceNm = totalDistanceNm + legDistanceNm
      legSpeedKnots = self:_CalculateLegSpeedKnots(previousWaypoint, waypoint, legDistanceNm)
    end

    local trueCourse = nil
    if nextWaypoint then
      trueCourse = waypoint.coordinate:HeadingTo(nextWaypoint.coordinate)
    end

    local lat, lon = self:_FormatCoordinate(waypoint.coordinate)

    table.insert(lines, string.format(
      "%02d %-10s %-12s %10s %11s %5s %-5s %3s %6.1f %6s %6.1f",
      waypoint.order,
      self:_FitText(waypoint.type, 10),
      self:_FitText(waypoint.name, 12),
      lat,
      lon,
      self:_FormatOptional(waypoint.altitudeFt),
      self:_FormatWaypointTot(waypoint, rolexSeconds),
      self:_FormatHeading(trueCourse),
      legDistanceNm,
      legSpeedKnots and string.format("%.0f", legSpeedKnots) or "---",
      totalDistanceNm
    ))
  end

  table.insert(lines, "")
  table.insert(lines, string.format("TOTAL_DISTANCE_NM: %.1f", totalDistanceNm))

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

function MosieNavigator:_WriteFlightPlanFiles(plans)
  if not self.Config.generateFlightPlanFiles then
    return
  end

  local assignments = self:_DiscoverGroupAssignments(plans)

  if #assignments > 0 then
    for _, assignment in ipairs(assignments) do
      self:_WriteFlightPlanFile(assignment.plan, assignment.groupName, assignment.rolexSeconds)
    end
    return
  end

  self:_Log("no group assignments found; writing one debug navlog per plan")

  for _, plan in pairs(plans) do
    self:_WriteFlightPlanFile(plan, nil)
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
  self:_Log("starting debug discovery")
  self:DrawDebug()
  self:_StartMenuRefreshScheduler()
end

if MOSIE_NAVIGATOR_AUTO_START ~= false then
  MosieNavigator:Start()
end
