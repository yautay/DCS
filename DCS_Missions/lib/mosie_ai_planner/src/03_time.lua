function MosieAiPlanner:_GetMissionTime()
  if timer and type(timer.getAbsTime) == "function" then
    return timer.getAbsTime()
  end

  return 0
end

function MosieAiPlanner:_FormatClock(seconds)
  local navigator = self:_GetNavigator()
  if navigator and type(navigator._FormatClock) == "function" then
    return navigator:_FormatClock(seconds or 0)
  end

  seconds = math.floor((seconds or 0) % 86400)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = seconds % 60
  return string.format("%02d:%02d:%02d", h, m, s)
end
