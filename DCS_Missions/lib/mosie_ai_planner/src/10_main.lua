function MosieAiPlanner:Tick()
  if not self.Config.enabled then
    return
  end

  local plans = self:_GetPlans()
  self.TargetPackages = self:_DiscoverTargetPackages()
  local assignments = self:_DiscoverAssignments(plans)
  self.States = self.States or {}

  for _, assignment in ipairs(assignments) do
    local state = self.States[assignment.groupName]
    if not state then
      state = {assignment = assignment, currentWpIndex = 2}
      self.States[assignment.groupName] = state
    end
    state.assignment = assignment
    self:_TickAssignment(state)
  end
end

function MosieAiPlanner:Start()
  if not self.Config.enabled or self.Scheduler then
    return
  end

  self.States = self.States or {}
  self:_ResetAiZoneDumpFile()
  self.Scheduler = SCHEDULER:New(nil, function()
    MosieAiPlanner:Tick()
  end, {}, 1, self.Config.tickInterval)
  self:_Log(string.format("scheduled every %d seconds", self.Config.tickInterval))
end

if MOSIE_AI_PLANNER_AUTO_START ~= false then
  MosieAiPlanner:Start()
end
