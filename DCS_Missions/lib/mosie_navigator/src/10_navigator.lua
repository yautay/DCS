function MosieNavigator:_SendNavigatorMessage(group, text, duration)
  local messageText = text or ""
  local messageDuration = duration or self.Config.navigatorMessageDuration

  if self:_IsTestMode() then
    local groupName = group and type(group.GetName) == "function" and group:GetName() or "---"
    self:_Log(string.format('TEST_MESSAGE_DUMP_BEGIN group="%s"', groupName))
    self:_Log(messageText)
    self:_Log(string.format('TEST_MESSAGE_DUMP_END group="%s"', groupName))
    MESSAGE:New(string.format("[%s]\n%s", groupName, messageText), messageDuration, "Mosie Navigator"):ToAll()
    return
  end

  MESSAGE:New(messageText, messageDuration, "Mosie Navigator"):ToGroup(group)
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

function MosieNavigator:_GetSecondsToClockSeconds(clockSeconds)
  if clockSeconds == nil then
    return nil
  end

  local now = timer.getAbsTime() % SECONDS_PER_DAY
  local delta = (clockSeconds % SECONDS_PER_DAY) - now

  if delta < -SECONDS_PER_HALF_DAY then
    delta = delta + SECONDS_PER_DAY
  elseif delta > SECONDS_PER_HALF_DAY then
    delta = delta - SECONDS_PER_DAY
  end

  return delta
end

function MosieNavigator:_GetInitialNavigatorWpIndexByTot(plan, rolexSeconds, computed)
  for index, waypoint in ipairs(plan.waypoints) do
    local computedWaypoint = computed and computed.valid and computed.waypoints and computed.waypoints[index]
    local secondsToTot = computedWaypoint and self:_GetSecondsToClockSeconds(computedWaypoint.etaSec)
      or self:_GetSecondsToWaypointTot(waypoint, rolexSeconds or 0)
    if waypoint.type == "HOLD" and secondsToTot and secondsToTot <= 0 then
      local holdDurationSeconds = computedWaypoint and (computedWaypoint.holdDurationSec or 0)
        or self:_GetNavigatorHoldDurationSecondsForPlan(plan, index, rolexSeconds or 0)
      if secondsToTot + holdDurationSeconds > 0 then
        return index
      end
    end

    if secondsToTot and secondsToTot > 0 and waypoint.type ~= "TAKE_OFF" then
      return index
    end
  end

  return self:_GetInitialNavigatorWpIndex(plan)
end

function MosieNavigator:_GetNavigatorState(group, plan, rolexSeconds, baseRolexSeconds, pilotRolexSeconds)
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
      baseRolexSeconds = baseRolexSeconds or rolexSeconds or 0,
      missionRolexSeconds = self.MissionRolexSeconds or 0,
      pilotRolexSeconds = pilotRolexSeconds or 0,
      currentWpIndex = self:_GetInitialNavigatorWpIndex(plan),
      reportInterval = self.Config.navigatorReportIntervalDefault,
      lastReportTime = nil,
      callouts = {},
      timedCallouts = {},
    }
    self.NavigatorStates[groupKey] = state
  end

  state.group = group
  state.plan = plan
  state.rolexSeconds = rolexSeconds or 0
  state.baseRolexSeconds = baseRolexSeconds or state.baseRolexSeconds or state.rolexSeconds
  state.missionRolexSeconds = self.MissionRolexSeconds or 0
  state.pilotRolexSeconds = pilotRolexSeconds or state.pilotRolexSeconds or 0
  return state
end

function MosieNavigator:_GetAdjustedTotSeconds(waypoint, rolexSeconds)
  if not waypoint.timeOnTargetSeconds then
    return nil
  end

  return (waypoint.timeOnTargetSeconds + (rolexSeconds or 0)) % SECONDS_PER_DAY
end

function MosieNavigator:_GetSecondsToWaypointTot(waypoint, rolexSeconds)
  if not waypoint then
    return nil
  end

  local adjustedTot = self:_GetAdjustedTotSeconds(waypoint, rolexSeconds)
  if not adjustedTot then
    return nil
  end

  return self:_GetSecondsToClockSeconds(adjustedTot)
end

function MosieNavigator:_GetTakeoffWaypoint(plan)
  if not plan or not plan.waypoints then
    return nil
  end

  local waypoint = plan.waypoints[1]
  if waypoint and waypoint.type == "TAKE_OFF" then
    return waypoint
  end

  return nil
end

function MosieNavigator:_IsNavigatorGroupAirborne(group)
  if group and type(group.IsAirborne) == "function" then
    return group:IsAirborne()
  end

  if group and type(group.IsAir) == "function" then
    return group:IsAir()
  end

  return false
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

function MosieNavigator:_FormatDurationHoursMinutes(seconds)
  if not seconds then
    return "--"
  end

  local prefix = ""
  if seconds < 0 then
    prefix = "-"
    seconds = -seconds
  end

  local totalMinutes = math.ceil(seconds / 60)
  local hours = math.floor(totalMinutes / 60)
  local minutes = totalMinutes % 60
  return string.format("%s%02d:%02d", prefix, hours, minutes)
end

function MosieNavigator:_FormatCountdown(seconds)
  if not seconds then
    return "--"
  end

  local prefix = ""
  if seconds < 0 then
    prefix = "-"
    seconds = -seconds
  end

  seconds = math.floor(seconds + 0.5)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local remainingSeconds = seconds % 60

  if hours > 0 then
    return string.format("%s%d:%02d:%02d", prefix, hours, minutes, remainingSeconds)
  end

  return string.format("%s%d:%02d", prefix, minutes, remainingSeconds)
end

function MosieNavigator:_FormatTimedCalloutReason(seconds)
  if seconds and seconds >= 60 and seconds % 60 == 0 then
    return string.format("%d min", seconds / 60)
  end

  return string.format("%d sec", seconds or 0)
end

function MosieNavigator:_GetNavigatorWaypointAltitudeFt(plan, index)
  if not plan or not plan.waypoints then
    return nil
  end

  for waypointIndex = index, 1, -1 do
    local waypoint = plan.waypoints[waypointIndex]
    if waypoint and waypoint.altitudeFt then
      return waypoint.altitudeFt
    end
  end

  return 0
end

function MosieNavigator:_GetNavigatorWaypointLabel(waypoint)
  if not waypoint then
    return "WP--"
  end

  if waypoint.type == "TARGET" then
    return string.format("TARGET WP%02d %s", waypoint.order, waypoint.name)
  end

  if waypoint.type == "HOLD" then
    return string.format("HOLD WP%02d %s", waypoint.order, waypoint.name)
  end

  if waypoint.type == "LANDING" then
    return string.format("HOME PLATE WP%02d %s", waypoint.order, waypoint.name)
  end

  return string.format("WP%02d %s", waypoint.order, waypoint.name)
end

function MosieNavigator:_GetNavigatorComputedWaypoint(state, index)
  if type(self._GetActiveComputedPlan) ~= "function" and type(self._GetComputedPlan) ~= "function" then
    return nil
  end

  local computed = nil
  if type(self._GetActiveComputedPlan) == "function" then
    computed = self:_GetActiveComputedPlan(
      state.plan,
      state.baseRolexSeconds or state.rolexSeconds or 0,
      (state.missionRolexSeconds or 0) + (state.pilotRolexSeconds or 0)
    )
  else
    computed = self:_GetComputedPlan(state.plan, state.rolexSeconds)
  end

  if not computed or not computed.valid or not computed.waypoints then
    return nil
  end

  return computed.waypoints[index]
end

function MosieNavigator:_GetNavigatorComputedWaypointForPlan(plan, index, rolexSeconds)
  if type(self._GetComputedPlan) ~= "function" then
    return nil
  end

  local computed = self:_GetComputedPlan(plan, rolexSeconds or 0)
  if not computed or not computed.valid or not computed.waypoints then
    return nil
  end

  return computed.waypoints[index]
end

function MosieNavigator:_GetSecondsToNavigatorWaypointEta(state, index)
  local computedWaypoint = self:_GetNavigatorComputedWaypoint(state, index)
  if computedWaypoint and computedWaypoint.etaSec ~= nil then
    return self:_GetSecondsToClockSeconds(computedWaypoint.etaSec)
  end

  local waypoint = state.plan and state.plan.waypoints and state.plan.waypoints[index]
  return self:_GetSecondsToWaypointTot(waypoint, state.rolexSeconds)
end

function MosieNavigator:_GetNavigatorHoldDurationSeconds(state, index)
  local computedWaypoint = self:_GetNavigatorComputedWaypoint(state, index)
  if computedWaypoint and computedWaypoint.holdDurationSec then
    return computedWaypoint.holdDurationSec
  end

  local waypoint = state.plan.waypoints[index]
  return (waypoint and waypoint.holdDurationSec) or 0
end

function MosieNavigator:_GetNavigatorHoldDurationSecondsForPlan(plan, index, rolexSeconds)
  local computedWaypoint = self:_GetNavigatorComputedWaypointForPlan(plan, index, rolexSeconds)
  if computedWaypoint and computedWaypoint.holdDurationSec then
    return computedWaypoint.holdDurationSec
  end

  local waypoint = plan and plan.waypoints and plan.waypoints[index]
  return (waypoint and waypoint.holdDurationSec) or 0
end

function MosieNavigator:_BuildNavigatorXtePhrase(state, waypoint, groupCoordinate)
  local previousWaypoint = state.plan.waypoints[state.currentWpIndex - 1]
  local xteNm, xteSide = self:_CalculateXte(previousWaypoint, waypoint, groupCoordinate)
  if not xteNm then
    return "We are on track."
  end

  local roundedXteNm = math.floor(xteNm + 0.5)
  if roundedXteNm < 1 then
    return "We are on track."
  end

  local sideText = xteSide == "stbd" and "starboard" or xteSide
  return string.format("We are approx. %d NM %s of track.", roundedXteNm, sideText)
end

function MosieNavigator:_GetSecondsToNavigatorHoldExit(state, index)
  local secondsToArrival = self:_GetSecondsToNavigatorWaypointEta(state, index)
  if not secondsToArrival then
    return nil
  end

  return secondsToArrival + self:_GetNavigatorHoldDurationSeconds(state, index)
end

function MosieNavigator:_BuildNavigatorTakeoffMessage(state, reason)
  local secondsToTakeoff = self:_GetSecondsToNavigatorWaypointEta(state, 1)
  return string.format("NAV: Brake release in %s. Stand by.", self:_FormatCountdown(secondsToTakeoff))
end

function MosieNavigator:_BuildNavigatorWaypointCalloutMessage(state, reason)
  local group = state.group
  local waypoint = state.plan.waypoints[state.currentWpIndex]

  if not waypoint then
    return "NAV: no active waypoint"
  end

  local groupCoordinate = group:GetCoordinate()
  local secondsToTot = self:_GetSecondsToNavigatorWaypointEta(state, state.currentWpIndex)
  local currentAltitudeFt = UTILS.MetersToFeet(group:GetAltitude(false) or 0)
  local headingTrue, _, requiredIas = self:_CalculateWindCorrectedGuidance(groupCoordinate, waypoint, secondsToTot, currentAltitudeFt)
  local headingMagnetic = self:_FormatMagneticHeading(headingTrue, groupCoordinate)
  local plannedAltitudeFt = self:_GetNavigatorWaypointAltitudeFt(state.plan, state.currentWpIndex)

  return string.format(
    "NAV: %s in %s. Steer %sM, height %s feet, IAS %s knots. %s",
    self:_GetNavigatorWaypointLabel(waypoint),
    self:_FormatCountdown(secondsToTot),
    headingMagnetic,
    self:_FormatOptional(plannedAltitudeFt, "%.0f"),
    self:_FormatSpeed(requiredIas),
    self:_BuildNavigatorXtePhrase(state, waypoint, groupCoordinate)
  )
end

function MosieNavigator:_BuildNavigatorCourseChangeMessage(state)
  local group = state.group
  local waypoint = state.plan.waypoints[state.currentWpIndex]

  if not waypoint then
    return "NAV: no active waypoint"
  end

  local groupCoordinate = group:GetCoordinate()
  local secondsToTot = self:_GetSecondsToNavigatorWaypointEta(state, state.currentWpIndex)
  local currentAltitudeFt = UTILS.MetersToFeet(group:GetAltitude(false) or 0)
  local headingTrue, _, requiredIas = self:_CalculateWindCorrectedGuidance(groupCoordinate, waypoint, secondsToTot, currentAltitudeFt)
  local headingMagnetic = self:_FormatMagneticHeading(headingTrue, groupCoordinate)
  local plannedAltitudeFt = self:_GetNavigatorWaypointAltitudeFt(state.plan, state.currentWpIndex)

  return string.format(
    "NAV: Set course for %s. Steer %sM, height %s feet, IAS %s knots, ETA %s. %s",
    self:_GetNavigatorWaypointLabel(waypoint),
    headingMagnetic,
    self:_FormatOptional(plannedAltitudeFt),
    self:_FormatSpeed(requiredIas),
    self:_FormatCountdown(secondsToTot),
    self:_BuildNavigatorXtePhrase(state, waypoint, groupCoordinate)
  )
end

function MosieNavigator:_BuildNavigatorHoldEntryMessage(state, holdRemainingSeconds)
  local waypoint = state.plan.waypoints[state.currentWpIndex]
  return string.format(
    "NAV: Holding at %s. Remain in hold %s.",
    self:_GetNavigatorWaypointLabel(waypoint),
    self:_FormatCountdown(holdRemainingSeconds)
  )
end

function MosieNavigator:_BuildNavigatorHoldRemainingMessage(state, reason, holdRemainingSeconds)
  local waypoint = state.plan.waypoints[state.currentWpIndex]
  return string.format(
    "NAV: %s, %s to leave hold.",
    self:_GetNavigatorWaypointLabel(waypoint),
    self:_FormatCountdown(holdRemainingSeconds)
  )
end

function MosieNavigator:_BuildNavigatorHoldExitMessage(state)
  local message = self:_BuildNavigatorCourseChangeMessage(state)
  return string.gsub(message, "^NAV: Set course", "NAV: Leaving hold. Set course")
end

function MosieNavigator:_TickNavigatorHold(state, waypoint, now)
  local holdRemainingSeconds = self:_GetSecondsToNavigatorHoldExit(state, state.currentWpIndex)

  if not holdRemainingSeconds or holdRemainingSeconds <= 0 then
    if state.currentWpIndex < #state.plan.waypoints then
      self:_SetNavigatorWaypoint(state, state.currentWpIndex + 1, "hold exit")
      return true
    end

    return false
  end

  state.holdEntries = state.holdEntries or {}
  local holdState = state.holdEntries[state.currentWpIndex] or {}
  state.holdEntries[state.currentWpIndex] = holdState

  if not holdState.entryAnnounced then
    holdState.entryAnnounced = true
    state.lastReportTime = now
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorHoldEntryMessage(state, holdRemainingSeconds))
    return true
  end

  local eventKey = string.format("HOLD_EXIT:%d", state.currentWpIndex)
  local sentCallout = self:_RunTimedCallouts(state, eventKey, holdRemainingSeconds, self.Config.navigatorHoldExitCalloutSeconds, function(calloutSeconds)
    return self:_BuildNavigatorHoldRemainingMessage(state, self:_FormatTimedCalloutReason(calloutSeconds), holdRemainingSeconds)
  end)

  if sentCallout then
    return true
  end

  local suppressIntervalSeconds = self.Config.navigatorHoldExitCalloutSeconds and self.Config.navigatorHoldExitCalloutSeconds[1]
  if suppressIntervalSeconds and holdRemainingSeconds <= suppressIntervalSeconds then
    return true
  end

  if not state.lastReportTime or now - state.lastReportTime >= state.reportInterval then
    state.lastReportTime = now
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorHoldRemainingMessage(state, "report", holdRemainingSeconds))
    return true
  end

  return true
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
  local secondsToTot = self:_GetSecondsToNavigatorWaypointEta(state, state.currentWpIndex)
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
  state.timedCallouts = {}
  state.holdEntries = {}
  for _, calloutSeconds in ipairs(self.Config.navigatorCalloutSeconds) do
    state.callouts[calloutSeconds] = false
  end
end

function MosieNavigator:_RunTimedCallouts(state, eventKey, secondsToEvent, thresholds, buildMessage)
  if not secondsToEvent or secondsToEvent <= 0 then
    return false
  end

  state.timedCallouts = state.timedCallouts or {}
  local eventCallouts = state.timedCallouts[eventKey]
  if not eventCallouts then
    eventCallouts = {}
    state.timedCallouts[eventKey] = eventCallouts
  end

  for _, calloutSeconds in ipairs(thresholds or {}) do
    if secondsToEvent <= calloutSeconds and not eventCallouts[calloutSeconds] then
      eventCallouts[calloutSeconds] = true
      self:_SendNavigatorMessage(state.group, buildMessage(calloutSeconds))
      return true
    end
  end

  return false
end

function MosieNavigator:_TickNavigatorTakeoff(state, takeoff, secondsToTakeoff, now)
  local eventKey = "TAKE_OFF:brake_release"

  if secondsToTakeoff <= 0 then
    state.timedCallouts = state.timedCallouts or {}
    local eventCallouts = state.timedCallouts[eventKey] or {}
    state.timedCallouts[eventKey] = eventCallouts

    if not eventCallouts.brakeRelease then
      eventCallouts.brakeRelease = true
      state.lastReportTime = now
      self:_SendNavigatorMessage(state.group, "NAV: Brakes! Brakes! Brakes! Commence take-off!")
      return true
    end

    return false
  end

  local sentCallout = self:_RunTimedCallouts(state, eventKey, secondsToTakeoff, self.Config.navigatorTakeoffCalloutSeconds, function(calloutSeconds)
    return self:_BuildNavigatorTakeoffMessage(state, string.format("%d sec", calloutSeconds))
  end)

  if sentCallout then
    return true
  end

  local suppressIntervalSeconds = self.Config.navigatorTakeoffCalloutSeconds and self.Config.navigatorTakeoffCalloutSeconds[1]
  if suppressIntervalSeconds and secondsToTakeoff <= suppressIntervalSeconds then
    return true
  end

  if not state.lastReportTime or now - state.lastReportTime >= state.reportInterval then
    state.lastReportTime = now
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorTakeoffMessage(state, "report"))
    return true
  end

  return true
end

function MosieNavigator:_SetNavigatorWaypoint(state, index, reason)
  if index < 1 or index > #state.plan.waypoints then
    return
  end

  state.currentWpIndex = index
  state.lastReportTime = timer.getTime()
  self:_ResetNavigatorCallouts(state)
  if reason == "new WP" then
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorCourseChangeMessage(state))
  elseif reason == "hold exit" then
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorHoldExitMessage(state))
  else
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, reason or "WP change"))
  end
end

function MosieNavigator:_AdvanceNavigatorWaypoint(state, reason)
  if state.currentWpIndex < #state.plan.waypoints then
    self:_SetNavigatorWaypoint(state, state.currentWpIndex + 1, reason or "next WP")
  end
end

function MosieNavigator:_SetNavigatorEnabled(group, plan, rolexSeconds, enabled, baseRolexSeconds, pilotRolexSeconds)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds, baseRolexSeconds, pilotRolexSeconds)
  state.enabled = enabled

  if enabled then
    local computed = nil
    if type(self._GetActiveComputedPlan) == "function" then
      computed = self:_GetActiveComputedPlan(
        plan,
        state.baseRolexSeconds or rolexSeconds or 0,
        (state.missionRolexSeconds or 0) + (state.pilotRolexSeconds or 0)
      )
    end
    state.currentWpIndex = self:_GetInitialNavigatorWpIndexByTot(plan, rolexSeconds, computed)
    self:_ResetNavigatorCallouts(state)
    local takeoff = self:_GetTakeoffWaypoint(plan)
    local secondsToTakeoff = self:_GetSecondsToNavigatorWaypointEta(state, 1)
    if takeoff and secondsToTakeoff and secondsToTakeoff > 0 and not self:_IsNavigatorGroupAirborne(group) then
      self:_SendNavigatorMessage(group, self:_BuildNavigatorTakeoffMessage(state, "on"))
    else
      self:_SendNavigatorMessage(group, self:_BuildNavigatorWaypointCalloutMessage(state, "on"))
    end
  else
    self:_SendNavigatorMessage(group, "NAV off")
  end
end

function MosieNavigator:_SetNavigatorReportInterval(group, plan, rolexSeconds, interval)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds)
  state.reportInterval = interval
  self:_SendNavigatorMessage(group, string.format("NAV report interval %d sec", interval))
end

function MosieNavigator:_NavigatorStatusNow(group, plan, rolexSeconds, baseRolexSeconds, pilotRolexSeconds)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds, baseRolexSeconds, pilotRolexSeconds)
  local takeoff = self:_GetTakeoffWaypoint(plan)
  local secondsToTakeoff = self:_GetSecondsToNavigatorWaypointEta(state, 1)
  if takeoff and secondsToTakeoff and secondsToTakeoff > 0 and not self:_IsNavigatorGroupAirborne(group) then
    self:_SendNavigatorMessage(group, self:_BuildNavigatorTakeoffMessage(state, "status"))
  else
    self:_SendNavigatorMessage(group, self:_BuildNavigatorWaypointCalloutMessage(state, "status"))
  end
end

function MosieNavigator:_TickNavigatorState(state)
  if not state.enabled or not state.group:IsAlive() then
    return
  end

  local waypoint = state.plan.waypoints[state.currentWpIndex]
  if not waypoint then
    return
  end

  local secondsToTot = self:_GetSecondsToNavigatorWaypointEta(state, state.currentWpIndex)
  local now = timer.getTime()

  local takeoff = self:_GetTakeoffWaypoint(state.plan)
  local secondsToTakeoff = self:_GetSecondsToNavigatorWaypointEta(state, 1)
  if takeoff and secondsToTakeoff and not self:_IsNavigatorGroupAirborne(state.group) then
    if self:_TickNavigatorTakeoff(state, takeoff, secondsToTakeoff, now) then
      return
    end
  end

  if secondsToTot then
    if waypoint.type == "HOLD" and secondsToTot <= 0 then
      if self:_TickNavigatorHold(state, waypoint, now) then
        return
      end
    end

    if secondsToTot <= 0 and state.currentWpIndex < #state.plan.waypoints then
      self:_AdvanceNavigatorWaypoint(state, "new WP")
      return
    end

    local thresholds = waypoint.type == "TARGET" and self.Config.navigatorTargetCalloutSeconds or self.Config.navigatorWaypointCalloutSeconds
    local eventKey = string.format("%s:%d", waypoint.type == "TARGET" and "TARGET" or "WP", state.currentWpIndex)
    local sentCallout = self:_RunTimedCallouts(state, eventKey, secondsToTot, thresholds, function(calloutSeconds)
      return self:_BuildNavigatorWaypointCalloutMessage(state, self:_FormatTimedCalloutReason(calloutSeconds))
    end)

    if sentCallout then
      return
    end

    local suppressIntervalSeconds = thresholds and thresholds[1]
    if suppressIntervalSeconds and secondsToTot <= suppressIntervalSeconds then
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
