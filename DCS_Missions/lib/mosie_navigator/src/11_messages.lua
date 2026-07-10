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
    table.insert(lines, "ID TY ALT   IASMPH TASKN COG HDGT  VAR  HDGM SOG DIST TIME ETA")
    table.insert(lines, "----------------------------------------------------------------")
  else
    table.insert(lines, string.format(
      "%-2s %-10s %6s %8s %7s %3s %9s %6s %8s %5s %6s %4s %5s",
      "ID", "TYPE", "ALT", "IAS(MPH)", "TAS(KN)", "COG", "HDG(TRUE)", "VAR", "HDG(MAG)", "SOG", "DIST", "TIME", "ETA"
    ))
    table.insert(lines, string.rep("-", 91))
  end

  for _, ow in ipairs(waypoints) do
    local altStr = ow.resolvedAltFt ~= nil
      and (tostring(ow.resolvedAltFt) .. (ow.altInherited and "*" or "")) or "---"
    local speedMark = ow.legSpeedInherited and "*" or ""
    local iasMph = ow.legIasKt and (string.format("%.0f", self:_KnotsToMph(ow.legIasKt)) .. speedMark) or "---"
    local tasStr = ow.legTasKt and string.format("%.0f", ow.legTasKt) or "---"
    local cogStr = self:_FormatHeading(ow.trueCourse)
    local hdgTrueStr = self:_FormatHeading(ow.headingTrue)
    local varStr = self:_FormatVariation(ow.magneticVar)
    local hdgMagStr = self:_FormatMagneticHeading(ow.headingTrue, ow.coordinate)
    local sogStr = ow.legGsKt and string.format("%.0f", ow.legGsKt) or "---"
    local distStr = ow.legDistNm and string.format("%.1f", ow.legDistNm) or "---"
    local timeStr = self:_FormatDisplayLegTime(ow.legTimeSec)
    local etaStr = self:_FormatDisplayEta(ow.etaSec)

    if compact then
      table.insert(lines, string.format(
        "%02d %-2s %-5s %6s %5s %3s %4s %5s %4s %3s %4s %4s %5s",
        ow.order,
        self:_FormatWaypointTypeShort(ow.type),
        altStr,
        iasMph,
        tasStr,
        cogStr,
        hdgTrueStr,
        varStr,
        hdgMagStr,
        sogStr,
        distStr,
        timeStr,
        etaStr
      ))
    else
      table.insert(lines, string.format(
        "%02d %-10s %6s %8s %7s %3s %9s %6s %8s %5s %6s %4s %5s",
        ow.order,
        self:_FitText(ow.type, 10),
        altStr,
        iasMph,
        tasStr,
        cogStr,
        hdgTrueStr,
        varStr,
        hdgMagStr,
        sogStr,
        distStr,
        timeStr,
        etaStr
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

function MosieNavigator:_BuildSimplifiedFlightPlanMessage(plan, groupName, rolexSeconds)
  rolexSeconds = rolexSeconds or 0
  local computed = self:_ComputePlan(plan, rolexSeconds)
  local lines = {}

  table.insert(lines, "MOSIE NAVIGATOR")
  table.insert(lines, "PLAN  : " .. plan.name)
  table.insert(lines, "GROUP : " .. (groupName or "---"))
  if rolexSeconds ~= 0 then
    table.insert(lines, "ROLEX : " .. self:_FormatRolex(rolexSeconds))
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

function MosieNavigator:_ShowFlightPlanForGroup(group, plan, rolexSeconds)
  if not group or not plan then
    return
  end

  local text = self:_BuildSimplifiedFlightPlanMessage(plan, group:GetName(), rolexSeconds)
  MESSAGE:New(text, self.Config.flightPlanMessageDuration, "Mosie Navigator"):ToGroup(group)
end

function MosieNavigator:_CreateGroupMenus(plans)
  self.MenusCreated = self.MenusCreated or {}

  local assignments = self:_DiscoverGroupAssignments(plans)
  local createdCount = 0

  for _, assignment in ipairs(assignments) do
    local group = assignment.group
    local plan = assignment.plan
    local menuKey = assignment.groupName .. "::" .. assignment.planName

    if not self.MenusCreated[menuKey] then
      local rootMenu = MENU_GROUP:New(group, self.Config.menuName)
      MENU_GROUP_COMMAND:New(group, "Show FP", rootMenu, function()
        MosieNavigator:_ShowFlightPlanForGroup(group, plan, assignment.rolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Navigator On", rootMenu, function()
        MosieNavigator:_SetNavigatorEnabled(group, plan, assignment.rolexSeconds, true)
      end)
      MENU_GROUP_COMMAND:New(group, "Navigator Off", rootMenu, function()
        MosieNavigator:_SetNavigatorEnabled(group, plan, assignment.rolexSeconds, false)
      end)
      MENU_GROUP_COMMAND:New(group, "Status Now", rootMenu, function()
        MosieNavigator:_NavigatorStatusNow(group, plan, assignment.rolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Next WP", rootMenu, function()
        local state = MosieNavigator:_GetNavigatorState(group, plan, assignment.rolexSeconds)
        MosieNavigator:_AdvanceNavigatorWaypoint(state, "manual WP")
      end)
      MENU_GROUP_COMMAND:New(group, "Prev WP", rootMenu, function()
        local state = MosieNavigator:_GetNavigatorState(group, plan, assignment.rolexSeconds)
        MosieNavigator:_SetNavigatorWaypoint(state, state.currentWpIndex - 1, "manual WP")
      end)

      local intervalMenu = MENU_GROUP:New(group, "Report Interval", rootMenu)
      for _, interval in ipairs(self.Config.navigatorReportIntervals) do
        MENU_GROUP_COMMAND:New(group, string.format("%d sec", interval), intervalMenu, function(reportInterval)
          MosieNavigator:_SetNavigatorReportInterval(group, plan, assignment.rolexSeconds, reportInterval)
        end, interval)
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

function MosieNavigator:_BuildFlightPlanTable(plan, groupName, rolexSeconds)
  rolexSeconds = rolexSeconds or 0
  local computed = self:_ComputePlan(plan, rolexSeconds)
  local lines = {}

  table.insert(lines, "MOSIE NAVIGATOR FLIGHT PLAN")
  table.insert(lines, "PLAN  : " .. plan.name)
  if groupName then
    table.insert(lines, "GROUP : " .. groupName)
  end
  if rolexSeconds ~= 0 then
    table.insert(lines, "ROLEX : " .. self:_FormatRolex(rolexSeconds))
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
