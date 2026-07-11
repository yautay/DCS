function MosieNavigator:_AppendFuelSummary(lines, fuel)
  table.insert(lines, "FUEL:")
  table.insert(lines, string.format("  TAXI:    %6.1f IMP GAL", fuel.taxiImpGal))
  table.insert(lines, string.format("  ROUTE:   %6.1f IMP GAL", fuel.routeImpGal))
  table.insert(lines, string.format("  RESERVE: %6.1f IMP GAL  (%d min)",
    fuel.reserveImpGal, self.Aircraft.fuel.reserveMinutes))
  table.insert(lines, string.format("  LANDING: %6.1f IMP GAL", fuel.landingImpGal))
  table.insert(lines, string.format("  TOTAL:   %6.1f IMP GAL", fuel.totalImpGal))

  local dcs = fuel.dcs
  if dcs then
    table.insert(lines, "")
    table.insert(lines, "DCS FUEL:")
    table.insert(lines, string.format("  REQUIRED: %6.1f GAL / %5.0f LBS", dcs.requiredGal, dcs.requiredLb))
    table.insert(lines, string.format("  INTERNAL: %3d%%  (%4.0f LBS max)", dcs.internalPercent, dcs.internalFuelLb))
    table.insert(lines, string.format("  DROP:     %s", dcs.dropTankLabel))
  end
end

function MosieNavigator:_FormatVariation(value)
  if value == nil then
    return "---"
  end

  return string.format("%+.1f", value)
end

function MosieNavigator:_FormatDisplayLegTime(seconds)
  if not seconds then
    return "---"
  end

  return string.format("%d", math.floor(seconds / 60 + 0.5))
end

function MosieNavigator:_AppendFlightPlanRows(lines, waypoints, compact)
  if compact then
    table.insert(lines, "ID TY ALT   IASMPH TASKN COG WHDG WTAS HDG(T) VAR  HDG(M) SOG DIST TIME ETA   GAS")
    table.insert(lines, "-------------------------------------------------------------------------------")
  else
    table.insert(lines, string.format(
      "%-2s %-10s %6s %8s %7s %3s %4s %4s %6s %6s %6s %5s %6s %4s %5s %5s",
      "ID", "TYPE", "ALT", "IAS(MPH)", "TAS(KN)", "COG", "WHDG", "WTAS", "HDG(T)", "VAR", "HDG(M)", "SOG", "DIST", "TIME", "ETA", "GAS"
    ))
    table.insert(lines, string.rep("-", 109))
  end

  for _, ow in ipairs(waypoints) do
    local altStr = ow.resolvedAltFt ~= nil
      and (tostring(ow.resolvedAltFt) .. (ow.altInherited and "*" or "")) or "---"
    local speedMark = ow.legSpeedInherited and "*" or ""
    local iasMph = ow.legIasKt and (string.format("%.0f", self:_KnotsToMph(ow.legIasKt)) .. speedMark) or "---"
    local tasStr = ow.legTasKt and string.format("%.0f", ow.legTasKt) or "---"
    local cogStr = self:_FormatHeading(ow.trueCourse)
    local whdgStr = self:_FormatSignedDegrees(ow.windCorrectionDeg)
    local wtasStr = self:_FormatSignedDegrees(ow.tasCorrectionKt)
    local hdgTrueStr = self:_FormatHeading(ow.headingTrue)
    local varStr = self:_FormatVariation(ow.magneticVar)
    local hdgMagStr = self:_FormatMagneticHeadingWithVariation(ow.headingTrue, ow.magneticVar)
    local sogStr = ow.legGsKt and string.format("%.0f", ow.legGsKt) or "---"
    local distStr = ow.legDistNm and string.format("%.1f", ow.legDistNm) or "---"
    local timeStr = self:_FormatDisplayLegTime(ow.legTimeSec)
    local etaStr = self:_FormatDisplayEta(ow.etaSec)
    local gasStr = (ow.legDistNm and ow.legFuelImpGal) and string.format("%.1f", ow.legFuelImpGal) or "---"

    if compact then
      table.insert(lines, string.format(
        "%02d %-2s %-5s %6s %5s %3s %4s %4s %6s %5s %6s %3s %4s %4s %5s %5s",
        ow.order,
        self:_FormatWaypointTypeShort(ow.type),
        altStr,
        iasMph,
        tasStr,
        cogStr,
        whdgStr,
        wtasStr,
        hdgTrueStr,
        varStr,
        hdgMagStr,
        sogStr,
        distStr,
        timeStr,
        etaStr,
        gasStr
      ))
    else
      table.insert(lines, string.format(
        "%02d %-10s %6s %8s %7s %3s %4s %4s %6s %6s %6s %5s %6s %4s %5s %5s",
        ow.order,
        self:_FitText(ow.type, 10),
        altStr,
        iasMph,
        tasStr,
        cogStr,
        whdgStr,
        wtasStr,
        hdgTrueStr,
        varStr,
        hdgMagStr,
        sogStr,
        distStr,
        timeStr,
        etaStr,
        gasStr
      ))
    end

    if ow.holdDurationSec and ow.holdDurationSec > 0 then
      local holdMin = math.floor(ow.holdDurationSec / 60 + 0.5)
      local exitSec = (ow.etaSec + ow.holdDurationSec) % 86400
      table.insert(lines, string.format(
        "   orbit %d min @ %d IAS: %.1f gal  (exit %s)",
        holdMin, self.Aircraft.holdIasKt,
        ow.holdFuelImpGal or 0, self:_FormatDisplayEta(exitSec)
      ))
    end
  end
end

function MosieNavigator:_GetComputedPlan(plan, rolexSeconds)
  rolexSeconds = rolexSeconds or 0
  self.ComputedPlanCache = self.ComputedPlanCache or {}
  local planCache = self.ComputedPlanCache[plan]
  if not planCache then
    planCache = {}
    self.ComputedPlanCache[plan] = planCache
  end

  if not planCache[rolexSeconds] then
    planCache[rolexSeconds] = self:_ComputePlan(plan, rolexSeconds)
  end

  return planCache[rolexSeconds]
end

function MosieNavigator:_CopyComputedPlanWithRolex(computed, pilotRolexSeconds)
  pilotRolexSeconds = pilotRolexSeconds or 0
  if pilotRolexSeconds == 0 or not computed or not computed.valid then
    return computed
  end

  local shifted = {}
  for key, value in pairs(computed) do
    shifted[key] = value
  end

  shifted.waypoints = {}
  for index, waypoint in ipairs(computed.waypoints or {}) do
    local waypointCopy = {}
    for key, value in pairs(waypoint) do
      waypointCopy[key] = value
    end
    if waypointCopy.etaSec then
      waypointCopy.etaSec = (waypointCopy.etaSec + pilotRolexSeconds) % SECONDS_PER_DAY
    end
    table.insert(shifted.waypoints, waypointCopy)
  end

  return shifted
end

function MosieNavigator:_GetActiveComputedPlan(plan, baseRolexSeconds, pilotRolexSeconds)
  local computed = self:_GetComputedPlan(plan, baseRolexSeconds or 0)
  return self:_CopyComputedPlanWithRolex(computed, pilotRolexSeconds or 0)
end

function MosieNavigator:_BuildSimplifiedFlightPlanMessage(plan, groupName, baseRolexSeconds, pilotRolexSeconds)
  baseRolexSeconds = baseRolexSeconds or 0
  pilotRolexSeconds = pilotRolexSeconds or 0
  local computed = self:_GetActiveComputedPlan(plan, baseRolexSeconds, pilotRolexSeconds)
  local lines = {}

  table.insert(lines, "MOSIE NAVIGATOR")
  table.insert(lines, "PLAN  : " .. plan.name)
  table.insert(lines, "GROUP : " .. (groupName or "---"))
  if pilotRolexSeconds ~= 0 then
    table.insert(lines, "ROLEX : " .. self:_FormatSignedRolex(pilotRolexSeconds))
  end
  table.insert(lines, "")

  if not computed.valid then
    table.insert(lines, "ERROR: " .. (computed.error or "unknown"))
    return table.concat(lines, "\n")
  end

  self:_AppendFlightPlanRows(lines, computed.waypoints, false)

  local f = computed.fuel
  table.insert(lines, "")
  self:_AppendFuelSummary(lines, f)

  if #computed.warnings > 0 then
    table.insert(lines, "WARNINGS:")
    for _, w in ipairs(computed.warnings) do
      table.insert(lines, "  " .. w)
    end
  end

  return table.concat(lines, "\n")
end

function MosieNavigator:_ShowFlightPlanForGroup(group, plan, baseRolexSeconds, pilotRolexSeconds)
  if not group or not plan then
    return
  end

  local text = self:_BuildSimplifiedFlightPlanMessage(plan, group:GetName(), baseRolexSeconds, pilotRolexSeconds)
  MESSAGE:New(text, self.Config.flightPlanMessageDuration, "Mosie Navigator"):ToGroup(group)
end

function MosieNavigator:_GetGroupPlanState(group, assignment)
  self.GroupPlanStates = self.GroupPlanStates or {}

  local groupName = group:GetName()
  local state = self.GroupPlanStates[groupName]
  if not state then
    state = { pilotRolexSeconds = 0 }
    self.GroupPlanStates[groupName] = state
  end

  state.group = group
  state.groupName = groupName
  state.plan = assignment.plan
  state.planName = assignment.planName
  state.baseRolexSeconds = assignment.rolexSeconds or 0

  return state
end

function MosieNavigator:_GetActiveRolexSeconds(groupPlanState)
  return (groupPlanState.baseRolexSeconds or 0) + (groupPlanState.pilotRolexSeconds or 0)
end

function MosieNavigator:_RefreshNavigatorRolex(groupPlanState, reason)
  if not self.NavigatorStates then
    return
  end

  local state = self.NavigatorStates[groupPlanState.groupName]
  if not state then
    return
  end

  state.group = groupPlanState.group
  state.plan = groupPlanState.plan
  state.rolexSeconds = self:_GetActiveRolexSeconds(groupPlanState)
  state.baseRolexSeconds = groupPlanState.baseRolexSeconds or 0
  state.pilotRolexSeconds = groupPlanState.pilotRolexSeconds or 0
  local computed = self:_GetActiveComputedPlan(state.plan, state.baseRolexSeconds, state.pilotRolexSeconds)
  state.currentWpIndex = self:_GetInitialNavigatorWpIndexByTot(state.plan, state.rolexSeconds, computed)
  self:_ResetNavigatorCallouts(state)

  if state.enabled then
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, reason or "ROLEX"))
  end
end

function MosieNavigator:_SetPilotRolex(group, assignment, pilotRolexSeconds)
  local state = self:_GetGroupPlanState(group, assignment)
  state.pilotRolexSeconds = pilotRolexSeconds or 0
  self:_RefreshNavigatorRolex(state, "ROLEX")

  local text = "ROLEX reset"
  if state.pilotRolexSeconds ~= 0 then
    text = "ROLEX " .. self:_FormatSignedRolex(state.pilotRolexSeconds)
  end
  self:_SendNavigatorMessage(group, text)
end

function MosieNavigator:_AdjustPilotRolex(group, assignment, deltaSeconds)
  local state = self:_GetGroupPlanState(group, assignment)
  self:_SetPilotRolex(group, assignment, (state.pilotRolexSeconds or 0) + (deltaSeconds or 0))
end

function MosieNavigator:_CreateGroupMenus(plans)
  self.MenusCreated = self.MenusCreated or {}

  local assignments = self:_DiscoverGroupAssignments(plans)
  local createdCount = 0

  for _, assignment in ipairs(assignments) do
    local group = assignment.group
    local menuKey = assignment.groupName .. "::" .. assignment.planName
    self:_GetGroupPlanState(group, assignment)

    if not self.MenusCreated[menuKey] then
      local rootMenu = MENU_GROUP:New(group, self.Config.menuName)
      local navigatorMenu = MENU_GROUP:New(group, "NAVIGATOR", rootMenu)
      MENU_GROUP_COMMAND:New(group, "Automatic ON", navigatorMenu, function()
        local state = MosieNavigator:_GetGroupPlanState(group, assignment)
        MosieNavigator:_SetNavigatorEnabled(group, state.plan, MosieNavigator:_GetActiveRolexSeconds(state), true, state.baseRolexSeconds, state.pilotRolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Automatic OFF", navigatorMenu, function()
        local state = MosieNavigator:_GetGroupPlanState(group, assignment)
        MosieNavigator:_SetNavigatorEnabled(group, state.plan, MosieNavigator:_GetActiveRolexSeconds(state), false, state.baseRolexSeconds, state.pilotRolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Show FP", navigatorMenu, function()
        local state = MosieNavigator:_GetGroupPlanState(group, assignment)
        MosieNavigator:_ShowFlightPlanForGroup(group, state.plan, state.baseRolexSeconds, state.pilotRolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Status Now", navigatorMenu, function()
        local state = MosieNavigator:_GetGroupPlanState(group, assignment)
        MosieNavigator:_NavigatorStatusNow(group, state.plan, MosieNavigator:_GetActiveRolexSeconds(state), state.baseRolexSeconds, state.pilotRolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Next WP", navigatorMenu, function()
        local planState = MosieNavigator:_GetGroupPlanState(group, assignment)
        local navState = MosieNavigator:_GetNavigatorState(group, planState.plan, MosieNavigator:_GetActiveRolexSeconds(planState), planState.baseRolexSeconds, planState.pilotRolexSeconds)
        MosieNavigator:_AdvanceNavigatorWaypoint(navState, "manual WP")
      end)
      MENU_GROUP_COMMAND:New(group, "Prev WP", navigatorMenu, function()
        local planState = MosieNavigator:_GetGroupPlanState(group, assignment)
        local navState = MosieNavigator:_GetNavigatorState(group, planState.plan, MosieNavigator:_GetActiveRolexSeconds(planState), planState.baseRolexSeconds, planState.pilotRolexSeconds)
        MosieNavigator:_SetNavigatorWaypoint(navState, navState.currentWpIndex - 1, "manual WP")
      end)

      local intervalMenu = MENU_GROUP:New(group, "Report Interval", navigatorMenu)
      for _, interval in ipairs(self.Config.navigatorReportIntervals) do
        MENU_GROUP_COMMAND:New(group, string.format("%d sec", interval), intervalMenu, function(reportInterval)
          local state = MosieNavigator:_GetGroupPlanState(group, assignment)
          MosieNavigator:_SetNavigatorReportInterval(group, state.plan, MosieNavigator:_GetActiveRolexSeconds(state), reportInterval)
        end, interval)
      end

      local rolexMenu = MENU_GROUP:New(group, "ROLEX", rootMenu)
      MENU_GROUP_COMMAND:New(group, "RESET", rolexMenu, function()
        MosieNavigator:_SetPilotRolex(group, assignment, 0)
      end)

      local advanceMenu = MENU_GROUP:New(group, "ADVANCE", rolexMenu)
      local retardMenu = MENU_GROUP:New(group, "RETARD", rolexMenu)
      for _, minutes in ipairs({1, 2, 3, 5, 10}) do
        MENU_GROUP_COMMAND:New(group, string.format("%d min", minutes), advanceMenu, function(value)
          MosieNavigator:_AdjustPilotRolex(group, assignment, -value * 60)
        end, minutes)
        MENU_GROUP_COMMAND:New(group, string.format("%d min", minutes), retardMenu, function(value)
          MosieNavigator:_AdjustPilotRolex(group, assignment, value * 60)
        end, minutes)
      end

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

function MosieNavigator:_BuildFlightPlanTable(plan, groupName, baseRolexSeconds, pilotRolexSeconds)
  baseRolexSeconds = baseRolexSeconds or 0
  pilotRolexSeconds = pilotRolexSeconds or 0
  local computed = self:_GetActiveComputedPlan(plan, baseRolexSeconds, pilotRolexSeconds)
  local lines = {}

  table.insert(lines, "MOSIE NAVIGATOR FLIGHT PLAN")
  table.insert(lines, "PLAN  : " .. plan.name)
  if groupName then
    table.insert(lines, "GROUP : " .. groupName)
  end
  if pilotRolexSeconds ~= 0 then
    table.insert(lines, "ROLEX : " .. self:_FormatSignedRolex(pilotRolexSeconds))
  end
  table.insert(lines, "ACFT  : " .. self.Aircraft.name)
  table.insert(lines, "")

  if not computed.valid then
    table.insert(lines, "ERROR: " .. (computed.error or "unknown"))
    return table.concat(lines, "\n") .. "\n"
  end

  local totalDist = 0
  for _, ow in ipairs(computed.waypoints) do
    if ow.legDistNm then totalDist = totalDist + ow.legDistNm end
  end

  self:_AppendFlightPlanRows(lines, computed.waypoints, false)

  local f = computed.fuel
  table.insert(lines, "")
  table.insert(lines, string.format("TOTAL_DIST: %.1f NM", totalDist))
  table.insert(lines, "")
  self:_AppendFuelSummary(lines, f)

  if #computed.warnings > 0 then
    table.insert(lines, "")
    table.insert(lines, "WARNINGS:")
    for _, w in ipairs(computed.warnings) do
      table.insert(lines, "  - " .. w)
    end
  end

  return table.concat(lines, "\n") .. "\n"
end
