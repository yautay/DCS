-- ###########################################################
-- ###                   RED COALITION                     ###
-- ###########################################################

function spawn_siri_base()
    siri_aaa_60 = SPAWN:New("siri-aaa"):InitLimit(10, 0):SpawnScheduled(UTILS.ClockToSeconds("03:00:00"), .25 )
    siri_aaa_23 = SPAWN:New("siri-aaa-1"):InitLimit(10, 0):SpawnScheduled(UTILS.ClockToSeconds("03:00:00"), .25 )
    siri_planes = SPAWN:New("siri-planes"):InitLimit(10, 0):SpawnScheduled(UTILS.ClockToSeconds("03:00:00"), .25 )
    siri_helo = SPAWN:New("siri-helo"):InitLimit(1, 0):SpawnScheduled(UTILS.ClockToSeconds("03:00:00"), .25 )
    siri_scuds = SPAWN:New("siri-scuds"):InitLimit(4, 0):SpawnScheduled(UTILS.ClockToSeconds("03:00:00"), .25 )
    siri_silkworm = SPAWN:New("siri-silkworm"):InitLimit(4, 0):SpawnScheduled(UTILS.ClockToSeconds("03:00:00"), .25 )
    -- siri_sa9 = SPAWN:New("red-sa9-sirri"):InitLimit(4, 0):SpawnScheduled(UTILS.ClockToSeconds("03:00:00"), .25 )
    mist.teleportInZone("red-sa9-sirri", "sirri-sa9")
end

spawn_siri_base()

