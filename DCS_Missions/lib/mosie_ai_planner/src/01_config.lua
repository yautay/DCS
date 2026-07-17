MosieAiPlanner = MosieAiPlanner or {}

local MosieAiPlannerConfigDefaults = {
  enabled = true,
  groupPlanTagPattern = "%[MN:([%w%-]+)%]",
  targetPackageZonePrefix = "MNT_",
  tickInterval = 15,
  retaskCooldownSeconds = 30,
  flightSampleIntervalSeconds = 15,
  etaToleranceSeconds = 15,
  startLeadSeconds = 3 * 60,
  waypointArrivalRadiusNm = 1.0,
  minSpeedKt = 140,
  maxSpeedKt = 300,
  holdSpeedKt = 140,
  lineInterceptMinDistanceNm = 10,
  lineInterceptXteThresholdNm = 1,
  lineInterceptLookaheadNm = 5,
  attackTimeoutSeconds = 120,
  attackStrafeLengthMeters = 400,
  attackCarpetLengthMeters = 500,
  searchDestroyMaxTargets = 4,
}

MosieAiPlanner.Config = MosieAiPlanner.Config or {}
for key, value in pairs(MosieAiPlannerConfigDefaults) do
  if MosieAiPlanner.Config[key] == nil then
    MosieAiPlanner.Config[key] = value
  end
end
