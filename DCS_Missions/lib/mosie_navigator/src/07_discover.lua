function MosieNavigator:_ExtractPlanFromGroupName(groupName)
  return string.match(groupName, self.Config.groupPlanTagPattern)
end

function MosieNavigator:_ExtractRolexFromGroupName(groupName)
  local rolexText = string.match(groupName, "__[Rr]([%d:]+)$")
  if not rolexText then
    local invalidToken = string.match(groupName, "(__[Rr]%S*)")
    if invalidToken then
      self:_Log("Ignoring invalid group ROLEX token: " .. invalidToken)
    end
    return 0
  end

  local rolexSeconds = self:_ParseRolexDuration(rolexText)
  if not rolexSeconds then
    self:_Log("Ignoring invalid group ROLEX token: __R" .. rolexText)
    return 0
  end

  return rolexSeconds
end

function MosieNavigator:_GetGroupSkill(group)
  if group and type(group.GetSkill) == "function" then
    return group:GetSkill()
  end

  return nil
end

function MosieNavigator:_IsClientGroup(group)
  local skill = self:_GetGroupSkill(group)
  return skill == "Client" or skill == "Player"
end

function MosieNavigator:_ShouldUseGroupAssignment(group)
  if self:_IsClientGroup(group) then
    return true
  end

  return self:_IsTestMode()
end

function MosieNavigator:_DiscoverGroupAssignments(plans)
  local assignments = {}
  self.InactiveGroupLogs = self.InactiveGroupLogs or {}

  local groupSet = SET_GROUP:New():FilterStart()

  groupSet:ForEachGroup(function(group)
    local groupName = group:GetName()
    local planName = self:_ExtractPlanFromGroupName(groupName)
    local rolexSeconds = self:_ExtractRolexFromGroupName(groupName)

    if planName then
      if plans[planName] then
        if group:IsAlive() and self:_ShouldUseGroupAssignment(group) then
          table.insert(assignments, {
            groupName = groupName,
            group = group,
            planName = planName,
            plan = plans[planName],
            rolexSeconds = rolexSeconds,
            skill = self:_GetGroupSkill(group),
            navigatorAutoDefault = true,
          })
        elseif not group:IsAlive() then
          if not self.InactiveGroupLogs[groupName] then
            self:_Log(string.format("group %s references plan %s but is not active yet", groupName, planName))
            self.InactiveGroupLogs[groupName] = true
          end
        end
      else
        self:_Log(string.format("group %s references missing plan %s", groupName, planName))
      end
    end
  end)

  return assignments
end

function MosieNavigator:_AddMarker(markId)
  if markId then
    table.insert(self.MarkIds, markId)
  end
end

function MosieNavigator:_DiscoverZones()
  local plans = {}
  local beacons = {}
  local zoneSet = SET_ZONE:New():FilterPrefixes({self.Config.flightZonePrefix, self.Config.beaconZonePrefix}):FilterStart()

  zoneSet:ForEachZone(function(zone)
    local zoneName = zone:GetName()
    local waypoint = self:_ParseWaypointZoneName(zoneName)

    if waypoint then
      waypoint.zoneName = zoneName
      waypoint.zone = zone
      waypoint.coordinate = zone:GetCoordinate()
      plans[waypoint.plan] = plans[waypoint.plan] or {name = waypoint.plan, waypoints = {}}
      table.insert(plans[waypoint.plan].waypoints, waypoint)
      return
    end

    local beacon = self:_ParseBeaconZoneName(zoneName)
    if beacon then
      beacon.zoneName = zoneName
      beacon.zone = zone
      beacon.coordinate = zone:GetCoordinate()
      table.insert(beacons, beacon)
      return
    end

    self:_Log("Ignoring malformed navigator zone: " .. zoneName)
  end)

  for _, plan in pairs(plans) do
    local seenOrders = {}
    for _, waypoint in ipairs(plan.waypoints) do
      local existing = seenOrders[waypoint.order]
      if existing then
        self:_Log(string.format(
          "WARN: plan %s has duplicate order %d: %s vs %s",
          plan.name, waypoint.order, existing.zoneName, waypoint.zoneName
        ))
      end
      seenOrders[waypoint.order] = waypoint
    end

    table.sort(plan.waypoints, function(a, b)
      return a.order < b.order
    end)
  end

  return plans, beacons
end
