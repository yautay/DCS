function MosieNavigator:_DrawWaypoint(plan, waypoint, color)
  local label = string.format("MN %s %02d %s\n%s", waypoint.plan, waypoint.order, waypoint.type, waypoint.name)
  local radius = self.Config.defaultWaypointRadiusM

  if waypoint.zone.GetRadius then
    radius = waypoint.zone:GetRadius()
  end

  self:_AddMarker(waypoint.coordinate:CircleToAll(
    radius,
    self.Config.coalition,
    self:_CopyColor(color),
    self.Config.waypointLineAlpha,
    self:_CopyColor(color),
    self.Config.waypointFillAlpha,
    1,
    self.Config.readOnly,
    label
  ))

  self:_AddMarker(waypoint.coordinate:TextToAll(
    string.format("%s %02d %s", waypoint.plan, waypoint.order, waypoint.name),
    self.Config.coalition,
    self:_CopyColor(color),
    1,
    {0, 0, 0},
    0.0,
    12,
    self.Config.readOnly
  ))
end

function MosieNavigator:_DrawPlan(plan, color)
  for index, waypoint in ipairs(plan.waypoints) do
    self:_DrawWaypoint(plan, waypoint, color)

    local nextWaypoint = plan.waypoints[index + 1]
    if nextWaypoint then
      self:_AddMarker(waypoint.coordinate:LineToAll(
        nextWaypoint.coordinate,
        self.Config.coalition,
        self:_CopyColor(color),
        self.Config.waypointLineAlpha,
        1,
        self.Config.readOnly,
        string.format("MN %s %02d-%02d", plan.name, waypoint.order, nextWaypoint.order)
      ))
    end
  end
end

function MosieNavigator:_DrawBeacon(beacon)
  local radius = UTILS.NMToMeters(beacon.powerNm)
  local label = string.format("MNB %s", beacon.id)

  if beacon.frequency then
    label = label .. string.format("\n%s", beacon.frequency)
  end

  label = label .. string.format("\nRange %d NM", beacon.powerNm)

  if beacon.altitudeFt then
    label = label .. string.format("\nAlt %d ft", beacon.altitudeFt)
  end

  self:_AddMarker(beacon.coordinate:CircleToAll(
    radius,
    self.Config.coalition,
    self:_CopyColor(self.BeaconColor),
    self.Config.beaconLineAlpha,
    self:_CopyColor(self.BeaconColor),
    self.Config.beaconFillAlpha,
    2,
    self.Config.readOnly,
    label
  ))

  self:_AddMarker(beacon.coordinate:TextToAll(
    label,
    self.Config.coalition,
    self:_CopyColor(self.BeaconColor),
    1,
    {0, 0, 0},
    0.0,
    13,
    self.Config.readOnly
  ))
end
