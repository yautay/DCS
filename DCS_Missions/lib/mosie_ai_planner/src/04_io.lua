function MosieAiPlanner:_GetOutputDirectory()
  local navigator = self:_GetNavigator()
  if navigator and type(navigator._GetOutputDirectory) == "function" then
    return navigator:_GetOutputDirectory()
  end

  if lfs and lfs.writedir then
    return lfs.writedir() .. "Logs/"
  end

  return "./"
end

function MosieAiPlanner:_GetAiZoneDumpPath()
  return self:_GetOutputDirectory() .. "AI_ZONE_DUMP.log"
end

function MosieAiPlanner:_ResetAiZoneDumpFile()
  if not self:_IsTestMode() then
    return
  end

  if not io then
    self:_Log("cannot reset AI zone dump file: io is not available")
    return
  end

  local path = self:_GetAiZoneDumpPath()
  local file = io.open(path, "w")
  if not file then
    self:_Log("cannot reset AI zone dump file: " .. path)
    return
  end

  file:write(string.format("AI_ZONE_DUMP reset at mission time %s\n", self:_FormatClock(timer and timer.getAbsTime and timer.getAbsTime() or 0)))
  file:close()
  self:_Log("reset AI zone dump file: " .. path)
end

function MosieAiPlanner:_AppendAiZoneDump(text)
  if not self:_IsTestMode() then
    return
  end

  if not io then
    self:_Log("cannot write AI zone dump file: io is not available")
    return
  end

  local path = self:_GetAiZoneDumpPath()
  local file = io.open(path, "a")
  if not file then
    self:_Log("cannot write AI zone dump file: " .. path)
    return
  end

  file:write(tostring(text or ""))
  file:write("\n---\n")
  file:close()
end

function MosieAiPlanner:_AppendAiDebugDump(state, message)
  if not self:_IsTestMode() then
    return
  end

  local text = string.format(
    "[%s] AI_DEBUG group=\"%s\" %s",
    self:_FormatClock(self:_GetMissionTime()),
    tostring(state and state.assignment and state.assignment.groupName or "---"),
    tostring(message or "")
  )
  self:_Log(text)
  self:_AppendAiZoneDump(text)
end

function MosieAiPlanner:_AppendAiCommandDump(state, command, details)
  if not self:_IsTestMode() then
    return
  end

  local text = string.format(
    "[%s] AI_COMMAND group=\"%s\" command=%s wp=%s reason=%s details=\"%s\"",
    self:_FormatClock(self:_GetMissionTime()),
    tostring(state and state.assignment and state.assignment.groupName or "---"),
    tostring(command or "---"),
    state and state.currentWpIndex and string.format("WP%02d", state.currentWpIndex) or "---",
    tostring(state and state.aiModeReason or "---"),
    tostring(details or "")
  )
  self:_Log(text)
  self:_AppendAiZoneDump(text)
end

function MosieAiPlanner:_SetAiMode(state, mode, reason, details)
  if not state then
    return
  end

  local previousMode    = state.aiMode
  local previousReason  = state.aiModeReason
  local previousDetails = state.aiModeDetails
  state.aiMode        = mode or "UNKNOWN"
  state.aiModeReason  = reason
  state.aiModeDetails = details

  if previousMode ~= state.aiMode or previousReason ~= state.aiModeReason or previousDetails ~= state.aiModeDetails then
    self:_AppendAiDebugDump(state, string.format(
      "mode=%s reason=%s details=\"%s\"",
      tostring(state.aiMode),
      tostring(reason or "---"),
      tostring(details or "")
    ))
  end
end
