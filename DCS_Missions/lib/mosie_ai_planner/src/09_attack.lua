local MOSIE_AI_WEAPON = {
  AUTO    = 1073741822,
  CANNON  = 805306368,
  ROCKETS = 30720,
  BOMBS   = 2032,
}

function MosieAiPlanner:_GetTargetPackage(packageId)
  return packageId and self.TargetPackages and self.TargetPackages[packageId] or nil
end

function MosieAiPlanner:_GetWaypointTargetPackageId(waypoint)
  local source = waypoint and (waypoint.source or waypoint) or nil
  return source and source.targetPackageId or nil
end

function MosieAiPlanner:_GetAttackCommitReached(state, waypoint)
  local source = waypoint and (waypoint.source or waypoint) or nil
  if not source or source.type ~= "TARGET" then
    return false
  end

  local groupCoordinate = self:_GetGroupCoordinate(state.assignment.group)
  if not groupCoordinate then
    return false
  end

  local inside = self:_IsCoordinateInWaypointZone(groupCoordinate, source)
  if inside then
    return true
  end

  local distanceNm = self:_GetDistanceNm(groupCoordinate, source.coordinate)
  return distanceNm ~= nil and distanceNm <= self.Config.waypointArrivalRadiusNm
end

function MosieAiPlanner:_GetAttackDirectionDegrees(computed, targetPackage, targetWaypointIndex)
  if not computed or not targetPackage or not targetPackage.coordinate then
    return nil
  end

  local previous = computed.waypoints and computed.waypoints[(targetWaypointIndex or 1) - 1] or nil
  local previousSource = previous and (previous.source or previous) or nil
  if not previousSource or not previousSource.coordinate or type(targetPackage.coordinate.HeadingTo) ~= "function" then
    return nil
  end

  return targetPackage.coordinate:HeadingTo(previousSource.coordinate)
end

function MosieAiPlanner:_BuildBombingTask(targetPackage, directionDegrees, altitudeMeters, dive)
  local vec2 = self:_CoordinateToVec2(targetPackage.coordinate)
  if not vec2 then
    return nil
  end

  return {
    id = "Bombing",
    params = {
      point = vec2,
      x = vec2.x,
      y = vec2.y,
      groupAttack = true,
      expend = "All",
      attackQtyLimit = false,
      attackQty = 1,
      directionEnabled = directionDegrees ~= nil,
      direction = directionDegrees and math.rad(directionDegrees) or 0,
      altitudeEnabled = altitudeMeters ~= nil,
      altitude = altitudeMeters or 0,
      weaponType = MOSIE_AI_WEAPON.BOMBS,
      attackType = dive and "Dive" or nil,
    },
  }
end

function MosieAiPlanner:_BuildCarpetBombingTask(targetPackage, directionDegrees, altitudeMeters)
  local vec2 = self:_CoordinateToVec2(targetPackage.coordinate)
  if not vec2 then
    return nil
  end

  return {
    id = "CarpetBombing",
    params = {
      attackType = "Carpet",
      x = vec2.x,
      y = vec2.y,
      groupAttack = true,
      carpetLength = self.Config.attackCarpetLengthMeters,
      weaponType = MOSIE_AI_WEAPON.BOMBS,
      expend = "All",
      attackQtyLimit = false,
      attackQty = 1,
      directionEnabled = directionDegrees ~= nil,
      direction = directionDegrees and math.rad(directionDegrees) or 0,
      altitudeEnabled = altitudeMeters ~= nil,
      altitude = altitudeMeters,
    },
  }
end

function MosieAiPlanner:_BuildStrafingTask(targetPackage, weaponType, directionDegrees)
  local vec2 = self:_CoordinateToVec2(targetPackage.coordinate)
  if not vec2 then
    return nil
  end

  return {
    id = "Strafing",
    params = {
      point = vec2,
      weaponType = weaponType,
      expend = "All",
      attackQty = 1,
      attackQtyLimit = false,
      directionEnabled = directionDegrees ~= nil,
      direction = directionDegrees and math.rad(directionDegrees) or 0,
      groupAttack = true,
      length = targetPackage.radiusM or self.Config.attackStrafeLengthMeters,
    },
  }
end

function MosieAiPlanner:_BuildAttackUnitTask(unit)
  if not unit or type(unit.getID) ~= "function" then
    return nil
  end

  local ok, unitId = pcall(function() return unit:getID() end)
  if not ok or not unitId then
    return nil
  end

  return {
    id = "AttackUnit",
    params = {
      unitId = unitId,
      groupAttack = true,
      expend = "All",
      attackQty = 1,
      attackQtyLimit = false,
      weaponType = MOSIE_AI_WEAPON.AUTO,
    },
  }
end

function MosieAiPlanner:_GetUnitCoalition(unit)
  if unit and type(unit.getCoalition) == "function" then
    local ok, value = pcall(function() return unit:getCoalition() end)
    if ok then return value end
  end
  return nil
end

function MosieAiPlanner:_GetGroupCoalition(group)
  if group and type(group.GetCoalition) == "function" then
    local ok, value = pcall(function() return group:GetCoalition() end)
    if ok then return value end
  end
  if group and type(group.getCoalition) == "function" then
    local ok, value = pcall(function() return group:getCoalition() end)
    if ok then return value end
  end
  return nil
end

function MosieAiPlanner:_UnitIsAlive(unit)
  if not unit then return false end
  if type(unit.isExist) == "function" then
    local ok, exists = pcall(function() return unit:isExist() end)
    if ok and exists == false then return false end
  end
  if type(unit.getLife) == "function" then
    local ok, life = pcall(function() return unit:getLife() end)
    if ok and life and life <= 0 then return false end
  end
  return true
end

function MosieAiPlanner:_UnitHasAttribute(desc, names)
  local attributes = desc and desc.attributes or nil
  if not attributes then return false end
  for _, name in ipairs(names) do
    if attributes[name] then return true end
  end
  return false
end

function MosieAiPlanner:_UnitMatchesFilter(unit, filter)
  local normalized = string.upper(filter or "ANY")
  if normalized == "ANY" then return true end

  local desc = nil
  if unit and type(unit.getDesc) == "function" then
    local ok, value = pcall(function() return unit:getDesc() end)
    if ok then desc = value end
  end

  local typeName = ""
  if unit and type(unit.getTypeName) == "function" then
    local ok, value = pcall(function() return unit:getTypeName() end)
    if ok and value then typeName = string.upper(value) end
  end

  if normalized == "SHIP" then
    return (desc and Unit and desc.category == Unit.Category.SHIP) or self:_UnitHasAttribute(desc, {"Ships", "Armed ships"})
  elseif normalized == "AAA" then
    return self:_UnitHasAttribute(desc, {"AAA", "Air Defence", "Air Defence vehicles", "SAM related"}) or string.find(typeName, "FLAK") ~= nil or string.find(typeName, "AAA") ~= nil
  elseif normalized == "TRUCK" then
    return self:_UnitHasAttribute(desc, {"Trucks", "Unarmed vehicles"}) or string.find(typeName, "TRUCK") ~= nil or string.find(typeName, "LORRY") ~= nil
  elseif normalized == "APC" then
    return self:_UnitHasAttribute(desc, {"APC"}) or string.find(typeName, "APC") ~= nil
  elseif normalized == "TANK" then
    return self:_UnitHasAttribute(desc, {"Tanks"}) or string.find(typeName, "TANK") ~= nil
  elseif normalized == "ARTY" then
    return self:_UnitHasAttribute(desc, {"Artillery"}) or string.find(typeName, "ARTILLERY") ~= nil
  elseif normalized == "INF" then
    return self:_UnitHasAttribute(desc, {"Infantry"}) or string.find(typeName, "INF") ~= nil
  end

  return string.find(typeName, normalized, 1, true) ~= nil
end

function MosieAiPlanner:_UnitMatchesAnyFilter(unit, filters)
  if not filters or #filters == 0 then
    return true
  end

  for _, filter in ipairs(filters) do
    if self:_UnitMatchesFilter(unit, filter) then
      return true
    end
  end

  return false
end

function MosieAiPlanner:_SearchDestroyTargets(state, targetPackage)
  local targets = {}
  if not world or type(world.searchObjects) ~= "function" or not Object or not targetPackage or not targetPackage.coordinate then
    return targets
  end

  local center = targetPackage.coordinate:GetVec3()
  local friendlyCoalition = self:_GetGroupCoalition(state.assignment.group)
  local searchArea = {
    id = world.VolumeType.SPHERE,
    params = {
      point = center,
      radius = targetPackage.radiusM or 500,
    },
  }

  world.searchObjects(Object.Category.UNIT, searchArea, function(unit)
    if self:_UnitIsAlive(unit) then
      local unitCoalition = self:_GetUnitCoalition(unit)
      local hostile = friendlyCoalition == nil or unitCoalition == nil or unitCoalition ~= friendlyCoalition
      if hostile and self:_UnitMatchesAnyFilter(unit, targetPackage.unitFilters) then
        table.insert(targets, unit)
      end
    end
    return true
  end)

  return targets
end

function MosieAiPlanner:_BuildSearchDestroyTask(state, targetPackage)
  local targets = self:_SearchDestroyTargets(state, targetPackage)
  local tasks = {}
  local maxTargets = self.Config.searchDestroyMaxTargets or #targets
  for index, unit in ipairs(targets) do
    if index > maxTargets then break end
    local task = self:_BuildAttackUnitTask(unit)
    if task then table.insert(tasks, task) end
  end

  return tasks, #targets
end

function MosieAiPlanner:_BuildAttackTasks(state, computed, targetWaypoint, targetWaypointIndex, targetPackage)
  local profile = targetPackage and targetPackage.profile or nil
  local direction = self:_GetAttackDirectionDegrees(computed, targetPackage, targetWaypointIndex)
  local altitudeMeters = state.assignment.group.GetAltitude and state.assignment.group:GetAltitude() or nil

  if profile == "DIVE_BOMB" then
    return {self:_BuildBombingTask(targetPackage, direction, altitudeMeters, true)}
  elseif profile == "LEVEL_BOMB" then
    return {self:_BuildCarpetBombingTask(targetPackage, direction, altitudeMeters)}
  elseif profile == "ROCKETS" then
    return {self:_BuildStrafingTask(targetPackage, MOSIE_AI_WEAPON.ROCKETS, direction)}
  elseif profile == "STRAFE" then
    return {self:_BuildStrafingTask(targetPackage, MOSIE_AI_WEAPON.CANNON, direction)}
  elseif profile == "SEARCH_DESTROY" then
    local tasks, foundCount = self:_BuildSearchDestroyTask(state, targetPackage)
    return tasks, foundCount
  end

  return {}
end

function MosieAiPlanner:_BuildComboTask(tasks)
  local combo = {id = "ComboTask", params = {tasks = {}}}
  for _, task in ipairs(tasks or {}) do
    if task then table.insert(combo.params.tasks, task) end
  end
  return combo
end

function MosieAiPlanner:_SetGroupTask(group, task)
  if group and type(group.SetTask) == "function" then
    group:SetTask(task, 1)
    return true
  end

  if group and type(group.GetController) == "function" then
    local controller = group:GetController()
    if controller and type(controller.setTask) == "function" then
      controller:setTask(task)
      return true
    end
  end

  return false
end

function MosieAiPlanner:_IlluminateTargetPackage(targetPackage)
  if not trigger or not trigger.action or type(trigger.action.illuminationBomb) ~= "function" or not targetPackage or not targetPackage.coordinate then
    return false
  end

  local vec3 = targetPackage.coordinate:GetVec3()
  trigger.action.illuminationBomb(vec3, 1000000)
  return true
end

function MosieAiPlanner:_FindNextWaypointIndexByType(computed, startIndex, waypointType)
  for index = (startIndex or 1) + 1, #(computed.waypoints or {}) do
    local waypoint = computed.waypoints[index]
    local source = waypoint and (waypoint.source or waypoint) or nil
    if source and source.type == waypointType then
      return index
    end
  end
  return math.min((startIndex or 1) + 1, #(computed.waypoints or {}))
end

function MosieAiPlanner:_FinishAttack(state, computed, reason)
  local attack = state.attack
  if not attack then
    return false
  end

  local egressIndex = attack.egressWpIndex or self:_FindNextWaypointIndexByType(computed, attack.targetWpIndex, "EGRESS")
  state.attack = nil
  state.currentWpIndex = egressIndex
  state.lastRetaskTime = nil
  self:_SetAiMode(state, "DIRECT_WP", reason or "attack complete", string.format("egress=WP%02d", egressIndex or 0))
  self:_AppendAiCommandDump(state, "ATTACK_EGRESS", string.format("wp=WP%02d reason=%s", egressIndex or 0, tostring(reason or "attack complete")))
  return self:_RetaskRoute(state, "attack egress", nil, computed)
end

function MosieAiPlanner:_TickAttack(state, computed)
  if not state.attack then
    return false
  end

  local now = timer and timer.getTime and timer.getTime() or 0
  local elapsed = now - (state.attack.startedAt or now)
  local timeout = state.attack.timeoutSeconds or self.Config.attackTimeoutSeconds
  if elapsed >= timeout then
    self:_FinishAttack(state, computed, "attack timeout")
    return true
  end

  self:_SetAiMode(state, "ATTACKING", "attack active", string.format(
    "package=%s profile=%s elapsed=%ds",
    tostring(state.attack.packageId or "---"),
    tostring(state.attack.profile or "---"),
    math.max(0, math.floor(elapsed + 0.5))
  ))
  return true
end

function MosieAiPlanner:_MaybeStartAttack(state, computed, waypoint)
  local source = waypoint and (waypoint.source or waypoint) or nil
  if not source or source.type ~= "TARGET" then
    return false
  end

  local packageId = self:_GetWaypointTargetPackageId(source)
  if not packageId or state.attackCompleted and state.attackCompleted[state.currentWpIndex] then
    return false
  end

  if not self:_GetAttackCommitReached(state, source) then
    return false
  end

  local targetPackage = self:_GetTargetPackage(packageId)
  state.attackCompleted = state.attackCompleted or {}
  state.attackCompleted[state.currentWpIndex] = true

  if not targetPackage then
    self:_AppendAiCommandDump(state, "ATTACK_SKIP", string.format("wp=WP%02d package=%s reason=missing_package", state.currentWpIndex or 0, tostring(packageId)))
    self:_Log(string.format("attack package %s not found for %s", tostring(packageId), state.assignment.groupName))
    return false
  end

  local now = timer and timer.getTime and timer.getTime() or 0
  local egressIndex = self:_FindNextWaypointIndexByType(computed, state.currentWpIndex, "EGRESS")
  state.attack = {
    startedAt = now,
    timeoutSeconds = self.Config.attackTimeoutSeconds,
    targetWpIndex = state.currentWpIndex,
    egressWpIndex = egressIndex,
    packageId = packageId,
    profile = targetPackage.profile,
  }

  self:_SetAiMode(state, "ATTACKING", "attack start", string.format("package=%s profile=%s", packageId, targetPackage.profile))

  if targetPackage.profile == "ILLUM" then
    local illuminated = self:_IlluminateTargetPackage(targetPackage)
    self:_AppendAiCommandDump(state, "ATTACK_ILLUM", string.format("package=%s illuminated=%s", packageId, tostring(illuminated)))
    self:_FinishAttack(state, computed, "illum complete")
    return true
  end

  local tasks, foundCount = self:_BuildAttackTasks(state, computed, source, state.currentWpIndex, targetPackage)
  local combo = self:_BuildComboTask(tasks)
  if #combo.params.tasks == 0 then
    self:_AppendAiCommandDump(state, "ATTACK_SKIP", string.format(
      "wp=WP%02d package=%s profile=%s reason=no_tasks found_targets=%s",
      state.currentWpIndex or 0,
      tostring(packageId),
      tostring(targetPackage.profile),
      foundCount and tostring(foundCount) or "---"
    ))
    self:_FinishAttack(state, computed, "attack no tasks")
    return true
  end

  local sent = self:_SetGroupTask(state.assignment.group, combo)
  self:_AppendAiCommandDump(state, "ATTACK_START", string.format(
    "wp=WP%02d package=%s profile=%s tasks=%d sent=%s found_targets=%s egress=WP%02d",
    state.currentWpIndex or 0,
    tostring(packageId),
    tostring(targetPackage.profile),
    #combo.params.tasks,
    tostring(sent),
    foundCount and tostring(foundCount) or "---",
    egressIndex or 0
  ))

  if not sent then
    self:_FinishAttack(state, computed, "attack task unsupported")
  end

  return true
end
