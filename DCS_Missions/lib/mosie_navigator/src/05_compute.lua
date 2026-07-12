-- Resolves GS (kt) for each leg in a segment between two __T anchors (no HOLD).
-- Returns table of gsKt per leg index (1-based within segment legs).
function MosieNavigator:_ClampGroundSpeed(gsKt, altitudeFt, warnings, context)
  if not gsKt then
    return nil
  end

  local iasKt = self:_ConvertTasToIas(gsKt, altitudeFt or 0) or gsKt
  local clampedIas, clamped = self:_ClampSpeed(iasKt, warnings, context)
  if clamped then
    return self:_ConvertIasToTas(clampedIas, altitudeFt or 0) or clampedIas, true
  end

  return gsKt, false
end

function MosieNavigator:_AddLowSpeedTimingAdvisory(timing, segLabel, segLegs, requiredIasKt)
  if not timing then
    return
  end

  local targetLeg = segLegs[#segLegs]
  if not targetLeg then
    return
  end

  local targetType = targetLeg.wpType or "WP"
  table.insert(timing, string.format(
    "%s: required %.0f IAS below minimum %.0f IAS; arrive early at min cruise; orbit/delay required before WP%02d %s",
    segLabel,
    requiredIasKt or 0,
    self.Aircraft.envelope.minIasKt,
    targetLeg.wpOrder,
    targetType
  ))
end

function MosieNavigator:_ClampDerivedSegmentSpeed(requiredIasKt, warnings, timing, segLabel, segLegs)
  local env = self.Aircraft.envelope
  if requiredIasKt < env.minIasKt then
    self:_AddLowSpeedTimingAdvisory(timing, segLabel, segLegs, requiredIasKt)
    return env.minIasKt, true
  end

  return self:_ClampSpeed(requiredIasKt, warnings, segLabel)
end

function MosieNavigator:_ResolveSegmentSpeeds(segLegs, totalTimeSec, warnings, timing, segLabel)
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
    derivedIas = self:_ClampDerivedSegmentSpeed(derivedIas, warnings, timing, segLabel .. " all-FIXED override", segLegs)
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
    derivedIas, _ = self:_ClampDerivedSegmentSpeed(derivedIas, warnings, timing, segLabel .. " FREE uniform", segLegs)
    local clampedGs = self:_ConvertIasToTas(derivedIas, avgAlt) or derivedIas
    for i = 1, n do result[i] = clampedGs; sources[i] = "computed" end
    return result, sources
  end

  -- Mixed: FIXED honored, FREE get averaged remainder
  local sources = {}
  local fixedTime = 0
  for _, i in ipairs(fixedIndices) do
    local leg = segLegs[i]
    local gs  = self:_ClampGroundSpeed(
      leg.speedKt,
      leg.altFt or 0,
      warnings,
      string.format("%s WP%02d __S", segLabel, leg.wpOrder)
    ) or leg.speedKt
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
  freeIas, _    = self:_ClampDerivedSegmentSpeed(freeIas, warnings, timing, segLabel .. " FREE averaged", segLegs)
  local clampedFreeGs = self:_ConvertIasToTas(freeIas, avgAltFree) or freeIas
  for _, i in ipairs(freeIndices) do result[i] = clampedFreeGs; sources[i] = "computed" end

  return result, sources
end

-- Computes full flight plan: ETA, speeds, IAS, profiles, fuel, warnings.
-- Returns { valid, error, waypoints, fuel, warnings }.
function MosieNavigator:_ComputePlan(plan, rolexSeconds)
  rolexSeconds = rolexSeconds or 0
  local warnings = {}
  local timing = {}
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
  local defaultGsRaw = takeoff.speedKt or aircraft.defaultCruiseSpeedKt

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
      return self:_ClampGroundSpeed(
        ld.speedKt,
        ld.altFt or 0,
        warnings,
        string.format("WP%02d __S", ld.wpOrder)
      ) or ld.speedKt, "explicit"
    end
    local altitudeFt = ld and ld.altFt or 0
    local wpOrder = ld and ld.wpOrder or k
    return self:_ClampGroundSpeed(
      defaultGsRaw,
      altitudeFt,
      warnings,
      string.format("WP%02d default __S", wpOrder)
    ) or defaultGsRaw, "default"
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
            wpType  = legDescs[k].wpType,
          })
        end

        local segSpeeds, segSources = self:_ResolveSegmentSpeeds(
          segLegs, dt, warnings, timing,
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
    local gs      = legGs[k] or (self:_ClampGroundSpeed(defaultGsRaw, resolvedAlt[k] or 0, warnings, string.format("WP%02d default __S", wps[k].order)) or defaultGsRaw)
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
          local jgs = legGs[j] or (self:_ClampGroundSpeed(defaultGsRaw, resolvedAlt[j] or 0, warnings, string.format("WP%02d default __S", wps[j].order)) or defaultGsRaw)
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
      local inGs    = legGs[k] or (self:_ClampGroundSpeed(defaultGsRaw, resolvedAlt[k] or 0, warnings, string.format("WP%02d default __S", wp.order)) or defaultGsRaw)
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
      local gs      = legGs[k] or (self:_ClampGroundSpeed(defaultGsRaw, resolvedAlt[k] or 0, warnings, string.format("WP%02d default __S", wp.order)) or defaultGsRaw)
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
    timing = timing,
  }
end
