function MosieAiPlanner:_CoordinateToVec2(coordinate)
  if not coordinate then
    return nil
  end

  if type(coordinate.GetVec2) == "function" then
    return coordinate:GetVec2()
  end

  if type(coordinate.GetVec3) == "function" then
    local vec3 = coordinate:GetVec3()
    return {x = vec3.x, y = vec3.z}
  end

  return {x = coordinate.x, y = coordinate.z or coordinate.y}
end

function MosieAiPlanner:_GetAirdromeCategory()
  return Airbase and Airbase.Category and Airbase.Category.AIRDROME or nil
end

function MosieAiPlanner:_GetAirbaseName(airbase)
  if not airbase then
    return nil
  end

  if type(airbase.GetName) == "function" then
    local ok, name = pcall(function() return airbase:GetName() end)
    if ok and name then
      return name
    end
  end

  if type(airbase.GetAirbaseName) == "function" then
    local ok, name = pcall(function() return airbase:GetAirbaseName() end)
    if ok and name then
      return name
    end
  end

  return airbase.AirbaseName or airbase.airbaseName or airbase.name
end

function MosieAiPlanner:_GetAirbaseCoordinate(airbase)
  if not airbase then
    return nil
  end

  if type(airbase.GetCoordinate) == "function" then
    local ok, coordinate = pcall(function() return airbase:GetCoordinate() end)
    if ok and coordinate then
      return coordinate
    end
  end

  if type(airbase.GetVec2) == "function" then
    local ok, vec2 = pcall(function() return airbase:GetVec2() end)
    if ok and vec2 then
      return {x = vec2.x, y = 0, z = vec2.y}
    end
  end

  return nil
end

function MosieAiPlanner:_GetAirbaseId(airbase)
  if not airbase then
    return nil
  end

  if type(airbase.GetID) == "function" then
    local ok, id = pcall(function() return airbase:GetID() end)
    if ok and id then
      return id
    end
  end

  if type(airbase.getID) == "function" then
    local ok, id = pcall(function() return airbase:getID() end)
    if ok and id then
      return id
    end
  end

  return airbase.AirbaseID or airbase.id
end

function MosieAiPlanner:_FindNearestLandingAirbase(coordinate)
  if not coordinate then
    return nil, nil
  end

  local airdromeCategory = self:_GetAirdromeCategory()
  if type(coordinate.GetClosestAirbase) == "function" then
    local ok, airbase, distanceMeters = pcall(function()
      return coordinate:GetClosestAirbase(airdromeCategory)
    end)
    if ok and airbase then
      return airbase, distanceMeters
    end
  end

  if not AIRBASE or type(AIRBASE.GetAllAirbases) ~= "function" or type(coordinate.Get2DDistance) ~= "function" then
    return nil, nil
  end

  local ok, airbases = pcall(function() return AIRBASE.GetAllAirbases(nil) end)
  if not ok or not airbases then
    return nil, nil
  end

  local closestAirbase = nil
  local closestDistanceMeters = nil
  for _, airbase in pairs(airbases) do
    local category = nil
    if airbase and type(airbase.GetAirbaseCategory) == "function" then
      local categoryOk, value = pcall(function() return airbase:GetAirbaseCategory() end)
      if categoryOk then
        category = value
      end
    end

    if airbase and (not airdromeCategory or category == airdromeCategory) then
      local airbaseCoordinate = self:_GetAirbaseCoordinate(airbase)
      if airbaseCoordinate then
        local distanceMeters = coordinate:Get2DDistance(airbaseCoordinate)
        if distanceMeters and (not closestDistanceMeters or distanceMeters < closestDistanceMeters) then
          closestAirbase = airbase
          closestDistanceMeters = distanceMeters
        end
      end
    end
  end

  return closestAirbase, closestDistanceMeters
end

function MosieAiPlanner:_GetGroupCoordinate(group)
  if group and type(group.GetCoordinate) == "function" then
    return group:GetCoordinate()
  end

  return nil
end

function MosieAiPlanner:_GetDistanceNm(fromCoordinate, toCoordinate)
  if not fromCoordinate or not toCoordinate or type(fromCoordinate.Get2DDistance) ~= "function" then
    return nil
  end

  return self:_MetersToNm(fromCoordinate:Get2DDistance(toCoordinate))
end
