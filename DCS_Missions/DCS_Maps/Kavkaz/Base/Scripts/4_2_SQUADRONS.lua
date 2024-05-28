--Squadron_WZ1 = SQUADRON:New("WIZARD #1", 1, "WIZARD #1")
--Squadron_WZ1:SetSkill(AI.Skill.EXCELLENT)
--Squadron_WZ1:SetFuelLowThreshold(0.3)
--Squadron_WZ1:SetFuelLowRefuel(true)
--Squadron_WZ1:AddMissionCapability({ AUFTRAG.Type.AWACS }, 100)

Spawn_Shell1 = SPAWN:New("SHELL #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (shell_11) shell_11:CommandSetCallsign(CALLSIGN.Tanker.Shell, 1) end):InitRepeatOnLanding()
Spawn_Texaco_1 = SPAWN:New("TEXACO #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (texaco_11) texaco_11:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 1) end):InitRepeatOnLanding()
Spawn_Texaco_2 = SPAWN:New("TEXACO #2"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (texaco_21) texaco_21:CommandSetCallsign(CALLSIGN.Tanker.Texaco, 2) end):InitRepeatOnLanding()
Spawn_Wizard_1 = SPAWN:New("WIZARD #1"):InitLimit( 1, 0 ):SpawnScheduled( 60, .1 ):OnSpawnGroup( function (wizard_11) wizard_11:CommandSetCallsign(CALLSIGN.AWACS.Wizard, 1) end):InitRepeatOnLanding()

