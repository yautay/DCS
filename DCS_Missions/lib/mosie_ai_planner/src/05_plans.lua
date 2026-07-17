function MosieAiPlanner:_GetMissionRolexSeconds()
  local navigator = self:_GetNavigator()
  return (navigator and navigator.MissionRolexSeconds) or 0
end

function MosieAiPlanner:_GetPlans()
  local navigator = self:_GetNavigator()
  if not navigator then
    return nil
  end

  if navigator.Plans then
    return navigator.Plans
  end

  if type(navigator._DiscoverZones) == "function" then
    local plans = navigator:_DiscoverZones()
    navigator.Plans = plans
    return plans
  end

  return nil
end

function MosieAiPlanner:_DiscoverAssignments(plans)
  local assignments = {}
  if not plans or not SET_GROUP then
    return assignments
  end

  local groupSet = SET_GROUP:New():FilterStart()
  groupSet:ForEachGroup(function(group)
    local groupName = group:GetName()
    local planName = self:_ExtractPlanFromGroupName(groupName)
    if planName and plans[planName] and self:_IsGroupExisting(group) and self:_IsAiGroup(group) then
      table.insert(assignments, {
        group = group,
        groupName = groupName,
        plan = plans[planName],
        planName = planName,
        rolexSeconds = self:_ExtractRolexFromGroupName(groupName),
      })
    end
  end)

  return assignments
end

function MosieAiPlanner:_ParseTargetPackageMetadata(metadataTokens)
  local metadata = {unitFilters = {}}

  for _, token in ipairs(metadataTokens or {}) do
    local upperToken = string.upper(token)
    local unitFilter = string.match(upperToken, "^U_(.+)$")
    if unitFilter and unitFilter ~= "" then
      table.insert(metadata.unitFilters, unitFilter)
    else
      self:_Log("Ignoring unknown target package metadata token: " .. tostring(token))
    end
  end

  return metadata
end

function MosieAiPlanner:_ParseTargetPackageZoneName(zoneName)
  local zoneParts = self:_SplitPlain(zoneName or "", "__")
  local tokens = self:_SplitPlain(zoneParts[1] or "", "_")
  if tokens[1] ~= "MNT" then
    return nil
  end

  for _, token in ipairs(tokens) do
    if token == "" then
      self:_Log("WARN: empty token in target package zone name: " .. tostring(zoneName))
      return nil
    end
  end

  local profiles = {
    {name = "SEARCH_DESTROY", parts = {"SEARCH", "DESTROY"}},
    {name = "DIVE_BOMB",      parts = {"DIVE", "BOMB"}},
    {name = "LEVEL_BOMB",     parts = {"LEVEL", "BOMB"}},
    {name = "ILLUM",          parts = {"ILLUM"}},
    {name = "ROCKETS",        parts = {"ROCKETS"}},
    {name = "STRAFE",         parts = {"STRAFE"}},
  }

  local profileName, profileStart, profileEnd = nil, nil, nil
  for index = 3, #tokens do
    for _, profile in ipairs(profiles) do
      local matches = true
      for offset, part in ipairs(profile.parts) do
        if tokens[index + offset - 1] ~= part then
          matches = false
          break
        end
      end
      if matches then
        profileName = profile.name
        profileStart = index
        profileEnd = index + #profile.parts - 1
        break
      end
    end
    if profileName then break end
  end

  if not profileName or profileStart <= 2 then
    return nil
  end

  local packageId = self:_Join(tokens, 2, profileStart - 1, "_")
  local rawName = self:_Join(tokens, profileEnd + 1, #tokens, "_")
  local metadataTokens = {}
  for index = 2, #zoneParts do
    table.insert(metadataTokens, zoneParts[index])
  end
  local metadata = self:_ParseTargetPackageMetadata(metadataTokens)

  return {
    id = packageId,
    profile = profileName,
    name = rawName ~= "" and rawName or packageId,
    unitFilters = metadata.unitFilters,
  }
end

function MosieAiPlanner:_DiscoverTargetPackages()
  local packages = {}
  if not SET_ZONE then
    return packages
  end

  local zoneSet = SET_ZONE:New():FilterPrefixes({self.Config.targetPackageZonePrefix}):FilterStart()
  zoneSet:ForEachZone(function(zone)
    local zoneName = zone:GetName()
    local package = self:_ParseTargetPackageZoneName(zoneName)
    if package then
      package.zoneName = zoneName
      package.zone = zone
      package.coordinate = zone:GetCoordinate()
      package.radiusM = type(zone.GetRadius) == "function" and zone:GetRadius() or nil
      packages[package.id] = package
    else
      self:_Log("Ignoring malformed target package zone: " .. tostring(zoneName))
    end
  end)

  return packages
end

function MosieAiPlanner:_GetComputedPlan(assignment)
  local navigator = self:_GetNavigator()
  if not navigator or not assignment or not assignment.plan then
    return nil
  end

  if type(navigator._GetActiveComputedPlan) == "function" then
    return navigator:_GetActiveComputedPlan(assignment.plan, assignment.rolexSeconds or 0, self:_GetMissionRolexSeconds())
  end

  if type(navigator._ComputePlan) == "function" then
    return navigator:_ComputePlan(assignment.plan, (assignment.rolexSeconds or 0) + self:_GetMissionRolexSeconds())
  end

  return nil
end

function MosieAiPlanner:_GetSecondsToClockSeconds(clockSeconds)
  local navigator = self:_GetNavigator()
  if navigator and type(navigator._GetSecondsToClockSeconds) == "function" then
    return navigator:_GetSecondsToClockSeconds(clockSeconds)
  end

  if not clockSeconds or not timer then
    return nil
  end

  local secondsPerDay     = SECONDS_PER_DAY or 86400
  local secondsPerHalfDay = SECONDS_PER_HALF_DAY or 43200
  local now   = timer.getAbsTime() % secondsPerDay
  local delta = (clockSeconds % secondsPerDay) - now
  if delta < -secondsPerHalfDay then
    delta = delta + secondsPerDay
  elseif delta > secondsPerHalfDay then
    delta = delta - secondsPerDay
  end
  return delta
end
