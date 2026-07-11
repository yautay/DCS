-- ============================================================
-- MosieNavigator.lua — GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Edit source modules under src/ and run: python3 build.py
-- ============================================================

-- ==== 01_config.lua ====

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
  defaultCruiseSpeedMph = 228,
  defaultCruiseSpeedKt = 228 * 0.8689762419,
  engineSettings = {
    {
      id = "takeoff_emergency_18",
      name = "Take-Off / Emergency +18",
      rpm = 3000,
      mixture = "rich",
      boostPsi = 18,
      limitMin = 5,
      fuelImpGphPerEngine = nil,
      fuelImpGph = nil,
      seaLevelIasKt = nil,
      notes = "+18 may not be used below 2850 RPM",
    },
    {
      id = "takeoff_12",
      name = "Take-Off +12",
      rpm = 3000,
      mixture = "rich",
      boostPsi = 12,
      fuelImpGphPerEngine = 115,
      fuelImpGph = 230,
      seaLevelIasKt = nil,
    },
    {
      id = "max_climb",
      name = "Max Climbing Power",
      rpm = 2850,
      mixture = "rich",
      boostPsi = 9,
      limitMin = 60,
      fuelImpGphPerEngine = 95,
      fuelImpGph = 190,
      seaLevelIasMph = 240,
      tenThousandFtIasMph = 240,
      seaLevelIasKt = 240 * 0.8689762419,
      profileName = "climb",
      profileCode = "CLB",
    },
    {
      id = "max_cont_rich",
      name = "Max Continuous Rich",
      rpm = 2650,
      mixture = "rich",
      boostPsi = 7,
      fuelImpGphPerEngine = 80,
      fuelImpGph = 160,
      seaLevelIasMph = 237,
      tenThousandFtIasMph = 237,
      seaLevelIasKt = 237 * 0.8689762419,
      profileName = "cont_r",
      profileCode = "MCR",
    },
    {
      id = "max_cont_weak",
      name = "Max Continuous Weak",
      rpm = 2650,
      mixture = "weak",
      boostPsi = 7,
      fuelImpGphPerEngine = 63,
      fuelImpGph = 126,
      seaLevelIasMph = 228,
      tenThousandFtIasMph = 226,
      seaLevelIasKt = 228 * 0.8689762419,
      profileName = "cont_w",
      profileCode = "MCW",
    },
    {
      id = "cruise_weak",
      name = "Cruise Weak",
      rpm = 2300,
      mixture = "weak",
      boostPsi = 2,
      fuelImpGphPerEngine = 42,
      fuelImpGph = 84,
      seaLevelIasMph = 192,
      tenThousandFtIasMph = 198,
      seaLevelIasKt = 192 * 0.8689762419,
      profileName = "cruise",
      profileCode = "CRZ",
    },
  },
  fuelCurveSettingIds = {
    "cruise_weak",
    "max_cont_weak",
    "max_cont_rich",
    "max_climb",
  },
  envelope = {
    minIasKt = 165,
    maxIasMph = 245,
    maxIasKt = 245 * 0.8689762419,
  },
  fuel = {
    unit           = "IMP_GAL",
    tankCapacity   = 653.1,
    internalFuelLb = 3269,
    fuelLbPerGal   = 7.215,
    internalFuelBufferPercent = 1,
    dropTankOptions = {
      { label = "NONE", gal = 0 },
      { label = "2x50 GAL", gal = 100 },
      { label = "2x100 GAL", gal = 200 },
    },
    taxiAllowance  = 15,
    landingAllowance = 5,
    reserveMinutes = 30,
  },
  holdIasKt      = 140,
  holdBurnImpGph = 84,
}

-- ==== 02_util.lua ====

function MosieNavigator:_Log(message)
  env.info("MOSIE_NAVIGATOR: " .. tostring(message))
end

function MosieNavigator:_Split(value, separator)
  local result = {}
  local pattern = string.format("([^%s]+)", separator)

  for part in string.gmatch(value, pattern) do
    table.insert(result, part)
  end

  return result
end

function MosieNavigator:_SplitPlain(value, delimiter)
  local result = {}
  local startIndex = 1

  while true do
    local delimiterStart, delimiterEnd = string.find(value, delimiter, startIndex, true)
    if not delimiterStart then
      table.insert(result, string.sub(value, startIndex))
      break
    end

    table.insert(result, string.sub(value, startIndex, delimiterStart - 1))
    startIndex = delimiterEnd + 1
  end

  return result
end

function MosieNavigator:_Join(tokens, startIndex, separator)
  local result = {}

  for index = startIndex, #tokens do
    table.insert(result, tokens[index])
  end

  return table.concat(result, separator)
end

function MosieNavigator:_FormatClock(seconds)
  seconds = seconds % SECONDS_PER_DAY

  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local clockSeconds = seconds % 60

  if clockSeconds == 0 then
    return string.format("%02d:%02d", hours, minutes)
  end

  return string.format("%02d:%02d:%02d", hours, minutes, clockSeconds)
end

function MosieNavigator:_FormatDisplayEta(seconds)
  local rounded = math.floor((seconds or 0) / 60 + 0.5) * 60
  return self:_FormatClock(rounded)
end

function MosieNavigator:_FormatWaypointTypeShort(waypointType)
  local shortcuts = {
    TAKE_OFF = "O",
    LANDING = "L",
    INGRESS = "I",
    TARGET = "T",
    EGRESS = "E",
    NAV = "N",
    HOLD = "H",
  }

  return shortcuts[waypointType] or string.sub(tostring(waypointType or "?"), 1, 1)
end

function MosieNavigator:_FuelGalToLb(gal)
  return (gal or 0) * self.Aircraft.fuel.fuelLbPerGal
end

function MosieNavigator:_FuelLbToGal(lb)
  return (lb or 0) / self.Aircraft.fuel.fuelLbPerGal
end

function MosieNavigator:_BuildDcsFuelRecommendation(requiredGal)
  local fuel = self.Aircraft.fuel
  local internalGal = self:_FuelLbToGal(fuel.internalFuelLb)
  local options = fuel.dropTankOptions or {{ label = "NONE", gal = 0 }}
  local selected = options[#options]

  for _, option in ipairs(options) do
    if requiredGal <= internalGal + option.gal then
      selected = option
      break
    end
  end

  local capacityGal = internalGal + selected.gal
  local internalPercent = 100
  if selected.gal == 0 then
    internalPercent = math.ceil(requiredGal / internalGal * 100) + (fuel.internalFuelBufferPercent or 0)
    if internalPercent > 100 then internalPercent = 100 end
  end

  local marginGal = capacityGal - requiredGal
  return {
    requiredGal = requiredGal,
    requiredLb = self:_FuelGalToLb(requiredGal),
    internalFuelGal = internalGal,
    internalFuelLb = fuel.internalFuelLb,
    internalPercent = internalPercent,
    dropTankLabel = selected.label,
    dropTankGal = selected.gal,
    capacityGal = capacityGal,
    capacityLb = self:_FuelGalToLb(capacityGal),
    marginGal = marginGal,
    marginLb = self:_FuelGalToLb(marginGal),
    marginPercent = capacityGal > 0 and (marginGal / capacityGal * 100) or 0,
    exceedsCapacity = requiredGal > capacityGal,
  }
end

function MosieNavigator:_FormatRolex(seconds)
  if not seconds or seconds == 0 then
    return "+00:00"
  end

  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local clockSeconds = seconds % 60

  if clockSeconds == 0 then
    return string.format("+%02d:%02d", hours, minutes)
  end

  return string.format("+%02d:%02d:%02d", hours, minutes, clockSeconds)
end

function MosieNavigator:_FormatSignedRolex(seconds)
  seconds = seconds or 0
  if seconds >= 0 then
    return self:_FormatRolex(seconds)
  end

  local text = self:_FormatRolex(-seconds)
  return "-" .. string.sub(text, 2)
end

function MosieNavigator:_GetPlanColor(planIndex)
  return self.PlanColors[((planIndex - 1) % #self.PlanColors) + 1]
end

function MosieNavigator:_CopyColor(color)
  return {color[1], color[2], color[3]}
end

function MosieNavigator:_SanitizeFilename(value)
  return string.gsub(tostring(value), "[^%w%-_]+", "_")
end

function MosieNavigator:_GetOutputDirectory()
  if self.Config.flightPlanOutputDirectory then
    return self.Config.flightPlanOutputDirectory
  end

  if lfs and lfs.writedir then
    return lfs.writedir() .. "Logs/"
  end

  return "./"
end

function MosieNavigator:_FormatHeading(heading)
  if not heading then
    return "---"
  end

  return string.format("%03d", math.floor(heading + 0.5) % 360)
end

function MosieNavigator:_FormatMagneticHeading(trueHeading, coordinate)
  if not trueHeading or not coordinate then
    return "---"
  end

  return self:_FormatHeading(trueHeading + self:_GetMagneticVariation(coordinate))
end

function MosieNavigator:_FormatMagneticHeadingWithVariation(trueHeading, magneticVariation)
  if trueHeading == nil or magneticVariation == nil then
    return "---"
  end

  return self:_FormatHeading(trueHeading + magneticVariation)
end

function MosieNavigator:_GetHeadingDelta(fromHeading, toHeading)
  if fromHeading == nil or toHeading == nil then
    return nil
  end

  return ((toHeading - fromHeading + 540) % 360) - 180
end

function MosieNavigator:_FormatSignedDegrees(value)
  if value == nil then
    return "---"
  end

  local rounded = value >= 0 and math.floor(value + 0.5) or math.ceil(value - 0.5)
  return string.format("%+03d", rounded)
end

function MosieNavigator:_GetMagneticVariation(coordinate)
  if not coordinate or not coordinate.GetMagneticDeclination then
    return 0
  end

  return -(coordinate:GetMagneticDeclination() or 0)
end

function MosieNavigator:_KnotsToMph(knots)
  if not knots then
    return nil
  end

  return knots * 1.15077945
end

function MosieNavigator:_FormatOptional(value)
  if value == nil then
    return "---"
  end

  return tostring(value)
end

function MosieNavigator:_FormatWaypointTot(waypoint, rolexSeconds)
  if not waypoint.timeOnTargetSeconds then
    return "---"
  end

  return self:_FormatDisplayEta(waypoint.timeOnTargetSeconds + (rolexSeconds or 0))
end

function MosieNavigator:_FormatSpeed(speedKt)
  if not speedKt then
    return "---"
  end

  return string.format("%.0f", speedKt)
end

function MosieNavigator:_NormalizeHeading(heading)
  return (heading % 360 + 360) % 360
end

function MosieNavigator:_Atan2(y, x)
  if math.atan2 then
    return math.atan2(y, x)
  end

  return math.atan(y, x)
end

function MosieNavigator:_FitText(value, width)
  value = tostring(value or "")

  if string.len(value) > width then
    return string.sub(value, 1, width)
  end

  return value
end



-- ==== 03_parser.lua ====

function MosieNavigator:_ParseTimeOnTarget(value)
  local hours, minutes = string.match(value or "", "^(%d%d?):(%d%d)$")

  if not hours or not minutes then
    return nil
  end

  hours = tonumber(hours)
  minutes = tonumber(minutes)

  if hours > 23 or minutes > 59 then
    return nil
  end

  return string.format("%02d:%02d", hours, minutes), hours * 3600 + minutes * 60
end

function MosieNavigator:_ParseRolexDuration(value)
  local parts = self:_Split(value or "", ":")

  if #parts == 1 then
    local minutes = tonumber(parts[1])
    if not minutes or minutes < 0 then return nil end
    return minutes * 60
  elseif #parts == 2 then
    local hours = tonumber(parts[1])
    local minutes = tonumber(parts[2])
    if not hours or not minutes or hours < 0 or minutes < 0 or minutes > 59 then
      return nil
    end
    return hours * 3600 + minutes * 60
  elseif #parts == 3 then
    local hours = tonumber(parts[1])
    local minutes = tonumber(parts[2])
    local seconds = tonumber(parts[3])
    if not hours or not minutes or not seconds
       or hours < 0 or minutes < 0 or seconds < 0
       or minutes > 59 or seconds > 59 then
      return nil
    end
    return hours * 3600 + minutes * 60 + seconds
  end

  return nil
end

function MosieNavigator:_ParseWaypointMetadata(metadataTokens)
  local metadata = {}

  for _, token in ipairs(metadataTokens) do
    local upperToken = string.upper(token)
    local altitude = string.match(upperToken, "^A(%-?%d+)$")
      or string.match(upperToken, "^A(%-?%d+)FT$")
    local timeText = string.match(token, "^T(.+)$")
    local speed = string.match(upperToken, "^S(%d+)$")
      or string.match(upperToken, "^S(%d+)KT$")

    if altitude then
      metadata.altitudeFt = tonumber(altitude)
    elseif timeText then
      metadata.timeOnTarget, metadata.timeOnTargetSeconds = self:_ParseTimeOnTarget(timeText)
      if not metadata.timeOnTarget then
        self:_Log("Ignoring invalid waypoint T token: " .. token)
      end
    elseif speed then
      metadata.speedKt = tonumber(speed)
    else
      self:_Log("Ignoring unknown waypoint metadata token: " .. token)
    end
  end

  return metadata
end

function MosieNavigator:_ParseWaypointZoneName(zoneName)
  local zoneParts = self:_SplitPlain(zoneName, "__")
  local tokens = self:_SplitPlain(zoneParts[1], "_")

  if tokens[1] ~= "MN" then
    return nil
  end

  for _, token in ipairs(tokens) do
    if token == "" then
      self:_Log("WARN: empty token in waypoint zone name: " .. zoneName)
      return nil
    end
  end

  local plan = tokens[2]
  local order = tonumber(tokens[3])
  local waypointType = tokens[4]
  local nameStartIndex = 5

  if waypointType == "TAKE" and tokens[5] == "OFF" then
    waypointType = "TAKE_OFF"
    nameStartIndex = 6
  end

  if waypointType == "LAND" then
    waypointType = "LANDING"
  end

  if not plan or not order or not waypointType or not self.WaypointTypes[waypointType] then
    return nil
  end

  local rawName = self:_Join(tokens, nameStartIndex, "_")
  local nameExplicit = rawName ~= ""
  local name = nameExplicit and rawName or waypointType

  local metadataTokens = {}
  for index = 2, #zoneParts do
    table.insert(metadataTokens, zoneParts[index])
  end

  local metadata = self:_ParseWaypointMetadata(metadataTokens)

  return {
    plan = plan,
    order = order,
    type = waypointType,
    name = name,
    nameExplicit = nameExplicit,
    altitudeFt = metadata.altitudeFt,
    speedKt = metadata.speedKt,
    timeOnTarget = metadata.timeOnTarget,
    timeOnTargetSeconds = metadata.timeOnTargetSeconds,
  }
end

function MosieNavigator:_ParseBeaconZoneName(zoneName)
  local tokens = self:_SplitPlain(zoneName, "_")

  if tokens[1] ~= "MNB" or not tokens[2] then
    return nil
  end

  for _, token in ipairs(tokens) do
    if token == "" then
      self:_Log("WARN: empty token in beacon zone name: " .. zoneName)
      return nil
    end
  end

  return {
    id = tokens[2],
    frequency = tokens[3],
    powerNm = self:_ParseNumberWithSuffix(tokens[4], "NM") or self.Config.defaultBeaconPowerNm,
    altitudeFt = self:_ParseNumberWithSuffix(tokens[5], "FT") or self.Config.defaultBeaconAltitudeFt,
  }
end

function MosieNavigator:_ParseNumberWithSuffix(value, suffix)
  if not value then
    return nil
  end

  local numberText = string.match(string.upper(value), "^(%-?%d+%.?%d*)" .. suffix .. "$")
  if not numberText then
    return nil
  end

  return tonumber(numberText)
end

-- ==== 04_physics.lua ====

function MosieNavigator:_ConvertTasToIas(tasKt, altitudeFt)
  if not tasKt or not altitudeFt then
    return nil
  end

  local altitudeM = UTILS.FeetToMeters(altitudeFt)
  local temperatureRatio = 1 - (0.0065 * altitudeM / 288.15)
  if temperatureRatio <= 0 then
    return nil
  end

  local densityRatio = temperatureRatio ^ 4.25588
  return tasKt * math.sqrt(densityRatio)
end

function MosieNavigator:_ConvertIasToTas(iasKt, altitudeFt)
  if not iasKt or not altitudeFt then
    return nil
  end

  local altitudeM = UTILS.FeetToMeters(altitudeFt)
  local temperatureRatio = 1 - (0.0065 * altitudeM / 288.15)
  if temperatureRatio <= 0 then
    return nil
  end

  local densityRatio = temperatureRatio ^ 4.25588
  return iasKt / math.sqrt(densityRatio)
end

function MosieNavigator:_MatchProfile(iasKt, altFt)
  return self:_EstimateFuelProfile(iasKt, altFt)
end

function MosieNavigator:_GetEngineSettingById(id)
  for _, setting in ipairs(self.Aircraft.engineSettings or {}) do
    if setting.id == id then
      return setting
    end
  end
  return nil
end

function MosieNavigator:_GetFuelCurveSettings()
  local curve = {}
  for _, id in ipairs(self.Aircraft.fuelCurveSettingIds or {}) do
    local setting = self:_GetEngineSettingById(id)
    if setting and setting.fuelImpGph and setting.seaLevelIasKt then
      table.insert(curve, setting)
    end
  end

  table.sort(curve, function(a, b)
    return a.seaLevelIasKt < b.seaLevelIasKt
  end)

  return curve
end

function MosieNavigator:_FuelProfileName(a, b)
  local aName = a.profileCode or a.profileName or a.id
  if not b or a.id == b.id then
    return aName
  end
  return aName .. "-" .. (b.profileCode or b.profileName or b.id)
end

function MosieNavigator:_EstimateFuelProfile(iasKt, altFt)
  local curve = self:_GetFuelCurveSettings()

  if #curve == 0 then
    return { name = "fuel_unknown", burnImpGph = 0, interpolated = false }
  end

  if iasKt <= curve[1].seaLevelIasKt then
    return {
      name = self:_FuelProfileName(curve[1]),
      burnImpGph = curve[1].fuelImpGph,
      interpolated = false,
      fromSetting = curve[1],
      toSetting = curve[1],
    }
  end

  for i = 1, #curve - 1 do
    local a = curve[i]
    local b = curve[i + 1]
    if iasKt <= b.seaLevelIasKt then
      local span = b.seaLevelIasKt - a.seaLevelIasKt
      local ratio = span > 0 and ((iasKt - a.seaLevelIasKt) / span) or 0
      local burn = a.fuelImpGph + ratio * (b.fuelImpGph - a.fuelImpGph)
      return {
        name = self:_FuelProfileName(a, b),
        burnImpGph = burn,
        interpolated = ratio > 0 and ratio < 1,
        fromSetting = a,
        toSetting = b,
      }
    end
  end

  local last = curve[#curve]
  return {
    name = self:_FuelProfileName(last),
    burnImpGph = last.fuelImpGph,
    interpolated = false,
    fromSetting = last,
    toSetting = last,
  }
end

function MosieNavigator:_ClampSpeed(requiredIasKt, warnings, context)
  local env = self.Aircraft.envelope
  if requiredIasKt < env.minIasKt then
    table.insert(warnings, string.format(
      "%s: required %.0f IAS below minimum %.0f IAS — clamped",
      context, requiredIasKt, env.minIasKt
    ))
    return env.minIasKt, true
  elseif requiredIasKt > env.maxIasKt then
    table.insert(warnings, string.format(
      "%s: required %.0f IAS above maximum %.0f IAS — clamped",
      context, requiredIasKt, env.maxIasKt
    ))
    return env.maxIasKt, true
  end
  return requiredIasKt, false
end

-- ==== 05_compute.lua ====

-- Resolves GS (kt) for each leg in a segment between two __T anchors (no HOLD).
-- Returns table of gsKt per leg index (1-based within segment legs).
function MosieNavigator:_ResolveSegmentSpeeds(segLegs, totalTimeSec, warnings, segLabel)
  local n = #segLegs

  -- Classify: FIXED = explicit __S on arriving WP, FREE = no explicit __S
  local fixedIndices = {}
  local freeIndices  = {}
  for i, leg in ipairs(segLegs) do
    if leg.speedKt then
      table.insert(fixedIndices, i)
    else
      table.insert(freeIndices, i)
    end
  end

  local result = {}

  if #freeIndices == 0 then
    -- All FIXED: __T wins, uniform derived speed
    local totalDist = 0
    for _, leg in ipairs(segLegs) do totalDist = totalDist + leg.distNm end
    local sources = {}
    if totalTimeSec <= 0 or totalDist <= 0 then
      for i = 1, n do result[i] = self.Aircraft.envelope.minIasKt; sources[i] = "computed" end
      return result, sources
    end
    local derivedGs = totalDist / (totalTimeSec / 3600)
    local avgAlt    = 0
    for _, leg in ipairs(segLegs) do avgAlt = avgAlt + (leg.altFt or 0) end
    avgAlt = avgAlt / n
    local derivedIas = self:_ConvertTasToIas(derivedGs, avgAlt) or derivedGs
    derivedIas = self:_ClampSpeed(derivedIas, warnings, segLabel .. " all-FIXED override")
    local clampedGs = self:_ConvertIasToTas(derivedIas, avgAlt) or derivedIas
    for i = 1, n do
      if segLegs[i].speedKt then
        table.insert(warnings, string.format(
          "%s WP%02d __S%d ignored — all-FIXED segment uses __T-derived speed %.0f kt GS",
          segLabel, segLegs[i].wpOrder, segLegs[i].speedKt, clampedGs
        ))
      end
      result[i] = clampedGs
      sources[i] = "computed"
    end
    return result, sources
  end

  if #fixedIndices == 0 then
    -- All FREE: uniform derived speed
    local sources = {}
    local totalDist = 0
    for _, leg in ipairs(segLegs) do totalDist = totalDist + leg.distNm end
    if totalTimeSec <= 0 or totalDist <= 0 then
      for i = 1, n do result[i] = self.Aircraft.envelope.minIasKt; sources[i] = "computed" end
      return result, sources
    end
    local derivedGs = totalDist / (totalTimeSec / 3600)
    local avgAlt    = 0
    for _, leg in ipairs(segLegs) do avgAlt = avgAlt + (leg.altFt or 0) end
    avgAlt = avgAlt / n
    local derivedIas = self:_ConvertTasToIas(derivedGs, avgAlt) or derivedGs
    derivedIas, _ = self:_ClampSpeed(derivedIas, warnings, segLabel .. " FREE uniform")
    local clampedGs = self:_ConvertIasToTas(derivedIas, avgAlt) or derivedIas
    for i = 1, n do result[i] = clampedGs; sources[i] = "computed" end
    return result, sources
  end

  -- Mixed: FIXED honored, FREE get averaged remainder
  local sources = {}
  local fixedTime = 0
  for _, i in ipairs(fixedIndices) do
    local leg = segLegs[i]
    local gs  = self:_ConvertIasToTas(leg.speedKt, leg.altFt or 0) or leg.speedKt
    local t   = leg.distNm / gs * 3600
    fixedTime = fixedTime + t
    result[i] = gs
    sources[i] = "explicit"
  end

  local freeTime = totalTimeSec - fixedTime
  local freeDist = 0
  for _, i in ipairs(freeIndices) do freeDist = freeDist + segLegs[i].distNm end

  if freeTime <= 0 or freeDist <= 0 then
    table.insert(warnings, string.format(
      "%s: FIXED __S legs consume entire time budget — FREE legs clamped to min speed",
      segLabel
    ))
    local minGs = self:_ConvertIasToTas(self.Aircraft.envelope.minIasKt, 0) or self.Aircraft.envelope.minIasKt
    for _, i in ipairs(freeIndices) do result[i] = minGs; sources[i] = "computed" end
    return result, sources
  end

  local freeGs   = freeDist / (freeTime / 3600)
  local avgAltFree = 0
  for _, i in ipairs(freeIndices) do avgAltFree = avgAltFree + (segLegs[i].altFt or 0) end
  avgAltFree = avgAltFree / #freeIndices
  local freeIas = self:_ConvertTasToIas(freeGs, avgAltFree) or freeGs
  freeIas, _    = self:_ClampSpeed(freeIas, warnings, segLabel .. " FREE averaged")
  local clampedFreeGs = self:_ConvertIasToTas(freeIas, avgAltFree) or freeIas
  for _, i in ipairs(freeIndices) do result[i] = clampedFreeGs; sources[i] = "computed" end

  return result, sources
end

-- Computes full flight plan: ETA, speeds, IAS, profiles, fuel, warnings.
-- Returns { valid, error, waypoints, fuel, warnings }.
function MosieNavigator:_ComputePlan(plan, rolexSeconds)
  rolexSeconds = rolexSeconds or 0
  local warnings = {}
  local aircraft  = self.Aircraft

  -- ── Validation ──────────────────────────────────────────────────────────
  local wps = plan.waypoints
  if not wps or #wps == 0 then
    return { valid = false, error = "plan has no waypoints", warnings = warnings }
  end

  local takeoff = wps[1]
  if takeoff.type ~= "TAKE_OFF" then
    return { valid = false, error = "first waypoint must be TAKE_OFF", warnings = warnings }
  end

  if wps[#wps].type ~= "LANDING" then
    return { valid = false, error = "last waypoint must be LANDING", warnings = warnings }
  end

  if not takeoff.timeOnTargetSeconds then
    return { valid = false, error = "TAKE_OFF must have __T (brake release time)", warnings = warnings }
  end

  -- Determine default plan speed. TAKE_OFF __S overrides the Mosquito default
  -- cruise speed of 228 mph, expressed internally in knots.
  local defaultIasKt = takeoff.speedKt or aircraft.defaultCruiseSpeedKt
  local defaultGs = self:_ConvertIasToTas(defaultIasKt, takeoff.altitudeFt or 0) or defaultIasKt

  -- ── Altitude cascade ─────────────────────────────────────────────────────
  local resolvedAlt = {}
  local hasAnyAlt   = false
  local prevAlt     = nil
  for i, wp in ipairs(wps) do
    if wp.altitudeFt then
      resolvedAlt[i]  = wp.altitudeFt
      prevAlt         = wp.altitudeFt
      hasAnyAlt       = true
    else
      resolvedAlt[i]  = prevAlt  -- may still be nil for first WPs
    end
  end
  if not hasAnyAlt then
    table.insert(warnings, "no __A defined anywhere — all waypoints default to 0 ft MSL")
    for i = 1, #wps do resolvedAlt[i] = resolvedAlt[i] or 0 end
  else
    for i = 1, #wps do resolvedAlt[i] = resolvedAlt[i] or 0 end
  end

  -- ── Build leg descriptors ─────────────────────────────────────────────────
  -- legDesc[n] describes leg (n-1)->n (arriving at WPn); legDesc[1] = nil (TAKE_OFF)
  local legDescs = {}
  for i = 2, #wps do
    legDescs[i] = {
      distNm   = UTILS.MetersToNM(wps[i-1].coordinate:Get2DDistance(wps[i].coordinate)),
      altFt    = resolvedAlt[i],
      speedKt  = wps[i].speedKt,   -- explicit __S on WPn (nil = FREE)
      wpOrder  = wps[i].order,
      wpType   = wps[i].type,
      wpIndex  = i,
    }
  end

  -- ── Identify __T anchors ──────────────────────────────────────────────────
  -- anchor[i] = true when wps[i] has timeOnTargetSeconds
  local anchors = {}
  for i, wp in ipairs(wps) do
    if wp.timeOnTargetSeconds then
      anchors[i] = true
    end
  end

  -- ── Resolve GS per leg ───────────────────────────────────────────────────
  local legGs = {}  -- legGs[i] = GS kt for leg arriving at WPi
  local legSpeedSource = {}

  local function legSpeedFromDecl(k)
    local ld = legDescs[k]
    if ld and ld.speedKt then
      return self:_ConvertIasToTas(ld.speedKt, ld.altFt or 0) or ld.speedKt, "explicit"
    end
    return defaultGs, "default"
  end

  local function setLegSpeedFromDecl(k)
    legGs[k], legSpeedSource[k] = legSpeedFromDecl(k)
  end

  -- Collect sorted anchor indices
  local anchorList = {}
  for k = 1, #wps do
    if anchors[k] then table.insert(anchorList, k) end
  end

  -- For each consecutive anchor pair, resolve the segment
  for ai = 1, #anchorList do
    local segStart = anchorList[ai]
    local segEnd   = anchorList[ai + 1]

    if not segEnd then
      -- After last anchor: use __S / default
      for k = segStart + 1, #wps do
        setLegSpeedFromDecl(k)
      end
    else
      -- Check for HOLD anywhere in this segment, including boundaries.
      -- A HOLD absorbs slack, so nogi używają declared __S / plan default.
      local hasHold = false
      for k = segStart, segEnd do
        if wps[k].type == "HOLD" then hasHold = true; break end
      end

      if hasHold then
        for k = segStart + 1, segEnd do
          setLegSpeedFromDecl(k)
        end
      else
        local totI = wps[segStart].timeOnTargetSeconds
        local totJ = wps[segEnd].timeOnTargetSeconds
        local dt   = totJ - totI
        if dt < 0 then dt = dt + 86400 end

        local segLegs  = {}
        local segRange = {}
        for k = segStart + 1, segEnd do
          table.insert(segRange, k)
          table.insert(segLegs, {
            distNm  = legDescs[k].distNm,
            altFt   = legDescs[k].altFt,
            speedKt = legDescs[k].speedKt,
            wpOrder = legDescs[k].wpOrder,
          })
        end

        local segSpeeds, segSources = self:_ResolveSegmentSpeeds(
          segLegs, dt, warnings,
          string.format("segment [WP%02d..WP%02d]", wps[segStart].order, wps[segEnd].order)
        )

        for idx = 1, #segRange do
          legGs[segRange[idx]] = segSpeeds[idx]
          legSpeedSource[segRange[idx]] = segSources[idx]
        end
      end
    end
  end

  -- Legs before the first anchor (shouldn't normally happen, but guard)
  if #anchorList > 0 then
    for k = 2, anchorList[1] do
      if not legGs[k] and wps[k].type ~= "HOLD" then
        setLegSpeedFromDecl(k)
      end
    end
  end

  -- Fill any remaining unset legs
  for k = 2, #wps do
    if not legGs[k] then
      setLegSpeedFromDecl(k)
    end
  end

  -- ── HOLD anchor mapping ───────────────────────────────────────────────────
  -- For each HOLD, find nearest downstream __T anchor. Every HOLD is a candidate
  -- for absorbing slack — __T on a HOLD only pins its arrival ETA, it does not
  -- exempt the HOLD from the "last one absorbs" rule.
  local function findDownstreamAnchor(startIdx)
    for k = startIdx + 1, #wps do
      if anchors[k] then return k end
    end
    return nil
  end

  local lastHoldBeforeAnchor = {}  -- [anchorIdx] = holdIdx
  for k = 2, #wps do
    if wps[k].type == "HOLD" then
      local a = findDownstreamAnchor(k)
      if a then
        lastHoldBeforeAnchor[a] = k  -- iteration in plan order → last write wins
      end
    end
  end

  -- ── Sequential ETA + HOLD duration pass ──────────────────────────────────
  -- Single forward walk. For each WP, compute arrival taking upstream HOLD
  -- durations into account, then (if HOLD) compute this HOLD's duration
  -- against its true arrival — not a stale first-pass value.
  local etaSec = {}
  local holdDurations = {}

  etaSec[1] = (takeoff.timeOnTargetSeconds + rolexSeconds) % 86400

  for k = 2, #wps do
    local gs      = legGs[k] or defaultGs
    local legTime = gs > 0 and ((legDescs[k] and legDescs[k].distNm or 0) / gs * 3600) or 0

    -- Propagated arrival = previous departure + leg time.
    local prevDep = etaSec[k-1]
    if wps[k-1].type == "HOLD" then
      prevDep = prevDep + (holdDurations[k-1] or 0)
    end
    local propagatedArrival = prevDep + legTime

    if wps[k].type == "HOLD" then
      local holdTot    = wps[k].timeOnTargetSeconds
      local downstream = findDownstreamAnchor(k)

      local arrivalSec
      if holdTot then
        arrivalSec = (holdTot + rolexSeconds) % 86400  -- __T pins arrival
      else
        arrivalSec = propagatedArrival
      end
      etaSec[k] = arrivalSec

      if not downstream then
        holdDurations[k] = 0
        table.insert(warnings, string.format(
          "WP%02d HOLD (%s): no downstream __T — duration 0",
          wps[k].order, wps[k].name
        ))
      elseif lastHoldBeforeAnchor[downstream] ~= k then
        holdDurations[k] = 0
        table.insert(warnings, string.format(
          "WP%02d HOLD (%s): not last HOLD before WP%02d — duration 0",
          wps[k].order, wps[k].name, wps[downstream].order
        ))
      else
        local downTot = (wps[downstream].timeOnTargetSeconds + rolexSeconds) % 86400
        local flightSec = 0
        for j = k + 1, downstream do
          local jgs = legGs[j] or defaultGs
          flightSec = flightSec + (legDescs[j] and legDescs[j].distNm or 0) / jgs * 3600
        end
        local dt = downTot - arrivalSec
        if dt < 0 then dt = dt + 86400 end
        local dur = dt - flightSec
        if dur < 0 then
          table.insert(warnings, string.format(
            "WP%02d HOLD (%s): negative slack (%.0f s) — duration 0",
            wps[k].order, wps[k].name, dur
          ))
          dur = 0
        end
        holdDurations[k] = dur
      end
    else
      etaSec[k] = propagatedArrival
    end
  end

  -- ── Build per-leg output ──────────────────────────────────────────────────
  local outWps = {}
  local fuelCum = aircraft.fuel.taxiAllowance  -- start with taxi allowance

  local function legTrueCourse(wpFrom, wpTo)
    if not wpFrom or not wpTo then return nil end
    return wpFrom.coordinate:HeadingTo(wpTo.coordinate)
  end

  for k = 1, #wps do
    local wp = wps[k]
    local ow = {
      order              = wp.order,
      type               = wp.type,
      name               = wp.name,
      nameExplicit       = wp.nameExplicit,
      coordinate         = wp.coordinate,
      zone               = wp.zone,
      resolvedAltFt      = resolvedAlt[k],
      altInherited       = (wp.altitudeFt == nil) and (resolvedAlt[k] ~= nil),
      etaSec             = etaSec[k] % 86400,
      rawSpeedKt         = wp.speedKt,
      legSpeedInherited = legSpeedSource[k] == "default",
      rawTimeOnTarget    = wp.timeOnTarget,
      rawTimeOnTargetSec = wp.timeOnTargetSeconds,
    }

    if k == 1 then
      -- TAKE_OFF: no incoming leg
      ow.legDistNm       = nil
      ow.legGsKt         = nil
      ow.legIasKt        = nil
      ow.legTasKt        = nil
      ow.legTimeSec      = nil
      ow.legProfile      = nil
      ow.legFuelImpGal   = aircraft.fuel.taxiAllowance
      ow.trueCourse      = nil
      ow.headingTrue     = nil
      ow.windCorrectionDeg = nil
      ow.tasCorrectionKt = nil
      ow.magneticVar     = nil
      ow.holdDurationSec = nil
    elseif wp.type == "HOLD" then
      local ld      = legDescs[k]
      local inGs    = legGs[k] or defaultGs
      local legDist = ld and ld.distNm or 0
      local legTime = inGs > 0 and (legDist / inGs) or 0
      local legTimeSec = legTime * 3600
      local trueCourse = legTrueCourse(wps[k-1], wp)
      local headingTrue, windTas, windIas = self:_CalculateWindCorrectedGuidance(
        wps[k-1].coordinate, wp, legTimeSec, resolvedAlt[k]
      )
      local inTas = windTas or inGs
      local inIas = windIas or (self:_ConvertTasToIas(inTas, resolvedAlt[k]) or inTas)

      local prof    = self:_EstimateFuelProfile(inIas, resolvedAlt[k])
      local legBurn = prof.burnImpGph * legTime

      local holdDur  = holdDurations[k] or 0
      local holdBurn = aircraft.holdBurnImpGph * (holdDur / 3600)

      fuelCum = fuelCum + legBurn

      ow.legDistNm       = legDist
      ow.legGsKt         = inGs
      ow.legTimeSec      = legTimeSec
      ow.legIasKt        = inIas
      ow.legTasKt        = inTas
      ow.legProfile      = prof and prof.name or nil
      ow.legFuelImpGal   = legBurn
      ow.holdDurationSec = holdDur
      ow.holdFuelImpGal  = holdBurn
      ow.trueCourse      = trueCourse
      ow.headingTrue     = headingTrue
      ow.windCorrectionDeg = self:_GetHeadingDelta(ow.trueCourse, ow.headingTrue)
      ow.tasCorrectionKt = ow.legTasKt and ow.legGsKt and (ow.legTasKt - ow.legGsKt) or nil
      ow.magneticVar     = self:_GetAverageLegMagneticVariation(wps[k-1].coordinate, wp.coordinate, legDist)

      fuelCum = fuelCum + holdBurn
    else
      local ld      = legDescs[k]
      local gs      = legGs[k] or defaultGs
      local legDist = ld and ld.distNm or 0
      local legTime = gs > 0 and (legDist / gs) or 0
      local legTimeSec = legTime * 3600
      local trueCourse = legTrueCourse(wps[k-1], wp)
      local headingTrue, windTas, windIas = self:_CalculateWindCorrectedGuidance(
        wps[k-1].coordinate, wp, legTimeSec, resolvedAlt[k]
      )
      local tas = windTas or gs
      local ias = windIas or (self:_ConvertTasToIas(tas, resolvedAlt[k]) or tas)

      local prof    = self:_EstimateFuelProfile(ias, resolvedAlt[k])
      local legBurn = prof.burnImpGph * legTime

      fuelCum = fuelCum + legBurn

      ow.legDistNm     = legDist
      ow.legGsKt       = gs
      ow.legTimeSec    = legTimeSec
      ow.legIasKt      = ias
      ow.legTasKt      = tas
      ow.legProfile    = prof and prof.name or nil
      ow.legFuelImpGal = legBurn
      ow.trueCourse    = trueCourse
      ow.headingTrue   = headingTrue
      ow.windCorrectionDeg = self:_GetHeadingDelta(ow.trueCourse, ow.headingTrue)
      ow.tasCorrectionKt = ow.legTasKt and ow.legGsKt and (ow.legTasKt - ow.legGsKt) or nil
      ow.magneticVar   = self:_GetAverageLegMagneticVariation(wps[k-1].coordinate, wp.coordinate, legDist)
    end

    ow.fuelCumImpGal = fuelCum
    table.insert(outWps, ow)
  end

  -- Reserve: 30 min at lowest documented engine-setting burn in the fuel curve.
  local fuelCurve = self:_GetFuelCurveSettings()
  local lowestBurn = fuelCurve[1] and fuelCurve[1].fuelImpGph or 0
  for _, p in ipairs(fuelCurve) do
    if p.fuelImpGph < lowestBurn then lowestBurn = p.fuelImpGph end
  end
  local reserveFuel = aircraft.fuel.reserveMinutes / 60 * lowestBurn
  local routeFuel   = fuelCum - aircraft.fuel.taxiAllowance
  local totalFuel   = fuelCum + reserveFuel + aircraft.fuel.landingAllowance
  local dcsFuel     = self:_BuildDcsFuelRecommendation(totalFuel)
  local margin      = dcsFuel.capacityGal - totalFuel

  if dcsFuel.exceedsCapacity then
    table.insert(warnings, string.format(
      "FUEL: required %.1f IMP GAL exceeds DCS max fuel %.1f IMP GAL (%.1f over)",
      totalFuel, dcsFuel.capacityGal, -margin
    ))
  end

  return {
    valid    = true,
    error    = nil,
    waypoints = outWps,
    fuel = {
      taxiImpGal      = aircraft.fuel.taxiAllowance,
      routeImpGal     = routeFuel,
      reserveImpGal   = reserveFuel,
      landingImpGal   = aircraft.fuel.landingAllowance,
      totalImpGal     = totalFuel,
      tankImpGal      = dcsFuel.capacityGal,
      marginImpGal    = margin,
      marginPercent   = dcsFuel.marginPercent,
      dcs             = dcsFuel,
    },
    warnings = warnings,
  }
end

-- ==== 06_csv.lua ====

function MosieNavigator:_FormatDecimalMinutes(value, positiveHemisphere, negativeHemisphere, degreeWidth)
  local hemisphere = positiveHemisphere
  if value < 0 then
    hemisphere = negativeHemisphere
    value = -value
  end

  local degrees = math.floor(value)
  local minutes = (value - degrees) * 60

  if minutes >= 59.995 then
    degrees = degrees + 1
    minutes = 0
  end

  return string.format("%s%0" .. degreeWidth .. "d %05.2f", hemisphere, degrees, minutes)
end

function MosieNavigator:_FormatCoordinate(coordinate)
  local lat, lon = coordinate:GetLLDDM()
  return self:_FormatDecimalMinutes(lat, "N", "S", 2), self:_FormatDecimalMinutes(lon, "E", "W", 3)
end

function MosieNavigator:_FormatCoordinateForCsvDD(coordinate)
  local lat, lon = coordinate:GetLLDDM()
  return string.format("%.6f", lat), string.format("%.6f", lon)
end

function MosieNavigator:_FormatCsvField(value)
  if value == nil then
    return ""
  end

  local text = tostring(value)
  if string.find(text, "[,\"\n\r]") then
    return "\"" .. string.gsub(text, "\"", "\"\"") .. "\""
  end

  return text
end

function MosieNavigator:_FormatCsvRow(fields)
  local escaped = {}
  for index, value in ipairs(fields) do
    escaped[index] = self:_FormatCsvField(value)
  end
  return table.concat(escaped, ",")
end

function MosieNavigator:_FormatTotForCsv(waypoint)
  local seconds = waypoint and waypoint.timeOnTargetSeconds
  if not seconds then
    return ""
  end

  return self:_FormatDisplayEta(seconds)
end

function MosieNavigator:_BuildFlightPlanCsv(plan, groupName, rolexSeconds)
  local lines = {}

  table.insert(lines, "# PLAN," .. self:_FormatCsvField(plan.name))
  table.insert(lines, "ORDER,TYPE,NAME,LAT,LON,ALT_FT,TOT,SPEED_KT")

  for _, waypoint in ipairs(plan.waypoints or {}) do
    local lat, lon = self:_FormatCoordinateForCsvDD(waypoint.coordinate)
    local nameField  = waypoint.nameExplicit and waypoint.name or ""
    local altField   = waypoint.altitudeFt ~= nil and tostring(waypoint.altitudeFt) or ""
    local totField   = self:_FormatTotForCsv(waypoint)
    local speedField = waypoint.speedKt ~= nil and string.format("%.0f", waypoint.speedKt) or ""

    table.insert(lines, self:_FormatCsvRow({
      waypoint.order,
      waypoint.type,
      nameField,
      lat,
      lon,
      altField,
      totField,
      speedField,
    }))
  end

  return table.concat(lines, "\n") .. "\n"
end

function MosieNavigator:_BuildBeaconsCsv(beacons)
  local lines = {}

  table.insert(lines, "ID,FREQUENCY,POWER_NM,ALT_FT,LAT,LON")

  for _, beacon in ipairs(beacons) do
    local lat, lon = self:_FormatCoordinateForCsvDD(beacon.coordinate)
    local frequencyField = beacon.frequency or ""

    table.insert(lines, self:_FormatCsvRow({
      beacon.id,
      frequencyField,
      beacon.powerNm,
      beacon.altitudeFt,
      lat,
      lon,
    }))
  end

  return table.concat(lines, "\n") .. "\n"
end

-- ==== 07_discover.lua ====

function MosieNavigator:_ExtractPlanFromGroupName(groupName)
  return string.match(groupName, self.Config.groupPlanTagPattern)
end

function MosieNavigator:_ExtractRolexFromGroupName(groupName)
  local rolexText = string.match(groupName, "__[Rr]([%d:]+)")
  if not rolexText then
    return 0
  end

  local rolexSeconds = self:_ParseRolexDuration(rolexText)
  if not rolexSeconds then
    self:_Log("Ignoring invalid group ROLEX token: __R" .. rolexText)
    return 0
  end

  return rolexSeconds
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
        if group:IsAlive() then
          table.insert(assignments, {
            groupName = groupName,
            group = group,
            planName = planName,
            plan = plans[planName],
            rolexSeconds = rolexSeconds,
          })
        else
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

-- ==== 08_draw.lua ====

function MosieNavigator:_DrawWaypoint(plan, waypoint, color)
  local label = string.format("MN %s %02d %s\n%s", waypoint.plan, waypoint.order, waypoint.type, waypoint.name)
  local radius = self.Config.defaultWaypointRadiusM

  if waypoint.zone.GetRadius then
    radius = waypoint.zone:GetRadius()
  end

  self:_AddMarker(waypoint.coordinate:CircleToAll(
    radius,
    self.Config.coalition,
    self:_CopyColor(color),
    self.Config.waypointLineAlpha,
    self:_CopyColor(color),
    self.Config.waypointFillAlpha,
    1,
    self.Config.readOnly,
    label
  ))

  self:_AddMarker(waypoint.coordinate:TextToAll(
    string.format("%s %02d %s", waypoint.plan, waypoint.order, waypoint.name),
    self.Config.coalition,
    self:_CopyColor(color),
    1,
    {0, 0, 0},
    0.0,
    12,
    self.Config.readOnly
  ))
end

function MosieNavigator:_DrawPlan(plan, color)
  for index, waypoint in ipairs(plan.waypoints) do
    self:_DrawWaypoint(plan, waypoint, color)

    local nextWaypoint = plan.waypoints[index + 1]
    if nextWaypoint then
      self:_AddMarker(waypoint.coordinate:LineToAll(
        nextWaypoint.coordinate,
        self.Config.coalition,
        self:_CopyColor(color),
        self.Config.waypointLineAlpha,
        1,
        self.Config.readOnly,
        string.format("MN %s %02d-%02d", plan.name, waypoint.order, nextWaypoint.order)
      ))
    end
  end
end

function MosieNavigator:_DrawBeacon(beacon)
  local radius = UTILS.NMToMeters(beacon.powerNm)
  local label = string.format("MNB %s", beacon.id)

  if beacon.frequency then
    label = label .. string.format("\n%s", beacon.frequency)
  end

  label = label .. string.format("\nRange %d NM", beacon.powerNm)

  if beacon.altitudeFt then
    label = label .. string.format("\nAlt %d ft", beacon.altitudeFt)
  end

  self:_AddMarker(beacon.coordinate:CircleToAll(
    radius,
    self.Config.coalition,
    self:_CopyColor(self.BeaconColor),
    self.Config.beaconLineAlpha,
    self:_CopyColor(self.BeaconColor),
    self.Config.beaconFillAlpha,
    2,
    self.Config.readOnly,
    label
  ))

  self:_AddMarker(beacon.coordinate:TextToAll(
    label,
    self.Config.coalition,
    self:_CopyColor(self.BeaconColor),
    1,
    {0, 0, 0},
    0.0,
    13,
    self.Config.readOnly
  ))
end

-- ==== 09_guidance.lua ====

function MosieNavigator:_GetLegSampleCoordinates(fromCoordinate, toCoordinate, distanceNm)
  local sampleCount = math.max(2, math.floor((distanceNm or 0) / 10) + 1)
  local samples = {}

  for i = 0, sampleCount - 1 do
    local fraction = sampleCount == 1 and 0 or (i / (sampleCount - 1))
    if i == 0 then
      table.insert(samples, fromCoordinate)
    elseif i == sampleCount - 1 then
      table.insert(samples, toCoordinate)
    elseif fromCoordinate and fromCoordinate.GetIntermediateCoordinate then
      table.insert(samples, fromCoordinate:GetIntermediateCoordinate(toCoordinate, fraction))
    end
  end

  return samples
end

function MosieNavigator:_GetAverageLegWindVec3(fromCoordinate, toCoordinate, altitudeFt, distanceNm)
  local samples = self:_GetLegSampleCoordinates(fromCoordinate, toCoordinate, distanceNm)
  local heightMeters = UTILS.FeetToMeters(altitudeFt or 0)
  local sumX, sumZ, count = 0, 0, 0

  for _, coordinate in ipairs(samples) do
    if coordinate and coordinate.GetWindVec3 then
      local wind = coordinate:GetWindVec3(heightMeters) or {x = 0, z = 0}
      sumX = sumX + (wind.x or 0)
      sumZ = sumZ + (wind.z or 0)
      count = count + 1
    end
  end

  if count == 0 then
    return {x = 0, z = 0}
  end

  return {x = sumX / count, z = sumZ / count}
end

function MosieNavigator:_GetAverageLegMagneticVariation(fromCoordinate, toCoordinate, distanceNm)
  local samples = self:_GetLegSampleCoordinates(fromCoordinate, toCoordinate, distanceNm)
  local sum, count = 0, 0

  for _, coordinate in ipairs(samples) do
    if coordinate then
      sum = sum + self:_GetMagneticVariation(coordinate)
      count = count + 1
    end
  end

  if count == 0 then
    return nil
  end

  return sum / count
end

function MosieNavigator:_CalculateWindCorrectedGuidance(groupCoordinate, waypoint, secondsToTot, altitudeFt)
  local distanceNm = UTILS.MetersToNM(groupCoordinate:Get2DDistance(waypoint.coordinate))
  local trackTrue = groupCoordinate:HeadingTo(waypoint.coordinate)

  if not secondsToTot or secondsToTot <= 0 then
    return trackTrue, nil, nil
  end

  local requiredGroundSpeedKt = distanceNm / (secondsToTot / 3600)
  local requiredGroundSpeedMps = UTILS.KnotsToMps(requiredGroundSpeedKt)
  local trackRadians = math.rad(trackTrue)
  local groundVectorX = math.sin(trackRadians) * requiredGroundSpeedMps
  local groundVectorZ = math.cos(trackRadians) * requiredGroundSpeedMps
  local windVector = self:_GetAverageLegWindVec3(groupCoordinate, waypoint.coordinate, altitudeFt, distanceNm)
  local airVectorX = groundVectorX - (windVector.x or 0)
  local airVectorZ = groundVectorZ - (windVector.z or 0)
  local requiredTas = UTILS.MpsToKnots(math.sqrt(airVectorX * airVectorX + airVectorZ * airVectorZ))
  local headingTrue = self:_NormalizeHeading(math.deg(self:_Atan2(airVectorX, airVectorZ)))
  local requiredIas = self:_ConvertTasToIas(requiredTas, altitudeFt)

  return headingTrue, requiredTas, requiredIas
end

function MosieNavigator:_CalculateXte(previousWaypoint, waypoint, groupCoordinate)
  if not previousWaypoint or not waypoint then
    return nil, nil
  end

  local startVec = previousWaypoint.coordinate:GetVec3()
  local endVec = waypoint.coordinate:GetVec3()
  local currentVec = groupCoordinate:GetVec3()
  local legX = endVec.x - startVec.x
  local legZ = endVec.z - startVec.z
  local legLength = math.sqrt(legX * legX + legZ * legZ)

  if legLength <= 0 then
    return nil, nil
  end

  local currentX = currentVec.x - startVec.x
  local currentZ = currentVec.z - startVec.z
  local cross = legX * currentZ - legZ * currentX
  local xteNm = UTILS.MetersToNM(math.abs(cross / legLength))
  local side = cross > 0 and "port" or "stbd"

  return xteNm, side
end

-- ==== 10_navigator.lua ====

function MosieNavigator:_SendNavigatorMessage(group, text, duration)
  MESSAGE:New(text, duration or self.Config.navigatorMessageDuration, "Mosie Navigator"):ToGroup(group)
end

function MosieNavigator:_GetGroupKey(group)
  return group:GetName()
end

function MosieNavigator:_GetInitialNavigatorWpIndex(plan)
  for index, waypoint in ipairs(plan.waypoints) do
    if waypoint.type ~= "TAKE_OFF" then
      return index
    end
  end

  return 1
end

function MosieNavigator:_GetInitialNavigatorWpIndexByTot(plan, rolexSeconds)
  for index, waypoint in ipairs(plan.waypoints) do
    local secondsToTot = self:_GetSecondsToWaypointTot(waypoint, rolexSeconds or 0)
    if secondsToTot and secondsToTot > 0 and waypoint.type ~= "TAKE_OFF" then
      return index
    end
  end

  return self:_GetInitialNavigatorWpIndex(plan)
end

function MosieNavigator:_GetNavigatorState(group, plan, rolexSeconds)
  self.NavigatorStates = self.NavigatorStates or {}

  local groupKey = self:_GetGroupKey(group)
  local state = self.NavigatorStates[groupKey]

  if not state then
    state = {
      enabled = false,
      group = group,
      groupName = groupKey,
      plan = plan,
      rolexSeconds = rolexSeconds or 0,
      currentWpIndex = self:_GetInitialNavigatorWpIndex(plan),
      reportInterval = self.Config.navigatorReportIntervalDefault,
      lastReportTime = nil,
      callouts = {},
    }
    self.NavigatorStates[groupKey] = state
  end

  state.group = group
  state.plan = plan
  state.rolexSeconds = rolexSeconds or 0
  return state
end

function MosieNavigator:_GetAdjustedTotSeconds(waypoint, rolexSeconds)
  if not waypoint.timeOnTargetSeconds then
    return nil
  end

  return (waypoint.timeOnTargetSeconds + (rolexSeconds or 0)) % SECONDS_PER_DAY
end

function MosieNavigator:_GetSecondsToWaypointTot(waypoint, rolexSeconds)
  local adjustedTot = self:_GetAdjustedTotSeconds(waypoint, rolexSeconds)
  if not adjustedTot then
    return nil
  end

  local now = timer.getAbsTime() % SECONDS_PER_DAY
  local delta = adjustedTot - now

  if delta < -SECONDS_PER_HALF_DAY then
    delta = delta + SECONDS_PER_DAY
  elseif delta > SECONDS_PER_HALF_DAY then
    delta = delta - SECONDS_PER_DAY
  end

  return delta
end

function MosieNavigator:_FormatDuration(seconds)
  if not seconds then
    return "--"
  end

  local prefix = ""
  if seconds < 0 then
    prefix = "-"
    seconds = -seconds
  end

  local minutes = math.floor(seconds / 60)
  local remainingSeconds = seconds % 60
  return string.format("%s%d:%02d", prefix, minutes, remainingSeconds)
end

function MosieNavigator:_BuildNavigatorStatusMessage(state, reason)
  local group = state.group
  local plan = state.plan
  local waypoint = plan.waypoints[state.currentWpIndex]

  if not waypoint then
    return "NAV: no active waypoint"
  end

  local groupCoordinate = group:GetCoordinate()
  local distanceNm = UTILS.MetersToNM(groupCoordinate:Get2DDistance(waypoint.coordinate))
  local trueCourse = groupCoordinate:HeadingTo(waypoint.coordinate)
  local secondsToTot = self:_GetSecondsToWaypointTot(waypoint, state.rolexSeconds)
  local altitudeFt = UTILS.MetersToFeet(group:GetAltitude(false) or 0)
  local headingTrue, requiredTas, requiredIas = self:_CalculateWindCorrectedGuidance(groupCoordinate, waypoint, secondsToTot, altitudeFt)
  local headingMagnetic = self:_FormatMagneticHeading(headingTrue, groupCoordinate)
  local currentIas = self:_ConvertTasToIas(group:GetVelocityKNOTS(), altitudeFt)
  local speedText = "spd ---"
  local previousWaypoint = state.plan.waypoints[state.currentWpIndex - 1]
  local xteNm, xteSide = self:_CalculateXte(previousWaypoint, waypoint, groupCoordinate)
  local xteText = "XTE ---"

  if requiredIas and currentIas then
    local delta = currentIas - requiredIas
    if math.abs(delta) <= 5 then
      speedText = "on speed"
    elseif delta > 0 then
      speedText = string.format("fast %.0f", delta)
    else
      speedText = string.format("slow %.0f", -delta)
    end
  end

  if xteNm and xteNm >= self.Config.navigatorXteStepNm then
    xteText = string.format("XTE %.0f %s", math.floor(xteNm + 0.5), xteSide)
  end

  local prefix = reason and ("NAV " .. reason .. ": ") or "NAV: "
  return string.format(
    "%sWP%02d %s, T-%s, TRK %sT, HDG %sM, TAS %s kt, IAS %s kt, %s, %s, DIST %.1f NM",
    prefix,
    waypoint.order,
    waypoint.name,
    self:_FormatDuration(secondsToTot),
    self:_FormatHeading(trueCourse),
    headingMagnetic,
    self:_FormatSpeed(requiredTas),
    self:_FormatSpeed(requiredIas),
    speedText,
    xteText,
    distanceNm
  )
end

function MosieNavigator:_ResetNavigatorCallouts(state)
  state.callouts = {}
  for _, calloutSeconds in ipairs(self.Config.navigatorCalloutSeconds) do
    state.callouts[calloutSeconds] = false
  end
end

function MosieNavigator:_SetNavigatorWaypoint(state, index, reason)
  if index < 1 or index > #state.plan.waypoints then
    return
  end

  state.currentWpIndex = index
  state.lastReportTime = timer.getTime()
  self:_ResetNavigatorCallouts(state)
  self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, reason or "WP change"))
end

function MosieNavigator:_AdvanceNavigatorWaypoint(state, reason)
  if state.currentWpIndex < #state.plan.waypoints then
    self:_SetNavigatorWaypoint(state, state.currentWpIndex + 1, reason or "next WP")
  end
end

function MosieNavigator:_SetNavigatorEnabled(group, plan, rolexSeconds, enabled)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds)
  state.enabled = enabled

  if enabled then
    state.currentWpIndex = self:_GetInitialNavigatorWpIndexByTot(plan, rolexSeconds)
    self:_ResetNavigatorCallouts(state)
    self:_SendNavigatorMessage(group, self:_BuildNavigatorStatusMessage(state, "on"))
  else
    self:_SendNavigatorMessage(group, "NAV off")
  end
end

function MosieNavigator:_SetNavigatorReportInterval(group, plan, rolexSeconds, interval)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds)
  state.reportInterval = interval
  self:_SendNavigatorMessage(group, string.format("NAV report interval %d sec", interval))
end

function MosieNavigator:_NavigatorStatusNow(group, plan, rolexSeconds)
  local state = self:_GetNavigatorState(group, plan, rolexSeconds)
  self:_SendNavigatorMessage(group, self:_BuildNavigatorStatusMessage(state, "status"))
end

function MosieNavigator:_TickNavigatorState(state)
  if not state.enabled or not state.group:IsAlive() then
    return
  end

  local waypoint = state.plan.waypoints[state.currentWpIndex]
  if not waypoint then
    return
  end

  local secondsToTot = self:_GetSecondsToWaypointTot(waypoint, state.rolexSeconds)
  local now = timer.getTime()

  if secondsToTot then
    for _, calloutSeconds in ipairs(self.Config.navigatorCalloutSeconds) do
      if secondsToTot <= calloutSeconds and secondsToTot > 0 and not state.callouts[calloutSeconds] then
        state.callouts[calloutSeconds] = true
        self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, string.format("%d sec", calloutSeconds)))
      end
    end

    if secondsToTot <= 0 and state.currentWpIndex < #state.plan.waypoints then
      self:_AdvanceNavigatorWaypoint(state, "new WP")
      return
    end
  end

  if not state.lastReportTime or now - state.lastReportTime >= state.reportInterval then
    state.lastReportTime = now
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, "report"))
  end
end

function MosieNavigator:_StartNavigatorScheduler()
  if self.NavigatorScheduler then
    return
  end

  self.NavigatorScheduler = SCHEDULER:New(nil, function()
    MosieNavigator:TickNavigators()
  end, {}, self.Config.navigatorTickInterval, self.Config.navigatorTickInterval)

  self:_Log(string.format("navigator tick scheduled every %d seconds", self.Config.navigatorTickInterval))
end

function MosieNavigator:TickNavigators()
  if not self.NavigatorStates then
    return
  end

  for _, state in pairs(self.NavigatorStates) do
    self:_TickNavigatorState(state)
  end
end

-- ==== 11_messages.lua ====

function MosieNavigator:_AppendFuelSummary(lines, fuel)
  table.insert(lines, "FUEL:")
  table.insert(lines, string.format("  TAXI:    %6.1f IMP GAL", fuel.taxiImpGal))
  table.insert(lines, string.format("  ROUTE:   %6.1f IMP GAL", fuel.routeImpGal))
  table.insert(lines, string.format("  RESERVE: %6.1f IMP GAL  (%d min)",
    fuel.reserveImpGal, self.Aircraft.fuel.reserveMinutes))
  table.insert(lines, string.format("  LANDING: %6.1f IMP GAL", fuel.landingImpGal))
  table.insert(lines, string.format("  TOTAL:   %6.1f IMP GAL", fuel.totalImpGal))

  local dcs = fuel.dcs
  if dcs then
    table.insert(lines, "")
    table.insert(lines, "DCS FUEL:")
    table.insert(lines, string.format("  REQUIRED: %6.1f GAL / %5.0f LBS", dcs.requiredGal, dcs.requiredLb))
    table.insert(lines, string.format("  INTERNAL: %3d%%  (%4.0f LBS max)", dcs.internalPercent, dcs.internalFuelLb))
    table.insert(lines, string.format("  DROP:     %s", dcs.dropTankLabel))
  end
end

function MosieNavigator:_FormatVariation(value)
  if value == nil then
    return "---"
  end

  return string.format("%+.1f", value)
end

function MosieNavigator:_FormatDisplayLegTime(seconds)
  if not seconds then
    return "---"
  end

  return string.format("%d", math.floor(seconds / 60 + 0.5))
end

function MosieNavigator:_AppendFlightPlanRows(lines, waypoints, compact)
  if compact then
    table.insert(lines, "ID TY ALT   IASMPH TASKN COG WHDG WTAS HDG(T) VAR  HDG(M) SOG DIST TIME ETA")
    table.insert(lines, "-------------------------------------------------------------------------")
  else
    table.insert(lines, string.format(
      "%-2s %-10s %6s %8s %7s %3s %4s %4s %6s %6s %6s %5s %6s %4s %5s",
      "ID", "TYPE", "ALT", "IAS(MPH)", "TAS(KN)", "COG", "WHDG", "WTAS", "HDG(T)", "VAR", "HDG(M)", "SOG", "DIST", "TIME", "ETA"
    ))
    table.insert(lines, string.rep("-", 103))
  end

  for _, ow in ipairs(waypoints) do
    local altStr = ow.resolvedAltFt ~= nil
      and (tostring(ow.resolvedAltFt) .. (ow.altInherited and "*" or "")) or "---"
    local speedMark = ow.legSpeedInherited and "*" or ""
    local iasMph = ow.legIasKt and (string.format("%.0f", self:_KnotsToMph(ow.legIasKt)) .. speedMark) or "---"
    local tasStr = ow.legTasKt and string.format("%.0f", ow.legTasKt) or "---"
    local cogStr = self:_FormatHeading(ow.trueCourse)
    local whdgStr = self:_FormatSignedDegrees(ow.windCorrectionDeg)
    local wtasStr = self:_FormatSignedDegrees(ow.tasCorrectionKt)
    local hdgTrueStr = self:_FormatHeading(ow.headingTrue)
    local varStr = self:_FormatVariation(ow.magneticVar)
    local hdgMagStr = self:_FormatMagneticHeadingWithVariation(ow.headingTrue, ow.magneticVar)
    local sogStr = ow.legGsKt and string.format("%.0f", ow.legGsKt) or "---"
    local distStr = ow.legDistNm and string.format("%.1f", ow.legDistNm) or "---"
    local timeStr = self:_FormatDisplayLegTime(ow.legTimeSec)
    local etaStr = self:_FormatDisplayEta(ow.etaSec)

    if compact then
      table.insert(lines, string.format(
        "%02d %-2s %-5s %6s %5s %3s %4s %4s %6s %5s %6s %3s %4s %4s %5s",
        ow.order,
        self:_FormatWaypointTypeShort(ow.type),
        altStr,
        iasMph,
        tasStr,
        cogStr,
        whdgStr,
        wtasStr,
        hdgTrueStr,
        varStr,
        hdgMagStr,
        sogStr,
        distStr,
        timeStr,
        etaStr
      ))
    else
      table.insert(lines, string.format(
        "%02d %-10s %6s %8s %7s %3s %4s %4s %6s %6s %6s %5s %6s %4s %5s",
        ow.order,
        self:_FitText(ow.type, 10),
        altStr,
        iasMph,
        tasStr,
        cogStr,
        whdgStr,
        wtasStr,
        hdgTrueStr,
        varStr,
        hdgMagStr,
        sogStr,
        distStr,
        timeStr,
        etaStr
      ))
    end

    if ow.holdDurationSec and ow.holdDurationSec > 0 then
      local holdMin = math.floor(ow.holdDurationSec / 60 + 0.5)
      local exitSec = (ow.etaSec + ow.holdDurationSec) % 86400
      table.insert(lines, string.format(
        "   orbit %d min @ %d IAS: %.1f gal  (exit %s)",
        holdMin, self.Aircraft.holdIasKt,
        ow.holdFuelImpGal or 0, self:_FormatDisplayEta(exitSec)
      ))
    end
  end
end

function MosieNavigator:_GetComputedPlan(plan, rolexSeconds)
  rolexSeconds = rolexSeconds or 0
  self.ComputedPlanCache = self.ComputedPlanCache or {}
  local planCache = self.ComputedPlanCache[plan]
  if not planCache then
    planCache = {}
    self.ComputedPlanCache[plan] = planCache
  end

  if not planCache[rolexSeconds] then
    planCache[rolexSeconds] = self:_ComputePlan(plan, rolexSeconds)
  end

  return planCache[rolexSeconds]
end

function MosieNavigator:_CopyComputedPlanWithRolex(computed, pilotRolexSeconds)
  pilotRolexSeconds = pilotRolexSeconds or 0
  if pilotRolexSeconds == 0 or not computed or not computed.valid then
    return computed
  end

  local shifted = {}
  for key, value in pairs(computed) do
    shifted[key] = value
  end

  shifted.waypoints = {}
  for index, waypoint in ipairs(computed.waypoints or {}) do
    local waypointCopy = {}
    for key, value in pairs(waypoint) do
      waypointCopy[key] = value
    end
    if waypointCopy.etaSec then
      waypointCopy.etaSec = (waypointCopy.etaSec + pilotRolexSeconds) % SECONDS_PER_DAY
    end
    table.insert(shifted.waypoints, waypointCopy)
  end

  return shifted
end

function MosieNavigator:_GetActiveComputedPlan(plan, baseRolexSeconds, pilotRolexSeconds)
  local computed = self:_GetComputedPlan(plan, baseRolexSeconds or 0)
  return self:_CopyComputedPlanWithRolex(computed, pilotRolexSeconds or 0)
end

function MosieNavigator:_BuildSimplifiedFlightPlanMessage(plan, groupName, baseRolexSeconds, pilotRolexSeconds)
  baseRolexSeconds = baseRolexSeconds or 0
  pilotRolexSeconds = pilotRolexSeconds or 0
  local computed = self:_GetActiveComputedPlan(plan, baseRolexSeconds, pilotRolexSeconds)
  local lines = {}

  table.insert(lines, "MOSIE NAVIGATOR")
  table.insert(lines, "PLAN  : " .. plan.name)
  table.insert(lines, "GROUP : " .. (groupName or "---"))
  if pilotRolexSeconds ~= 0 then
    table.insert(lines, "ROLEX : " .. self:_FormatSignedRolex(pilotRolexSeconds))
  end
  table.insert(lines, "")

  if not computed.valid then
    table.insert(lines, "ERROR: " .. (computed.error or "unknown"))
    return table.concat(lines, "\n")
  end

  self:_AppendFlightPlanRows(lines, computed.waypoints, false)

  local f = computed.fuel
  table.insert(lines, "")
  self:_AppendFuelSummary(lines, f)

  if #computed.warnings > 0 then
    table.insert(lines, "WARNINGS:")
    for _, w in ipairs(computed.warnings) do
      table.insert(lines, "  " .. w)
    end
  end

  return table.concat(lines, "\n")
end

function MosieNavigator:_ShowFlightPlanForGroup(group, plan, baseRolexSeconds, pilotRolexSeconds)
  if not group or not plan then
    return
  end

  local text = self:_BuildSimplifiedFlightPlanMessage(plan, group:GetName(), baseRolexSeconds, pilotRolexSeconds)
  MESSAGE:New(text, self.Config.flightPlanMessageDuration, "Mosie Navigator"):ToGroup(group)
end

function MosieNavigator:_GetGroupPlanState(group, assignment)
  self.GroupPlanStates = self.GroupPlanStates or {}

  local groupName = group:GetName()
  local state = self.GroupPlanStates[groupName]
  if not state then
    state = { pilotRolexSeconds = 0 }
    self.GroupPlanStates[groupName] = state
  end

  state.group = group
  state.groupName = groupName
  state.plan = assignment.plan
  state.planName = assignment.planName
  state.baseRolexSeconds = assignment.rolexSeconds or 0

  return state
end

function MosieNavigator:_GetActiveRolexSeconds(groupPlanState)
  return (groupPlanState.baseRolexSeconds or 0) + (groupPlanState.pilotRolexSeconds or 0)
end

function MosieNavigator:_RefreshNavigatorRolex(groupPlanState, reason)
  if not self.NavigatorStates then
    return
  end

  local state = self.NavigatorStates[groupPlanState.groupName]
  if not state then
    return
  end

  state.group = groupPlanState.group
  state.plan = groupPlanState.plan
  state.rolexSeconds = self:_GetActiveRolexSeconds(groupPlanState)
  state.currentWpIndex = self:_GetInitialNavigatorWpIndexByTot(state.plan, state.rolexSeconds)
  self:_ResetNavigatorCallouts(state)

  if state.enabled then
    self:_SendNavigatorMessage(state.group, self:_BuildNavigatorStatusMessage(state, reason or "ROLEX"))
  end
end

function MosieNavigator:_SetPilotRolex(group, assignment, pilotRolexSeconds)
  local state = self:_GetGroupPlanState(group, assignment)
  state.pilotRolexSeconds = pilotRolexSeconds or 0
  self:_RefreshNavigatorRolex(state, "ROLEX")

  local text = "ROLEX reset"
  if state.pilotRolexSeconds ~= 0 then
    text = "ROLEX " .. self:_FormatSignedRolex(state.pilotRolexSeconds)
  end
  self:_SendNavigatorMessage(group, text)
end

function MosieNavigator:_AdjustPilotRolex(group, assignment, deltaSeconds)
  local state = self:_GetGroupPlanState(group, assignment)
  self:_SetPilotRolex(group, assignment, (state.pilotRolexSeconds or 0) + (deltaSeconds or 0))
end

function MosieNavigator:_CreateGroupMenus(plans)
  self.MenusCreated = self.MenusCreated or {}

  local assignments = self:_DiscoverGroupAssignments(plans)
  local createdCount = 0

  for _, assignment in ipairs(assignments) do
    local group = assignment.group
    local menuKey = assignment.groupName .. "::" .. assignment.planName
    self:_GetGroupPlanState(group, assignment)

    if not self.MenusCreated[menuKey] then
      local rootMenu = MENU_GROUP:New(group, self.Config.menuName)
      local navigatorMenu = MENU_GROUP:New(group, "NAVIGATOR", rootMenu)
      MENU_GROUP_COMMAND:New(group, "Automatic ON", navigatorMenu, function()
        local state = MosieNavigator:_GetGroupPlanState(group, assignment)
        MosieNavigator:_SetNavigatorEnabled(group, state.plan, MosieNavigator:_GetActiveRolexSeconds(state), true)
      end)
      MENU_GROUP_COMMAND:New(group, "Automatic OFF", navigatorMenu, function()
        local state = MosieNavigator:_GetGroupPlanState(group, assignment)
        MosieNavigator:_SetNavigatorEnabled(group, state.plan, MosieNavigator:_GetActiveRolexSeconds(state), false)
      end)
      MENU_GROUP_COMMAND:New(group, "Show FP", navigatorMenu, function()
        local state = MosieNavigator:_GetGroupPlanState(group, assignment)
        MosieNavigator:_ShowFlightPlanForGroup(group, state.plan, state.baseRolexSeconds, state.pilotRolexSeconds)
      end)
      MENU_GROUP_COMMAND:New(group, "Status Now", navigatorMenu, function()
        local state = MosieNavigator:_GetGroupPlanState(group, assignment)
        MosieNavigator:_NavigatorStatusNow(group, state.plan, MosieNavigator:_GetActiveRolexSeconds(state))
      end)
      MENU_GROUP_COMMAND:New(group, "Next WP", navigatorMenu, function()
        local planState = MosieNavigator:_GetGroupPlanState(group, assignment)
        local navState = MosieNavigator:_GetNavigatorState(group, planState.plan, MosieNavigator:_GetActiveRolexSeconds(planState))
        MosieNavigator:_AdvanceNavigatorWaypoint(navState, "manual WP")
      end)
      MENU_GROUP_COMMAND:New(group, "Prev WP", navigatorMenu, function()
        local planState = MosieNavigator:_GetGroupPlanState(group, assignment)
        local navState = MosieNavigator:_GetNavigatorState(group, planState.plan, MosieNavigator:_GetActiveRolexSeconds(planState))
        MosieNavigator:_SetNavigatorWaypoint(navState, navState.currentWpIndex - 1, "manual WP")
      end)

      local intervalMenu = MENU_GROUP:New(group, "Report Interval", navigatorMenu)
      for _, interval in ipairs(self.Config.navigatorReportIntervals) do
        MENU_GROUP_COMMAND:New(group, string.format("%d sec", interval), intervalMenu, function(reportInterval)
          local state = MosieNavigator:_GetGroupPlanState(group, assignment)
          MosieNavigator:_SetNavigatorReportInterval(group, state.plan, MosieNavigator:_GetActiveRolexSeconds(state), reportInterval)
        end, interval)
      end

      local rolexMenu = MENU_GROUP:New(group, "ROLEX", rootMenu)
      MENU_GROUP_COMMAND:New(group, "RESET", rolexMenu, function()
        MosieNavigator:_SetPilotRolex(group, assignment, 0)
      end)

      local advanceMenu = MENU_GROUP:New(group, "ADVANCE", rolexMenu)
      local retardMenu = MENU_GROUP:New(group, "RETARD", rolexMenu)
      for _, minutes in ipairs({1, 2, 3, 5, 10}) do
        MENU_GROUP_COMMAND:New(group, string.format("%d min", minutes), advanceMenu, function(value)
          MosieNavigator:_AdjustPilotRolex(group, assignment, -value * 60)
        end, minutes)
        MENU_GROUP_COMMAND:New(group, string.format("%d min", minutes), retardMenu, function(value)
          MosieNavigator:_AdjustPilotRolex(group, assignment, value * 60)
        end, minutes)
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

function MosieNavigator:_BuildFlightPlanTable(plan, groupName, baseRolexSeconds, pilotRolexSeconds)
  baseRolexSeconds = baseRolexSeconds or 0
  pilotRolexSeconds = pilotRolexSeconds or 0
  local computed = self:_GetActiveComputedPlan(plan, baseRolexSeconds, pilotRolexSeconds)
  local lines = {}

  table.insert(lines, "MOSIE NAVIGATOR FLIGHT PLAN")
  table.insert(lines, "PLAN  : " .. plan.name)
  if groupName then
    table.insert(lines, "GROUP : " .. groupName)
  end
  if pilotRolexSeconds ~= 0 then
    table.insert(lines, "ROLEX : " .. self:_FormatSignedRolex(pilotRolexSeconds))
  end
  table.insert(lines, "ACFT  : " .. self.Aircraft.name)
  table.insert(lines, "")

  if not computed.valid then
    table.insert(lines, "ERROR: " .. (computed.error or "unknown"))
    return table.concat(lines, "\n") .. "\n"
  end

  local totalDist = 0
  for _, ow in ipairs(computed.waypoints) do
    if ow.legDistNm then totalDist = totalDist + ow.legDistNm end
  end

  self:_AppendFlightPlanRows(lines, computed.waypoints, false)

  local f = computed.fuel
  table.insert(lines, "")
  table.insert(lines, string.format("TOTAL_DIST: %.1f NM", totalDist))
  table.insert(lines, "")
  self:_AppendFuelSummary(lines, f)

  if #computed.warnings > 0 then
    table.insert(lines, "")
    table.insert(lines, "WARNINGS:")
    for _, w in ipairs(computed.warnings) do
      table.insert(lines, "  - " .. w)
    end
  end

  return table.concat(lines, "\n") .. "\n"
end

-- ==== 12_io.lua ====

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

-- ==== 13_main.lua ====

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
  self:_Log("starting debug discovery")
  self:DrawDebug()
  self:_StartMenuRefreshScheduler()
  self:_StartNavigatorScheduler()
end

if MOSIE_NAVIGATOR_AUTO_START ~= false then
  MosieNavigator:Start()
end
