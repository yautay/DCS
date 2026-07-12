function MosieNavigator:DrawDebug()
  self.MarkIds = self.MarkIds or {}

  local plans, beacons = self:_DiscoverZones()
  self.Plans = plans

  local planIndex = 0
  local waypointCount = 0

  for _, plan in pairs(plans) do
    planIndex = planIndex + 1
    waypointCount = waypointCount + #plan.waypoints
    self:_DrawPlan(plan, self:_GetPlanColor(planIndex))
  end

  for _, beacon in ipairs(beacons) do
    self:_DrawBeacon(beacon)
  end

  self:_CreateGroupMenus(plans)
  self:_WriteFlightPlanFiles(plans)
  if self.Config.generateCsvFiles then
    self:_WriteBeaconsCsvFile(beacons)
  end

  self:_Log(string.format(
    "debug draw complete: %d plans, %d waypoints, %d beacons",
    planIndex,
    waypointCount,
    #beacons
  ))
end

function MosieNavigator:Start()
  self.MarkIds = {}
  self.MenusCreated = {}
  self.InactiveGroupLogs = {}
  self.NavigatorStates = {}
  self.GroupPlanStates = {}
  self.MissionRolexSeconds = self.MissionRolexSeconds or 0
  self:_Log("starting debug discovery")
  self:DrawDebug()
  self:_StartMenuRefreshScheduler()
  self:_StartNavigatorScheduler()
end

if MOSIE_NAVIGATOR_AUTO_START ~= false then
  MosieNavigator:Start()
end
