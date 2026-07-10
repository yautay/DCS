SECONDS_PER_DAY = 86400
SECONDS_PER_HALF_DAY = 43200

MosieNavigator = MosieNavigator or {}

MosieNavigator.Config = MosieNavigator.Config or {
  flightZonePrefix = "MN_",
  beaconZonePrefix = "MNB_",
  coalition = -1,
  readOnly = true,
  waypointLineAlpha = 0.95,
  waypointFillAlpha = 0.25,
  beaconLineAlpha = 0.85,
  beaconFillAlpha = 0.22,
  defaultBeaconPowerNm = 60,
  defaultBeaconAltitudeFt = 0,
  defaultWaypointRadiusM = 250,
  generateFlightPlanFiles = true,
  generateCsvFiles = true,
  flightPlanOutputDirectory = nil,
  groupPlanTagPattern = "%[MN:([%w%-]+)%]",
  menuName = "Mosie Navigator",
  flightPlanMessageDuration = 30,
  menuRefreshDelay = 5,
  menuRefreshInterval = 15,
  navigatorTickInterval = 5,
  navigatorReportIntervalDefault = 120,
  navigatorReportIntervals = {30, 60, 120, 300},
  navigatorMessageDuration = 20,
  navigatorCalloutSeconds = {60, 30},
  navigatorXteStepNm = 1,
}

MosieNavigator.WaypointTypes = {
  TAKE_OFF = true,
  LANDING = true,
  RENDEZVOUS = true,
  INGRESS = true,
  TARGET = true,
  EGRESS = true,
  NAV = true,
  HOLD = true,
}

MosieNavigator.PlanColors = {
  {0.20, 0.60, 1.00},
  {1.00, 0.55, 0.10},
  {0.30, 0.90, 0.35},
  {0.90, 0.30, 0.90},
  {1.00, 0.90, 0.20},
  {0.15, 0.90, 0.90},
  {1.00, 0.25, 0.25},
}

MosieNavigator.BeaconColor = {0.20, 0.80, 0.20}

MosieNavigator.Aircraft = MosieNavigator.Aircraft or {
  name = "Mosquito FB Mk VI",
  profiles = {
    { name = "econ_low",  altMaxFt = 10000, iasKtMin = 185, iasKtMax = 215, burnImpGph = 78  },
    { name = "econ_high", altMinFt = 10000, iasKtMin = 165, iasKtMax = 185, burnImpGph = 75  },
    { name = "fast_low",  altMaxFt = 10000, iasKtMin = 215, iasKtMax = 240, burnImpGph = 90  },
    { name = "combat",                      iasKtMin = 240, iasKtMax = 260, burnImpGph = 115 },
  },
  envelope = {
    minIasKt = 165,
    maxIasKt = 260,
  },
  fuel = {
    unit           = "IMP_GAL",
    tankCapacity   = 546,
    taxiAllowance  = 15,
    landingAllowance = 5,
    reserveMinutes = 30,
  },
  holdIasKt      = 140,
  holdBurnImpGph = 65,
}
