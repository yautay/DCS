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
  local windVector = groupCoordinate:GetWindVec3(UTILS.FeetToMeters(altitudeFt or 0)) or {x = 0, z = 0}
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
