function MosieNavigator:_SendNavigatorMessage(group, text, duration)
  local messageText = text or ""
  local messageDuration = duration or self.Config.navigatorMessageDuration

  if self:_IsTestMode() then
    local groupName = group and type(group.GetName) == "function" and group:GetName() or "---"
    self:_Log(string.format('TEST_MESSAGE_DUMP_BEGIN group="%s"', groupName))
    self:_Log(messageText)
    self:_Log(string.format('TEST_MESSAGE_DUMP_END group="%s"', groupName))
    self:_AppendNavigatorDump(groupName, messageText)
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

  seconds = math.floor(seconds + 0.5)
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

  local totalMinutes = math.ceil(math.floor(seconds + 0.5) / 60)
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

function MosieNavigator:_FormatNavigatorEtaClock(secondsToEta)
  if secondsToEta == nil or not timer or type(timer.getAbsTime) ~= "function" then
    return "--"
  end

  return self:_FormatClock(math.floor((timer.getAbsTime() + secondsToEta) % SECONDS_PER_DAY + 0.5))
end

function MosieNavigator:_GetNavigatorCurrentGroundSpeedKt(group)
  if group and type(group.GetVelocityKNOTS) == "function" then
    local speed = group:GetVelocityKNOTS()
    if speed and speed > 1 then
      return speed
    end
  end

  return nil
end

function MosieNavigator:_GetActualSecondsToWaypoint(distanceNm, currentGroundSpeedKt)
  if not distanceNm or not currentGroundSpeedKt or currentGroundSpeedKt <= 1 then
    return nil
  end

  return distanceNm / currentGroundSpeedKt * 3600
end

function MosieNavigator:_IsNavigatorRequiredSpeedAchievable(requiredIas)
  if not requiredIas then
    return false
  end

  local maxIasKt = self.Config.navigatorRequiredMaxIasKt
  if not maxIasKt then
    return true
  end

  return requiredIas <= maxIasKt
end

function MosieNavigator:_FormatNavigatorRequiredIas(requiredIas)
  if not requiredIas then
    return "---"
  end

  if not self:_IsNavigatorRequiredSpeedAchievable(requiredIas) then
    return self:_FormatSpeed(requiredIas) .. " kt >MAX"
  end

  return self:_FormatSpeed(requiredIas) .. " kt"
end

function MosieNavigator:_FormatNavigatorSpeedCorrection(currentIas, requiredIas)
  if not currentIas or not requiredIas then
    return "---"
  end

  local delta = requiredIas - currentIas
  if math.abs(delta) <= 5 then
    return "on speed"
  end

  local suffix = ""
  if delta > 0 and not self:_IsNavigatorRequiredSpeedAchievable(requiredIas) then
    suffix = " UNACH"
  elseif delta < 0 and self.Aircraft and self.Aircraft.envelope and self.Aircraft.envelope.minIasKt and requiredIas < self.Aircraft.envelope.minIasKt then
    suffix = " / ORBIT"
  end

  if delta > 0 then
    return string.format("+%.0f kt%s", delta, suffix)
  end

  return string.format("%.0f kt%s", delta, suffix)
end

function MosieNavigator:_BuildNavigatorCalloutMessage(calloutSeconds, message)
  return string.format("%s CALLOUT: %s", self:_FormatCountdown(calloutSeconds), message)
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

function MosieNavigator:_GetWaypointPassRadiusM(waypoint)
  if waypoint and waypoint.radiusM then
    return waypoint.radiusM
  end
  local t = waypoint and waypoint.type
  if t == "TARGET"  then return self.Config.navigatorTargetPassRadiusM  end
  if t == "HOLD"    then return self.Config.navigatorHoldEntryRadiusM   end
  if t == "LANDING" then return self.Config.navigatorLandingPassRadiusM end
  return self.Config.navigatorWaypointPassRadiusM
end

function MosieNavigator:_IsWaypointReachedFlyOver(waypoint, groupCoordinate)
  local passRadius = self:_GetWaypointPassRadiusM(waypoint)
  return groupCoordinate:Get2DDistance(waypoint.coordinate) <= passRadius
end

function MosieNavigator:_IsWaypointReachedFlyBy(previousWaypoint, waypoint, groupCoordinate)
  if not previousWaypoint then return false end
  local xteNm, _, alongTrackM, legLengthM = self:_CalculateXte(previousWaypoint, waypoint, groupCoordinate)
  if not xteNm or not legLengthM or legLengthM <= 0 or not alongTrackM then return false end
  if alongTrackM < legLengthM then return false end
  local flyByRadius = self:_GetWaypointPassRadiusM(waypoint) * (self.Config.navigatorFlyByRadiusMultiplier or 2)
  return UTILS.NMToMeters(xteNm) <= flyByRadius
end

function MosieNavigator:_IsWaypointReachedPositionally(state, waypoint, previousWaypoint, groupCoordinate)
  local flyOverOnly = waypoint.type == "TARGET" or waypoint.type == "LANDING"
  if flyOverOnly then
    return self:_IsWaypointReachedFlyOver(waypoint, groupCoordinate)
  end
  return self:_IsWaypointReachedFlyOver(waypoint, groupCoordinate)
    or self:_IsWaypointReachedFlyBy(previousWaypoint, waypoint, groupCoordinate)
end

function MosieNavigator:_ComputeHoldExitClockSec(state, index)
  local computedWp = self:_GetNavigatorComputedWaypoint(state, index)
  if computedWp and computedWp.etaSec ~= nil then
    return (computedWp.etaSec + (computedWp.holdDurationSec or 0)) % SECONDS_PER_DAY
  end
  local waypoint = state.plan.waypoints[index]
  if not waypoint then return nil end
  local arrivalClockSec = self:_GetAdjustedTotSeconds(waypoint, state.rolexSeconds)
  if not arrivalClockSec then return nil end
  local holdDurationSec = self:_GetNavigatorHoldDurationSeconds(state, index)
  return (arrivalClockSec + holdDurationSec) % SECONDS_PER_DAY
end

function MosieNavigator:_HandleEtaLateAlert(state, waypoint)
  state.etaAlerts = state.etaAlerts or {}
  if state.etaAlerts[state.currentWpIndex] then return end
  state.etaAlerts[state.currentWpIndex] = true
  self:_SendNavigatorMessage(state.group, string.format(
    "NAV: %s ETA passed, waypoint not reached. Continue or advance manually.",
    self:_GetNavigatorWaypointLabel(waypoint)
  ))
end

function MosieNavigator:_HandleTargetDepartureAlert(state, waypoint, groupCoordinate)
  state.targetApproach = state.targetApproach or {}
  local approach = state.targetApproach[state.currentWpIndex] or {}
  state.targetApproach[state.currentWpIndex] = approach

  local dist = groupCoordinate:Get2DDistance(waypoint.coordinate)
  if not approach.minDistM or dist < approach.minDistM then
    approach.minDistM = dist
  end

  if approach.departureAlerted then return end

  local passRadius = self:_GetWaypointPassRadiusM(waypoint)
  if approach.minDistM and approach.minDistM < passRadius * 3 and dist > approach.minDistM * 1.1 then
    approach.departureAlerted = true
    self:_SendNavigatorMessage(state.group, string.format(
      "NAV: Departing %s without confirmed pass. Use NEXT WP if attack complete.",
      self:_GetNavigatorWaypointLabel(waypoint)
    ))
  end
end

function MosieNavigator:_HandleNavigatorLandingReached(state)
  state.enabled = false
  self:_SendNavigatorMessage(state.group, "NAV: Home plate reached. Welcome back. Navigator off.")
end

function MosieNavigator:_GetInitialNavigatorWpIndexByPosition(plan, group)
  if not plan or not plan.waypoints then
    return self:_GetInitialNavigatorWpIndex(plan)
  end
  if not group or type(group.GetCoordinate) ~= "function" then
    return self:_GetInitialNavigatorWpIndex(plan)
  end
  local groupCoordinate = group:GetCoordinate()
  if not groupCoordinate then
    return self:_GetInitialNavigatorWpIndex(plan)
  end

  local waypoints = plan.waypoints
  local minDist = math.huge
  local nearestIndex = nil

  for index, wp in ipairs(waypoints) do
    if wp.type ~= "TAKE_OFF" then
      local dist = groupCoordinate:Get2DDistance(wp.coordinate)
      if dist < minDist then
        minDist = dist
        nearestIndex = index
      end
      local prevWp = waypoints[index - 1]
      if not prevWp then
        return index
      end
      local _, _, alongTrackM, legLengthM = self:_CalculateXte(prevWp, wp, groupCoordinate)
      if not alongTrackM or not legLengthM or legLengthM <= 0 or alongTrackM < legLengthM then
        return index
      end
    end
  end

  return nearestIndex or self:_GetInitialNavigatorWpIndex(plan)
end

function MosieNavigator:_BuildNavigatorTakeoffMessage(state, reason)
  local secondsToTakeoff = self:_GetSecondsToNavigatorWaypointEta(state, 1)
  if secondsToTakeoff and secondsToTakeoff <= 0 then
    return string.format("NAV: Awaiting takeoff. Planned brake release T+%s.", self:_FormatCountdown(-secondsToTakeoff))
  end

  return string.format("NAV: Brake release in %s. Stand by.", self:_FormatCountdown(secondsToTakeoff))
end

function MosieNavigator:_BuildNavigatorWaypointGuidanceMessage(state, prefix)
  local group = state.group
  local waypoint = state.plan.waypoints[state.currentWpIndex]

  if not waypoint then
    return "NAV: no active waypoint"
  end

  local groupCoordinate = group:GetCoordinate()
  local distanceNm = UTILS.MetersToNM(groupCoordinate:Get2DDistance(waypoint.coordinate))
  local secondsToPlanEta = self:_GetSecondsToNavigatorWaypointEta(state, state.currentWpIndex)
  local currentGroundSpeedKt = self:_GetNavigatorCurrentGroundSpeedKt(group)
  local actualSecondsToWaypoint = self:_GetActualSecondsToWaypoint(distanceNm, currentGroundSpeedKt)
  local currentAltitudeFt = UTILS.MetersToFeet(group:GetAltitude(false) or 0)
  local headingTrue, _, requiredIas = self:_CalculateWindCorrectedGuidance(groupCoordinate, waypoint, secondsToPlanEta, currentAltitudeFt)
  local headingMagnetic = self:_FormatMagneticHeading(headingTrue, groupCoordinate)
  local plannedAltitudeFt = self:_GetNavigatorWaypointAltitudeFt(state.plan, state.currentWpIndex)
  local currentIas = currentGroundSpeedKt and self:_ConvertTasToIas(currentGroundSpeedKt, currentAltitudeFt) or nil

  return string.format(
    "%s, DIST %.1f NM, PLAN ETA %s, ACT ETA %s, REQ IAS %s, SPD CORR %s. Steer %sM, height %s feet. %s",
    prefix,
    distanceNm,
    self:_FormatNavigatorEtaClock(secondsToPlanEta),
    self:_FormatNavigatorEtaClock(actualSecondsToWaypoint),
    self:_FormatNavigatorRequiredIas(requiredIas),
    self:_FormatNavigatorSpeedCorrection(currentIas, requiredIas),
    headingMagnetic,
    self:_FormatOptional(plannedAltitudeFt, "%.0f"),
    self:_BuildNavigatorXtePhrase(state, waypoint, groupCoordinate)
  )
end

function MosieNavigator:_BuildNavigatorWaypointCalloutMessage(state, reason)
  local waypoint = state.plan.waypoints[state.currentWpIndex]

  if not waypoint then
    return "NAV: no active waypoint"
  end

  return self:_BuildNavigatorWaypointGuidanceMessage(state, "NAV: " .. self:_GetNavigatorWaypointLabel(waypoint))
end

function MosieNavigator:_BuildNavigatorCourseChangeMessage(state)
  local waypoint = state.plan.waypoints[state.currentWpIndex]

  if not waypoint then
    return "NAV: no active waypoint"
  end

  return self:_BuildNavigatorWaypointGuidanceMessage(state, "NAV: Set course for " .. self:_GetNavigatorWaypointLabel(waypoint))
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

function MosieNavigator:_TickNavigatorHold(state, waypoint, now, groupCoordinate)
  state.holdEntries = state.holdEntries or {}
  local hEntry = state.holdEntries[state.currentWpIndex] or {}
  state.holdEntries[state.currentWpIndex] = hEntry

  if not hEntry.entered then
    if self:_IsWaypointReachedFlyOver(waypoint, groupCoordinate) then
      hEntry.entered = true
      local holdExitClockSec = self:_ComputeHoldExitClockSec(state, state.currentWpIndex)
      hEntry.holdExitClockSec = holdExitClockSec
      local holdRemainingSeconds = holdExitClockSec and self:_GetSecondsToClockSeconds(holdExitClockSec)

      if not holdRemainingSeconds or holdRemainingSeconds <= 0 then
        self:_SendNavigatorMessage(state.group, string.format(
          "NAV: Hold at %s skipped — arrived past planned exit. Advancing.",
          self:_GetNavigatorWaypointLabel(waypoint)
        ))
        if state.currentWpIndex < #state.plan.waypoints then
          self:_SetNavigatorWaypoint(state, state.currentWpIndex + 1, "hold exit")
        end
        return
      end

      state.lastReportTime = now
      self:_SendNavigatorMessage(state.group, self:_BuildNavigatorHoldEntryMessage(state, holdRemainingSeconds))
      return
    end

    local secondsToTot = self:_GetSecondsToNavigatorWaypointEta(state, state.currentWpIndex)
    if secondsToTot then
      local thresholds = self.Config.navigatorWaypointCalloutSeconds
      local eventKey = string.format("WP:%d", state.currentWpIndex)
      local sentCallout = self:_RunTimedCallouts(state, eventKey, secondsToTot, thresholds, function(calloutSeconds)
        return self:_BuildNavigatorWaypointCalloutMessage(state, self:_FormatTimedCalloutReason(calloutSeconds))
      end)
      if sentCallout then return end

      local suppressIntervalSeconds = thresholds and thresholds[1]
      if suppressIntervalSeconds and secondsToTot <= suppressIntervalSeconds then return end
    end

    if not state.lastReportTime or now - state.lastReportTime >= state.reportInterval then
      state.lastReportTime = now
      self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, "report"))
    end
    return
  end

  local holdRemainingSeconds = hEntry.holdExitClockSec and self:_GetSecondsToClockSeconds(hEntry.holdExitClockSec)

  if not holdRemainingSeconds or holdRemainingSeconds <= 0 then
    if state.currentWpIndex < #state.plan.waypoints then
      self:_SetNavigatorWaypoint(state, state.currentWpIndex + 1, "hold exit")
    end
    return
  end

  local eventKey = string.format("HOLD_EXIT:%d", state.currentWpIndex)
  local sentCallout = self:_RunTimedCallouts(state, eventKey, holdRemainingSeconds, self.Config.navigatorHoldExitCalloutSeconds, function(calloutSeconds)
    return self:_BuildNavigatorHoldRemainingMessage(state, self:_FormatTimedCalloutReason(calloutSeconds), holdRemainingSeconds)
  end)

  if sentCallout then return end

  local suppressIntervalSeconds = self.Config.navigatorHoldExitCalloutSeconds and self.Config.navigatorHoldExitCalloutSeconds[1]
  if suppressIntervalSeconds and holdRemainingSeconds <= suppressIntervalSeconds then return end

  if not state.lastReportTime or now - state.lastReportTime >= state.reportInterval then
    state.lastReportTime = now
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorHoldRemainingMessage(state, "report", holdRemainingSeconds))
  end
end

function MosieNavigator:_BuildNavigatorStatusMessage(state, reason)
  local plan = state.plan
  local waypoint = plan.waypoints[state.currentWpIndex]

  if not waypoint then
    return "NAV: no active waypoint"
  end

  local prefix = reason and ("NAV " .. reason .. ": ") or "NAV: "
  return self:_BuildNavigatorWaypointGuidanceMessage(state, prefix .. self:_GetNavigatorWaypointLabel(waypoint))
end

function MosieNavigator:_ResetNavigatorCallouts(state)
  state.callouts = {}
  state.timedCallouts = {}
  state.holdEntries = {}
  state.etaAlerts = {}
  state.targetApproach = {}
  for _, calloutSeconds in ipairs(self.Config.navigatorCalloutSeconds) do
    state.callouts[calloutSeconds] = false
  end
end

function MosieNavigator:_MarkNavigatorTakeoffComplete(state)
  state.takeoffComplete = true
  state.timedCallouts = state.timedCallouts or {}
  local eventCallouts = state.timedCallouts["TAKE_OFF:brake_release"] or {}
  eventCallouts.brakeRelease = true
  state.timedCallouts["TAKE_OFF:brake_release"] = eventCallouts
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

  local thresholdList = thresholds or {}
  for i = #thresholdList, 1, -1 do
    local calloutSeconds = thresholdList[i]
    if secondsToEvent <= calloutSeconds and not eventCallouts[calloutSeconds] then
      eventCallouts[calloutSeconds] = true
      self:_SendNavigatorMessage(state.group, self:_BuildNavigatorCalloutMessage(calloutSeconds, buildMessage(calloutSeconds)))
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
    if self:_IsNavigatorGroupAirborne(group) then
      self:_MarkNavigatorTakeoffComplete(state)
      state.currentWpIndex = self:_GetInitialNavigatorWpIndexByPosition(plan, group)
      self:_ResetNavigatorCallouts(state)
      self:_SendNavigatorMessage(group, self:_BuildNavigatorWaypointCalloutMessage(state, "on"))
    else
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
      if takeoff and secondsToTakeoff and not state.takeoffComplete then
        state.currentWpIndex = 1
        self:_SendNavigatorMessage(group, self:_BuildNavigatorTakeoffMessage(state, "on"))
      else
        self:_SendNavigatorMessage(group, self:_BuildNavigatorWaypointCalloutMessage(state, "on"))
      end
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
  if takeoff and secondsToTakeoff and not state.takeoffComplete and not self:_IsNavigatorGroupAirborne(group) then
    self:_SendNavigatorMessage(group, self:_BuildNavigatorTakeoffMessage(state, "status"))
  else
    if takeoff and self:_IsNavigatorGroupAirborne(group) then
      self:_MarkNavigatorTakeoffComplete(state)
      if state.currentWpIndex == 1 then
        state.currentWpIndex = self:_GetInitialNavigatorWpIndex(plan)
      end
    end
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

  local now = timer.getTime()

  local takeoff = self:_GetTakeoffWaypoint(state.plan)
  local secondsToTakeoff = self:_GetSecondsToNavigatorWaypointEta(state, 1)
  local airborne = self:_IsNavigatorGroupAirborne(state.group)
  if takeoff and secondsToTakeoff and not state.takeoffComplete and not airborne then
    state.currentWpIndex = 1
    self:_TickNavigatorTakeoff(state, takeoff, secondsToTakeoff, now)
    return
  end

  if takeoff and airborne then
    self:_MarkNavigatorTakeoffComplete(state)
    if waypoint.type == "TAKE_OFF" then
      state.currentWpIndex = self:_GetInitialNavigatorWpIndex(state.plan)
      waypoint = state.plan.waypoints[state.currentWpIndex]
      if not waypoint then
        return
      end
    end
  end

  local groupCoordinate = state.group:GetCoordinate()
  if not groupCoordinate then
    return
  end

  if waypoint.type == "HOLD" then
    self:_TickNavigatorHold(state, waypoint, now, groupCoordinate)
    return
  end

  local previousWaypoint = state.plan.waypoints[state.currentWpIndex - 1]
  local secondsToTot = self:_GetSecondsToNavigatorWaypointEta(state, state.currentWpIndex)

  if self:_IsWaypointReachedPositionally(state, waypoint, previousWaypoint, groupCoordinate) then
    if waypoint.type == "LANDING" then
      self:_HandleNavigatorLandingReached(state)
      return
    end
    if state.currentWpIndex < #state.plan.waypoints then
      self:_AdvanceNavigatorWaypoint(state, "new WP")
      return
    end
  end

  if secondsToTot and secondsToTot < 0 then
    self:_HandleEtaLateAlert(state, waypoint)
  end

  if waypoint.type == "TARGET" then
    self:_HandleTargetDepartureAlert(state, waypoint, groupCoordinate)
  end

  if secondsToTot then
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
