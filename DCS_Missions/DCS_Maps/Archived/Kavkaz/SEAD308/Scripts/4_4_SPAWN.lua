Spawn_Shell1 = SPAWN:New("SHELL #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (shell_11) shell_11:CommandSetCallsign(CALLSIGN.Tanker.Shell, 1) end):InitRepeatOnLanding()
Spawn_Texaco_1 = SPAWN:New("TEXACO #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (texaco_11) texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1) end):InitRepeatOnLanding()
Spawn_Texaco_2 = SPAWN:New("TEXACO #2"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (texaco_11) texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 2) end):InitRepeatOnLanding()

