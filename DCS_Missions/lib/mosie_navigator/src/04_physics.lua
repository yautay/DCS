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
