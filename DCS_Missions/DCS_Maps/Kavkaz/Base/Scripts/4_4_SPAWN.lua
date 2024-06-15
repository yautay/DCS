Spawn_Shell1 = SPAWN:New("SHELL #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (shell_11) shell_11:CommandSetCallsign(CALLSIGN.Tanker.Shell, 1) end):InitRepeatOnLanding()
Spawn_Texaco_1 = SPAWN:New("TEXACO #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (texaco_11) texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1) end):InitRepeatOnLanding()



function spawnStrike()
    Spawn_Aggressor_1 = SPAWN:New("AGRESOR1"):Spawn()
    Spawn_Aggressor_2 = SPAWN:New("AGRESOR2"):Spawn()
    Spawn_Aggressor_3 = SPAWN:New("AGRESOR3"):Spawn()
end

function spawnMig21()
    Spawn_Aggressor_1 = SPAWN:New("MIGS21"):Spawn()
    Spawn_Aggressor_2 = SPAWN:New("AGRESOR2"):Spawn()
    Spawn_Aggressor_3 = SPAWN:New("AGRESOR3"):Spawn()
end

MenuSpawnAttackOnSenaki = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn Strike", MenuSpawn, spawnStrike )
MenuSpawnMIG21 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn pair of MiG-21 from South", MenuSpawn, spawnMig21 )