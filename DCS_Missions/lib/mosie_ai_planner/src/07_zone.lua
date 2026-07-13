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

  local speedKt   = group.GetVelocityKNOTS and group:GetVelocityKNOTS() or nil
  local altitude  = group.GetAltitude and group:GetAltitude() or nil

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
    radiusNm   and string.format("%.3f", radiusNm)   or "---",
    etaSec     and self:_FormatClock(etaSec)          or "---",
    deltaSec   and string.format("%+.0f", deltaSec)   or "---",
    speedKt    and string.format("%.0f", speedKt)     or "---",
    altitude   and string.format("%.0f", altitude)    or "---",
    vec2.x     and string.format("%.1f", vec2.x)      or "---",
    vec2.y     and string.format("%.1f", vec2.y)      or "---"
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

  local currentIndex    = state.currentWpIndex or 2
  local previousWaypoint = self:_GetPlanWaypoint(state, currentIndex - 1)
  local waypoint         = self:_GetPlanWaypoint(state, currentIndex)
  if not previousWaypoint or not waypoint then
    return nil, nil
  end

  return navigator:_CalculateXte(previousWaypoint, waypoint, groupCoordinate)
end

function MosieAiPlanner:_FormatAiFlightSample(state, computed)
  local group            = state.assignment.group
  local groupCoordinate  = self:_GetGroupCoordinate(group)
  local vec2             = self:_CoordinateToVec2(groupCoordinate) or {}
  local currentIndex     = state.currentWpIndex or 2
  local planWaypoint     = self:_GetPlanWaypoint(state, currentIndex)
  local computedWaypoint = self:_GetComputedWaypoint(computed, currentIndex)
  local waypoint = computedWaypoint and (computedWaypoint.source or (computedWaypoint.coordinate and computedWaypoint)) or planWaypoint

  local distanceNm              = waypoint and waypoint.coordinate and self:_GetDistanceNm(groupCoordinate, waypoint.coordinate) or nil
  local speedKt                 = group.GetVelocityKNOTS and group:GetVelocityKNOTS() or nil
  local actualSecondsToWaypoint = distanceNm and speedKt and speedKt > 1 and distanceNm / speedKt * 3600 or nil
  local plannedEtaSec           = computedWaypoint and computedWaypoint.etaSec or nil
  local actualEtaSec            = actualSecondsToWaypoint and ((self:_GetMissionTime() + actualSecondsToWaypoint) % (SECONDS_PER_DAY or 86400)) or nil
  local plannedSecondsToEta     = plannedEtaSec and self:_GetSecondsToClockSeconds(plannedEtaSec) or nil
  local etaDeltaSec             = nil
  local requiredSpeedKt         = nil
  if distanceNm and plannedSecondsToEta and plannedSecondsToEta > 0 then
    requiredSpeedKt = distanceNm / plannedSecondsToEta * 3600
  end
  if actualSecondsToWaypoint and plannedSecondsToEta then
    etaDeltaSec = actualSecondsToWaypoint - plannedSecondsToEta
  end

  local xteNm, xteSide = self:_GetAiXte(state, groupCoordinate)
  local altitude       = group.GetAltitude and group:GetAltitude() or nil

  return string.format(
    "[%s] AI_FLIGHT_SAMPLE group=\"%s\" plan=\"%s\" mode=%s reason=%s wp=%s type=%s dist_nm=%s plan_eta=%s act_eta=%s eta_delta_sec=%s req_speed_kt=%s speed_kt=%s alt_m=%s xte_nm=%s xte_side=%s last_retask=\"%s\" pos_x=%s pos_y=%s",
    self:_FormatClock(self:_GetMissionTime()),
    tostring(state.assignment.groupName or "---"),
    tostring(state.assignment.planName or "---"),
    tostring(state.aiMode or "UNKNOWN"),
    tostring(state.aiModeReason or "---"),
    waypoint and string.format("WP%02d", waypoint.order or currentIndex) or "---",
    waypoint and tostring(waypoint.type or "---") or "---",
    distanceNm    and string.format("%.3f", distanceNm)    or "---",
    self:_FormatClockOrDash(plannedEtaSec),
    self:_FormatClockOrDash(actualEtaSec),
    self:_FormatSignedSeconds(etaDeltaSec),
    requiredSpeedKt and string.format("%.0f", requiredSpeedKt) or "---",
    speedKt   and string.format("%.0f", speedKt)   or "---",
    altitude  and string.format("%.0f", altitude)  or "---",
    xteNm     and string.format("%.3f", xteNm)     or "---",
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
