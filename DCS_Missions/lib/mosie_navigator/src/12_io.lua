function MosieNavigator:_WriteFlightPlanFile(plan, groupName, rolexSeconds)
  if not io then
    self:_Log("cannot write flight plan file: io is not available")
    return
  end

  local outputDirectory = self:_GetOutputDirectory()
  local filename = nil

  if groupName then
    filename = string.format("MosieNavigator_%s_%s.txt", self:_SanitizeFilename(groupName), self:_SanitizeFilename(plan.name))
  else
    filename = string.format("MosieNavigator_%s.txt", self:_SanitizeFilename(plan.name))
  end

  local path = outputDirectory .. filename
  local file = io.open(path, "w")

  if not file then
    self:_Log("cannot write flight plan file: " .. path)
    return
  end

  file:write(self:_BuildFlightPlanTable(plan, groupName, rolexSeconds))
  file:close()

  self:_Log("wrote flight plan file: " .. path)
end

function MosieNavigator:_WriteFlightPlanCsvFile(plan)
  if not io then
    self:_Log("cannot write flight plan CSV file: io is not available")
    return
  end

  local outputDirectory = self:_GetOutputDirectory()
  local filename = string.format("MosieNavigator_%s.csv", self:_SanitizeFilename(plan.name))

  local path = outputDirectory .. filename
  local file = io.open(path, "w")

  if not file then
    self:_Log("cannot write flight plan CSV file: " .. path)
    return
  end

  file:write(self:_BuildFlightPlanCsv(plan))
  file:close()

  self:_Log("wrote flight plan CSV file: " .. path)
end

function MosieNavigator:_WriteBeaconsCsvFile(beacons)
  if not beacons or #beacons == 0 then
    return
  end

  if not io then
    self:_Log("cannot write beacons CSV file: io is not available")
    return
  end

  local path = self:_GetOutputDirectory() .. "MosieNavigator_Beacons.csv"
  local file = io.open(path, "w")

  if not file then
    self:_Log("cannot write beacons CSV file: " .. path)
    return
  end

  file:write(self:_BuildBeaconsCsv(beacons))
  file:close()

  self:_Log("wrote beacons CSV file: " .. path)
end

function MosieNavigator:_WriteFlightPlanFiles(plans)
  if not self.Config.generateFlightPlanFiles and not self.Config.generateCsvFiles then
    return
  end

  local assignments = self:_DiscoverGroupAssignments(plans)

  if #assignments > 0 then
    for _, assignment in ipairs(assignments) do
      if self.Config.generateFlightPlanFiles then
        self:_WriteFlightPlanFile(assignment.plan, assignment.groupName, assignment.rolexSeconds)
      end
    end
  end

  if #assignments == 0 then
    self:_Log("no group assignments found; writing one debug navlog per plan")
  end

  for _, plan in pairs(plans) do
    if #assignments == 0 and self.Config.generateFlightPlanFiles then
      self:_WriteFlightPlanFile(plan, nil)
    end
    if self.Config.generateCsvFiles then
      self:_WriteFlightPlanCsvFile(plan)
    end
  end
end
