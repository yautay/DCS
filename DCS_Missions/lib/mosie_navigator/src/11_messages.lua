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

  for _, ow in ipairs(computed.waypoints) do
    local altStr  = ow.resolvedAltFt ~= nil
      and (tostring(ow.resolvedAltFt) .. (ow.altInherited and "*" or "")) or "---"
    local gsStr   = ow.legGsKt  and string.format("%.0f", ow.legGsKt)  or "---"
    local iasStr  = ow.legIasKt and string.format("%.0f", ow.legIasKt) or "---"
    local profStr = ow.legProfile or "---"
    local fuelStr = ow.legFuelImpGal and string.format("%.1f", ow.legFuelImpGal) or "---"

    table.insert(lines, string.format(
      "[%02d] %-10s %-12s  ALT %s  ETA %s  GS %s IAS %s  PROF %s  LEG %s gal",
      ow.order,
      self:_FitText(ow.type, 10),
      self:_FitText(ow.name, 12),
      altStr, self:_FormatClock(ow.etaSec), gsStr, iasStr, profStr, fuelStr
    ))

    if ow.holdDurationSec and ow.holdDurationSec > 0 then
      local holdMin  = math.floor(ow.holdDurationSec / 60)
      local holdSec2 = ow.holdDurationSec % 60
      local exitSec  = (ow.etaSec + ow.holdDurationSec) % 86400
      table.insert(lines, string.format(
        "     orbit %d:%02d @ %d IAS: %.1f gal  (exit %s)",
        holdMin, holdSec2, self.Aircraft.holdIasKt,
        ow.holdFuelImpGal or 0, self:_FormatClock(exitSec)
      ))
    end
  end

  local f = computed.fuel
  table.insert(lines, "")
  table.insert(lines, string.format("FUEL: %.1f / %.1f IMP GAL  (%.1f%% margin)",
    f.totalImpGal, f.tankImpGal, f.marginPercent))

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

  local hdr = string.format(
    "%-2s %-10s %-12s %10s %11s %6s %5s %5s %5s %6s %5s %5s %-9s %6s %7s",
    "NO","TYPE","NAME","LAT","LON","ALT","ETA","CRS_T","CRS_M","LEG","GS","IAS","PROF","FUEL","CUM"
  )
  table.insert(lines, hdr)
  table.insert(lines, string.rep("-", string.len(hdr)))

  local totalDist = 0
  for _, ow in ipairs(computed.waypoints) do
    local lat, lon = self:_FormatCoordinate(ow.coordinate)
    local altStr  = ow.resolvedAltFt ~= nil
      and (tostring(ow.resolvedAltFt) .. (ow.altInherited and "*" or "")) or "---"
    local etaStr  = self:_FormatClock(ow.etaSec)
    local crsT    = self:_FormatHeading(ow.trueCourse)
    local crsM    = self:_FormatMagneticHeading(ow.trueCourse, ow.coordinate)
    local legStr  = ow.legDistNm    and string.format("%6.1f", ow.legDistNm)    or "   ---"
    local gsStr   = ow.legGsKt      and string.format("%5.0f", ow.legGsKt)      or "  ---"
    local iasStr  = ow.legIasKt     and string.format("%5.0f", ow.legIasKt)     or "  ---"
    local profStr = self:_FitText(ow.legProfile or "---", 9)
    local fuelStr = ow.legFuelImpGal and string.format("%6.1f", ow.legFuelImpGal) or "   ---"
    local cumStr  = string.format("%7.1f", ow.fuelCumImpGal or 0)

    if ow.legDistNm then totalDist = totalDist + ow.legDistNm end

    table.insert(lines, string.format(
      "%02d %-10s %-12s %10s %11s %6s %5s %5s %5s %s %s %s %-9s %s %s",
      ow.order,
      self:_FitText(ow.type, 10),
      self:_FitText(ow.name, 12),
      lat, lon, altStr, etaStr, crsT, crsM, legStr, gsStr, iasStr, profStr, fuelStr, cumStr
    ))

    if ow.holdDurationSec and ow.holdDurationSec > 0 then
      local holdMin  = math.floor(ow.holdDurationSec / 60)
      local holdSec2 = ow.holdDurationSec % 60
      local exitSec  = (ow.etaSec + ow.holdDurationSec) % 86400
      table.insert(lines, string.format(
        "   orbit %d:%02d @ %d IAS: %.1f gal  (exit %s)",
        holdMin, holdSec2, self.Aircraft.holdIasKt,
        ow.holdFuelImpGal or 0, self:_FormatClock(exitSec)
      ))
    end
  end

  local f = computed.fuel
  table.insert(lines, "")
  table.insert(lines, string.format("TOTAL_DIST: %.1f NM", totalDist))
  table.insert(lines, "")
  table.insert(lines, "FUEL:")
  table.insert(lines, string.format("  TAXI:    %6.1f IMP GAL", f.taxiImpGal))
  table.insert(lines, string.format("  ROUTE:   %6.1f IMP GAL", f.routeImpGal))
  table.insert(lines, string.format("  RESERVE: %6.1f IMP GAL  (%d min)",
    f.reserveImpGal, self.Aircraft.fuel.reserveMinutes))
  table.insert(lines, string.format("  LANDING: %6.1f IMP GAL", f.landingImpGal))
  table.insert(lines, string.format("  TOTAL:   %6.1f IMP GAL", f.totalImpGal))
  table.insert(lines, string.format("  TANK:    %6.1f IMP GAL", f.tankImpGal))
  table.insert(lines, string.format("  MARGIN:  %6.1f IMP GAL  (%.1f%%)",
    f.marginImpGal, f.marginPercent))

  if #computed.warnings > 0 then
    table.insert(lines, "")
    table.insert(lines, "WARNINGS:")
    for _, w in ipairs(computed.warnings) do
      table.insert(lines, "  - " .. w)
    end
  end

  return table.concat(lines, "\n") .. "\n"
end
