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
