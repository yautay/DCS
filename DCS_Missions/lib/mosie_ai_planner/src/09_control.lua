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
      state.startCommanded  = true
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
  local source          = waypoint.source or waypoint
  local distNm          = self:_GetDistanceNm(groupCoordinate, source.coordinate)
  if distNm and distNm <= self.Config.waypointArrivalRadiusNm and state.currentWpIndex < #computed.waypoints then
    local previousIndex   = state.currentWpIndex
    state.currentWpIndex  = state.currentWpIndex + 1
    state.holdStarted     = false
    state.lastRetaskTime  = nil
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

  local holdDuration  = waypoint.holdDurationSec or 0
  local secondsToExit = self:_GetSecondsToClockSeconds((waypoint.etaSec + holdDuration) % (SECONDS_PER_DAY or 86400))
  if secondsToExit and secondsToExit <= 0 then
    if state.currentWpIndex < #computed.waypoints then
      local previousIndex   = state.currentWpIndex
      state.currentWpIndex  = state.currentWpIndex + 1
      state.holdStarted     = false
      state.lastRetaskTime  = nil
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

  local orbitSource      = orbitWaypoint and (orbitWaypoint.source or orbitWaypoint) or nil
  local groupCoordinate  = self:_GetGroupCoordinate(group)
  local orbitCoordinate  = orbitSource and orbitSource.coordinate or groupCoordinate
  local vec2             = self:_CoordinateToVec2(orbitCoordinate)
  if not vec2 then
    return false
  end

  local altitudeMeters = group.GetAltitude and group:GetAltitude() or self:_FeetToMeters((waypoint and waypoint.resolvedAltFt) or 0)
  local task = group:TaskOrbitCircleAtVec2(vec2, altitudeMeters, self:_KnotsToMps(self.Config.holdSpeedKt))
  group:SetTask(task, 1)
  state.timingOrbit             = true
  state.timingOrbitWaypointIndex = state.currentWpIndex
  state.lastRetaskTime          = nil
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

  state.timingOrbit              = false
  state.timingOrbitWaypointIndex = nil
  state.lastRetaskTime           = nil
  self:_SetAiMode(state, "DIRECT_WP", "timing_orbit_exit", string.format("required_speed=%.0f", requiredSpeed or 0))
  self:_AppendAiCommandDump(state, "TIMING_ORBIT_EXIT", string.format("required_speed_kt=%.0f", requiredSpeed or 0))
  return self:_RetaskRoute(state, "timing orbit exit", requiredSpeed)
end

function MosieAiPlanner:_RequiredSpeedToWaypointKt(state, waypoint)
  local groupCoordinate = self:_GetGroupCoordinate(state.assignment.group)
  local source          = waypoint.source or waypoint
  local distNm          = self:_GetDistanceNm(groupCoordinate, source.coordinate)
  local secondsToEta    = self:_GetSecondsToClockSeconds(waypoint.etaSec)

  if not distNm or not secondsToEta or secondsToEta <= 0 then
    return nil, nil
  end

  local requiredSpeed  = distNm / secondsToEta * 3600
  local currentSpeed   = state.assignment.group.GetVelocityKNOTS and state.assignment.group:GetVelocityKNOTS() or self:_GetWaypointSpeedKt(waypoint) or requiredSpeed
  local predictedSeconds = currentSpeed > 1 and distNm / currentSpeed * 3600 or secondsToEta
  local etaErrorSeconds  = predictedSeconds - secondsToEta
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
