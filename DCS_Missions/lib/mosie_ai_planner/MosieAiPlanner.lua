MosieAiPlanner = MosieAiPlanner or {}

local MosieAiPlannerConfigDefaults = {
  enabled = true,
  groupPlanTagPattern = "%[MN:([%w%-]+)%]",
  tickInterval = 30,
  retaskCooldownSeconds = 30,
  etaToleranceSeconds = 15,
  startLeadSeconds = 3 * 60,
  waypointArrivalRadiusNm = 1.0,
  minSpeedKt = 140,
  maxSpeedKt = 300,
  holdSpeedKt = 140,
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
    if planName and plans[planName] and group:IsAlive() and self:_IsAiGroup(group) then
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

function MosieAiPlanner:_GetWaypointSpeedKt(computedWaypoint)
  return computedWaypoint and (computedWaypoint.legGsKt or computedWaypoint.legTasKt or computedWaypoint.speedKt) or nil
end

function MosieAiPlanner:_BuildRoutePoint(computedWaypoint, speedKt)
  local waypoint = computedWaypoint.source or computedWaypoint
  local vec2 = self:_CoordinateToVec2(waypoint.coordinate)
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
    routePoint.type = "Land"
    routePoint.action = "Landing"
  end

  return routePoint
end

function MosieAiPlanner:_BuildRoute(group, computed, startIndex, firstLegSpeedKt)
  local route = {}
  local groupCoordinate = self:_GetGroupCoordinate(group)

  if groupCoordinate then
    local vec2 = self:_CoordinateToVec2(groupCoordinate)
    table.insert(route, {
      x = vec2.x,
      y = vec2.y,
      alt = group.GetAltitude and group:GetAltitude() or 0,
      alt_type = "BARO",
      speed = self:_KnotsToMps(firstLegSpeedKt or self.Config.minSpeedKt),
      speed_locked = true,
      type = "Turning Point",
      action = "Turning Point",
      task = {id = "ComboTask", params = {tasks = {}}},
    })
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

  return route
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

  local route = self:_BuildRoute(state.assignment.group, computed, state.currentWpIndex or 2, firstLegSpeedKt)
  if #route < 2 then
    return false
  end

  state.assignment.group:Route(route, 1)
  state.lastRetaskTime = now
  state.lastRouteReason = reason or "route"
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
    state.currentWpIndex = state.currentWpIndex + 1
    state.holdStarted = false
    state.lastRetaskTime = nil
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
      state.currentWpIndex = state.currentWpIndex + 1
      state.holdStarted = false
      state.lastRetaskTime = nil
      self:_RetaskRoute(state, "hold exit")
    end
    return true
  end

  if not state.holdStarted and type(state.assignment.group.TaskOrbitCircleAtVec2) == "function" then
    local vec2 = self:_CoordinateToVec2(source.coordinate)
    local task = state.assignment.group:TaskOrbitCircleAtVec2(
      vec2,
      self:_FeetToMeters(waypoint.resolvedAltFt or source.altitudeFt or 0),
      self:_KnotsToMps(self.Config.holdSpeedKt)
    )
    state.assignment.group:SetTask(task, 1)
    state.holdStarted = true
    self:_Log(string.format("hold task sent to %s", state.assignment.groupName))
  end

  return true
end

function MosieAiPlanner:_StartTimingOrbit(state, waypoint, rawRequiredSpeed)
  if state.timingOrbit then
    return true
  end

  local group = state.assignment.group
  if type(group.TaskOrbitCircleAtVec2) ~= "function" or type(group.SetTask) ~= "function" then
    self:_LogStateOnce(state, "timing-orbit-unsupported", string.format("%s timing orbit skipped: orbit task unsupported", state.assignment.groupName))
    return false
  end

  local groupCoordinate = self:_GetGroupCoordinate(group)
  local vec2 = self:_CoordinateToVec2(groupCoordinate)
  if not vec2 then
    return false
  end

  local altitudeMeters = group.GetAltitude and group:GetAltitude() or self:_FeetToMeters((waypoint and waypoint.resolvedAltFt) or 0)
  local task = group:TaskOrbitCircleAtVec2(vec2, altitudeMeters, self:_KnotsToMps(self.Config.holdSpeedKt))
  group:SetTask(task, 1)
  state.timingOrbit = true
  state.timingOrbitWaypointIndex = state.currentWpIndex
  state.lastRetaskTime = nil
  self:_Log(string.format(
    "timing orbit sent to %s: required %.0f kt below AI minimum %.0f kt",
    state.assignment.groupName,
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
  if not state.assignment.group:IsAlive() then
    return
  end

  local computed = self:_GetComputedPlan(state.assignment)
  if not computed or not computed.valid or not computed.waypoints then
    return
  end

  state.currentWpIndex = state.currentWpIndex or 2
  self:_MaybeStartUncontrolled(state, computed)

  if not self:_IsGroupAirborne(state.assignment.group) then
    self:_LogStateOnce(state, "route-skip-not-airborne", string.format("%s route skipped: not airborne; use DCS/ME route for taxi/takeoff", state.assignment.groupName))
    return
  end

  local waypoint = computed.waypoints[state.currentWpIndex]
  if not waypoint then
    return
  end

  if self:_TickHold(state, computed, waypoint) then
    return
  end

  self:_AdvanceArrivedWaypoint(state, computed)
  waypoint = computed.waypoints[state.currentWpIndex]
  if not waypoint or not waypoint.etaSec then
    return
  end

  local requiredSpeed, etaErrorSeconds, rawRequiredSpeed = self:_RequiredSpeedToWaypointKt(state, waypoint)
  if requiredSpeed and etaErrorSeconds and etaErrorSeconds < -self.Config.etaToleranceSeconds and rawRequiredSpeed and rawRequiredSpeed < self.Config.minSpeedKt then
    if self:_StartTimingOrbit(state, waypoint, rawRequiredSpeed) then
      return
    end
  elseif state.timingOrbit and requiredSpeed then
    if self:_StopTimingOrbit(state, requiredSpeed) then
      return
    end
  end

  if requiredSpeed and etaErrorSeconds and math.abs(etaErrorSeconds) > self.Config.etaToleranceSeconds then
    self:_RetaskRoute(state, string.format("ETA %+ds", math.floor(etaErrorSeconds + 0.5)), requiredSpeed)
  elseif not state.lastRetaskTime then
    self:_RetaskRoute(state, "initial airborne route")
  end
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
  self.Scheduler = SCHEDULER:New(nil, function()
    MosieAiPlanner:Tick()
  end, {}, 1, self.Config.tickInterval)
  self:_Log(string.format("scheduled every %d seconds", self.Config.tickInterval))
end

if MOSIE_AI_PLANNER_AUTO_START ~= false then
  MosieAiPlanner:Start()
end
