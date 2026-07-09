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

function MosieNavigator:_Join(tokens, startIndex, separator)
  local result = {}

  for index = startIndex, #tokens do
    table.insert(result, tokens[index])
  end

  return table.concat(result, separator)
end

function MosieNavigator:_ParseWaypointZoneName(zoneName)
  local tokens = self:_Split(zoneName, "_")

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

  return {
    plan = plan,
    order = order,
    type = waypointType,
    name = name,
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

function MosieNavigator:_FormatCoordinate(coordinate)
  local lat, lon = coordinate:GetLLDDM()
  return lat, lon
end

function MosieNavigator:_ExtractPlanFromGroupName(groupName)
  return string.match(groupName, self.Config.groupPlanTagPattern)
end

function MosieNavigator:_DiscoverGroupAssignments(plans)
  local assignments = {}
  local groupSet = SET_GROUP:New():FilterStart()

  groupSet:ForEachGroup(function(group)
    local groupName = group:GetName()
    local planName = self:_ExtractPlanFromGroupName(groupName)

    if planName then
      if plans[planName] then
        table.insert(assignments, {
          groupName = groupName,
          group = group,
          planName = planName,
          plan = plans[planName],
        })
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

function MosieNavigator:_BuildSimplifiedFlightPlanMessage(plan, groupName)
  local lines = {}

  table.insert(lines, "MOSIE NAVIGATOR")
  table.insert(lines, "GROUP: " .. groupName)
  table.insert(lines, "PLAN: " .. plan.name)
  table.insert(lines, "")

  for index, waypoint in ipairs(plan.waypoints) do
    local nextWaypoint = plan.waypoints[index + 1]
    local trueCourse = nil
    local legDistanceNm = nil

    if nextWaypoint then
      trueCourse = waypoint.coordinate:HeadingTo(nextWaypoint.coordinate)
      legDistanceNm = UTILS.MetersToNM(waypoint.coordinate:Get2DDistance(nextWaypoint.coordinate))
    end

    table.insert(lines, string.format(
      "%02d %-10s %-16s CRS %s LEG %s",
      waypoint.order,
      waypoint.type,
      waypoint.name,
      self:_FormatHeading(trueCourse),
      legDistanceNm and string.format("%.1fNM", legDistanceNm) or "---"
    ))
  end

  return table.concat(lines, "\n")
end

function MosieNavigator:_ShowFlightPlanForGroup(group, plan)
  if not group or not plan then
    return
  end

  local text = self:_BuildSimplifiedFlightPlanMessage(plan, group:GetName())
  MESSAGE:New(text, self.Config.flightPlanMessageDuration, "Mosie Navigator"):ToGroup(group)
end

function MosieNavigator:_CreateGroupMenus(plans)
  local assignments = self:_DiscoverGroupAssignments(plans)

  for _, assignment in ipairs(assignments) do
    local group = assignment.group
    local plan = assignment.plan
    local rootMenu = MENU_GROUP:New(group, self.Config.menuName)
    MENU_GROUP_COMMAND:New(group, "Show FP", rootMenu, function()
      MosieNavigator:_ShowFlightPlanForGroup(group, plan)
    end)
  end

  if #assignments > 0 then
    self:_Log(string.format("created navigation menu for %d assigned groups", #assignments))
  end
end

function MosieNavigator:_BuildFlightPlanTable(plan, groupName)
  local lines = {}
  local totalDistanceNm = 0

  table.insert(lines, "MOSIE NAVIGATOR FLIGHT PLAN")
  table.insert(lines, "PLAN: " .. plan.name)
  if groupName then
    table.insert(lines, "GROUP: " .. groupName)
  end
  table.insert(lines, "")
  table.insert(lines, string.format("%-4s %-12s %-12s %-10s %-14s %-12s %-12s %-s", "NO", "LAT", "LON", "TRUE_CRS", "DIST_START_NM", "LEG_DIST_NM", "TYPE", "NAME"))
  table.insert(lines, string.rep("-", 98))

  for index, waypoint in ipairs(plan.waypoints) do
    local previousWaypoint = plan.waypoints[index - 1]
    local nextWaypoint = plan.waypoints[index + 1]
    local legDistanceNm = 0

    if previousWaypoint then
      legDistanceNm = UTILS.MetersToNM(previousWaypoint.coordinate:Get2DDistance(waypoint.coordinate))
      totalDistanceNm = totalDistanceNm + legDistanceNm
    end

    local trueCourse = nil
    if nextWaypoint then
      trueCourse = waypoint.coordinate:HeadingTo(nextWaypoint.coordinate)
    end

    local lat, lon = self:_FormatCoordinate(waypoint.coordinate)

    table.insert(lines, string.format(
      "%-4d %-12.6f %-12.6f %-10s %-14.1f %-12.1f %-12s %-s",
      waypoint.order,
      lat,
      lon,
      self:_FormatHeading(trueCourse),
      totalDistanceNm,
      legDistanceNm,
      waypoint.type,
      waypoint.name
    ))
  end

  table.insert(lines, "")
  table.insert(lines, string.format("TOTAL_DISTANCE_NM: %.1f", totalDistanceNm))

  return table.concat(lines, "\n") .. "\n"
end

function MosieNavigator:_WriteFlightPlanFile(plan, groupName)
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

  file:write(self:_BuildFlightPlanTable(plan, groupName))
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
      self:_WriteFlightPlanFile(assignment.plan, assignment.groupName)
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
  self:_Log("starting debug discovery")
  self:DrawDebug()
end

if MOSIE_NAVIGATOR_AUTO_START ~= false then
  MosieNavigator:Start()
end
