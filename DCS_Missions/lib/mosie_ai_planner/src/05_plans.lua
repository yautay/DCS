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
