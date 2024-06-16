Spawn_Shell1 = SPAWN:New("SHELL #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (shell_11) shell_11:CommandSetCallsign(CALLSIGN.Tanker.Shell, 1) end):InitRepeatOnLanding()
Spawn_Texaco_1 = SPAWN:New("TEXACO #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (texaco_11) texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1) end):InitRepeatOnLanding()



function spawnStrike()
    Spawn_Aggressor_1 = SPAWN:New("AGRESOR1"):Spawn()
    Spawn_Aggressor_2 = SPAWN:New("AGRESOR2"):Spawn()
    Spawn_Aggressor_3 = SPAWN:New("AGRESOR3"):Spawn()
end

function spawnMig21()
    Spawn_Mig21 = SPAWN:New("MIGS21"):Spawn()
end
function spawnMig19()
    Spawn_Mig21 = SPAWN:New("MIGS19"):Spawn()
end
function spawnMig15()
    Spawn_Mig21 = SPAWN:New("MIGS15"):Spawn()
end
function spawnMig29()
    Spawn_Mig21 = SPAWN:New("MIGS15"):Spawn()
end

MenuSpawnAir = MENU_COALITION:New( coalition.side.BLUE, "Spawn Menu PvE" )

MenuSpawnAttackOnSenaki = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn Strike", MenuSpawnAir, spawnStrike )
MenuSpawnMIG21 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn 2-ship of MiG-21 from South", MenuSpawnAir, spawnMig21 )
MenuSpawnMIG19 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn 2-ship of MiG-19 from South-East", MenuSpawnAir, spawnMig19 )
MenuSpawnMIG15 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn 4-ship of MiG-15 from East", MenuSpawnAir, spawnMig15 )
MenuSpawnMIG29 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn 2-ship of MiG-29 from West", MenuSpawnAir, spawnMig29 )