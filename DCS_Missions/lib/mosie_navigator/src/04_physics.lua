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
  local aircraft = self.Aircraft
  local candidates = {}

  for _, p in ipairs(aircraft.profiles) do
    if p.altMinFt and altFt < p.altMinFt then
      -- skip
    elseif p.altMaxFt and altFt > p.altMaxFt then
      -- skip
    elseif iasKt < p.iasKtMin or iasKt > p.iasKtMax then
      -- skip
    else
      table.insert(candidates, p)
    end
  end

  if #candidates == 0 then
    return nil
  end

  local best = candidates[1]
  for i = 2, #candidates do
    if candidates[i].burnImpGph < best.burnImpGph then
      best = candidates[i]
    end
  end

  return best
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
