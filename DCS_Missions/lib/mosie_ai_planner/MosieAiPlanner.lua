MosieAiPlanner = MosieAiPlanner or {}

local MosieAiPlannerConfigDefaults = {
  enabled = true,
  groupPlanTagPattern = "%[MN:([%w%-]+)%]",
  tickInterval = 15,
  retaskCooldownSeconds = 30,
  flightSampleIntervalSeconds = 15,
  etaToleranceSeconds = 15,
  startLeadSeconds = 3 * 60,
  waypointArrivalRadiusNm = 1.0,
  minSpeedKt = 140,
  maxSpeedKt = 300,
  holdSpeedKt = 140,
  lineInterceptMinDistanceNm = 10,
  lineInterceptXteThresholdNm = 1,
  lineInterceptLookaheadNm = 5,
}

MosieAiPlanner.Config = MosieAiPlanner.Config or {}
for key, value in pairs(MosieAiPlannerConfigDefaults) do
  if MosieAiPlanner.Config[key] == nil then
    MosieAiPlanner.Config[key] = value
  end
end

function MosieAiPlanner:_Log(message)
  env.info("MOSIE_AI_PLANNER: " .. tostring(message))
end

function MosieAiPlanner:_IsTestMode()
  return TEST_MODE == true
end

function MosieAiPlanner:_GetNavigator()
  return MosieNavigator
end

function MosieAiPlanner:_ExtractPlanFromGroupName(groupName)
  return string.match(groupName or "", self.Config.groupPlanTagPattern)
end

function MosieAiPlanner:_ExtractRolexFromGroupName(groupName)
  local navigator = self:_GetNavigator()
  if navigator and type(navigator._ExtractRolexFromGroupName) == "function" then
    return navigator:_ExtractRolexFromGroupName(groupName)
  end

  return 0
end

function MosieAiPlanner:_GetGroupSkill(group)
  if group and type(group.GetSkill) == "function" then
    return group:GetSkill()
  end

  return nil
end

function MosieAiPlanner:_IsAiGroup(group)
  local skill = self:_GetGroupSkill(group)
  return skill ~= "Client" and skill ~= "Player"
end

function MosieAiPlanner:_IsGroupExisting(group)
  if not group then
    return false
  end
  if type(group.GetDCSObject) == "function" then
    local ok, dcsGroup = pcall(function() return group:GetDCSObject() end)
    if ok and dcsGroup and type(dcsGroup.isExist) == "function" then
      local existOk, exists = pcall(function() return dcsGroup:isExist() end)
      return existOk and exists == true
    end
  end
  if type(group.IsAlive) == "function" then
    return group:IsAlive() == true
  end
  return false
end

function MosieAiPlanner:_KnotsToMps(knots)
  if UTILS and type(UTILS.KnotsToMps) == "function" then
    return UTILS.KnotsToMps(knots or 0)
  end

  return (knots or 0) * 0.514444
end

function MosieAiPlanner:_MetersToNm(meters)
  if UTILS and type(UTILS.MetersToNM) == "function" then
    return UTILS.MetersToNM(meters or 0)
  end

  return (meters or 0) / 1852
end

function MosieAiPlanner:_FeetToMeters(feet)
  return (feet or 0) * 0.3048
end

function MosieAiPlanner:_Clamp(value, minValue, maxValue)
  if value < minValue then return minValue end
  if value > maxValue then return maxValue end
  return value
end

function MosieAiPlanner:_IsGroupAirborne(group)
  if group and type(group.IsAirborne) == "function" then
    return group:IsAirborne()
  end

  return false
end

function MosieAiPlanner:_LogStateOnce(state, key, message)
  state.logged = state.logged or {}
  if state.logged[key] then
    return
  end

  state.logged[key] = true
  self:_Log(message)
end

function MosieAiPlanner:_GetMissionTime()
  if timer and type(timer.getAbsTime) == "function" then
    return timer.getAbsTime()
  end

  return 0
end

function MosieAiPlanner:_FormatClock(seconds)
  local navigator = self:_GetNavigator()
  if navigator and type(navigator._FormatClock) == "function" then
    return navigator:_FormatClock(seconds or 0)
  end

  seconds = math.floor((seconds or 0) % 86400)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = seconds % 60
  return string.format("%02d:%02d:%02d", h, m, s)
end

function MosieAiPlanner:_GetOutputDirectory()
  local navigator = self:_GetNavigator()
  if navigator and type(navigator._GetOutputDirectory) == "function" then
    return navigator:_GetOutputDirectory()
  end

  if lfs and lfs.writedir then
    return lfs.writedir() .. "Logs/"
  end

  return "./"
end

function MosieAiPlanner:_GetAiZoneDumpPath()
  return self:_GetOutputDirectory() .. "AI_ZONE_DUMP.log"
end

function MosieAiPlanner:_ResetAiZoneDumpFile()
  if not self:_IsTestMode() then
    return
  end

  if not io then
    self:_Log("cannot reset AI zone dump file: io is not available")
    return
  end

  local path = self:_GetAiZoneDumpPath()
  local file = io.open(path, "w")
  if not file then
    self:_Log("cannot reset AI zone dump file: " .. path)
    return
  end

  file:write(string.format("AI_ZONE_DUMP reset at mission time %s\n", self:_FormatClock(timer and timer.getAbsTime and timer.getAbsTime() or 0)))
  file:close()
  self:_Log("reset AI zone dump file: " .. path)
end

function MosieAiPlanner:_AppendAiZoneDump(text)
  if not self:_IsTestMode() then
    return
  end

  if not io then
    self:_Log("cannot write AI zone dump file: io is not available")
    return
  end

  local path = self:_GetAiZoneDumpPath()
  local file = io.open(path, "a")
  if not file then
    self:_Log("cannot write AI zone dump file: " .. path)
    return
  end

  file:write(tostring(text or ""))
  file:write("\n---\n")
  file:close()
end

function MosieAiPlanner:_AppendAiDebugDump(state, message)
  if not self:_IsTestMode() then
    return
  end

  local text = string.format(
    "[%s] AI_DEBUG group=\"%s\" %s",
    self:_FormatClock(self:_GetMissionTime()),
    tostring(state and state.assignment and state.assignment.groupName or "---"),
    tostring(message or "")
  )
  self:_Log(text)
  self:_AppendAiZoneDump(text)
end

function MosieAiPlanner:_AppendAiCommandDump(state, command, details)
  if not self:_IsTestMode() then
    return
  end

  local text = string.format(
    "[%s] AI_COMMAND group=\"%s\" command=%s wp=%s reason=%s details=\"%s\"",
    self:_FormatClock(self:_GetMissionTime()),
    tostring(state and state.assignment and state.assignment.groupName or "---"),
    tostring(command or "---"),
    state and state.currentWpIndex and string.format("WP%02d", state.currentWpIndex) or "---",
    tostring(state and state.aiModeReason or "---"),
    tostring(details or "")
  )
  self:_Log(text)
  self:_AppendAiZoneDump(text)
end

function MosieAiPlanner:_SetAiMode(state, mode, reason, details)
  if not state then
    return
  end

  local previousMode = state.aiMode
  local previousReason = state.aiModeReason
  local previousDetails = state.aiModeDetails
  state.aiMode = mode or "UNKNOWN"
  state.aiModeReason = reason
  state.aiModeDetails = details

  if previousMode ~= state.aiMode or previousReason ~= state.aiModeReason or previousDetails ~= state.aiModeDetails then
    self:_AppendAiDebugDump(state, string.format(
      "mode=%s reason=%s details=\"%s\"",
      tostring(state.aiMode),
      tostring(reason or "---"),
      tostring(details or "")
    ))
  end
end

function MosieAiPlanner:_GetMissionRolexSeconds()
  local navigator = self:_GetNavigator()
  return (navigator and navigator.MissionRolexSeconds) or 0
end

function MosieAiPlanner:_GetPlans()
  local navigator = self:_GetNavigator()
  if not navigator then
    return nil
  end

  if navigator.Plans then
    return navigator.Plans
  end

  if type(navigator._DiscoverZones) == "function" then
    local plans = navigator:_DiscoverZones()
    navigator.Plans = plans
    return plans
  end

  return nil
end

function MosieAiPlanner:_DiscoverAssignments(plans)
  local assignments = {}
  if not plans or not SET_GROUP then
    return assignments
  end

  local groupSet = SET_GROUP:New():FilterStart()
  groupSet:ForEachGroup(function(group)
    local groupName = group:GetName()
    local planName = self:_ExtractPlanFromGroupName(groupName)
    if planName and plans[planName] and self:_IsGroupExisting(group) and self:_IsAiGroup(group) then
      table.insert(assignments, {
        group = group,
        groupName = groupName,
        plan = plans[planName],
        planName = planName,
        rolexSeconds = self:_ExtractRolexFromGroupName(groupName),
      })
    end
  end)

  return assignments
end

function MosieAiPlanner:_GetComputedPlan(assignment)
  local navigator = self:_GetNavigator()
  if not navigator or not assignment or not assignment.plan then
    return nil
  end

  if type(navigator._GetActiveComputedPlan) == "function" then
    return navigator:_GetActiveComputedPlan(assignment.plan, assignment.rolexSeconds or 0, self:_GetMissionRolexSeconds())
  end

  if type(navigator._ComputePlan) == "function" then
    return navigator:_ComputePlan(assignment.plan, (assignment.rolexSeconds or 0) + self:_GetMissionRolexSeconds())
  end

  return nil
end

function MosieAiPlanner:_GetSecondsToClockSeconds(clockSeconds)
  local navigator = self:_GetNavigator()
  if navigator and type(navigator._GetSecondsToClockSeconds) == "function" then
    return navigator:_GetSecondsToClockSeconds(clockSeconds)
  end

  if not clockSeconds or not timer then
    return nil
  end

  local secondsPerDay = SECONDS_PER_DAY or 86400
  local secondsPerHalfDay = SECONDS_PER_HALF_DAY or 43200
  local now = timer.getAbsTime() % secondsPerDay
  local delta = (clockSeconds % secondsPerDay) - now
  if delta < -secondsPerHalfDay then
    delta = delta + secondsPerDay
  elseif delta > secondsPerHalfDay then
    delta = delta - secondsPerDay
  end
  return delta
end

function MosieAiPlanner:_CoordinateToVec2(coordinate)
  if not coordinate then
    return nil
  end

  if type(coordinate.GetVec2) == "function" then
    return coordinate:GetVec2()
  end

  if type(coordinate.GetVec3) == "function" then
    local vec3 = coordinate:GetVec3()
    return {x = vec3.x, y = vec3.z}
  end

  return {x = coordinate.x, y = coordinate.z or coordinate.y}
end

function MosieAiPlanner:_GetAirdromeCategory()
  return Airbase and Airbase.Category and Airbase.Category.AIRDROME or nil
end

function MosieAiPlanner:_GetAirbaseName(airbase)
  if not airbase then
    return nil
  end

  if type(airbase.GetName) == "function" then
    local ok, name = pcall(function() return airbase:GetName() end)
    if ok and name then
      return name
    end
  end

  if type(airbase.GetAirbaseName) == "function" then
    local ok, name = pcall(function() return airbase:GetAirbaseName() end)
    if ok and name then
      return name
    end
  end

  return airbase.AirbaseName or airbase.airbaseName or airbase.name
end

function MosieAiPlanner:_GetAirbaseCoordinate(airbase)
  if not airbase then
    return nil
  end

  if type(airbase.GetCoordinate) == "function" then
    local ok, coordinate = pcall(function() return airbase:GetCoordinate() end)
    if ok and coordinate then
      return coordinate
    end
  end

  if type(airbase.GetVec2) == "function" then
    local ok, vec2 = pcall(function() return airbase:GetVec2() end)
    if ok and vec2 then
      return {x = vec2.x, y = 0, z = vec2.y}
    end
  end

  return nil
end

function MosieAiPlanner:_GetAirbaseId(airbase)
  if not airbase then
    return nil
  end

  if type(airbase.GetID) == "function" then
    local ok, id = pcall(function() return airbase:GetID() end)
    if ok and id then
      return id
    end
  end

  if type(airbase.getID) == "function" then
    local ok, id = pcall(function() return airbase:getID() end)
    if ok and id then
      return id
    end
  end

  return airbase.AirbaseID or airbase.id
end

function MosieAiPlanner:_FindNearestLandingAirbase(coordinate)
  if not coordinate then
    return nil, nil
  end

  local airdromeCategory = self:_GetAirdromeCategory()
  if type(coordinate.GetClosestAirbase) == "function" then
    local ok, airbase, distanceMeters = pcall(function()
      return coordinate:GetClosestAirbase(airdromeCategory)
    end)
    if ok and airbase then
      return airbase, distanceMeters
    end
  end

  if not AIRBASE or type(AIRBASE.GetAllAirbases) ~= "function" or type(coordinate.Get2DDistance) ~= "function" then
    return nil, nil
  end

  local ok, airbases = pcall(function() return AIRBASE.GetAllAirbases(nil) end)
  if not ok or not airbases then
    return nil, nil
  end

  local closestAirbase = nil
  local closestDistanceMeters = nil
  for _, airbase in pairs(airbases) do
    local category = nil
    if airbase and type(airbase.GetAirbaseCategory) == "function" then
      local categoryOk, value = pcall(function() return airbase:GetAirbaseCategory() end)
      if categoryOk then
        category = value
      end
    end

    if airbase and (not airdromeCategory or category == airdromeCategory) then
      local airbaseCoordinate = self:_GetAirbaseCoordinate(airbase)
      if airbaseCoordinate then
        local distanceMeters = coordinate:Get2DDistance(airbaseCoordinate)
        if distanceMeters and (not closestDistanceMeters or distanceMeters < closestDistanceMeters) then
          closestAirbase = airbase
          closestDistanceMeters = distanceMeters
        end
      end
    end
  end

  return closestAirbase, closestDistanceMeters
end

function MosieAiPlanner:_GetGroupCoordinate(group)
  if group and type(group.GetCoordinate) == "function" then
    return group:GetCoordinate()
  end

  return nil
end

function MosieAiPlanner:_GetDistanceNm(fromCoordinate, toCoordinate)
  if not fromCoordinate or not toCoordinate or type(fromCoordinate.Get2DDistance) ~= "function" then
    return nil
  end

  return self:_MetersToNm(fromCoordinate:Get2DDistance(toCoordinate))
end

function MosieAiPlanner:_IsCoordinateInWaypointZone(coordinate, waypoint)
  if not coordinate or not waypoint or not waypoint.zone then
    return false, nil, nil
  end

  local zone = waypoint.zone
  local ok, inside = false, false
  if type(zone.IsCoordinateInZone) == "function" then
    ok, inside = pcall(function() return zone:IsCoordinateInZone(coordinate) end)
    if ok and inside ~= nil then
      return inside == true, self:_GetDistanceNm(coordinate, waypoint.coordinate), zone.GetRadius and self:_MetersToNm(zone:GetRadius()) or nil
    end
  end

  if type(zone.IsVec2InZone) == "function" then
    local vec2 = self:_CoordinateToVec2(coordinate)
    if vec2 then
      ok, inside = pcall(function() return zone:IsVec2InZone(vec2) end)
      if ok and inside ~= nil then
        return inside == true, self:_GetDistanceNm(coordinate, waypoint.coordinate), zone.GetRadius and self:_MetersToNm(zone:GetRadius()) or nil
      end
    end
  end

  if type(zone.GetRadius) ~= "function" or not waypoint.coordinate then
    return false, self:_GetDistanceNm(coordinate, waypoint.coordinate), nil
  end

  local radiusMeters = zone:GetRadius()
  local distanceMeters = coordinate.Get2DDistance and coordinate:Get2DDistance(waypoint.coordinate) or nil
  if not distanceMeters or not radiusMeters then
    return false, nil, radiusMeters and self:_MetersToNm(radiusMeters) or nil
  end

  return distanceMeters <= radiusMeters, self:_MetersToNm(distanceMeters), self:_MetersToNm(radiusMeters)
end

function MosieAiPlanner:_FormatAiZoneDumpEntry(state, waypoint, computedWaypoint, distanceNm, radiusNm)
  local group = state.assignment.group
  local groupCoordinate = self:_GetGroupCoordinate(group)
  local vec2 = self:_CoordinateToVec2(groupCoordinate) or {}
  local now = timer and timer.getAbsTime and timer.getAbsTime() or 0
  local etaSec = computedWaypoint and computedWaypoint.etaSec or nil
  local deltaSec = nil
  if etaSec then
    local secondsToEta = self:_GetSecondsToClockSeconds(etaSec)
    if secondsToEta then
      deltaSec = -secondsToEta
    end
  end

  local speedKt = group.GetVelocityKNOTS and group:GetVelocityKNOTS() or nil
  local altitude = group.GetAltitude and group:GetAltitude() or nil

  return string.format(
    "[%s] AI_ZONE_ENTRY group=\"%s\" plan=\"%s\" wp=WP%02d type=%s name=\"%s\" zone=\"%s\" dist_nm=%s radius_nm=%s eta=%s delta_sec=%s speed_kt=%s alt_m=%s pos_x=%s pos_y=%s",
    self:_FormatClock(now),
    tostring(state.assignment.groupName or "---"),
    tostring(state.assignment.planName or "---"),
    waypoint.order or 0,
    tostring(waypoint.type or "---"),
    tostring(waypoint.name or "---"),
    tostring(waypoint.zoneName or "---"),
    distanceNm and string.format("%.3f", distanceNm) or "---",
    radiusNm and string.format("%.3f", radiusNm) or "---",
    etaSec and self:_FormatClock(etaSec) or "---",
    deltaSec and string.format("%+.0f", deltaSec) or "---",
    speedKt and string.format("%.0f", speedKt) or "---",
    altitude and string.format("%.0f", altitude) or "---",
    vec2.x and string.format("%.1f", vec2.x) or "---",
    vec2.y and string.format("%.1f", vec2.y) or "---"
  )
end

function MosieAiPlanner:_TickZoneDump(state, computed)
  if not self:_IsTestMode() or not state or not state.assignment or not state.assignment.plan then
    return
  end

  local groupCoordinate = self:_GetGroupCoordinate(state.assignment.group)
  if not groupCoordinate then
    return
  end

  state.zoneDumpInside = state.zoneDumpInside or {}

  for index, waypoint in ipairs(state.assignment.plan.waypoints or {}) do
    if waypoint.zone then
      local inside, distanceNm, radiusNm = self:_IsCoordinateInWaypointZone(groupCoordinate, waypoint)
      local key = tostring(waypoint.zoneName or waypoint.order or index)
      if inside and not state.zoneDumpInside[key] then
        local computedWaypoint = computed and computed.waypoints and computed.waypoints[index] or nil
        self:_AppendAiZoneDump(self:_FormatAiZoneDumpEntry(state, waypoint, computedWaypoint, distanceNm, radiusNm))
      end
      state.zoneDumpInside[key] = inside == true or nil
    end
  end
end

function MosieAiPlanner:_GetPlanWaypoint(state, index)
  return state and state.assignment and state.assignment.plan and state.assignment.plan.waypoints and state.assignment.plan.waypoints[index] or nil
end

function MosieAiPlanner:_GetComputedWaypoint(computed, index)
  return computed and computed.waypoints and computed.waypoints[index] or nil
end

function MosieAiPlanner:_FormatClockOrDash(clockSeconds)
  if clockSeconds == nil then
    return "---"
  end

  return self:_FormatClock(clockSeconds)
end

function MosieAiPlanner:_FormatSignedSeconds(value)
  if value == nil then
    return "---"
  end

  return string.format("%+.0f", value)
end

function MosieAiPlanner:_GetAiXte(state, groupCoordinate)
  local navigator = self:_GetNavigator()
  if not navigator or type(navigator._CalculateXte) ~= "function" then
    return nil, nil
  end

  local currentIndex = state.currentWpIndex or 2
  local previousWaypoint = self:_GetPlanWaypoint(state, currentIndex - 1)
  local waypoint = self:_GetPlanWaypoint(state, currentIndex)
  if not previousWaypoint or not waypoint then
    return nil, nil
  end

  return navigator:_CalculateXte(previousWaypoint, waypoint, groupCoordinate)
end

function MosieAiPlanner:_FormatAiFlightSample(state, computed)
  local group = state.assignment.group
  local groupCoordinate = self:_GetGroupCoordinate(group)
  local vec2 = self:_CoordinateToVec2(groupCoordinate) or {}
  local currentIndex = state.currentWpIndex or 2
  local planWaypoint = self:_GetPlanWaypoint(state, currentIndex)
  local computedWaypoint = self:_GetComputedWaypoint(computed, currentIndex)
  local waypoint = computedWaypoint and (computedWaypoint.source or (computedWaypoint.coordinate and computedWaypoint)) or planWaypoint

  local distanceNm = waypoint and waypoint.coordinate and self:_GetDistanceNm(groupCoordinate, waypoint.coordinate) or nil
  local speedKt = group.GetVelocityKNOTS and group:GetVelocityKNOTS() or nil
  local actualSecondsToWaypoint = distanceNm and speedKt and speedKt > 1 and distanceNm / speedKt * 3600 or nil
  local plannedEtaSec = computedWaypoint and computedWaypoint.etaSec or nil
  local actualEtaSec = actualSecondsToWaypoint and ((self:_GetMissionTime() + actualSecondsToWaypoint) % (SECONDS_PER_DAY or 86400)) or nil
  local plannedSecondsToEta = plannedEtaSec and self:_GetSecondsToClockSeconds(plannedEtaSec) or nil
  local etaDeltaSec = nil
  local requiredSpeedKt = nil
  if distanceNm and plannedSecondsToEta and plannedSecondsToEta > 0 then
    requiredSpeedKt = distanceNm / plannedSecondsToEta * 3600
  end
  if actualSecondsToWaypoint and plannedSecondsToEta then
    etaDeltaSec = actualSecondsToWaypoint - plannedSecondsToEta
  end

  local xteNm, xteSide = self:_GetAiXte(state, groupCoordinate)
  local altitude = group.GetAltitude and group:GetAltitude() or nil

  return string.format(
    "[%s] AI_FLIGHT_SAMPLE group=\"%s\" plan=\"%s\" mode=%s reason=%s wp=%s type=%s dist_nm=%s plan_eta=%s act_eta=%s eta_delta_sec=%s req_speed_kt=%s speed_kt=%s alt_m=%s xte_nm=%s xte_side=%s last_retask=\"%s\" pos_x=%s pos_y=%s",
    self:_FormatClock(self:_GetMissionTime()),
    tostring(state.assignment.groupName or "---"),
    tostring(state.assignment.planName or "---"),
    tostring(state.aiMode or "UNKNOWN"),
    tostring(state.aiModeReason or "---"),
    waypoint and string.format("WP%02d", waypoint.order or currentIndex) or "---",
    waypoint and tostring(waypoint.type or "---") or "---",
    distanceNm and string.format("%.3f", distanceNm) or "---",
    self:_FormatClockOrDash(plannedEtaSec),
    self:_FormatClockOrDash(actualEtaSec),
    self:_FormatSignedSeconds(etaDeltaSec),
    requiredSpeedKt and string.format("%.0f", requiredSpeedKt) or "---",
    speedKt and string.format("%.0f", speedKt) or "---",
    altitude and string.format("%.0f", altitude) or "---",
    xteNm and string.format("%.3f", xteNm) or "---",
    tostring(xteSide or "---"),
    tostring(state.lastRouteReason or "---"),
    vec2.x and string.format("%.1f", vec2.x) or "---",
    vec2.y and string.format("%.1f", vec2.y) or "---"
  )
end

function MosieAiPlanner:_TickFlightSampleDump(state, computed)
  if not self:_IsTestMode() or not state then
    return
  end

  local now = timer and type(timer.getTime) == "function" and timer.getTime() or self:_GetMissionTime()
  if state.lastFlightSampleTime and now - state.lastFlightSampleTime < self.Config.flightSampleIntervalSeconds then
    return
  end

  state.lastFlightSampleTime = now
  self:_AppendAiZoneDump(self:_FormatAiFlightSample(state, computed))
end

function MosieAiPlanner:_GetWaypointSpeedKt(computedWaypoint)
  return computedWaypoint and (computedWaypoint.legGsKt or computedWaypoint.legTasKt or computedWaypoint.speedKt) or nil
end

function MosieAiPlanner:_BuildRoutePoint(computedWaypoint, speedKt)
  local waypoint = computedWaypoint.source or computedWaypoint
  local landingAirbase = nil
  local routeCoordinate = waypoint.coordinate

  if waypoint.type == "LANDING" then
    landingAirbase = self:_FindNearestLandingAirbase(waypoint.coordinate)
    routeCoordinate = self:_GetAirbaseCoordinate(landingAirbase) or routeCoordinate
  end

  local vec2 = self:_CoordinateToVec2(routeCoordinate)
  if not vec2 then
    return nil
  end

  local routePoint = {
    x = vec2.x,
    y = vec2.y,
    alt = self:_FeetToMeters(computedWaypoint.resolvedAltFt or waypoint.altitudeFt or 0),
    alt_type = "BARO",
    speed = self:_KnotsToMps(speedKt or self:_GetWaypointSpeedKt(computedWaypoint) or self.Config.minSpeedKt),
    speed_locked = true,
    type = "Turning Point",
    action = "Fly Over Point",
    task = {id = "ComboTask", params = {tasks = {}}},
  }

  if waypoint.type == "LANDING" then
    local airbaseId = self:_GetAirbaseId(landingAirbase)
    if airbaseId then
      routePoint.type = "Land"
      routePoint.action = "Landing"
      routePoint.speed_locked = false
      routePoint.airdromeId = airbaseId
      local airbaseName = self:_GetAirbaseName(landingAirbase)
      if airbaseName then
        routePoint.name = airbaseName
      end
    else
      self:_Log(string.format("LANDING waypoint has no nearby airdrome — routing as fly-over"))
    end
  end

  return routePoint
end

function MosieAiPlanner:_BuildVec2RoutePoint(vec2, altitudeMeters, speedKt)
  if not vec2 then
    return nil
  end

  return {
    x = vec2.x,
    y = vec2.y,
    alt = altitudeMeters or 0,
    alt_type = "BARO",
    speed = self:_KnotsToMps(speedKt or self.Config.minSpeedKt),
    speed_locked = true,
    type = "Turning Point",
    action = "Turning Point",
    task = {id = "ComboTask", params = {tasks = {}}},
  }
end

function MosieAiPlanner:_GetLineInterceptVec2(state, computed, startIndex)
  if not state or not computed or not computed.waypoints then
    return nil, nil
  end

  local currentIndex = startIndex or state.currentWpIndex or 2
  if currentIndex <= 1 then
    return nil, nil
  end

  local previousWaypoint = computed.waypoints[currentIndex - 1]
  local currentWaypoint = computed.waypoints[currentIndex]
  if not previousWaypoint or not currentWaypoint then
    return nil, nil
  end

  local previousSource = previousWaypoint.source or previousWaypoint
  local currentSource = currentWaypoint.source or currentWaypoint
  if not previousSource.coordinate or not currentSource.coordinate then
    return nil, nil
  end

  local groupCoordinate = self:_GetGroupCoordinate(state.assignment.group)
  local distanceToWaypointNm = self:_GetDistanceNm(groupCoordinate, currentSource.coordinate)
  if not distanceToWaypointNm or distanceToWaypointNm <= self.Config.lineInterceptMinDistanceNm then
    return nil, nil
  end

  local xteNm, xteSide = self:_GetAiXte(state, groupCoordinate)
  if not xteNm or xteNm < self.Config.lineInterceptXteThresholdNm then
    return nil, nil
  end

  local startVec = previousSource.coordinate:GetVec3()
  local endVec = currentSource.coordinate:GetVec3()
  local currentVec = groupCoordinate:GetVec3()
  local legX = endVec.x - startVec.x
  local legZ = endVec.z - startVec.z
  local legLength = math.sqrt(legX * legX + legZ * legZ)
  if legLength <= 0 then
    return nil, nil
  end

  local currentX = currentVec.x - startVec.x
  local currentZ = currentVec.z - startVec.z
  local alongMeters = (currentX * legX + currentZ * legZ) / legLength
  if alongMeters < 0 then
    alongMeters = 0
  elseif alongMeters > legLength then
    return nil, nil
  end

  local lookaheadMeters = (self.Config.lineInterceptLookaheadNm or 0) * 1852
  local interceptAlongMeters = math.min(legLength, alongMeters + lookaheadMeters)
  if legLength - interceptAlongMeters < 1 then
    return nil, nil
  end

  local fraction = interceptAlongMeters / legLength
  return {
    x = startVec.x + legX * fraction,
    y = startVec.z + legZ * fraction,
  }, string.format(
    "intercept_xte_nm=%.1f intercept_side=%s intercept_dist_to_wp_nm=%.1f",
    xteNm,
    tostring(xteSide or "---"),
    distanceToWaypointNm
  )
end

function MosieAiPlanner:_BuildRoute(stateOrGroup, computed, startIndex, firstLegSpeedKt)
  local route = {}
  local state = stateOrGroup and stateOrGroup.assignment and stateOrGroup or nil
  local group = state and state.assignment.group or stateOrGroup
  local groupCoordinate = self:_GetGroupCoordinate(group)
  local routeMode = "DIRECT_WP"
  local routeDetails = "route follows active waypoint sequence"

  if groupCoordinate then
    local vec2 = self:_CoordinateToVec2(groupCoordinate)
    table.insert(route, self:_BuildVec2RoutePoint(vec2, group.GetAltitude and group:GetAltitude() or 0, firstLegSpeedKt))
  end

  local interceptVec2, interceptDetails = self:_GetLineInterceptVec2(state, computed, startIndex)
  if interceptVec2 then
    table.insert(route, self:_BuildVec2RoutePoint(interceptVec2, group.GetAltitude and group:GetAltitude() or 0, firstLegSpeedKt))
    routeMode = "INTERCEPT_LINE"
    routeDetails = interceptDetails or "intercept planned track"
  end

  for index = startIndex or 1, #(computed.waypoints or {}) do
    local waypoint = computed.waypoints[index]
    local source = waypoint.source or waypoint
    if source.type ~= "TAKE_OFF" then
      local speedKt = index == startIndex and firstLegSpeedKt or self:_GetWaypointSpeedKt(waypoint)
      local routePoint = self:_BuildRoutePoint(waypoint, speedKt)
      if routePoint then
        table.insert(route, routePoint)
      end
    end
  end

  return route, routeMode, routeDetails
end

function MosieAiPlanner:_RetaskRoute(state, reason, firstLegSpeedKt)
  local now = timer and timer.getTime() or 0
  if state.lastRetaskTime and now - state.lastRetaskTime < self.Config.retaskCooldownSeconds then
    return false
  end

  local computed = self:_GetComputedPlan(state.assignment)
  if not computed or not computed.valid then
    return false
  end

  local route, routeMode, routeDetails = self:_BuildRoute(state, computed, state.currentWpIndex or 2, firstLegSpeedKt)
  if #route < 2 then
    return false
  end

  state.assignment.group:Route(route, 1)
  state.lastRetaskTime = now
  state.lastRouteReason = reason or "route"
  self:_SetAiMode(state, routeMode or "DIRECT_WP", state.lastRouteReason, routeDetails or "route follows active waypoint sequence")
  self:_AppendAiCommandDump(state, "ROUTE", string.format(
    "reason=%s route_points=%d first_leg_speed_kt=%s %s",
    tostring(state.lastRouteReason),
    #route,
    firstLegSpeedKt and string.format("%.0f", firstLegSpeedKt) or "---",
    tostring(routeDetails or "")
  ))
  self:_Log(string.format("retasked %s: %s", state.assignment.groupName, state.lastRouteReason))
  return true
end

function MosieAiPlanner:_MaybeStartUncontrolled(state, computed)
  local airborne = self:_IsGroupAirborne(state.assignment.group)
  if state.startCommanded then
    if not airborne then
      local elapsed = state.startCommandTime and ((timer and timer.getTime and timer.getTime() or 0) - state.startCommandTime) or 0
      self:_Log(string.format("%s waiting for airborne after StartUncontrolled, elapsed %ds", state.assignment.groupName, math.max(0, math.floor(elapsed + 0.5))))
    end
    return
  end

  if airborne then
    return
  end

  local takeoff = computed and computed.waypoints and computed.waypoints[1]
  if not takeoff or not takeoff.etaSec then
    return
  end

  local secondsToTakeoff = self:_GetSecondsToClockSeconds(takeoff.etaSec)
  if secondsToTakeoff then
    self:_Log(string.format(
      "%s wake window: takeoff in %ds, lead %ds",
      state.assignment.groupName,
      math.floor(secondsToTakeoff + 0.5),
      self.Config.startLeadSeconds
    ))
  end

  if secondsToTakeoff and secondsToTakeoff <= self.Config.startLeadSeconds then
    if type(state.assignment.group.StartUncontrolled) == "function" then
      state.assignment.group:StartUncontrolled()
      state.startCommanded = true
      state.startCommandTime = timer and timer.getTime and timer.getTime() or 0
      self:_AppendAiCommandDump(state, "START_UNCONTROLLED", string.format("seconds_to_takeoff=%.0f", secondsToTakeoff or 0))
      self:_Log(string.format("StartUncontrolled sent to %s", state.assignment.groupName))
    else
      self:_LogStateOnce(state, "start-unsupported", string.format("%s has no StartUncontrolled method; DCS/ME takeoff control required", state.assignment.groupName))
    end
  end
end

function MosieAiPlanner:_AdvanceArrivedWaypoint(state, computed)
  local waypoint = computed.waypoints[state.currentWpIndex]
  if not waypoint then
    return
  end

  local groupCoordinate = self:_GetGroupCoordinate(state.assignment.group)
  local source = waypoint.source or waypoint
  local distNm = self:_GetDistanceNm(groupCoordinate, source.coordinate)
  if distNm and distNm <= self.Config.waypointArrivalRadiusNm and state.currentWpIndex < #computed.waypoints then
    local previousIndex = state.currentWpIndex
    state.currentWpIndex = state.currentWpIndex + 1
    state.holdStarted = false
    state.lastRetaskTime = nil
    self:_AppendAiCommandDump(state, "WP_ADVANCE", string.format(
      "from=WP%02d to=WP%02d dist_nm=%.3f",
      previousIndex,
      state.currentWpIndex,
      distNm
    ))
    self:_RetaskRoute(state, "next waypoint")
  end
end

function MosieAiPlanner:_TickHold(state, computed, waypoint)
  local source = waypoint.source or waypoint
  if source.type ~= "HOLD" or not waypoint.etaSec then
    return false
  end

  local secondsToHold = self:_GetSecondsToClockSeconds(waypoint.etaSec)
  if not secondsToHold or secondsToHold > 0 then
    return false
  end

  local holdDuration = waypoint.holdDurationSec or 0
  local secondsToExit = self:_GetSecondsToClockSeconds((waypoint.etaSec + holdDuration) % (SECONDS_PER_DAY or 86400))
  if secondsToExit and secondsToExit <= 0 then
    if state.currentWpIndex < #computed.waypoints then
      local previousIndex = state.currentWpIndex
      state.currentWpIndex = state.currentWpIndex + 1
      state.holdStarted = false
      state.lastRetaskTime = nil
      self:_AppendAiCommandDump(state, "HOLD_EXIT", string.format("from=WP%02d to=WP%02d", previousIndex, state.currentWpIndex))
      self:_RetaskRoute(state, "hold exit")
    end
    return true
  end

  self:_SetAiMode(state, "HOLD", "hold active", string.format("WP%02d", source.order or state.currentWpIndex or 0))

  if not state.holdStarted and type(state.assignment.group.TaskOrbitCircleAtVec2) == "function" then
    local vec2 = self:_CoordinateToVec2(source.coordinate)
    local task = state.assignment.group:TaskOrbitCircleAtVec2(
      vec2,
      self:_FeetToMeters(waypoint.resolvedAltFt or source.altitudeFt or 0),
      self:_KnotsToMps(self.Config.holdSpeedKt)
    )
    state.assignment.group:SetTask(task, 1)
    state.holdStarted = true
    self:_AppendAiCommandDump(state, "SET_TASK_HOLD_ORBIT", string.format(
      "wp=WP%02d speed_kt=%.0f alt_m=%.0f",
      source.order or state.currentWpIndex or 0,
      self.Config.holdSpeedKt,
      self:_FeetToMeters(waypoint.resolvedAltFt or source.altitudeFt or 0)
    ))
    self:_Log(string.format("hold task sent to %s", state.assignment.groupName))
  end

  return true
end

function MosieAiPlanner:_StartTimingOrbit(state, waypoint, rawRequiredSpeed, orbitWaypoint)
  if state.timingOrbit then
    return true
  end

  local group = state.assignment.group
  if type(group.TaskOrbitCircleAtVec2) ~= "function" or type(group.SetTask) ~= "function" then
    self:_LogStateOnce(state, "timing-orbit-unsupported", string.format("%s timing orbit skipped: orbit task unsupported", state.assignment.groupName))
    return false
  end

  local orbitSource = orbitWaypoint and (orbitWaypoint.source or orbitWaypoint) or nil
  local groupCoordinate = self:_GetGroupCoordinate(group)
  local orbitCoordinate = orbitSource and orbitSource.coordinate or groupCoordinate
  local vec2 = self:_CoordinateToVec2(orbitCoordinate)
  if not vec2 then
    return false
  end

  local altitudeMeters = group.GetAltitude and group:GetAltitude() or self:_FeetToMeters((waypoint and waypoint.resolvedAltFt) or 0)
  local task = group:TaskOrbitCircleAtVec2(vec2, altitudeMeters, self:_KnotsToMps(self.Config.holdSpeedKt))
  group:SetTask(task, 1)
  state.timingOrbit = true
  state.timingOrbitWaypointIndex = state.currentWpIndex
  state.lastRetaskTime = nil
  self:_SetAiMode(state, "TIMING_ORBIT", "early_min_speed", string.format("raw_required_speed=%.0f", rawRequiredSpeed or 0))
  local source = waypoint and (waypoint.source or waypoint) or nil
  self:_AppendAiCommandDump(state, "SET_TASK_TIMING_ORBIT", string.format(
    "at=WP%02d before=WP%02d raw_required_speed_kt=%.0f speed_kt=%.0f alt_m=%.0f pos_x=%.1f pos_y=%.1f",
    orbitSource and orbitSource.order or 0,
    source and source.order or 0,
    rawRequiredSpeed or 0,
    self.Config.holdSpeedKt,
    altitudeMeters or 0,
    vec2.x or 0,
    vec2.y or 0
  ))
  self:_Log(string.format(
    "timing orbit sent to %s at WP%02d before WP%02d: required %.0f kt below AI minimum %.0f kt",
    state.assignment.groupName,
    orbitSource and orbitSource.order or 0,
    source and source.order or 0,
    rawRequiredSpeed or 0,
    self.Config.minSpeedKt
  ))
  return true
end

function MosieAiPlanner:_StopTimingOrbit(state, requiredSpeed)
  if not state.timingOrbit then
    return false
  end

  state.timingOrbit = false
  state.timingOrbitWaypointIndex = nil
  state.lastRetaskTime = nil
  self:_SetAiMode(state, "DIRECT_WP", "timing_orbit_exit", string.format("required_speed=%.0f", requiredSpeed or 0))
  self:_AppendAiCommandDump(state, "TIMING_ORBIT_EXIT", string.format("required_speed_kt=%.0f", requiredSpeed or 0))
  return self:_RetaskRoute(state, "timing orbit exit", requiredSpeed)
end

function MosieAiPlanner:_RequiredSpeedToWaypointKt(state, waypoint)
  local groupCoordinate = self:_GetGroupCoordinate(state.assignment.group)
  local source = waypoint.source or waypoint
  local distNm = self:_GetDistanceNm(groupCoordinate, source.coordinate)
  local secondsToEta = self:_GetSecondsToClockSeconds(waypoint.etaSec)

  if not distNm or not secondsToEta or secondsToEta <= 0 then
    return nil, nil
  end

  local requiredSpeed = distNm / secondsToEta * 3600
  local currentSpeed = state.assignment.group.GetVelocityKNOTS and state.assignment.group:GetVelocityKNOTS() or self:_GetWaypointSpeedKt(waypoint) or requiredSpeed
  local predictedSeconds = currentSpeed > 1 and distNm / currentSpeed * 3600 or secondsToEta
  local etaErrorSeconds = predictedSeconds - secondsToEta
  return self:_Clamp(requiredSpeed, self.Config.minSpeedKt, self.Config.maxSpeedKt), etaErrorSeconds, requiredSpeed, currentSpeed, secondsToEta
end

function MosieAiPlanner:_TickAssignment(state)
  if not self:_IsGroupExisting(state.assignment.group) then
    return
  end

  local computed = self:_GetComputedPlan(state.assignment)
  if not computed or not computed.valid or not computed.waypoints then
    return
  end

  state.currentWpIndex = state.currentWpIndex or 2
  self:_TickZoneDump(state, computed)
  self:_MaybeStartUncontrolled(state, computed)

  if not self:_IsGroupAirborne(state.assignment.group) then
    self:_SetAiMode(state, "GROUND", "not_airborne", "waiting for DCS/ME taxi/takeoff or StartUncontrolled")
    self:_TickFlightSampleDump(state, computed)
    self:_LogStateOnce(state, "route-skip-not-airborne", string.format("%s route skipped: not airborne; use DCS/ME route for taxi/takeoff", state.assignment.groupName))
    return
  end

  local waypoint = computed.waypoints[state.currentWpIndex]
  if not waypoint then
    return
  end

  if self:_TickHold(state, computed, waypoint) then
    self:_TickFlightSampleDump(state, computed)
    return
  end

  self:_AdvanceArrivedWaypoint(state, computed)
  waypoint = computed.waypoints[state.currentWpIndex]
  if not waypoint or not waypoint.etaSec then
    self:_SetAiMode(state, "DIRECT_WP", "no_eta", "route follows active waypoint sequence")
    self:_TickFlightSampleDump(state, computed)
    return
  end

  local requiredSpeed, etaErrorSeconds, rawRequiredSpeed = self:_RequiredSpeedToWaypointKt(state, waypoint)
  if requiredSpeed and etaErrorSeconds and etaErrorSeconds < -self.Config.etaToleranceSeconds and rawRequiredSpeed and rawRequiredSpeed < self.Config.minSpeedKt then
    if self:_StartTimingOrbit(state, waypoint, rawRequiredSpeed, computed.waypoints[(state.currentWpIndex or 2) - 1]) then
      self:_TickFlightSampleDump(state, computed)
      return
    end
  elseif state.timingOrbit and requiredSpeed then
    if self:_StopTimingOrbit(state, requiredSpeed) then
      self:_TickFlightSampleDump(state, computed)
      return
    end
  end

  if requiredSpeed and etaErrorSeconds and math.abs(etaErrorSeconds) > self.Config.etaToleranceSeconds then
    self:_RetaskRoute(state, string.format("ETA %+ds", math.floor(etaErrorSeconds + 0.5)), requiredSpeed)
  elseif not state.lastRetaskTime then
    self:_RetaskRoute(state, "initial airborne route")
  else
    self:_SetAiMode(state, "DIRECT_WP", "within_eta_tolerance", "route follows active waypoint sequence")
  end
  self:_TickFlightSampleDump(state, computed)
end

function MosieAiPlanner:Tick()
  if not self.Config.enabled then
    return
  end

  local plans = self:_GetPlans()
  local assignments = self:_DiscoverAssignments(plans)
  self.States = self.States or {}

  for _, assignment in ipairs(assignments) do
    local state = self.States[assignment.groupName]
    if not state then
      state = {assignment = assignment, currentWpIndex = 2}
      self.States[assignment.groupName] = state
    end
    state.assignment = assignment
    self:_TickAssignment(state)
  end
end

function MosieAiPlanner:Start()
  if not self.Config.enabled or self.Scheduler then
    return
  end

  self.States = self.States or {}
  self:_ResetAiZoneDumpFile()
  self.Scheduler = SCHEDULER:New(nil, function()
    MosieAiPlanner:Tick()
  end, {}, 1, self.Config.tickInterval)
  self:_Log(string.format("scheduled every %d seconds", self.Config.tickInterval))
end

if MOSIE_AI_PLANNER_AUTO_START ~= false then
  MosieAiPlanner:Start()
end
