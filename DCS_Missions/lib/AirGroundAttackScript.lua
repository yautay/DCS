----- Air-Ground Attack Script -----
-- improved air-ground attack tactics for DCS AI
-- version 2021.12.28
-- by Marc "MBot" Marbot

---------------------------------------------------------------------------------------------------------------------------------
-- AirGroundAttackTask(FlightName, Target, WeaponType, ExpendQty, Dive, OffsetAngle, ClimbAngle, PopAlt, AttackDist, Reattack) --
---------------------------------------------------------------------------------------------------------------------------------

-- FlightName	"Aerial-1"		Group name of flight that is tasked to attack

-- Target						Four types of ground targets can be attacked (vehicles/ships, static objects, scenery objects, parked aircraft/helicopters)
--- Option 1:	"Ground-1"											Vehicles/Ships: Group name of vehicle or ship group
--- Option 2:	{"StaticName-1", StaticName-2", StaticName-N"}		Static Objects: Object name of static object, listed in {} (a single static objects also needs {} ).
--- Option 3:	{{x = 123, y = 123}, {x = 456, y = 456}}			Scenery Objects: x-/y-coordinate of scenery object in {}, listed in {} (a single scenery objects needs double {{}} ).
--- Option 4:	{x = 123, y = 123}									Parked aicraft or helicopters: x-/y-coordinate in {}. Stationary aicraft or helicopters within 5000 m of this coordinate will be attacked.

-- WeaponType					Weapon type for the attack
---	Option 1:	"Auto"			Automatic weapon type selection (note: might lead to gun strafing)
---	Option 2:	"Cannon"		Attack with gun
---	Option 3:	"Rockets"		Attack with unguided rockets
---	Option 4:	"Bombs"			Attack with unguided bombs
---	Option 5:	"Guided bombs"	Attack with guided bombs
---	Option 6:	"ASM"			Attack with guided missiles
---	Option 7:	number			Alternatively, the internal DCS code for certain weapon types or combinations of weapon types may be entered as a number

-- ExpendQty					Number of weapons to be expended per attack run
---	Option 1:	"Auto"			Automatic selection of number of weapons to be expended
---	Option 2:	"One"			Expend one weapon		
---	Option 3:	"Two"			Expend two weapons
---	Option 4:	"Four"			Expend four weapons
---	Option 5:	"Quarter"		Expend 1/4 of weapons carried per type	
---	Option 6:	"Half"			Expend 1/2 of weapons carried per type
---	Option 7:	"All"			Expend all weapons carried per type

-- Dive							Whether a dive attack is performed
---	Option 1:	true			Perform a dive attack (when possible)
---	Option 2:	false			Perform a level attack (when possible)
---	Option 3:	nil				Perform a level attack (when possible)

-- OffsetAngle					Offset turn to side prior to pop-up maneuver
---	Option 1:	number			Angle in degress of offset turn (enter positive number only, offset side is determined by egress geometry)
---	Option 2:	0				Do not perform an offset turn
---	Option 3:	nil				Do not perform an offset turn 

-- ClimbAngle	number			The climb angle in degrees for any pop-up climb (climb angles smaller than 15 are not possible)

-- PopAlt						Pop-up maneuver prior to attack
---	Option 1:	number			Height in meters above target to which a pop-up shall be performed
---	Option 2:	0				Do not perform a pop-up maneuever
---	Option 3:	nil				Do not perform a pop-up maneuever

-- AttackDist					Distance from target where a pop-up maneuver shall be completed (if no pop-up maneuver is performed, this is ignored and attacks will be initiated imediately)
---	Option 1:	number			Distance in meters (useful to set a specific distance for weapons with stand-off range such as missiles and heavy rockets)
---	Option 2:	nil				When attacking with bombs, the distance will be calculated automatically in order to keep to pop-up as short as possible
---	Option 3:	nil				When attacking with rockets, a generic distance is selected automatically that works with the most common rocket types

-- Reattack						Whether aircraft egress after the first attack or return for subsequent attacks
---	Option 1:	true			Repeat attacks as long as weapons and targets remain
---	Option 2:	false			Egress after first attack
---	Option 3:	nil				Egress after first attack

---------------------------------------------------------------------------------------------------------------------------------


local AttackCounter	= {}																		--table to count how many flights have already attacked the same target and distribute target sub-elements for subsequent attacks accordingly

function AirGroundAttackTask(FlightName, Target, WeaponType, ExpendQty, Dive, OffsetAngle, ClimbAngle, PopAlt, AttackDist, Reattack, Debug)
	local wingman = Group.getByName(FlightName):getUnits()
	
	--get flight route of group for egress and resume route after attack
	local function GetPlaneGroupRoute(groupname)
		for coalition_name,coal in pairs(env.mission.coalition) do
			for country_n,country in pairs(coal.country) do
				if country.plane then
					for group_n,group in pairs(country.plane.group) do
						if groupname == env.getValueDictByKey(group.name) then					--find group in env.mission
							return group.route.points											--return the route
						end
					end
				end
			end
		end
	end
	local route	= GetPlaneGroupRoute(FlightName)												--get the route of the flight from env.mission
	local AttackWpN																				--number of attack waypoint in route
	local EgressWpN																				--number of egress waypoint in route
	for w = 1, #route do																		--iterate through waypoints of group
		for t = 1, #route[w].task.params.tasks do												--iterate through tasks in waypoint
			if route[w].task.params.tasks[t].id == "WrappedAction" and route[w].task.params.tasks[t].params.action.id == "Script" then	--if task is a do script
				if string.find(route[w].task.params.tasks[t].params.action.params.command, "AirGroundAttackTask") then					--if this do script includes "AirGroundAttackTask"
					AttackWpN = w																--store number of attack waypoint
					EgressWpN = w + 1															--store number of egress waypoint (as a draft the WP after the attack WP, if a named egress WP is found later this will get used instead)
					break
				end
			end
		end
		if route[w].name and string.find(route[w].name, "Egress") then							--find WP that is named as egress waypoint
			EgressWpN = w																		--store this number for egress waypoint instead
			break
		end
	end
	local AttackSpeed = route[AttackWpN].speed													--get speed at attack waypoint
	local EgressSpeed = route[EgressWpN].speed													--get speed at egress waypoint
	
	--turn radius
	local G = 3																					--make all turns at 3g
	local TurnRadius = math.pow(AttackSpeed, 2) / (math.sqrt(math.pow(G, 2) - 1) * 9.81)		--calculate turn radius based on g pulled
	
	
	----- build target list based on target type -----
	local TargetList = {}																		--list of all target sub-elements
	local TargetType																			--store the type of target
	local AttackN
	
	--vehicle/ship
	if type(Target) == "string" then															--target is vehicle/ship (group name)
		TargetType = "unit"
		local TargetGroup = Group.getByName(Target):getUnits()									--get target group
		if TargetGroup then																		--target group exists
			for n = 1, #TargetGroup do															--iterate through units in target group
				local TgtPoint = TargetGroup[n]:getPoint()										--get point of target unit
				TgtPoint.y = TgtPoint.z															--turn vec3 coordinate into vec2 coordinate
				table.insert(TargetList, TgtPoint)												--insert target unit coordinates into Target List
			end
		end
		if AttackCounter[Target] then															--counter with number of flights that have already attacked this target
			AttackCounter[Target] = AttackCounter[Target] + 1									--increase counter by one
		else																					--no flight has attacked this target yet
			AttackCounter[Target] = 1															--set to one
		end
		AttackN = AttackCounter[Target]
		
	--static object
	elseif type(Target) == "table" and Target[1] and type(Target[1]) == "string" then			--target is static object (array of static object names)
		TargetType = "static"
		for n = #Target, 1, -1 do																--iterate through static objects in target array backwards (to allow element removal)
			local obj = StaticObject.getByName(Target[n])										--get static object
			if obj then																			--static object exists
				local TgtPoint = obj:getPoint()													--get point of static object
				TgtPoint.y = TgtPoint.z															--turn vec3 coordinate into vec2 coordinate
				table.insert(TargetList, 1, TgtPoint)											--insert static object coordinates into first position of Target List (this alows same order in Target List as in Target array)
			else																				--static object does not exist
				table.remove(Target, n)															--remove name from target array
			end
		end
		if AttackCounter[Target[1]] then														--counter with number of flights that have already attacked this target
			AttackCounter[Target[1]] = AttackCounter[Target[1]] + 1								--increase counter by one
		else																					--no flight has attacked this target yet
			AttackCounter[Target[1]] = 1														--set to one
		end
		AttackN = AttackCounter[Target[1]]
		
	--scenery object
	elseif type(Target) == "table" and Target[1] and Target[1].x and Target[1].y then			--target is scenery object (array of coordinates)
		TargetType = "scenery"
		TargetList = Target																		--Target List is this array
		if AttackCounter[Target[1].x .. Target[1].y] then										--counter with number of flights that have already attacked this target
			AttackCounter[Target[1].x .. Target[1].y] = AttackCounter[Target[1].x .. Target[1].y] + 1	--increase counter by one
		else																					--no flight has attacked this target yet
			AttackCounter[Target[1].x .. Target[1].y] = 1										--set to one
		end
		AttackN = AttackCounter[Target[1].x .. Target[1].y]
		
	--airbase
	elseif type(Target) == "table" and Target.x and Target.y then								--target is airbase (single coordinate; search for parked aircraft to attack)
		TargetType = "airbase"
		local function Found(u)																	--for each found unit, determine if it is a parked aircraft and insert coordinates into target list
			if u:getCoalition() ~= wingman[1]:getCoalition() then								--unit is hostile
				local desc = u:getDesc()														--get unit description
				if desc.category == 0 or desc.category == 1 then								--unit is an aircraft or helicopter
					if u:inAir() == false then													--aircraft is on ground
						local uV = u:getVelocity()												--get aircraft speed
						if (desc.category == 0 and uV.x == 0 and uV.y == 0 and uV.z == 0) or desc.category == 1 then	--aircraft is stationary/parked	(doesn't work for helicopters because for helos getVelocity returns IAS not absolute speed)	
							local uP = u:getPoint()												--get aircraft point
							table.insert(TargetList, {x = uP.x, y = uP.z})						--insert x-y coordinates into targetlist
						end
					end
				end
			end
			return true																			--continue search
		end

		local SearchArea = {																	--define area where to search for parked aircraft
			id = world.VolumeType.SPHERE,
			params = {
				point = {
					x = Target.x,
					y = land.getHeight({Target.x, Target.y}),
					z = Target.y,
				},
				radius = 5000
			}
		}
		world.searchObjects(Object.Category.UNIT, SearchArea, Found)							--search for parked aircraft
		
		if AttackCounter[Target.x .. Target.y] then												--counter with number of flights that have already attacked this target
			AttackCounter[Target.x .. Target.y] = AttackCounter[Target.x .. Target.y] + 1		--increase counter by one
		else																					--no flight has attacked this target yet
			AttackCounter[Target.x .. Target.y] = 1												--set to one
		end
		AttackN = AttackCounter[Target.x .. Target.y]
	end
	
	
	----- weapon types -----																	--weapon types can either be given as numbers (DCS codes), strings as convenient helpers (are converted to actual numbers below) or arrays of numbers (if multiple weapon types shall be used)
	if WeaponType == nil or WeaponType == "Auto" then
		WeaponType = 1073741822																	--DCS code for auto
	elseif WeaponType == "Cannon" then
		WeaponType = 805306368																	--DCS code for cannon
	elseif WeaponType == "Rockets" then
		WeaponType = 30720																		--DCS code for unguided rockets		
	elseif WeaponType == "Bombs" then
		WeaponType = 2032																		--DCS code for unguided bombs
	elseif WeaponType == "Guided bombs" then
		WeaponType = 14																			--DCS code for guided bombs
	elseif WeaponType == "ASM" then
		WeaponType = 4161536																	--DCS code for guided missiles
	end
			
	if type(WeaponType) == "number" then														--there is only a single weapon type
		WeaponType = {WeaponType}																--turn weapon type into an array
	end
	
	
	----- egress direction -----
	local EgressAngle																			--angle between attack axis and egress direction (positive to the right, negative to the left)
	local EgressVec2 = {																		--vector from target to egress waypoint
		x = route[EgressWpN].x - TargetList[1].x,												--use first element of target list so that egress vector is the same for all wingmen
		y = route[EgressWpN].y - TargetList[1].y,
	}
	local d_Tgt_Egress = math.sqrt(math.pow(EgressVec2.x, 2) + math.pow(EgressVec2.y, 2))		--distance from target to egress waypoint
	EgressVec2.x = EgressVec2.x / d_Tgt_Egress													--normalize vector
	EgressVec2.y = EgressVec2.y / d_Tgt_Egress													--normalize vector
	
	if PopAlt and PopAlt > 0 then																--if attack profile includes a pop-up, get ingress-egress direction to make egress turn
		local IngressVec2 = {																	--vector from attack waypoint to target
			x = TargetList[1].x - route[AttackWpN].x,											--use first element of target list so that ingress vector is the same for all wingmen
			y = TargetList[1].y - route[AttackWpN].y,
		}
		EgressAngle = math.deg(math.atan2(EgressVec2.y, EgressVec2.x) - math.atan2(IngressVec2.y, IngressVec2.x))
		if EgressAngle < -180 then
			EgressAngle = EgressAngle + 360
		elseif EgressAngle > 180 then
			EgressAngle = EgressAngle - 360
		end
	end
	
	
	----- assign target to wingman -----
	if #TargetList > 0 then																		--there is at least one target in target list
		for w = 1, #wingman do																	--iterate through wingmen
			local TgtN = 1 + math.ceil((w - 1) * (#TargetList / #wingman))						--distribute target numbers across flight
			TgtN = TgtN + AttackN - 1															--increase target number to adjust for previous attacks
			while TgtN > #TargetList do
				TgtN = TgtN - #TargetList
			end
			
			----- calculate the geometry of the pop-up maneuver -----
			local AoA																			--AoA of aircraft 
			local Abort = {}																	--table to collect if a flight member is aborting attack
			local PopDist																		--distance from target to Pop-Up point (only needed for pop-up)
			local TgtToAcDist																	--distance from target to aircraft (only needed for pop-up)
			local PopPoint																		--start of pop-up maneuver (only needed for pop-up)
			local ClimbGroundDist																--ground distance covered in climb (only needed for pop-up)
			local ClimbEndPoint																	--end of the pop-up climb (only needed for offset turn)
			local OffsetSide = 0																--side of the offset turn (only needed for offset turn)
			local RollInAngle																	--angle to turn into the target at the top of the pop-up (only needed for offset turn)
			local TgtElev = land.getHeight(TargetList[TgtN])									--target ground elevation
				
			if PopAlt and PopAlt > 0 then														--attack profile has a pop-up element
			
				if OffsetAngle == nil then														--attack profile has no offset
					OffsetAngle = 0																--set angle zero to enable pop-up calculations
				end
				
				--AoA is required later because climb angle needs to be corrected for AoA (climb task is based on pitch)
				local VecNose = wingman[w]:getPosition().x										--vector the aircraft is pointed at
				local FlightPath = wingman[w]:getVelocity()										--get current direction of travel
				local speed = math.sqrt(math.pow(FlightPath.x, 2) + math.pow(FlightPath.y, 2) + math.pow(FlightPath.z, 2))	--get airspeed
				local VerticalSpeedNorm = FlightPath.y / speed									--normalize the vertical component of the flight path
				AoA = math.deg(math.asin(VecNose.y - VerticalSpeedNorm))						--calculate AoA based on difference between the vertical components of the nose vector and flight path
				if AoA < 0 then																	--if the AoA is smaller than zero the aircraft is probably maneuvering at the moment
					AoA = 3																		--set it to an average of 3°
				elseif AoA > 6 then																--if the AoA is bigger than 6 the aircraft is probably maneuvering at the moment
					AoA = 3																		--set it to an average of 3°
				end
				
				--create time on target interval for wingmen
				if OffsetAngle > 0 then																	--attack profile as an offset turn element
					if w > 1 then																		--for any wingman
						OffsetAngle = OffsetAngle + 3													--increase offset angle by 3° from previous aircraft
						ClimbAngle = ClimbAngle - 3														--decrease climb angle by 3° from previous aircraft (min climb angle is hard limited to 15° later)
						if WeaponType[1] ~= 4161536 then												--for weapons other than guided missiles increase pop-altitude (guided missiles have standoff and are less sensitive for TOT deconfliction)
							PopAlt = PopAlt + 166														--increase pop-up altitude by 166m (500 ft) from previous aircraft
						end
					end
				end
				
				--dive
				local AttackDist = AttackDist															--make a local copy of attack distance
				if AttackDist == nil then																--if no specific attack distance is forced, then the shortest possible is calculated based on weapon type
					if WeaponType[1] == 30720 then														--when attacking with rockets
						AttackDist = 6000																--generic value that seems to work well for most rocket types
					else																				--when attacking with anything else (primary measure shall be bombing)
						AttackDist = 5900 + 1827 * math.log((PopAlt - 1000) / 500 + 1)					--formula tries to match empirical data for minimum dive bomb attack distance based on altitude at 1000 kph (formula not perfect but close enough)
						AttackDist = AttackDist * math.pow(1.04, (AttackSpeed * 3.6 - 1000) / 100)		--correct attack distance for speed (baseline at 1000 kph, distance increases by 4% for each additional 100 kph)
						if AttackDist < 5000 then														--make sure it is at least 5000m
							AttackDist = 5000
						end
					end
				end
				
				--offset side
				if OffsetAngle > 0 then																	--attack profile as an offset turn element
					if EgressAngle >= 45 and EgressAngle <= 135 then									--egress to the right
						OffsetSide = 0																	--0 == left side
					elseif EgressAngle <= -45 and EgressAngle >= -135 then								--egress to the left
						OffsetSide = 1																	--1 == right side
					else																				--egress forward or back
						local function ReturnSide(ac1, ac2)												--function to return on which side ac2 is in relation to ac1's nose
							local ac1pos = ac1:getPosition()											--get position of aircraft 1
							local Vec3Ac1Ac2 = {														--vector from aircraft 1 to aircraft 2
								x = ac2:getPoint().x - ac1pos.p.x,
								z = ac2:getPoint().z - ac1pos.p.z
							}
							local angle = math.deg(math.atan2(Vec3Ac1Ac2.z, Vec3Ac1Ac2.x) - math.atan2(ac1pos.x.z, ac1pos.x.x))	--angle between aircraft 1's nose and vector to aircraft 2
							if angle < -180 then
								angle = angle + 360
							elseif angle > 180 then
								angle = angle - 360
							end
							if angle > 0 then															--aircraft 2 is on the right side of aircraft 1
								return 1
							else																		--aircraft 2 is on the left side of aircraft 1
								return 0
							end
						end
					
						if #wingman == 1 then															--single ship flight
							if EgressAngle < 0 then
								OffsetSide = 1															
							else
								OffsetSide = 0															
							end
						elseif #wingman == 2 then														--two ship flight
							if w == 1 then
								OffsetSide = ReturnSide(wingman[2], wingman[w])
							elseif w == 2 then
								OffsetSide = ReturnSide(wingman[1], wingman[w])
							end
						elseif #wingman == 3 then														--three ship flight
							if w == 1 then
								OffsetSide = ReturnSide(wingman[3], wingman[w])
							elseif w == 2 then
								OffsetSide = ReturnSide(wingman[3], wingman[w])
							elseif w == 3 then
								OffsetSide = ReturnSide(wingman[1], wingman[w])
							end
						elseif #wingman == 4 then														--four ship flight
							if w == 1 then
								OffsetSide = ReturnSide(wingman[4], wingman[w])
							elseif w == 2 then
								OffsetSide = ReturnSide(wingman[4], wingman[w])
							elseif w == 3 then
								OffsetSide = ReturnSide(wingman[1], wingman[w])
							elseif w == 4 then
								OffsetSide = ReturnSide(wingman[1], wingman[w])
							end
						end
					end
				end
				
				--offset turn
				local d_OffsetTurnStart_OffsetTurnEnd = math.sin(math.rad(OffsetAngle / 2)) * TurnRadius * 2													--distance from offset turn start to offset turn end point
				local d_OffsetTurnStart_OffsetTurnCorner = (d_OffsetTurnStart_OffsetTurnEnd / 2) / math.sin(math.rad((180 - OffsetAngle) / 2))					--distance from offset turn start to the offset turn corner (the turn cuts this corner)
				d_OffsetTurnStart_OffsetTurnCorner = d_OffsetTurnStart_OffsetTurnCorner + 2 * AttackSpeed														--add two seconds worth of distance covered during rolling in/out of the turn
				
				--climb altitude initial assumtion
				local ClimbStartMSL = route[AttackWpN].alt													--alt MSL where pop-up maneuver starts
				if route[AttackWpN].alt_type == "RADIO" then												--if the waypoint alt is AGL
					ClimbStartMSL = land.getHeight(route[AttackWpN]) + route[AttackWpN].alt					--ground elevation plus alt AGL
				end
				local DeltaClimbH = TgtElev + PopAlt - ClimbStartMSL										--height to climb to reach pop-up altitute above target (initial assumption altitude at pop-up point is the same as at attack waypoint)
				
				--attack geometry calculation loop
				for n = 1, 10 do																			--attack geometry calculation loop (mulitple rounds to update for elevation differences between pop-up point and target, but stop after 10 rounds)
					if Debug then
						trigger.action.outText(wingman[w]:getName() .. " Geometry Calculation Loop " .. n, 99)
					end
					
					--climb ground distance
					if ClimbAngle < 15 then																	--minimum climb angle for aerobatics task is 15°
						ClimbAngle = 15
					end
					local ClimbTurnG = 1.5																	--pull into climb at 2.5G means 1.5G goes into generating the turn radius
					local ClimbTurnRadius = math.pow(AttackSpeed, 2) / (ClimbTurnG * 9.81)					--calculate turn radius based on G pulled
					local ClimbTurnGroundDist = math.sin(math.rad(ClimbAngle)) * ClimbTurnRadius			--ground distance covered when pulling up into the climb
					local ClimbTurnAlt = ClimbTurnRadius - math.sqrt(math.pow(ClimbTurnRadius, 2) - math.pow(ClimbTurnGroundDist, 2))	--altitude change when pulling into the climb
					ClimbGroundDist = (DeltaClimbH - 2 * ClimbTurnAlt)  / math.tan(math.rad(ClimbAngle))	--ground distance covered during straight part of the climb
					ClimbGroundDist = ClimbGroundDist + ClimbTurnGroundDist * 2								--add ground distance covered during the pull up/down
					
					--confusing as hell without the drawing
					local d_OffsetTurnCorner_ClimbEnd = ClimbGroundDist + d_OffsetTurnStart_OffsetTurnCorner														--distance from offset turn corner to climb end point
					local d_OffsetTurnCorner_RollInTurnPivot = math.sqrt(math.pow(d_OffsetTurnCorner_ClimbEnd, 2) + math.pow(TurnRadius, 2))						--distance from offset turn corner to roll-in turn pivot point
					local a_OffsetTurnCorner_ClimbEnd_OffsetTurnCorner_RollInTurnPivot = math.deg(math.atan(TurnRadius / d_OffsetTurnCorner_ClimbEnd))				--angle between line "offset turn corner to climb end" and line "offset turn corner to roll-in turn pivot"
					local a_OffsetTurnCorner_RollInTurnPivot_OffsetTurnCorner_Target = OffsetAngle - a_OffsetTurnCorner_ClimbEnd_OffsetTurnCorner_RollInTurnPivot	--angle between line "offset turn corner to roll-in turn pivot" and line "offset turn corner to target"
					local d_Target_RollInTurnPivot = math.sqrt(math.pow(AttackDist, 2) + math.pow(TurnRadius, 2))													--distance from target to roll-in turn pivot point
					local a_Target_OffsetTurnCorner_Target_RollInTurnPivot = math.deg(math.asin(d_OffsetTurnCorner_RollInTurnPivot / (d_Target_RollInTurnPivot / math.sin(math.rad(a_OffsetTurnCorner_RollInTurnPivot_OffsetTurnCorner_Target)))))		--angle between line "target to offset turn corner" and line "target to roll-in turn pivot"
					local a_Target_RollInTurnPivot_Target_RollInTurnEnd = math.deg(math.asin(TurnRadius / d_Target_RollInTurnPivot))								--angle between line "target to roll-in turn pivot" and line "target to roll-in turn end"
					local a_RollInTurnPivot_OffsetTurnCorner_RollInTurnPivot_Target = 180 - a_OffsetTurnCorner_RollInTurnPivot_OffsetTurnCorner_Target - a_Target_OffsetTurnCorner_Target_RollInTurnPivot												--angle between line "roll-in turn pivot to offset turn corner" and line "roll-in turn pivot to target"
					local d_Target_OffsetTurnCorner = d_Target_RollInTurnPivot / math.sin(math.rad(a_OffsetTurnCorner_RollInTurnPivot_OffsetTurnCorner_Target)) * math.sin(math.rad(a_RollInTurnPivot_OffsetTurnCorner_RollInTurnPivot_Target))			--distance form target to offset turn corner
					
					--roll-in turn
					RollInAngle = OffsetAngle + a_Target_OffsetTurnCorner_Target_RollInTurnPivot + a_Target_RollInTurnPivot_Target_RollInTurnEnd					--angle to turn into the target at the top of the pop-up
					
					--point to start pop-up maneuver
					local VectorTgtToAc = {																	--vector from target to aircraft
						x = wingman[w]:getPoint().x - TargetList[TgtN].x,
						y = wingman[w]:getPoint().z - TargetList[TgtN].y,
					}
					TgtToAcDist = math.sqrt(math.pow(VectorTgtToAc.x, 2) + math.pow(VectorTgtToAc.y, 2))	--lenght of vector (distance from target to aircraft)
					if OffsetAngle > 0 then																	--attack profile has an offset turn element
						PopDist = d_Target_OffsetTurnCorner + d_OffsetTurnStart_OffsetTurnCorner			--distance from target to Pop-Up point (start of the offset turn)
						PopDist = PopDist + 100																--add 100m for reaction delay to initiate the turn
					elseif AttackDist and AttackDist + ClimbGroundDist < TgtToAcDist then 					--attack profile is directly towards target, attack distance is defined pop-up point will be ahead of aircraft
						PopDist = AttackDist + ClimbGroundDist												--start pop-up at the attack distance plus distance required to climb
					else																					--attack profile is directly towards target with no attack distance defined or not enough distance to target	
						PopDist = TgtToAcDist																--pop-up directly from where the aircraft is now
					end
					PopPoint = {																			--define the position for the start of the offset pop-up maneuver
						x = TargetList[TgtN].x + VectorTgtToAc.x / TgtToAcDist * PopDist,
						y = TargetList[TgtN].y + VectorTgtToAc.y / TgtToAcDist * PopDist,
					}
					local VecAcTgtNorm = {
						x = VectorTgtToAc.x / TgtToAcDist * -1,
						y = VectorTgtToAc.y / TgtToAcDist * -1,
					}
					ClimbEndPoint = {																		--calculate the position of the end of the pop-up climb going from pop-up point forward
						x = PopPoint.x + VecAcTgtNorm.x * d_OffsetTurnStart_OffsetTurnCorner + (VecAcTgtNorm.x * math.cos(math.rad(OffsetAngle * (OffsetSide * 2 - 1))) - VecAcTgtNorm.y * math.sin(math.rad(OffsetAngle * (OffsetSide * 2 - 1)))) * (d_OffsetTurnStart_OffsetTurnCorner + ClimbGroundDist),
						y = PopPoint.y + VecAcTgtNorm.y * d_OffsetTurnStart_OffsetTurnCorner + (VecAcTgtNorm.x * math.sin(math.rad(OffsetAngle * (OffsetSide * 2 - 1))) + VecAcTgtNorm.y * math.cos(math.rad(OffsetAngle * (OffsetSide * 2 - 1)))) * (d_OffsetTurnStart_OffsetTurnCorner + ClimbGroundDist),
					}
					
					--check if ground elevation of the pop-up point works for this attack geometry
					if route[AttackWpN].alt_type == "RADIO" then											--aircraft approaches the pop-up point at AGL alt
						if land.getHeight(PopPoint) + route[AttackWpN].alt + DeltaClimbH - PopAlt < TgtElev + 30 and land.getHeight(PopPoint) + route[AttackWpN].alt + DeltaClimbH - PopAlt > TgtElev - 30 then	--current assumtion about height to climb leads to within 30m of target elevation
							break																			--all ok, stop attack geometry calculation loop
						else																				--current assumtion about height to climb does not lead to within 100m of target elevation
							DeltaClimbH = TgtElev + PopAlt - route[AttackWpN].alt - land.getHeight(PopPoint)	--calculate new height to climb and continue attack geometry calculation loop
						end
					else																					--aircraft approaches the pop-up point at MSL alt
						if route[AttackWpN].alt >= land.getHeight(PopPoint) + 30 then						--aircraft will be at pop-up point at least 30m above ground level
							break																			--all ok, stop attack geometry calculation loop
						else																				--aircraft will be too low at pop-up point
							DeltaClimbH = TgtElev + PopAlt - land.getHeight(PopPoint) + 30					--calculate new height to climb and continue attack geometry calculation loop
						end
					end
				end
				
				--abort offset-pop up attack if not sufficient distance from target
				if OffsetAngle > 0 and PopDist > TgtToAcDist then											--there is not sufficient distance from target to perfom the offset pop-up maneuver
					if w == 1 then																			--for flight leader
						Abort[w] = true																		--abort attack and go to egress
					else																					--for wingmen
						if Abort[1] then																	--leader is aborting
							break																			--don't do anything and stay with leader
						else																				--leader is not aborting
							Abort[w] = true																	--wingman abort attack and go to egress independently
						end
					end
					trigger.action.outText(wingman[w]:getName() .. " too close to target to perform Offset Pop-Up Attack. Abort attack and egress.", 10)
				end

				if Debug then
					trigger.action.markToAll(w * 10 + 1, wingman[w]:getName() .. "\nStart Offset Turn", {x = PopPoint.x, y = 0, z = PopPoint.y})
					trigger.action.markToAll(w * 10 + 2, wingman[w]:getName() .. "\nEnd Climb", {x = ClimbEndPoint.x, y = 0, z = ClimbEndPoint.y})
					
					trigger.action.outText("Offset Angle: " .. OffsetAngle, 99)
					trigger.action.outText("Climb Angle: " .. ClimbAngle, 99)
					trigger.action.outText("Roll-In Angle: " .. RollInAngle, 99)
					trigger.action.outText("Offset Turn Radius: " .. TurnRadius, 99)
					trigger.action.outText("Offset Turn To Corner Distance: " .. d_OffsetTurnStart_OffsetTurnCorner, 99)
					trigger.action.outText("Pop-Up Distance: " .. PopDist, 99)
					trigger.action.outText("Climb Distance: " .. ClimbGroundDist, 99)
					trigger.action.outText("Dive Distance: " .. AttackDist, 99)
				end
			end
			
			----- prepare and set all tasks for pop-up, attack, egress and route resume -----
			local ComboTask = {
				["id"] = "ComboTask",
				["params"] = {
					["tasks"] = {}
				}
			}
			
			if Abort[w] == nil then																			--attack should not be aborted
				if PopAlt and PopAlt > 0 then																--attack profile has a pop-up element
					local FlyToPopTask = {																	--fly to pop-up point
						id = 'Mission',
						params = {
							airborne = true,
							route = {
								points = {
									[1] = {
										["type"] = "Turning Point",
										["action"] = "Fly Over Point",
										["x"] = PopPoint.x,
										["y"] = PopPoint.y,
										["alt"] = route[AttackWpN].alt,
										["alt_type"] = route[AttackWpN].alt_type,
										["speed"] = AttackSpeed,
									},
								}
							}
						}
					}
					table.insert(ComboTask.params.tasks, FlyToPopTask)
					
					if OffsetAngle > 0 then																	--attack profile has an offset element
						local OffsetTurnTask = {															--aerobatics task for offset turn
							["id"] = "ControlledTask",
							["params"] = {
								["task"] = {
									["id"] = "Aerobatics",
									["params"] = {
										["maneuversSequency"] = {
											[1] = {
												["name"] = "TURN",
												["params"] = {
													["RepeatQty"] = {
														["order"] = 1,
														["value"] = 1,
														["min_v"] = 1,
														["max_v"] = 10,
													},
													["InitAltitude"] = {
														["order"] = 2,
														["value"] = 0,
													},
													["InitSpeed"] = {
														["order"] = 3,
														["value"] = 0,
													},
													["UseSmoke"] = {
														["order"] = 4,
														["value"] = 0,
													},
													["StartImmediatly"] = {
														["order"] = 5,
														["value"] = 1,										--start imediately (ignore InitAltitude and InitSpeed)
													},
													["Ny_req"] = {
														["order"] = 6,
														["value"] = G,										--amount of G to pull
													},
													["ROLL"] = {
														["order"] = 7,
														["value"] = 70.528779365509,						--roll angle in turn (this is a function of G)
													},
													["SECTOR"] = {
														["order"] = 8,
														["value"] = OffsetAngle,							--angle to turn
													},
													["SIDE"] = {
														["order"] = 9,
														["value"] = OffsetSide,								--0 == left, 1 == right side
													},
												},
											},
										},
									},
								},
								["stopCondition"] = {
									["condition"] = 'if MatchHeading("' .. wingman[w]:getName() .. '", {x = ' .. ClimbEndPoint.x .. ', y = ' .. ClimbEndPoint.y .. '}) then return true end',		--AI will always overshoot turns, therefore the task must be stopped prematurely via stop condition when the desired heading is reached
								},
							},
						}
						table.insert(ComboTask.params.tasks, OffsetTurnTask)
						
						local FlyStraighTask = {															--aerobatics task to fly straight for 2 seconds helps to quicker level out from the turn
							["id"] = "Aerobatics",
							["params"] = {
								["maneuversSequency"] = {
									[1] = {
										["name"] = "STRAIGHT_FLIGHT",
										["params"] = {
											["RepeatQty"] = {
												["min_v"] = 1,
												["max_v"] = 10,
												["value"] = 1,
												["order"] = 1,
											},
											["InitAltitude"] = {
												["order"] = 2,
												["value"] = 0,
											},
											["InitSpeed"] = {
												["order"] = 3,
												["value"] = 0,
											},
											["UseSmoke"] = {
												["order"] = 4,
												["value"] = 0,
											},
											["StartImmediatly"] = {
												["order"] = 5,
												["value"] = 1,
											},
											["FlightTime"] = {
												["min_v"] = 1,
												["max_v"] = 200,
												["value"] = 2,
												["step"] = 0.1,
												["order"] = 6,
											},
						
										},
									}, 
								},
							},
						}
						table.insert(ComboTask.params.tasks, FlyStraighTask)
					
					end
					
					local ClimbTask = {																		--aerobatics task for pop-up climb
						["id"] = "Aerobatics",
						["params"] = {
							["maneuversSequency"] = {
								[1] = {
									["name"] = "CLIMB",
									["params"] = {
										["RepeatQty"] = {
											["order"] = 1,
											["value"] = 1,
											["min_v"] = 1,
											["max_v"] = 10,
										},
										["InitAltitude"] = {
											["order"] = 2,
											["value"] = 0,
										},
										["InitSpeed"] = {
											["order"] = 3,
											["value"] = 0,
										},
										["UseSmoke"] = {
											["order"] = 4,
											["value"] = 0,
										},
										["StartImmediatly"] = {
											["order"] = 5,
											["value"] = 1,													--start imediately (ignore InitAltitude and InitSpeed)
										},
										["Angle"] = {
											["order"] = 6,
											["value"] = ClimbAngle + AoA,									--climb angle needs to be corrected with AoA (the value set here is the pitch value, not the flight path)
											["min_v"] = 15,
											["max_v"] = 90,
											["step"] = 5,
										},
										["FinalAltitude"] = {
											["order"] = 7,
											["value"] = TgtElev + PopAlt,									--alt to climb to
										},
									},
								},
							},
						},
					}
					table.insert(ComboTask.params.tasks, ClimbTask)
					
					if OffsetAngle > 0 then																	--attack profile has an offset element
						local RollInTurnTask = {															--aerobatics task for roll-in turn
							["id"] = "ControlledTask",
							["params"] = {
								["task"] = {
									["id"] = "Aerobatics",
									["params"] = {
										["maneuversSequency"] = {
											[1] = {
												["name"] = "TURN",
												["params"] = {
													["RepeatQty"] = {
														["order"] = 1,
														["value"] = 1,
														["min_v"] = 1,
														["max_v"] = 10,
													},
													["InitAltitude"] = {
														["order"] = 2,
														["value"] = 0,
													},
													["InitSpeed"] = {
														["order"] = 3,
														["value"] = 0,
													},
													["UseSmoke"] = {
														["order"] = 4,
														["value"] = 0,
													},
													["StartImmediatly"] = {
														["order"] = 5,
														["value"] = 1,										--start imediately (ignore InitAltitude and InitSpeed)
													},
													["Ny_req"] = {
														["order"] = 6,
														["value"] = G,										--amount of G to pull
													},
													["ROLL"] = {
														["order"] = 7,
														["value"] = 70.528779365509,						--roll angle in turn (this is a function of G)
													},
													["SECTOR"] = {
														["order"] = 8,
														["value"] = RollInAngle,							--angle to turn
													},
													["SIDE"] = {
														["order"] = 9,
														["value"] = OffsetSide * -1 + 1,					--0 == left, 1 == right side
													},
												},
											},
										},
									},
								},
								["stopCondition"] = {
									["condition"] = 'if MatchHeading("' .. wingman[w]:getName() .. '", {x = ' .. TargetList[TgtN].x .. ', y = ' .. TargetList[TgtN].y .. '}) then return true end',		--AI will always overshoot turns, therefore the task must be stopped prematurely via stop condition when the desired heading is reached
								},
							},
						}
						table.insert(ComboTask.params.tasks, RollInTurnTask)
						
						local FlyStraighTask = {															--aerobatics task to fly straight for 1 seconds helps to quicker level out from the turn
							["id"] = "Aerobatics",
							["params"] = {
								["maneuversSequency"] = {
									[1] = {
										["name"] = "STRAIGHT_FLIGHT",
										["params"] = {
											["RepeatQty"] = {
												["min_v"] = 1,
												["max_v"] = 10,
												["value"] = 1,
												["order"] = 1,
											},
											["InitAltitude"] = {
												["order"] = 2,
												["value"] = 0,
											},
											["InitSpeed"] = {
												["order"] = 3,
												["value"] = 0,
											},
											["UseSmoke"] = {
												["order"] = 4,
												["value"] = 0,
											},
											["StartImmediatly"] = {
												["order"] = 5,
												["value"] = 1,
											},
											["FlightTime"] = {
												["min_v"] = 1,
												["max_v"] = 200,
												["value"] = 1,
												["step"] = 0.1,
												["order"] = 6,
											},
										},
									}, 
								},
							},
						}
						table.insert(ComboTask.params.tasks, FlyStraighTask)
					end
					
					local EmptyTask = {																		--it seems to be necessary to have a task between the aerobatics task and the bombing task for the bombing to work. This empty command task fulfills this
						["id"] = "WrappedAction",
						["params"] = {
							["action"] = {
								["id"] = "Script",
								["params"] = {
									["command"] = "",
								},
							},
						},
					}
					table.insert(ComboTask.params.tasks, EmptyTask)
				end
				
				--attack task
				for n = 1, #WeaponType do																			--make an attack task variant for each wapon type
					for t = 1, #TargetList do															
						if t == 1 or Reattack then																	--make an attack task variant for the first target or for each target element if re-attack is enabled
							local TgtNum = TgtN + t - 1																--make a modifier if target number (each target elements gets its own attack task, starting with TgtN)
							if TgtNum > #TargetList then
								TgtNum = TgtNum - #TargetList
							end
							
							local AttackTask = {																	--define generic attack task (to be completed below based on target type)
								["params"] = {
									["groupAttack"] = true,
									["attackQty"] = 1,
									["expend"] = ExpendQty,
									["weaponType"] = WeaponType[n],
									["altitudeEnabled"] = false,
									["altitude"] = route[AttackWpN].alt,
									["directionEnabled"] = false,
									["direction"] = 0,
								},
							}
							
							if Dive then																			--if argument dive is true
								AttackTask.params.attackType = "Dive"												--set attack type to dive
							end
							
							if TargetType == "unit" then															--target is a unit
								if ExpendQty == "Auto" then															--expend quantity Auto
									AttackTask.id = "AttackUnit"													--attack unit
									AttackTask.params.unitId = Group.getByName(Target):getUnits()[TgtNum]:getID()	--get unit id
								elseif Group.getByName(Target):getUnits()[TgtNum]:getVelocity().x ~= 0 or Group.getByName(Target):getUnits()[TgtNum]:getVelocity().z ~= 0 then		--target is moving
									AttackTask.id = "AttackUnit"													--attack unit
									AttackTask.params.unitId = Group.getByName(Target):getUnits()[TgtNum]:getID()	--get unit id
								elseif WeaponType[n] == 2032 or WeaponType[n] == 30720 then							--weapon type is unguided bomb or rocket
									AttackTask.id = "Bombing"														--attack coordinates (bombing task is better because it centers salvo on target instead of first round on target)
									AttackTask.params.x = TargetList[TgtNum].x
									AttackTask.params.y = TargetList[TgtNum].y
								else																				--for the remaining weapon types (guided or cannon)
									AttackTask.id = "AttackUnit"													--attack unit
									AttackTask.params.unitId = Group.getByName(Target):getUnits()[TgtNum]:getID()	--get unit id
								end
		
							elseif TargetType == "static" then														--target is a static unit
								if ExpendQty == "Auto" then															--expend quantity Auto
									AttackTask.id = "AttackUnit"													--attack unit
									AttackTask.params.unitId = StaticObject.getByName(Target[TgtNum]):getID()		--get unit id
								elseif WeaponType[n] == 2032 or WeaponType[n] == 30720 then							--weapon type is unguided bomb or rocket
									AttackTask.id = "Bombing"														--attack coordinates (bombing task is better because it centers salvo on target instead of first round on target)
									AttackTask.params.x = TargetList[TgtNum].x
									AttackTask.params.y = TargetList[TgtNum].y
								else																				--for the remaining weapon types (guided or cannon)
									AttackTask.id = "AttackUnit"													--attack unit
									AttackTask.params.unitId = StaticObject.getByName(Target[TgtNum]):getID()		--get unit id
								end
								
							else																					--scenery and airbase target
								AttackTask.id = "Bombing"															--attack coordinates
								AttackTask.params.x = TargetList[TgtNum].x
								AttackTask.params.y = TargetList[TgtNum].y
							end
							
							if AttackTask.id == "AttackUnit" and Reattack then										--for unit targets, allow for re-attacks on undestroyed targets
								AttackTask.params.attackQtyLimit = false
							else																					--for all fixed expend quantities, do not allow re-attacks on undestroyed targets
								AttackTask.params.attackQtyLimit = true
							end
							
							if PopAlt == nil or PopAlt == 0 or Dive ~= true then									--if no pop-up altitude is set or no dive
								AttackTask.params.altitudeEnabled = true											--enable attack altitude setting (altitude of attack waypoint)
							end
							
							table.insert(ComboTask.params.tasks, AttackTask)										--insert attack task
						end
					end
				end
			
				--post-weapon release maneuvers
				if PopAlt and PopAlt > 0 and Reattack ~= true then													--only do post-release maneuvering for pop-up attacks and if re-attack is turned off (unknown attack direction from subsequent attacks)
					
					--egress turn
					local EgressSide
					local EgressTurnAngle
					if OffsetAngle > 0 then																			--attack profile has an offset element
						if (EgressAngle < 0 and OffsetSide == 0) or (EgressAngle > 0 and OffsetSide == 1) then		--offset is on the side of the egress
							EgressTurnAngle = math.abs(math.abs(EgressAngle) + (180 - OffsetAngle - (180 - RollInAngle)))	--angle between attack run and egress
							EgressSide = OffsetSide
						else																						--offset is on the opposing side of the egress
							EgressTurnAngle = math.abs(math.abs(EgressAngle) - (180 - OffsetAngle - (180 - RollInAngle)))	--angle between attack run and egress
							if math.abs(EgressAngle) > (180 - OffsetAngle - (180 - RollInAngle)) then
								EgressSide = OffsetSide * -1 + 1
							else
								EgressSide = OffsetSide
							end														
						end
						if EgressTurnAngle > 180 then
							EgressTurnAngle = math.abs(EgressTurnAngle - 360)
							EgressSide = EgressSide * -1 + 1
						end
					else																							--attack with no offset
						EgressTurnAngle = math.abs(EgressAngle)														--egress turn angle is positive angle between attack direction and egress direction
						if EgressAngle < 0 then
							EgressSide = 0
						else
							EgressSide = 1
						end
					end
					
					local EgressTurnTask = {																		--aerobatics task for turn
						["id"] = "ControlledTask",
						["params"] = {
							["task"] = {
								["id"] = "Aerobatics",
								["params"] = {
									["maneuversSequency"] = {
										[1] = {
											["name"] = "TURN",
											["params"] = {
												["RepeatQty"] = {
													["order"] = 1,
													["value"] = 1,
													["min_v"] = 1,
													["max_v"] = 10,
												},
												["InitAltitude"] = {
													["order"] = 2,
													["value"] = 0,
												},
												["InitSpeed"] = {
													["order"] = 3,
													["value"] = 0,
												},
												["UseSmoke"] = {
													["order"] = 4,
													["value"] = 0,
												},
												["StartImmediatly"] = {
													["order"] = 5,
													["value"] = 1,													--start imediately (ignore InitAltitude and InitSpeed)
												},
												["Ny_req"] = {
													["order"] = 6,
													["value"] = 5,													--pull 5 G for the egress turn
												},
												["ROLL"] = {
													["order"] = 7,
													["value"] = 78,													--roll angle in turn (this is a function of G)
												},
												["SECTOR"] = {
													["order"] = 8,
													["value"] = EgressTurnAngle,									--angle to turn
												},
												["SIDE"] = {
													["order"] = 9,
													["value"] = EgressSide,											--0 == left, 1 == right side
												},
											},
										},
									},
								},
							},
							["stopCondition"] = {
								["condition"] = 'if MatchHeading("' .. wingman[w]:getName() .. '", {x = ' .. route[EgressWpN].x .. ', y = ' .. route[EgressWpN].y .. '}) then return true end',		--AI will always overshoot turns, therefore the task must be stopped prematurely via stop condition when the desired heading is reached
							},
						},
					}
					table.insert(ComboTask.params.tasks, EgressTurnTask)
				end
			end
			
			--egress
			local EgressTask = {																					--define mission task to go to egress waypoint (copy the egress waypoint)
				id = 'Mission',
				params = {
					airborne = true,
					route = {
						points = {
							[1] = {
								["type"] = route[EgressWpN].type,
								["action"] = route[EgressWpN].action,
								["x"] = route[EgressWpN].x,
								["y"] = route[EgressWpN].y,
								["alt"] = route[EgressWpN].alt,
								["alt_type"] = route[EgressWpN].alt_type,
								["speed"] = route[EgressWpN].speed,
								["task"] = {
									["id"] = "ComboTask",
									["params"] = {
										["tasks"] = {
											[1] = {
												["id"] = "WrappedAction",
												["params"] = {
													["action"] = {
														["id"] = "Script",
														["params"] = {
															["command"] = 'timer.scheduleFunction(SetResumeMissionTask, "' .. wingman[w]:getName() .. '", timer.getTime() + 0.1)',		--execute function SetResumeMissionTask() to put group back onto mission route (function will only be executed for current group leader). Function needs to be scheduled, as setting new tasks within a task will crash DCS.
														},
													},
												},
											},
										},
									},
								},
							},
						},
					},
				},
			}
			if w == 1 and route[EgressWpN + 1] then																	--for leader and if a route waypoint exists after egress waypoint
				table.insert(EgressTask.params.route.points, route[EgressWpN + 1])									--add the waypoint after the egress waypoint (this ensures that leader will cut the corner correctly when reaching the egress waypoint)
			end
			
			--adjust egress waypoint for each wingman so that flight will not converge on the same position and collide
			if w == 2 then																							--wingman 2, move 200m left of leader
				EgressTask.params.route.points[1].x = EgressTask.params.route.points[1].x + EgressVec2.y * 200
				EgressTask.params.route.points[1].y = EgressTask.params.route.points[1].y + EgressVec2.x * 200 * -1
			elseif w == 3 then																						--wingman 3, move 600m right of wingman 2
				EgressTask.params.route.points[1].x = EgressTask.params.route.points[1].x + EgressVec2.y * 600 * -1
				EgressTask.params.route.points[1].y = EgressTask.params.route.points[1].y + EgressVec2.x * 600
			elseif w == 4 then																						--wingman 4, move 200m right of wingman 3
				EgressTask.params.route.points[1].x = EgressTask.params.route.points[1].x + EgressVec2.y * 200 * -1
				EgressTask.params.route.points[1].y = EgressTask.params.route.points[1].y + EgressVec2.x * 200
			end
			
			EgressTaskTable[wingman[w]:getName()] = EgressTask														--store the egress task (will be used by function SetEgressTask() when the aircraft has completed the attack)
			
			--resume route
			if w == 1 then																							--for group leader
				local ResumeRouteTask = {																			--define mission task for the remaining route from egress waypoint on
					id = 'Mission',
					params = {
						airborne = true,
						route = {
							points = {}
						}
					}
				}
				
				for r = EgressWpN, #route do																		--iterate through group route waypoints from egress waypoint on
					table.insert(ResumeRouteTask.params.route.points, route[r])										--insert waypoint into remaining route to be flown
				end
				
				local WingmanRejoinTask = {																			--when the group leader reaches the egress waypoint, this run script command should reset the individual tasks of all group wingmen so that they rejoin the flight
					["id"] = "WrappedAction",
					["params"] = {
						["action"] = {
							["id"] = "Script",
							["params"] = {
								["command"] = 'local wingman = Group.getByName("' .. FlightName .. '"):getUnits() for n = 2, #wingman do wingman[n]:getController():resetTask() end',
							},
						},
					},
				}
				table.insert(ResumeRouteTask.params.route.points[1].task.params.tasks, WingmanRejoinTask)			--insert wingman rejoin task into first waypoint of resume route (egress waypoint)
				
				EgressTaskTable[FlightName] = ResumeRouteTask														--store the resume route task (will be used by function SetEgressTask() when the aircraft has completed the attack)
			end
			
			--SetEgressTask
			local SetEgressTask = {																					--the egress task must be set by the function SetEgressTask() when the aircraft has completed the attack (current aircraft position at that time is required for calculations)
				["id"] = "WrappedAction",
				["params"] = {
					["action"] = {
						["id"] = "Script",
						["params"] = {
							["command"] = 'timer.scheduleFunction(SetEgressTask, "' .. wingman[w]:getName() .. '", timer.getTime() + 0.1)',		--function needs to be scheduled, as setting new tasks within a task will crash DCS
						},
					},
				},
			}
			table.insert(ComboTask.params.tasks, SetEgressTask)
			
			--set the completed ComboTask for each individual group member
			if w == 1 then
				wingman[w]:getGroup():getController():setTask(ComboTask)											--for the leader, the task has to be set on the group level
				wingman[w]:getGroup():getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, 2)				--evade fire
			else
				wingman[w]:getController():setTask(ComboTask)														--for the wingmen, the task has to be set on a unit level
				wingman[w]:getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, 2)						--tasked units do not inherit the options of their parent group, so reaction to threat has to be set to evade fire (otherwise they may abort the attack against defended targets)
			end
		end
	end
end


--function to return true when an aircraft points in target direction
function MatchHeading(AcName, Tgt)
	local Ac = Unit.getByName(AcName)																--get aircraft
	if Ac then																						--aircraft exists
		local AcPos = Ac:getPosition()
		local AcHeadingVec2 = {																		--aircraft heading as a normalized 2d vector
			x = AcPos.x.x,																			--x component of aircraft nose
			y = AcPos.x.z ,																			--y component of aircraft nose
		}
		local AcVel = Ac:getVelocity()
		local AcVelVec2 = {																			--aircraft velocity vector as a normalized 2d vector
			x = AcVel.x,																			--x component of aircraft flight path
			y = AcVel.z,																			--y component of aircraft flight path
		}
																					
		local TgtHeadingVec2																		--target heading as normalized 2d vector
		if type(Tgt) == "number" then																--the target is a specific heading
			TgtHeadingVec2 = {
				x = math.cos(math.rad(Tgt)),														--x component of target heading
				y = math.sin(math.rad(Tgt)),														--y component of target heading
			}
		else																						--the target heading is based on the heading towards a specific unit or point
			local TgtPos																			--target position
			if type(Tgt) == "string" then															--the target is a string, then it is the name of a target unit
				if Unit.getByName(Tgt) then															--target exists
					TgtPos = Unit.getByName(Tgt):getPoint()											--get target position
				else																				--target does not exist
					return false																	--do not continue
				end
			elseif type(Tgt) == "table"	then														--target is given as coordinates
				TgtPos = Tgt
				TgtPos.z = TgtPos.y																	--convert target position from 2d to 3d (so it has the same format as when the position is taken from a unit)
			else																					--no valid target is given
				return false																		--do not continue
			end
			
			TgtHeadingVec2 = {																								
				x = TgtPos.x - AcPos.p.x,															--x component of vector to target
				y = TgtPos.z - AcPos.p.z,															--y component of vector to target
			}
		end
		
		--to roll out at the target heading, turning needs to be stopped when aircraft velocity vector comes within margin of target heading
		local margin = math.deg(math.atan2(AcHeadingVec2.y, AcHeadingVec2.x) - math.atan2(AcVelVec2.y, AcVelVec2.x))			--angle between velocity vector and aircraft nose
		if margin < -180 then
			margin = margin + 360
		elseif margin > 180 then
			margin = margin - 360
		end
		margin = margin / 2
			
		local deltaHeading = math.deg(math.atan2(AcVelVec2.y, AcVelVec2.x) - math.atan2(TgtHeadingVec2.y, TgtHeadingVec2.x))	--difference between aircraft velocity vector and target heading
		if deltaHeading < -180 then
			deltaHeading = deltaHeading + 360
		elseif deltaHeading > 180 then
			deltaHeading = deltaHeading - 360
		end
		--trigger.action.outText(deltaHeading .. " / " .. margin, 3, true)
		if math.abs(deltaHeading) < math.abs(margin) then											--check if difference between aircraft heading and target heading is within margin (target heading is exactly half between aircraft heading and velocity vector)
			--trigger.action.outText("Stop Turn", 5)
			return true
		end
	end
end


--function to send aircraft to their egress waypoints (executed only after egress turn is completed to generate descend waypoint based on current aircraft postion)
EgressTaskTable = {}																				--table to store egress task that are generated inside AirGroundAttackTask() (global table because it needs to be accessed by waypoint action)
function SetEgressTask(AcName)																		--global because it needs to be accessed by waypoint action
	local Ac = Unit.getByName(AcName)																--get aircraft
	if Ac then																						--aircraft exists
		local EgressTask = EgressTaskTable[AcName]													--shortcut to the egress task that is prepared and stored in the EgressTaskTable
	
		local AcPoint = Ac:getPoint()																--get aircraft point
		local AcEgressVec2 = {																		--make a vector between aircraft and egress wayoint
			x = EgressTask.params.route.points[1].x - AcPoint.x,
			y = EgressTask.params.route.points[1].y - AcPoint.z,
		}
		local AcEgressDist = math.sqrt(math.pow(AcEgressVec2.x, 2) + math.pow(AcEgressVec2.y, 2))	--distance between aircraft and egress waypoint
		
		local DeltaAlt																				--altitude to descend
		if EgressTask.params.route.points[1].alt_type == "RADIO" then								--egress waypoint alt is AGL
			DeltaAlt = AcPoint.y - land.getHeight({x = AcPoint.x, y = AcPoint.z}) + EgressTask.params.route.points[1].alt	--altitude difference to AGL alt above current ground ground elevation
		else																						--egress waypoint alt is MSL
			DeltaAlt = AcPoint.y - EgressTask.params.route.points[1].alt							--altitude difference to MSL waypoint alt
		end
		
		local DescendDist = DeltaAlt / math.tan(math.rad(15))										--distance required to descend to egress alt at 15° descend angle
		
		if DescendDist > 0 and DescendDist < AcEgressDist then										--if distance to descend is positive (no climb) and shorter than the distance to egress waypoint, insert a descend waypoint
			local DescendWP = {																		--define the descend waypoint
				["x"] = AcPoint.x + AcEgressVec2.x / AcEgressDist * DescendDist,
				["y"] = AcPoint.z + AcEgressVec2.y / AcEgressDist * DescendDist,
				["type"] = "Turning Point",
				["action"] = "Fly Over Point",
				["alt"] = EgressTask.params.route.points[1].alt,
				["alt_type"] = EgressTask.params.route.points[1].alt_type,
				["speed"] = EgressTask.params.route.points[1].speed,
			}
			table.insert(EgressTask.params.route.points, 1, DescendWP)								--insert descend waypoint into egress task
		end
		
		--trigger.action.markToAll(1, "Descend WP", {x = EgressTask.params.route.points[1].x, y = 0, z = EgressTask.params.route.points[1].y})
		--trigger.action.markToAll(2, "Egress WP", {x = EgressTask.params.route.points[2].x, y = 0, z = EgressTask.params.route.points[2].y})
		
		if Ac == Ac:getGroup():getUnit(1)then														--aircraft is the group leader
			Ac:getGroup():getController():setTask(EgressTask)										--the task has to be set on the group level
			Ac:getGroup():getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, 2)			--evade fire
		else																						--aircraft is a group wingman
			Ac:getController():setTask(EgressTask)													--set on a unit level
			Ac:getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, 2)					--tasked units do not inherit the options of their parent group, so reaction to threat has to be set to evade fire (otherwise they may abort the attack against defended targets)
		end
	end
end


--function to resume group to its mission route
function SetResumeMissionTask(AcName)
	local Ac = Unit.getByName(AcName)																--get aircraft
	if Ac then																						--aircraft exists
		if Ac == Ac:getGroup():getUnit(1)then														--aircraft is the group leader
			local ResumeMissionTask = EgressTaskTable[Ac:getGroup():getName()]						--shortcut to the group resume mission task that is prepared and stored in the EgressTaskTable
			Ac:getGroup():getController():setTask(ResumeMissionTask)								--the task has to be set on the group level
			Ac:getGroup():getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, 2)			--evade fire
		end
	end
end