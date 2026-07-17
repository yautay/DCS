function MosieAiPlanner:_Log(message)
  env.info("MOSIE_AI_PLANNER: " .. tostring(message))
end

function MosieAiPlanner:_IsTestMode()
  return TEST_MODE == true
end

function MosieAiPlanner:_GetNavigator()
  return MosieNavigator
end

function MosieAiPlanner:_SplitPlain(value, delimiter)
  local result = {}
  local startIndex = 1

  while true do
    local delimiterStart, delimiterEnd = string.find(value or "", delimiter, startIndex, true)
    if not delimiterStart then
      table.insert(result, string.sub(value or "", startIndex))
      break
    end

    table.insert(result, string.sub(value or "", startIndex, delimiterStart - 1))
    startIndex = delimiterEnd + 1
  end

  return result
end

function MosieAiPlanner:_Join(tokens, startIndex, endIndex, separator)
  local result = {}
  local lastIndex = endIndex or #tokens
  for index = startIndex, lastIndex do
    table.insert(result, tokens[index])
  end

  return table.concat(result, separator or "")
end

function MosieAiPlanner:_ExtractPlanFromGroupName(groupName)
  return string.match(groupName or "", self.Config.groupPlanTagPattern)
end

function MosieAiPlanner:_ExtractRolexFromGroupName(groupName)
  local navigator = self:_GetNavigator()
  if navigator and type(navigator._ExtractRolexFromGroupName) == "function" then
    return navigator:_ExtractRolexFromGroupName(groupName)
  end

  return 0
end

function MosieAiPlanner:_GetGroupSkill(group)
  if group and type(group.GetSkill) == "function" then
    return group:GetSkill()
  end

  return nil
end

function MosieAiPlanner:_IsAiGroup(group)
  local skill = self:_GetGroupSkill(group)
  return skill ~= "Client" and skill ~= "Player"
end

function MosieAiPlanner:_IsGroupExisting(group)
  if not group then
    return false
  end
  if type(group.GetDCSObject) == "function" then
    local ok, dcsGroup = pcall(function() return group:GetDCSObject() end)
    if ok and dcsGroup and type(dcsGroup.isExist) == "function" then
      local existOk, exists = pcall(function() return dcsGroup:isExist() end)
      return existOk and exists == true
    end
  end
  if type(group.IsAlive) == "function" then
    return group:IsAlive() == true
  end
  return false
end

function MosieAiPlanner:_KnotsToMps(knots)
  if UTILS and type(UTILS.KnotsToMps) == "function" then
    return UTILS.KnotsToMps(knots or 0)
  end

  return (knots or 0) * 0.514444
end

function MosieAiPlanner:_MetersToNm(meters)
  if UTILS and type(UTILS.MetersToNM) == "function" then
    return UTILS.MetersToNM(meters or 0)
  end

  return (meters or 0) / 1852
end

function MosieAiPlanner:_FeetToMeters(feet)
  return (feet or 0) * 0.3048
end

function MosieAiPlanner:_Clamp(value, minValue, maxValue)
  if value < minValue then return minValue end
  if value > maxValue then return maxValue end
  return value
end

function MosieAiPlanner:_IsGroupAirborne(group)
  if group and type(group.IsAirborne) == "function" then
    return group:IsAirborne()
  end

  return false
end

function MosieAiPlanner:_LogStateOnce(state, key, message)
  state.logged = state.logged or {}
  if state.logged[key] then
    return
  end

  state.logged[key] = true
  self:_Log(message)
end
