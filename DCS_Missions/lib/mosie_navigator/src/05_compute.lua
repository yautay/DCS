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
    if totalTimeSec <= 0 or totalDist <= 0 then
      for i = 1, n do result[i] = self.Aircraft.envelope.minIasKt end
      return result
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
    end
    return result
  end

  if #fixedIndices == 0 then
    -- All FREE: uniform derived speed
    local totalDist = 0
    for _, leg in ipairs(segLegs) do totalDist = totalDist + leg.distNm end
    if totalTimeSec <= 0 or totalDist <= 0 then
      for i = 1, n do result[i] = self.Aircraft.envelope.minIasKt end
      return result
    end
    local derivedGs = totalDist / (totalTimeSec / 3600)
    local avgAlt    = 0
    for _, leg in ipairs(segLegs) do avgAlt = avgAlt + (leg.altFt or 0) end
    avgAlt = avgAlt / n
    local derivedIas = self:_ConvertTasToIas(derivedGs, avgAlt) or derivedGs
    derivedIas, _ = self:_ClampSpeed(derivedIas, warnings, segLabel .. " FREE uniform")
    local clampedGs = self:_ConvertIasToTas(derivedIas, avgAlt) or derivedIas
    for i = 1, n do result[i] = clampedGs end
    return result
  end

  -- Mixed: FIXED honored, FREE get averaged remainder
  local fixedTime = 0
  for _, i in ipairs(fixedIndices) do
    local leg = segLegs[i]
    local gs  = self:_ConvertIasToTas(leg.speedKt, leg.altFt or 0) or leg.speedKt
    local t   = leg.distNm / gs * 3600
    fixedTime = fixedTime + t
    result[i] = gs
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
    for _, i in ipairs(freeIndices) do result[i] = minGs end
    return result
  end

  local freeGs   = freeDist / (freeTime / 3600)
  local avgAltFree = 0
  for _, i in ipairs(freeIndices) do avgAltFree = avgAltFree + (segLegs[i].altFt or 0) end
  avgAltFree = avgAltFree / #freeIndices
  local freeIas = self:_ConvertTasToIas(freeGs, avgAltFree) or freeGs
  freeIas, _    = self:_ClampSpeed(freeIas, warnings, segLabel .. " FREE averaged")
  local clampedFreeGs = self:_ConvertIasToTas(freeIas, avgAltFree) or freeIas
  for _, i in ipairs(freeIndices) do result[i] = clampedFreeGs end

  return result
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

  if not takeoff.timeOnTargetSeconds then
    return { valid = false, error = "TAKE_OFF must have __T (brake release time)", warnings = warnings }
  end

  -- Determine default plan speed (GS kt)
  local defaultGs = nil
  if takeoff.speedKt then
    defaultGs = self:_ConvertIasToTas(takeoff.speedKt, takeoff.altitudeFt or 0) or takeoff.speedKt
  end

  if not defaultGs then
    -- Try to derive from first downstream __T pair
    local firstTotSec = takeoff.timeOnTargetSeconds
    for i = 2, #wps do
      if wps[i].timeOnTargetSeconds then
        local totalDist = 0
        for j = 2, i do
          totalDist = totalDist + UTILS.MetersToNM(wps[j-1].coordinate:Get2DDistance(wps[j].coordinate))
        end
        local dt = wps[i].timeOnTargetSeconds - firstTotSec
        if dt < 0 then dt = dt + 86400 end
        if dt > 0 and totalDist > 0 then
          defaultGs = totalDist / (dt / 3600)
        end
        break
      end
    end
  end

  if not defaultGs then
    return {
      valid = false,
      error = "TAKE_OFF has no __S and no downstream __T constraints — cannot compute speeds",
      warnings = warnings,
    }
  end

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

  local function legSpeedFromDecl(k)
    local ld = legDescs[k]
    if ld and ld.speedKt then
      return self:_ConvertIasToTas(ld.speedKt, ld.altFt or 0) or ld.speedKt
    end
    return defaultGs
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
        legGs[k] = legSpeedFromDecl(k)
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
          legGs[k] = legSpeedFromDecl(k)
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

        local segSpeeds = self:_ResolveSegmentSpeeds(
          segLegs, dt, warnings,
          string.format("segment [WP%02d..WP%02d]", wps[segStart].order, wps[segEnd].order)
        )

        for idx = 1, #segRange do
          legGs[segRange[idx]] = segSpeeds[idx]
        end
      end
    end
  end

  -- Legs before the first anchor (shouldn't normally happen, but guard)
  if #anchorList > 0 then
    for k = 2, anchorList[1] do
      if not legGs[k] and wps[k].type ~= "HOLD" then
        legGs[k] = legSpeedFromDecl(k)
      end
    end
  end

  -- Fill any remaining unset legs
  for k = 2, #wps do
    if not legGs[k] then
      legGs[k] = legSpeedFromDecl(k)
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

  -- Heading helpers need the magnetic declination at the WP coordinate
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
      rawTimeOnTarget    = wp.timeOnTarget,
      rawTimeOnTargetSec = wp.timeOnTargetSeconds,
    }

    if k == 1 then
      -- TAKE_OFF: no incoming leg
      ow.legDistNm       = nil
      ow.legGsKt         = nil
      ow.legIasKt        = nil
      ow.legProfile      = nil
      ow.legFuelImpGal   = aircraft.fuel.taxiAllowance
      ow.trueCourse      = nil
      ow.holdDurationSec = nil
    elseif wp.type == "HOLD" then
      local ld      = legDescs[k]
      local inGs    = legGs[k] or defaultGs
      local inIas   = self:_ConvertTasToIas(inGs, resolvedAlt[k]) or inGs
      local legDist = ld and ld.distNm or 0
      local legTime = inGs > 0 and (legDist / inGs) or 0

      local prof    = self:_MatchProfile(inIas, resolvedAlt[k])
      local legBurn = (prof and prof.burnImpGph or 100) * legTime

      local holdDur  = holdDurations[k] or 0
      local holdBurn = aircraft.holdBurnImpGph * (holdDur / 3600)

      fuelCum = fuelCum + legBurn

      ow.legDistNm       = legDist
      ow.legGsKt         = inGs
      ow.legIasKt        = inIas
      ow.legProfile      = prof and prof.name or nil
      ow.legFuelImpGal   = legBurn
      ow.holdDurationSec = holdDur
      ow.holdFuelImpGal  = holdBurn
      ow.trueCourse      = legTrueCourse(wps[k-1], wp)

      fuelCum = fuelCum + holdBurn
    else
      local ld      = legDescs[k]
      local gs      = legGs[k] or defaultGs
      local ias     = self:_ConvertTasToIas(gs, resolvedAlt[k]) or gs
      local legDist = ld and ld.distNm or 0
      local legTime = gs > 0 and (legDist / gs) or 0

      local prof    = self:_MatchProfile(ias, resolvedAlt[k])
      if not prof then
        table.insert(warnings, string.format(
          "WP%02d %s: no profile match for IAS %.0f kt at %d ft — using 100 gph fallback",
          wp.order, wp.name, ias, resolvedAlt[k]
        ))
      end
      local legBurn = (prof and prof.burnImpGph or 100) * legTime

      fuelCum = fuelCum + legBurn

      ow.legDistNm     = legDist
      ow.legGsKt       = gs
      ow.legIasKt      = ias
      ow.legProfile    = prof and prof.name or nil
      ow.legFuelImpGal = legBurn
      ow.trueCourse    = legTrueCourse(wps[k-1], wp)
    end

    ow.fuelCumImpGal = fuelCum
    table.insert(outWps, ow)
  end

  -- Reserve: 30 min at lowest burn profile
  local lowestBurn = aircraft.profiles[1].burnImpGph
  for _, p in ipairs(aircraft.profiles) do
    if p.burnImpGph < lowestBurn then lowestBurn = p.burnImpGph end
  end
  local reserveFuel = aircraft.fuel.reserveMinutes / 60 * lowestBurn
  local routeFuel   = fuelCum - aircraft.fuel.taxiAllowance
  local totalFuel   = fuelCum + reserveFuel + aircraft.fuel.landingAllowance
  local margin      = aircraft.fuel.tankCapacity - totalFuel

  if totalFuel > aircraft.fuel.tankCapacity then
    table.insert(warnings, string.format(
      "FUEL: required %.1f IMP GAL exceeds tank %.1f IMP GAL (%.1f over)",
      totalFuel, aircraft.fuel.tankCapacity, -margin
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
      tankImpGal      = aircraft.fuel.tankCapacity,
      marginImpGal    = margin,
      marginPercent   = margin / aircraft.fuel.tankCapacity * 100,
    },
    warnings = warnings,
  }
end
