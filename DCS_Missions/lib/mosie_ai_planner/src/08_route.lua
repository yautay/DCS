function MosieAiPlanner:_BuildRoutePoint(computedWaypoint, speedKt)
  local waypoint = computedWaypoint.source or computedWaypoint
  local vec2 = self:_CoordinateToVec2(waypoint.coordinate)
  if not vec2 then
    return nil
  end

  return {
    x          = vec2.x,
    y          = vec2.y,
    alt        = self:_FeetToMeters(computedWaypoint.resolvedAltFt or waypoint.altitudeFt or 0),
    alt_type   = "BARO",
    speed      = self:_KnotsToMps(speedKt or self:_GetWaypointSpeedKt(computedWaypoint) or self.Config.minSpeedKt),
    speed_locked = true,
    type       = "Turning Point",
    action     = "Fly Over Point",
    task       = {id = "ComboTask", params = {tasks = {}}},
  }
end

function MosieAiPlanner:_BuildVec2RoutePoint(vec2, altitudeMeters, speedKt)
  if not vec2 then
    return nil
  end

  return {
    x          = vec2.x,
    y          = vec2.y,
    alt        = altitudeMeters or 0,
    alt_type   = "BARO",
    speed      = self:_KnotsToMps(speedKt or self.Config.minSpeedKt),
    speed_locked = true,
    type       = "Turning Point",
    action     = "Turning Point",
    task       = {id = "ComboTask", params = {tasks = {}}},
  }
end

function MosieAiPlanner:_BuildAirbaseLandRoutePoint(computedWaypoint)
  local waypoint = computedWaypoint.source or computedWaypoint
  local landingAirbase = self:_FindNearestLandingAirbase(waypoint.coordinate)
  if not landingAirbase then
    self:_Log("LANDING: no nearby airdrome found — skipping final Land point")
    return nil
  end

  local airbaseCoordinate = self:_GetAirbaseCoordinate(landingAirbase) or waypoint.coordinate
  local vec2 = self:_CoordinateToVec2(airbaseCoordinate)
  if not vec2 then
    return nil
  end

  local routePoint = {
    x            = vec2.x,
    y            = vec2.y,
    alt          = self:_FeetToMeters(computedWaypoint.resolvedAltFt or waypoint.altitudeFt or 0),
    alt_type     = "BARO",
    speed        = self:_KnotsToMps(self.Config.minSpeedKt),
    speed_locked = false,
    type         = "Land",
    action       = "Landing",
    task         = {id = "ComboTask", params = {tasks = {}}},
  }

  local airbaseId = self:_GetAirbaseId(landingAirbase)
  if airbaseId then
    routePoint.airdromeId = airbaseId
  end

  local airbaseName = self:_GetAirbaseName(landingAirbase)
  if airbaseName then
    routePoint.name = airbaseName
  end

  return routePoint
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
  local currentWaypoint  = computed.waypoints[currentIndex]
  if not previousWaypoint or not currentWaypoint then
    return nil, nil
  end

  local previousSource = previousWaypoint.source or previousWaypoint
  local currentSource  = currentWaypoint.source  or currentWaypoint
  if not previousSource.coordinate or not currentSource.coordinate then
    return nil, nil
  end

  local groupCoordinate       = self:_GetGroupCoordinate(state.assignment.group)
  local distanceToWaypointNm  = self:_GetDistanceNm(groupCoordinate, currentSource.coordinate)
  if not distanceToWaypointNm or distanceToWaypointNm <= self.Config.lineInterceptMinDistanceNm then
    return nil, nil
  end

  local xteNm, xteSide = self:_GetAiXte(state, groupCoordinate)
  if not xteNm or xteNm < self.Config.lineInterceptXteThresholdNm then
    return nil, nil
  end

  local startVec  = previousSource.coordinate:GetVec3()
  local endVec    = currentSource.coordinate:GetVec3()
  local currentVec = groupCoordinate:GetVec3()
  local legX      = endVec.x - startVec.x
  local legZ      = endVec.z - startVec.z
  local legLength = math.sqrt(legX * legX + legZ * legZ)
  if legLength <= 0 then
    return nil, nil
  end

  local currentX    = currentVec.x - startVec.x
  local currentZ    = currentVec.z - startVec.z
  local alongMeters = (currentX * legX + currentZ * legZ) / legLength
  if alongMeters < 0 then
    alongMeters = 0
  elseif alongMeters > legLength then
    return nil, nil
  end

  local lookaheadMeters      = (self.Config.lineInterceptLookaheadNm or 0) * 1852
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
  local route      = {}
  local state      = stateOrGroup and stateOrGroup.assignment and stateOrGroup or nil
  local group      = state and state.assignment.group or stateOrGroup
  local groupCoordinate = self:_GetGroupCoordinate(group)
  local routeMode    = "DIRECT_WP"
  local routeDetails = "route follows active waypoint sequence"

  if groupCoordinate then
    local vec2 = self:_CoordinateToVec2(groupCoordinate)
    table.insert(route, self:_BuildVec2RoutePoint(vec2, group.GetAltitude and group:GetAltitude() or 0, firstLegSpeedKt))
  end

  local interceptVec2, interceptDetails = self:_GetLineInterceptVec2(state, computed, startIndex)
  if interceptVec2 then
    table.insert(route, self:_BuildVec2RoutePoint(interceptVec2, group.GetAltitude and group:GetAltitude() or 0, firstLegSpeedKt))
    routeMode    = "INTERCEPT_LINE"
    routeDetails = interceptDetails or "intercept planned track"
  end

  for index = startIndex or 1, #(computed.waypoints or {}) do
    local waypoint = computed.waypoints[index]
    local source   = waypoint.source or waypoint
    if source.type ~= "TAKE_OFF" then
      local speedKt  = index == startIndex and firstLegSpeedKt or self:_GetWaypointSpeedKt(waypoint)
      local routePoint = self:_BuildRoutePoint(waypoint, speedKt)
      if routePoint then
        table.insert(route, routePoint)
      end
    end
  end

  local waypoints = computed.waypoints or {}
  local lastWp = waypoints[#waypoints]
  if lastWp then
    local lastSource = lastWp.source or lastWp
    if lastSource.type == "LANDING" then
      local landPoint = self:_BuildAirbaseLandRoutePoint(lastWp)
      if landPoint then
        table.insert(route, landPoint)
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
  state.lastRetaskTime  = now
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
