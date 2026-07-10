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
