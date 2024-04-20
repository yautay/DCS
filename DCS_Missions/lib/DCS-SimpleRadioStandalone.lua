-- Version 2.1.0.2
-- Special thanks to Cap. Zeen, Tarres and Splash for all the help
-- with getting the radio information :)
-- Run the installer to correctly install this file
local SR = {}

SR.SEAT_INFO_PORT = 9087
SR.LOS_RECEIVE_PORT = 9086
SR.LOS_SEND_TO_PORT = 9085
SR.RADIO_SEND_TO_PORT = 9084


SR.LOS_HEIGHT_OFFSET = 20.0 -- sets the line of sight offset to simulate radio waves bending
SR.LOS_HEIGHT_OFFSET_MAX = 200.0 -- max amount of "bend"
SR.LOS_HEIGHT_OFFSET_STEP = 20.0 -- Interval to "bend" in

SR.unicast = true --DONT CHANGE THIS

SR.lastKnownPos = { x = 0, y = 0, z = 0 }
SR.lastKnownSeat = 0

SR.MIDS_FREQ = 1030.0 * 1000000 -- Start at UHF 300
SR.MIDS_FREQ_SEPARATION = 1.0 * 100000 -- 0.1 MHZ between MIDS channels

SR.logFile = io.open(lfs.writedir() .. [[Logs\DCS-SimpleRadioStandalone.log]], "w")
function SR.log(str)
    if SR.logFile then
        SR.logFile:write(str .. "\n")
        SR.logFile:flush()
    end
end

package.path = package.path .. ";.\\LuaSocket\\?.lua;"
package.cpath = package.cpath .. ";.\\LuaSocket\\?.dll;"

---- DCS Search Paths - So we can load Terrain!
local guiBindPath = './dxgui/bind/?.lua;' ..
        './dxgui/loader/?.lua;' ..
        './dxgui/skins/skinME/?.lua;' ..
        './dxgui/skins/common/?.lua;'

package.path = package.path .. ";"
        .. guiBindPath
        .. './MissionEditor/?.lua;'
        .. './MissionEditor/themes/main/?.lua;'
        .. './MissionEditor/modules/?.lua;'
        .. './Scripts/?.lua;'
        .. './LuaSocket/?.lua;'
        .. './Scripts/UI/?.lua;'
        .. './Scripts/UI/Multiplayer/?.lua;'
        .. './Scripts/DemoScenes/?.lua;'

local socket = require("socket")

local JSON = loadfile("Scripts\\JSON.lua")()
SR.JSON = JSON

SR.UDPSendSocket = socket.udp()
SR.UDPLosReceiveSocket = socket.udp()
SR.UDPSeatReceiveSocket = socket.udp()

--bind for listening for LOS info
SR.UDPLosReceiveSocket:setsockname("*", SR.LOS_RECEIVE_PORT)
SR.UDPLosReceiveSocket:settimeout(0) --receive timer was 0001

SR.UDPSeatReceiveSocket:setsockname("*", SR.SEAT_INFO_PORT)
SR.UDPSeatReceiveSocket:settimeout(0) 

local terrain = require('terrain')

if terrain ~= nil then
    SR.log("Loaded Terrain - SimpleRadio Standalone!")
end

-- Prev Export functions.
local _prevLuaExportActivityNextEvent = LuaExportActivityNextEvent
local _prevLuaExportBeforeNextFrame = LuaExportBeforeNextFrame

local _lastUnitId = "" -- used for a10c volume
local _lastUnitType = ""    -- used for F/A-18C ENT button
local _fa18ent = false      -- saves ENT button state (needs to be declared before LuaExportBeforeNextFrame)
local _tNextSRS = 0

SR.exporters = {}   -- exporter table. Initialized at the end

SR.fc3 = {}
SR.fc3["A-10A"] = true
SR.fc3["F-15C"] = true
SR.fc3["MiG-29A"] = true
SR.fc3["MiG-29S"] = true
SR.fc3["MiG-29G"] = true
SR.fc3["Su-27"] = true
SR.fc3["J-11A"] = true
SR.fc3["Su-33"] = true
SR.fc3["Su-25"] = true
SR.fc3["Su-25T"] = true

--[[ Reading special options.
   option: dot separated 'path' to your option under the plugins field,
   ie 'DCS-SRS.srsAutoLaunchEnabled', or 'SA342.HOT_MIC'
--]]
SR.specialOptions = {}
function SR.getSpecialOption(option)
    if not SR.specialOptions[option] then
        local options = require('optionsEditor')
        -- If the option doesn't exist, a nil value is returned.
        -- Memoize into a subtable to avoid entering that code again,
        -- since options.getOption ends up doing a disk access.
        SR.specialOptions[option] = { value = options.getOption('plugins.'..option) }
    end
    
    return SR.specialOptions[option].value
end

-- Function to load mods' SRS plugin script
function SR.LoadModsPlugins()
    local mode, errmsg

    -- Mod folder's path
    local modsPath = lfs.writedir() .. [[Mods\Aircraft]]
   
    mode, errmsg = lfs.attributes (modsPath, "mode")
   
    -- Check that Mod folder actually exists, if not then do nothing
    if mode == nil or mode ~= "directory" then
        return
    end

    -- Process each available Mod
    for modFolder in lfs.dir(modsPath) do
        modAutoloadPath = modsPath..[[\]]..modFolder..[[\SRS\autoload.lua]]

        -- If the Mod declares an SRS autoload file we process it
        mode, errmsg = lfs.attributes (modAutoloadPath, "mode")
        if mode ~= nil and mode == "file" then
            -- Try to load the Mod's script through a protected environment to avoid to invalidate SRS entirely if the script contains any error
            local status, error = pcall(function () loadfile(modAutoloadPath)().register(SR) end)
            
            if error then
                SR.log("Failed loading SRS Mod plugin due to an error in '"..modAutoloadPath.."'")
            else
                SR.log("Loaded SRS Mod plugin '"..modAutoloadPath.."'")
            end
        end
    end
end

function SR.exporter()
    local _update
    local _data = LoGetSelfData()

    -- REMOVE
 --   SR.log(SR.debugDump(_data).."\n\n")

    if _data ~= nil and not SR.fc3[_data.Name] then
        -- check for death / eject -- call below returns a number when ejected - ignore FC3
        local _device = GetDevice(0)

        if type(_device) == 'number' then
            _data = nil -- wipe out data - aircraft is gone really
        end
    end

    if _data ~= nil then

        _update = {
            name = "",
            unit = "",
            selected = 1,
            simultaneousTransmissionControl = 0,
            unitId = 0,
            ptt = false,
            capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" },
            radios = {
                -- Radio 1 is always Intercom
                { name = "", freq = 100, modulation = 3, volume = 1.0, secFreq = 0, freqMin = 1, freqMax = 1, encKey = 0, enc = false, encMode = 0, freqMode = 0, guardFreqMode = 0, volMode = 0, expansion = false, rtMode = 2 },
                { name = "", freq = 0, modulation = 3, volume = 1.0, secFreq = 0, freqMin = 1, freqMax = 1, encKey = 0, enc = false, encMode = 0, freqMode = 0, guardFreqMode = 0, volMode = 0, expansion = false, rtMode = 2 }, -- enc means encrypted
                { name = "", freq = 0, modulation = 3, volume = 1.0, secFreq = 0, freqMin = 1, freqMax = 1, encKey = 0, enc = false, encMode = 0, freqMode = 0, guardFreqMode = 0, volMode = 0, expansion = false, rtMode = 2 },
                { name = "", freq = 0, modulation = 3, volume = 1.0, secFreq = 0, freqMin = 1, freqMax = 1, encKey = 0, enc = false, encMode = 0, freqMode = 0, guardFreqMode = 0, volMode = 0, expansion = false, rtMode = 2 },
                { name = "", freq = 0, modulation = 3, volume = 1.0, secFreq = 0, freqMin = 1, freqMax = 1, encKey = 0, enc = false, encMode = 0, freqMode = 0, guardFreqMode = 0, volMode = 0, expansion = false, rtMode = 2 },
                { name = "", freq = 0, modulation = 3, volume = 1.0, secFreq = 0, freqMin = 1, freqMax = 1, encKey = 0, enc = false, encMode = 0, freqMode = 0, guardFreqMode = 0, volMode = 0, expansion = false, rtMode = 2 },
            },
            control = 0, -- HOTAS
        }
        _update.ambient = {vol = 0.0, abType = '' }
        _update.name = _data.UnitName
        _update.unit = _data.Name
        _update.unitId = LoGetPlayerPlaneId()

        local _latLng,_point = SR.exportPlayerLocation(_data)

        _update.latLng = _latLng
        SR.lastKnownPos = _point

        -- IFF_STATUS:  OFF = 0,  NORMAL = 1 , or IDENT = 2 (IDENT means Blink on LotATC)
        -- M1:-1 = off, any other number on
        -- M2: -1 = OFF, any other number on
        -- M3: -1 = OFF, any other number on
        -- M4: 1 = ON or 0 = OFF
        -- EXPANSION: only enabled if IFF Expansion is enabled
        -- CONTROL: 1 - OVERLAY / SRS, 0 - COCKPIT / Realistic, 2 = DISABLED / NOT FITTED AT ALL
        -- MIC - -1 for OFF or ID of the radio to trigger IDENT Mode if the PTT is used
        -- IFF STATUS{"control":1,"expansion":false,"mode1":51,"mode3":7700,"mode4":1,"status":2,mic=1}

        _update.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=0,control=1,expansion=false,mic=-1}

        --SR.log(_update.unit.."\n\n")

        local aircraftExporter = SR.exporters[_update.unit]

        if aircraftExporter then
            _update = aircraftExporter(_update)
        else
            -- FC 3
            _update.radios[2].name = "FC3 VHF"
            _update.radios[2].freq = 124.8 * 1000000 --116,00-151,975 MHz
            _update.radios[2].modulation = 0
            _update.radios[2].secFreq = 121.5 * 1000000
            _update.radios[2].volume = 1.0
            _update.radios[2].freqMin = 116 * 1000000
            _update.radios[2].freqMax = 151.975 * 1000000
            _update.radios[2].volMode = 1
            _update.radios[2].freqMode = 1
            _update.radios[2].rtMode = 1

            _update.radios[3].name = "FC3 UHF"
            _update.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
            _update.radios[3].modulation = 0
            _update.radios[3].secFreq = 243.0 * 1000000
            _update.radios[3].volume = 1.0
            _update.radios[3].freqMin = 225 * 1000000
            _update.radios[3].freqMax = 399.975 * 1000000
            _update.radios[3].volMode = 1
            _update.radios[3].freqMode = 1
            _update.radios[3].rtMode = 1
            _update.radios[3].encKey = 1
            _update.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

            _update.radios[4].name = "FC3 FM"
            _update.radios[4].freq = 30.0 * 1000000 --VHF/FM opera entre 30.000 y 76.000 MHz.
            _update.radios[4].modulation = 1
            _update.radios[4].volume = 1.0
            _update.radios[4].freqMin = 30 * 1000000
            _update.radios[4].freqMax = 76 * 1000000
            _update.radios[4].volMode = 1
            _update.radios[4].freqMode = 1
            _update.radios[4].encKey = 1
            _update.radios[4].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting
            _update.radios[4].rtMode = 1

            _update.control = 0;
            _update.selected = 1
            _update.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=0,control=0,expansion=false,mic=-1}

            _update.ambient = {vol = 0.2, abType = 'jet' }
        end

        _lastUnitId = _update.unitId
        _lastUnitType = _data.Name
    else
        --Ground Commander or spectator
        _update = {
            name = "Unknown",
            ambient = {vol = 0.0, abType = ''},
            unit = "CA",
            selected = 1,
            ptt = false,
            capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" },
            simultaneousTransmissionControl = 1,
            latLng = { lat = 0, lng = 0, alt = 0 },
            unitId = 100000001, -- pass through starting unit id here
            radios = {
                --- Radio 0 is always intercom now -- disabled if AWACS panel isnt open
                { name = "SATCOM", freq = 100, modulation = 2, volume = 1.0, secFreq = 0, freqMin = 100, freqMax = 100, encKey = 0, enc = false, encMode = 0, freqMode = 0, volMode = 1, expansion = false, rtMode = 2 },
                { name = "UHF Guard", freq = 251.0 * 1000000, modulation = 0, volume = 1.0, secFreq = 243.0 * 1000000, freqMin = 1 * 1000000, freqMax = 400 * 1000000, encKey = 1, enc = false, encMode = 1, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "UHF Guard", freq = 251.0 * 1000000, modulation = 0, volume = 1.0, secFreq = 243.0 * 1000000, freqMin = 1 * 1000000, freqMax = 400 * 1000000, encKey = 1, enc = false, encMode = 1, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "VHF FM", freq = 30.0 * 1000000, modulation = 1, volume = 1.0, secFreq = 1, freqMin = 1 * 1000000, freqMax = 76 * 1000000, encKey = 1, enc = false, encMode = 1, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "UHF Guard", freq = 251.0 * 1000000, modulation = 0, volume = 1.0, secFreq = 243.0 * 1000000, freqMin = 1 * 1000000, freqMax = 400 * 1000000, encKey = 1, enc = false, encMode = 1, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "UHF Guard", freq = 251.0 * 1000000, modulation = 0, volume = 1.0, secFreq = 243.0 * 1000000, freqMin = 1 * 1000000, freqMax = 400 * 1000000, encKey = 1, enc = false, encMode = 1, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "VHF Guard", freq = 124.8 * 1000000, modulation = 0, volume = 1.0, secFreq = 121.5 * 1000000, freqMin = 1 * 1000000, freqMax = 400 * 1000000, encKey = 0, enc = false, encMode = 0, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "VHF Guard", freq = 124.8 * 1000000, modulation = 0, volume = 1.0, secFreq = 121.5 * 1000000, freqMin = 1 * 1000000, freqMax = 400 * 1000000, encKey = 0, enc = false, encMode = 0, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "VHF FM", freq = 30.0 * 1000000, modulation = 1, volume = 1.0, secFreq = 1, freqMin = 1 * 1000000, freqMax = 76 * 1000000, encKey = 1, enc = false, encMode = 1, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "VHF Guard", freq = 124.8 * 1000000, modulation = 0, volume = 1.0, secFreq = 121.5 * 1000000, freqMin = 1 * 1000000, freqMax = 400 * 1000000, encKey = 0, enc = false, encMode = 0, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
                { name = "VHF Guard", freq = 124.8 * 1000000, modulation = 0, volume = 1.0, secFreq = 121.5 * 1000000, freqMin = 1 * 1000000, freqMax = 400 * 1000000, encKey = 0, enc = false, encMode = 0, freqMode = 1, volMode = 1, expansion = false, rtMode = 1 },
            },
            radioType = 3,
            iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=0,control=0,expansion=false,mic=-1}
        }

        local _latLng,_point = SR.exportCameraLocation()

        _update.latLng = _latLng
        SR.lastKnownPos = _point

        _lastUnitId = ""
        _lastUnitType = ""
    end

    _update.seat = SR.lastKnownSeat

    if SR.unicast then
        socket.try(SR.UDPSendSocket:sendto(SR.JSON:encode(_update) .. " \n", "127.0.0.1", SR.RADIO_SEND_TO_PORT))
    else
        socket.try(SR.UDPSendSocket:sendto(SR.JSON:encode(_update) .. " \n", "127.255.255.255", SR.RADIO_SEND_TO_PORT))
    end
end


function SR.readLOSSocket()
    -- Receive buffer is 8192 in LUA Socket
    -- will contain 10 clients for LOS
    local _received = SR.UDPLosReceiveSocket:receive()

    if _received then
        local _decoded = SR.JSON:decode(_received)

        if _decoded then

            local _losList = SR.checkLOS(_decoded)

            --DEBUG
            -- SR.log('LOS check ' .. SR.JSON:encode(_losList))
            if SR.unicast then
                socket.try(SR.UDPSendSocket:sendto(SR.JSON:encode(_losList) .. " \n", "127.0.0.1", SR.LOS_SEND_TO_PORT))
            else
                socket.try(SR.UDPSendSocket:sendto(SR.JSON:encode(_losList) .. " \n", "127.255.255.255", SR.LOS_SEND_TO_PORT))
            end
        end

    end
end

function SR.readSeatSocket()
    -- Receive buffer is 8192 in LUA Socket
    local _received = SR.UDPSeatReceiveSocket:receive()

    if _received then
        local _decoded = SR.JSON:decode(_received)

        if _decoded then
            SR.lastKnownSeat = _decoded.seat
            --SR.log("lastKnownSeat "..SR.lastKnownSeat)
        end

    end
end

function SR.checkLOS(_clientsList)

    local _result = {}

    for _, _client in pairs(_clientsList) do
        -- add 10 meter tolerance
        --Coordinates convertion :
        --{x,y,z}                 = LoGeoCoordinatesToLoCoordinates(longitude_degrees,latitude_degrees)
        local _point = LoGeoCoordinatesToLoCoordinates(_client.lng,_client.lat)
        -- Encoded Point: {"x":3758906.25,"y":0,"z":-1845112.125}

        local _los = 1.0 -- 1.0 is NO line of sight as in full signal loss - 0.0 is full signal, NO Loss

        local _hasLos = terrain.isVisible(SR.lastKnownPos.x, SR.lastKnownPos.y + SR.LOS_HEIGHT_OFFSET, SR.lastKnownPos.z, _point.x, _client.alt + SR.LOS_HEIGHT_OFFSET, _point.z)

        if _hasLos then
            table.insert(_result, { id = _client.id, los = 0.0 })
        else
        
            -- find the lowest offset that would provide line of sight
            for _losOffset = SR.LOS_HEIGHT_OFFSET + SR.LOS_HEIGHT_OFFSET_STEP, SR.LOS_HEIGHT_OFFSET_MAX - SR.LOS_HEIGHT_OFFSET_STEP, SR.LOS_HEIGHT_OFFSET_STEP do

                _hasLos = terrain.isVisible(SR.lastKnownPos.x, SR.lastKnownPos.y + _losOffset, SR.lastKnownPos.z, _point.x, _client.alt + SR.LOS_HEIGHT_OFFSET, _point.z)

                if _hasLos then
                    -- compute attenuation as a percentage of LOS_HEIGHT_OFFSET_MAX
                    -- e.g.: 
                    --    LOS_HEIGHT_OFFSET_MAX = 500   -- max offset
                    --    _losOffset = 200              -- offset actually used
                    --    -> attenuation would be 200 / 500 = 0.4
                    table.insert(_result, { id = _client.id, los = (_losOffset / SR.LOS_HEIGHT_OFFSET_MAX) })
                    break ;
                end
            end
            
            -- if there is still no LOS            
            if not _hasLos then

              -- then check max offset gives LOS
              _hasLos = terrain.isVisible(SR.lastKnownPos.x, SR.lastKnownPos.y + SR.LOS_HEIGHT_OFFSET_MAX, SR.lastKnownPos.z, _point.x, _client.alt + SR.LOS_HEIGHT_OFFSET, _point.z)

              if _hasLos then
                  -- but make sure that we do not get 1.0 attenuation when using LOS_HEIGHT_OFFSET_MAX
                  -- (LOS_HEIGHT_OFFSET_MAX / LOS_HEIGHT_OFFSET_MAX would give attenuation of 1.0)
                  -- I'm using 0.99 as a placeholder, not sure what would work here
                  table.insert(_result, { id = _client.id, los = (0.99) })
              else
                  -- otherwise set attenuation to 1.0
                  table.insert(_result, { id = _client.id, los = 1.0 }) -- 1.0 Being NO line of sight - FULL signal loss
              end
            end
        end

    end
    return _result
end

--Coordinates convertion :
--{latitude,longitude}  = LoLoCoordinatesToGeoCoordinates(x,z);

function SR.exportPlayerLocation(_data)

    if _data ~= nil and _data.Position ~= nil then

        local latLng  = LoLoCoordinatesToGeoCoordinates(_data.Position.x,_data.Position.z)
        --LatLng: {"latitude":25.594814853729,"longitude":55.938746498011}

        return { lat = latLng.latitude, lng = latLng.longitude, alt = _data.Position.y },_data.Position
    else
        return { lat = 0, lng = 0, alt = 0 },{ x = 0, y = 0, z = 0 }
    end
end

function SR.exportCameraLocation()
    local _cameraPosition = LoGetCameraPosition()

    if _cameraPosition ~= nil and _cameraPosition.p ~= nil then

        local latLng = LoLoCoordinatesToGeoCoordinates(_cameraPosition.p.x, _cameraPosition.p.z)

        return { lat = latLng.latitude, lng = latLng.longitude, alt = _cameraPosition.p.y },_cameraPosition.p
    end

    return { lat = 0, lng = 0, alt = 0 },{ x = 0, y = 0, z = 0 }
end

function SR.exportRadioA10A(_data)

    _data.radios[2].name = "AN/ARC-186(V)"
    _data.radios[2].freq = 124.8 * 1000000 --116,00-151,975 MHz
    _data.radios[2].modulation = 0
    _data.radios[2].secFreq = 121.5 * 1000000
    _data.radios[2].volume = 1.0
    _data.radios[2].freqMin = 116 * 1000000
    _data.radios[2].freqMax = 151.975 * 1000000
    _data.radios[2].volMode = 1
    _data.radios[2].freqMode = 1

    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1

    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.radios[4].name = "AN/ARC-186(V)FM"
    _data.radios[4].freq = 30.0 * 1000000 --VHF/FM opera entre 30.000 y 76.000 MHz.
    _data.radios[4].modulation = 1
    _data.radios[4].volume = 1.0
    _data.radios[4].freqMin = 30 * 1000000
    _data.radios[4].freqMax = 76 * 1000000
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1

    _data.radios[4].encKey = 1
    _data.radios[4].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

      --  local _door = SR.getButtonPosition(181)

      --  if _door > 0.15 then 
            _data.ambient = {vol = 0.3,  abType = 'a10' }
       -- else
       --     _data.ambient = {vol = 0.2,  abType = 'a10' }
      --  end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'a10' }
    end

    return _data
end

function SR.exportRadioMiG29(_data)

    _data.radios[2].name = "R-862"
    _data.radios[2].freq = 251.0 * 1000000 --V/UHF, frequencies are: VHF range of 100 to 149.975 MHz and UHF range of 220 to 399.975 MHz
    _data.radios[2].modulation = 0
    _data.radios[2].secFreq = 121.5 * 1000000
    _data.radios[2].volume = 1.0
    _data.radios[2].freqMin = 100 * 1000000
    _data.radios[2].freqMax = 399.975 * 1000000
    _data.radios[2].volMode = 1
    _data.radios[2].freqMode = 1

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

      --  local _door = SR.getButtonPosition(181)

     --   if _door > 0.15 then 
            _data.ambient = {vol = 0.3,  abType = 'mig29' }
     --   else
      --      _data.ambient = {vol = 0.2,  abType = 'mig29' }
    --    end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'mig29' }
    end

    return _data
end

function SR.exportRadioSU25(_data)

    _data.radios[2].name = "R-862"
    _data.radios[2].freq = 251.0 * 1000000 --V/UHF, frequencies are: VHF range of 100 to 149.975 MHz and UHF range of 220 to 399.975 MHz
    _data.radios[2].modulation = 0
    _data.radios[2].secFreq = 121.5 * 1000000
    _data.radios[2].volume = 1.0
    _data.radios[2].freqMin = 100 * 1000000
    _data.radios[2].freqMax = 399.975 * 1000000
    _data.radios[2].volMode = 1
    _data.radios[2].freqMode = 1

    _data.radios[3].name = "R-828"
    _data.radios[3].freq = 30.0 * 1000000 --20 - 60 MHz.
    _data.radios[3].modulation = 1
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 20 * 1000000
    _data.radios[3].freqMax = 59.975 * 1000000
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
     --   local _door = SR.getButtonPosition(181)
    
    --    if _door > 0.15 then 
            _data.ambient = {vol = 0.3,  abType = 'su25' }
     --   else
      --      _data.ambient = {vol = 0.2,  abType = 'su25' }
    --    end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'su25' }
    end

    return _data
end

function SR.exportRadioSU27(_data)

    _data.radios[2].name = "R-800"
    _data.radios[2].freq = 251.0 * 1000000 --V/UHF, frequencies are: VHF range of 100 to 149.975 MHz and UHF range of 220 to 399.975 MHz
    _data.radios[2].modulation = 0
    _data.radios[2].secFreq = 121.5 * 1000000
    _data.radios[2].volume = 1.0
    _data.radios[2].freqMin = 100 * 1000000
    _data.radios[2].freqMax = 399.975 * 1000000
    _data.radios[2].volMode = 1
    _data.radios[2].freqMode = 1

    _data.radios[3].name = "R-864"
    _data.radios[3].freq = 3.5 * 1000000 --HF frequencies in the 3-10Mhz, like the Jadro
    _data.radios[3].modulation = 0
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 3 * 1000000
    _data.radios[3].freqMax = 10 * 1000000
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

      --  local _door = SR.getButtonPosition(181)

      --  if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'su27' }
      --  else
      --      _data.ambient = {vol = 0.2,  abType = 'su27' }
     --   end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'su27' }
    end

    return _data
end

local  _ah64 = {}
_ah64.cipher = {
    key = 1,
    enabled = false
}


function SR.exportRadioAH64D(_data)
    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = true, intercomHotMic = true, desc = "Recommended: Always Allow SRS Hotkeys - OFF. Bind Intercom Select & PTT, Radio PTT and DCS RTS up down" }

-- 17 is the pilot (back seat)
-- 18 is the gunner (front seat)
-- Rts_FM1 is LEFT (single underscore) - current radio selected
-- Rts__FM1 is RIGHT (double underscore) - current radio selected in the OTHER seat (swaps if front or back)
-- we only care bout LEFT
-- { ["Net_FM1"] = ,
-- ["Net_Standby_FM2"] = ,
-- ["Frequency_Standby_VHF"] = 121.500,
-- ["Idm_FM2"] = ,
-- ["Idm_UHF"] = ,
-- ["Transponder_ID"] = XPNDR,
-- ["Net_VHF"] = ,
-- ["PowerStatus_FM1"] = NORM,
-- ["AdvisoryList_1"] = TAIL WHL LOCK SEL ,
-- ["Rts__FM1"] = =,
-- ["Idm_FM1"] = ],
-- ["Squelch_FM2"] = *,
-- ["Net_Standby_FM1"] = ,
-- ["Net_Standby_VHF"] = ,
-- ["Symbols_1"] = |,
-- ["RadioStats_HF"] = ,
-- ["Call_Standby_FM2"] = -----,
-- ["Idm_VHF"] = [,
-- ["Call_Standby_VHF"] = -----,
-- ["PowerStatus_HF"] = LOW,
-- ["Frequency_FM1"] =  30.000,
-- ["Symbols_5"] = |,
-- ["Arrows_3"] = |,
-- ["Symbols_10"] = |,
-- ["Rts_FM1_"] = =,
-- ["Symbols_6"] = |,
-- ["Radio_VHF"] = VHF,
-- ["Symbols_4"] = |,
-- ["Squelch_VHF"] = *,
-- ["Transponder_MODE_3A"] = 1200,
-- ["Rts__VHF"] = =,
-- ["Call_Standby_FM1"] = -----,
-- ["Call_UHF"] = -----,
-- ["Frequency_VHF"] = 121.000,
-- ["Radio_FM1"] = FM1,
-- ["background"] = ,
-- ["Frequency_Standby_UHF"] = 305.000,
-- ["Transponder_MC"] = NORM,
-- ["Call_VHF"] = -----,
-- ["Call_FM2"] = -----,
-- ["Net_UHF"] = ,
-- ["Arrows_4"] = |,
-- ["Symbols_7"] = |,
-- ["Frequency_HF"] =   2.0000A,
-- ["Watch_"] = 04:02:40 Z,
-- ["Frequency_Standby_FM1"] =  30.000,
-- ["Symbols_2"] = |,
-- ["Frequency_FM2"] =  30.000,
-- ["Rts__FM2"] = =,
-- ["XPNDR_MODE_S"] = S,
-- ["Call_FM1"] = -----,
-- ["Fuel_"] = 3140,
-- ["Fuel"] = FUEL,
-- ["XPNDR_MODE_4"] = A,
-- ["Call_Standby_HF"] = -----,
-- ["Symbols_3"] = |,
-- ["Call_Standby_UHF"] = -----,
-- ["Frequency_Standby_HF"] =   2.0000A,
-- ["Frequency_Standby_FM2"] =  30.000,
-- ["Idm_HF"] = ,
-- ["Net_FM2"] = ,
-- ["Rts__UHF"] = >,
-- ["Rts_HF_"] = =,
-- ["Guard"] = ,
-- ["Symbols_9"] = |,
-- ["Squelch_HF"] = *,
-- ["Radio_HF"] = HF ,
-- ["Arrows_1"] = |,
-- ["Squelch_UHF"] = *,
-- ["Squelch_FM1"] = *,
-- ["Radio_FM2"] = FM2,
-- ["Rts__HF"] = =,
-- ["Arrows_2"] = |,
-- ["Symbols_8"] = |,
-- ["Rts_VHF_"] = =,
-- ["Frequency_UHF"] = 305.000,
-- ["Call_HF"] = -----,
-- ["Rts_UHF_"] = =,
-- ["Rts_FM2_"] = <,
-- ["Radio_UHF"] = UHF,
-- ["Net_Standby_UHF"] = ,
-- } 



    -- Check if player is in a new aircraft
    if _lastUnitId ~= _data.unitId then
        -- New aircraft; SENS volume is at 0
            pcall(function()
                 -- source https://github.com/DCSFlightpanels/dcs-bios/blob/master/Scripts/DCS-BIOS/lib/AH-64D.lua
                GetDevice(63):performClickableAction(3011, 1) -- Pilot Master
                GetDevice(63):performClickableAction(3012, 1) -- Pilot SENS

                GetDevice(62):performClickableAction(3011, 1) -- CoPilot Master
                GetDevice(62):performClickableAction(3012, 1) -- CoPilot SENS
            end)
    end

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volMode = 0

    _data.radios[2].name = "VHF-ARC-186"
    _data.radios[2].freq = SR.getRadioFrequency(58)
    _data.radios[2].modulation = SR.getRadioModulation(58)
    _data.radios[2].volMode = 0

    _data.radios[3].name = "UHF-ARC-164"
    _data.radios[3].freq = SR.getRadioFrequency(57)
    _data.radios[3].modulation = SR.getRadioModulation(57)
    _data.radios[3].volMode = 0

    _data.radios[4].name = "FM1-ARC-201D"
    _data.radios[4].freq = SR.getRadioFrequency(59)
    _data.radios[4].modulation = SR.getRadioModulation(59)
    _data.radios[4].volMode = 0
    _data.radios[4].encKey = 1
    _data.radios[4].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.radios[5].name = "FM2-ARC-201D"
    _data.radios[5].freq = SR.getRadioFrequency(60)
    _data.radios[5].modulation = SR.getRadioModulation(60)
    _data.radios[5].volMode = 0
    _data.radios[5].encKey = 1
    _data.radios[5].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.radios[6].name = "HF-ARC-220"
    _data.radios[6].freq = SR.getRadioFrequency(61)
    _data.radios[6].modulation = 0
    _data.radios[6].volMode = 0

    local _radioPanel = nil
    local _cipher = nil

    if SR.lastKnownSeat == 0 then

        _radioPanel = SR.getListIndicatorValue(17)
        _cipher = SR.getListIndicatorValue(6)

        local _masterVolume = SR.getRadioVolume(0, 344, { 0.0, 1.0 }, false) 
        
        --intercom 
        _data.radios[1].volume = SR.getRadioVolume(0, 345, { 0.0, 1.0 }, false) * _masterVolume

        -- VHF
        if SR.getButtonPosition(449) == 0 then
            _data.radios[2].volume = SR.getRadioVolume(0, 334, { 0.0, 1.0 }, false) * _masterVolume 
        else
            _data.radios[2].volume = 0
        end

        -- UHF
        if SR.getButtonPosition(450) == 0 then
            _data.radios[3].volume = SR.getRadioVolume(0, 335, { 0.0, 1.0 }, false) * _masterVolume
        else
            _data.radios[3].volume = 0
        end

        -- FM1
        if SR.getButtonPosition(451) == 0 then
            _data.radios[4].volume = SR.getRadioVolume(0, 336, { 0.0, 1.0 }, false) * _masterVolume
        else
            _data.radios[4].volume = 0
        end

         -- FM2
        if SR.getButtonPosition(452) == 0 then
            _data.radios[5].volume = SR.getRadioVolume(0, 337, { 0.0, 1.0 }, false) * _masterVolume
        else
            _data.radios[5].volume = 0
        end

         -- HF
        if SR.getButtonPosition(453) == 0 then
            _data.radios[6].volume = SR.getRadioVolume(0, 338, { 0.0, 1.0 }, false) * _masterVolume
        else
            _data.radios[6].volume = 0
        end

         if SR.getButtonPosition(346) ~= 1 then
            _data.intercomHotMic = true
        end

    else
        local _masterVolume = SR.getRadioVolume(0, 385, { 0.0, 1.0 }, false) 
        _cipher = SR.getListIndicatorValue(10)

        _radioPanel = SR.getListIndicatorValue(18)

        --intercom 
        _data.radios[1].volume = SR.getRadioVolume(0, 386, { 0.0, 1.0 }, false) * _masterVolume

        -- VHF
        if SR.getButtonPosition(459) == 0 then
            _data.radios[2].volume = SR.getRadioVolume(0, 375, { 0.0, 1.0 }, false) * _masterVolume 
        else
            _data.radios[2].volume = 0
        end

        -- UHF
        if SR.getButtonPosition(460) == 0 then
            _data.radios[3].volume = SR.getRadioVolume(0, 376, { 0.0, 1.0 }, false) * _masterVolume
        else
            _data.radios[3].volume = 0
        end

        -- FM1
        if SR.getButtonPosition(461) == 0 then
            _data.radios[4].volume = SR.getRadioVolume(0, 377, { 0.0, 1.0 }, false) * _masterVolume
        else
            _data.radios[4].volume = 0
        end

         -- FM2
        if SR.getButtonPosition(462) == 0 then
            _data.radios[5].volume = SR.getRadioVolume(0, 378, { 0.0, 1.0 }, false) * _masterVolume
        else
            _data.radios[5].volume = 0
        end

         -- HF
        if SR.getButtonPosition(463) == 0 then
            _data.radios[6].volume = SR.getRadioVolume(0, 379, { 0.0, 1.0 }, false) * _masterVolume
        else
            _data.radios[6].volume = 0
        end

        if SR.getButtonPosition(387) ~= 1 then
            _data.intercomHotMic = true
        end

    end

    if _radioPanel then
        -- figure out selected
        if _radioPanel['Rts_VHF_'] == '<' then
            _data.selected = 1
        elseif _radioPanel['Rts_UHF_'] == '<' then
            _data.selected = 2
        elseif _radioPanel['Rts_FM1_'] == '<' then
            _data.selected = 3
        elseif _radioPanel['Rts_FM2_'] == '<' then
            _data.selected = 4
        elseif _radioPanel['Rts_HF_'] == '<' then
            _data.selected = 5
        end

        if _radioPanel['Guard'] == 'G' then
            _data.radios[3].secFreq = 243e6
        end
    end

    if _cipher then
          -- PLAIN, CIPHER , RECEIVE
        if _cipher["PB7_17"] then
            _ah64.cipher.enabled = _cipher["PB7_17"] == "CIPHER"
        end

        -- KEY 1,2,3,4,5,6
        if _cipher["PB8_21"] then
            _ah64.cipher.key = tonumber(_cipher["PB8_21"])
        end
        _data.radios[3].encKey = _ah64.cipher.key
        _data.radios[3].enc = _ah64.cipher.enabled
    end

    _data.control = 1
    _data.radios[3].encMode = 2 -- Mode 2 is set by aircraft

      --CYCLIC_RTS_SW_LEFT 573 CPG 531 PLT
    local _pttButtonId = 573
    if SR.lastKnownSeat == 0 then
        _pttButtonId = 531
    end

    local _pilotPTT = SR.getButtonPosition(_pttButtonId)
    if _pilotPTT >= 0.5 then

        _data.intercomHotMic = false
        -- intercom
        _data.selected = 0
        _data.ptt = true

    elseif _pilotPTT <= -0.5 then
        _data.ptt = true
    end

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'ah64' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'ah64' }
    end

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _doorLeft = SR.getButtonPosition(795)
        local _doorRight = SR.getButtonPosition(798)

        if _doorLeft > 0.3 or _doorRight > 0.3 then 
            _data.ambient = {vol = 0.35,  abType = 'ah64' }
        else
            _data.ambient = {vol = 0.2,  abType = 'ah64' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'ah64' }
    end

    return _data

end

function SR.exportRadioUH60L(_data)
    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = true, intercomHotMic = true, desc = "" }

    local isDCPower = SR.getButtonPosition(17) > 0 -- just using battery switch position for now, could tie into DC ESS BUS later?
    local intercomVolume = 0
    if isDCPower then
        -- ics master volume
        intercomVolume = GetDevice(0):get_argument_value(401)
    end

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = intercomVolume
    _data.radios[1].volMode = 0
    _data.radios[1].freqMode = 0
    _data.radios[1].rtMode = 0

    -- Pilots' AN/ARC-201 FM
    local fm1Device = GetDevice(6)
    local fm1Power = GetDevice(0):get_argument_value(601) > 0.01
    local fm1Volume = 0
    local fm1Freq = 0
    local fm1Modulation = 1

    if fm1Power and isDCPower then
        -- radio volume * ics master volume * ics switch
        fm1Volume = GetDevice(0):get_argument_value(604) * GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(403)
        fm1Freq = fm1Device:get_frequency()
        ARC201FM1Freq = get_param_handle("ARC201FM1param"):get()
        fm1Modulation = get_param_handle("ARC201_FM1_MODULATION"):get()
    end
    
    if not (fm1Power and isDCPower) then
        ARC201FM1Freq = 0
    end

    _data.radios[2].name = "AN/ARC-201 (1)"
    _data.radios[2].freq = ARC201FM1Freq --fm1Freq
    _data.radios[2].modulation = fm1Modulation
    _data.radios[2].volume = fm1Volume
    _data.radios[2].freqMin = 29.990e6
    _data.radios[2].freqMax = 87.985e6
    _data.radios[2].volMode = 0
    _data.radios[2].freqMode = 0
    _data.radios[2].rtMode = 0
    
    -- AN/ARC-164 UHF
    local arc164Device = GetDevice(5)
    local arc164Power = GetDevice(0):get_argument_value(50) > 0
    local arc164Volume = 0
    local arc164Freq = 0
    local arc164SecFreq = 0

    if arc164Power and isDCPower then
        -- radio volume * ics master volume * ics switch
        arc164Volume = GetDevice(0):get_argument_value(51) * GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(404)
        arc164Freq = arc164Device:get_frequency()
        arc164SecFreq = 243e6
    end

    _data.radios[3].name = "AN/ARC-164(V)"
    _data.radios[3].freq = arc164Freq
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = arc164SecFreq
    _data.radios[3].volume = arc164Volume
    _data.radios[3].freqMin = 225e6
    _data.radios[3].freqMax = 399.975e6
    _data.radios[3].volMode = 0
    _data.radios[3].freqMode = 0
    _data.radios[3].rtMode = 0

    -- AN/ARC-186 VHF
    local arc186Device = GetDevice(8)
    local arc186Power = GetDevice(0):get_argument_value(419) > 0
    local arc186Volume = 0
    local arc186Freq = 0
    local arc186SecFreq = 0

    if arc186Power and isDCPower then
        -- radio volume * ics master volume * ics switch
        arc186Volume = GetDevice(0):get_argument_value(410) * GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(405)
        arc186Freq = get_param_handle("ARC186param"):get() --arc186Device:get_frequency()
        arc186SecFreq = 121.5e6
    end
    
    if not (arc186Power and isDCPower) then
        arc186Freq = 0
    arc186SecFreq = 0
    end
    
    _data.radios[4].name = "AN/ARC-186(V)"
    _data.radios[4].freq = arc186Freq
    _data.radios[4].modulation = 0
    _data.radios[4].secFreq = arc186SecFreq
    _data.radios[4].volume = arc186Volume
    _data.radios[4].freqMin = 30e6
    _data.radios[4].freqMax = 151.975e6
    _data.radios[4].volMode = 0
    _data.radios[4].freqMode = 0
    _data.radios[4].rtMode = 0

    -- Copilot's AN/ARC-201 FM
    local fm2Device = GetDevice(10)
    local fm2Power = GetDevice(0):get_argument_value(701) > 0.01
    local fm2Volume = 0
    local fm2Freq = 0
    local fm2Modulation = 1

    if fm2Power and isDCPower then
        -- radio volume * ics master volume * ics switch
        fm2Volume = GetDevice(0):get_argument_value(704) * GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(406)
        fm2Freq = fm2Device:get_frequency()
        ARC201FM2Freq = get_param_handle("ARC201FM2param"):get()
        fm2Modulation = get_param_handle("ARC201_FM2_MODULATION"):get()
    end
    
    if not (fm2Power and isDCPower) then
        ARC201FM2Freq = 0
    end

    _data.radios[5].name = "AN/ARC-201 (2)"
    _data.radios[5].freq = ARC201FM2Freq --fm2Freq
    _data.radios[5].modulation = fm2Modulation
    _data.radios[5].volume = fm2Volume
    _data.radios[5].freqMin = 29.990e6
    _data.radios[5].freqMax = 87.985e6
    _data.radios[5].volMode = 0
    _data.radios[5].freqMode = 0
    _data.radios[5].rtMode = 0

    -- AN/ARC-220 HF radio - not implemented in module, freqs must be changed through SRS UI
    _data.radios[6].name = "AN/ARC-220"
    _data.radios[6].freq = 2e6
    _data.radios[6].modulation = 0
    _data.radios[6].volume = GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(407)
    _data.radios[6].freqMin = 2e6
    _data.radios[6].freqMax = 29.9999e6
    _data.radios[6].volMode = 1
    _data.radios[6].freqMode = 1
    _data.radios[6].encKey = 1 
    _data.radios[6].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting --ANDR0ID Added
    _data.radios[6].rtMode = 1 

    -- Only select radio if power to ICS panel
    local radioXMTSelectorValue = _data.selected or 0
    if isDCPower then
        radioXMTSelectorValue = SR.round(GetDevice(0):get_argument_value(400) * 5, 1)
        -- SR.log(radioXMTSelectorValue)
    end

    _data.selected = radioXMTSelectorValue
    _data.intercomHotMic = GetDevice(0):get_argument_value(402) > 0
    _data.ptt = GetDevice(0):get_argument_value(82) > 0
    _data.control = 1; -- full radio HOTAS control

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'uh60' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'uh60' }
    end
    
    return _data
end

function SR.exportRadioSH60B(_data)
    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = true, intercomHotMic = true, desc = "" }

    local isDCPower = SR.getButtonPosition(17) > 0 -- just using battery switch position for now, could tie into DC ESS BUS later?
    local intercomVolume = 0
    if isDCPower then
        -- ics master volume
        intercomVolume = GetDevice(0):get_argument_value(401)
    end

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = intercomVolume
    _data.radios[1].volMode = 0
    _data.radios[1].freqMode = 0
    _data.radios[1].rtMode = 0

    -- Copilot's AN/ARC-182 FM (COM1)
    local fm2Device = GetDevice(8)
    local fm2Power = GetDevice(0):get_argument_value(3113) > 0 --NEEDS UPDATE
    local fm2Volume = 0
    local fm2Freq = 0
    local fm2Mod = 0

    if fm2Power and isDCPower then
        -- radio volume * ics master volume * ics switch
        fm2Volume = GetDevice(0):get_argument_value(3167) * GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(403)
        fm2Freq = fm2Device:get_frequency()
        ARC182FM2Freq = get_param_handle("ARC182_1_param"):get()
        fm2Mod = GetDevice(0):get_argument_value(3119)
    end
    
    if not (fm2Power and isDCPower) then
        ARC182FM2Freq = 0
    end
    
    if fm2Mod == 1 then --Nessecary since cockpit switches are inverse from SRS settings 
        fm2ModCorrected = 0 
    else fm2ModCorrected = 1
    end

    _data.radios[2].name = "AN/ARC-182 (1)"
    _data.radios[2].freq = ARC182FM2Freq--fm2Freq
    _data.radios[2].modulation = fm2ModCorrected
    _data.radios[2].volume = fm2Volume
    _data.radios[2].freqMin = 30e6
    _data.radios[2].freqMax = 399.975e6
    _data.radios[2].volMode = 0
    _data.radios[2].freqMode = 0
    _data.radios[2].rtMode = 0

    -- Pilots' AN/ARC-182 FM (COM2)
    local fm1Device = GetDevice(6)
    local fm1Power = GetDevice(0):get_argument_value(3113) > 0 --NEEDS UPDATE
    local fm1Volume = 0
    local fm1Freq = 0
    local fm1Mod = 0

    if fm1Power and isDCPower then
        -- radio volume * ics master volume * ics switch
        fm1Volume = GetDevice(0):get_argument_value(3168) * GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(404)
        fm1Freq = fm1Device:get_frequency()
        ARC182FM1Freq = get_param_handle("ARC182_2_param"):get()
        fm1Mod = GetDevice(0):get_argument_value(3120)
    end
    
    if not (fm1Power and isDCPower) then
        ARC182FM1Freq = 0
    end
    
    if fm1Mod == 1 then 
        fm1ModCorrected = 0 
    else fm1ModCorrected = 1
    end

    _data.radios[3].name = "AN/ARC-182 (2)"
    _data.radios[3].freq = ARC182FM1Freq--fm1Freq
    _data.radios[3].modulation = fm1ModCorrected
    _data.radios[3].volume = fm1Volume
    _data.radios[3].freqMin = 30e6
    _data.radios[3].freqMax = 399.975e6
    _data.radios[3].volMode = 0
    _data.radios[3].freqMode = 0
    _data.radios[3].rtMode = 0
    
    --D/L not implemented in module, using a "dummy radio" for now
    _data.radios[4].name = "DATA LINK (D/L)"
    _data.radios[4].freq = 0
    _data.radios[4].modulation = 0
    _data.radios[4].volume = GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(409)
    _data.radios[4].freqMin = 15e9
    _data.radios[4].freqMax = 15e9
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1
    _data.radios[4].encKey = 1 
    _data.radios[4].encMode = 0 
    _data.radios[4].rtMode = 1 

    -- AN/ARC-174A HF radio - not implemented in module, freqs must be changed through SRS UI
    _data.radios[5].name = "AN/ARC-174(A)"
    _data.radios[5].freq = 2e6
    _data.radios[5].modulation = 0
    _data.radios[5].volume = GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(407)
    _data.radios[5].freqMin = 2e6
    _data.radios[5].freqMax = 29.9999e6
    _data.radios[5].volMode = 1
    _data.radios[5].freqMode = 1
    _data.radios[5].encKey = 1 
    _data.radios[5].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting --ANDR0ID Added
    _data.radios[5].rtMode = 1 

    -- Only select radio if power to ICS panel
    local radioXMTSelectorValue = _data.selected or 0
    if isDCPower then
        radioXMTSelectorValue = SR.round(GetDevice(0):get_argument_value(400) * 5, 1)
        -- SR.log(radioXMTSelectorValue)
    end

    -- UHF/VHF BACKUP
    local arc164Device = GetDevice(5)
    local arc164Power = GetDevice(0):get_argument_value(3091) > 0
    local arc164Volume = 0
    local arc164Freq = 0
    local arc164Mod = 0
    --local arc164SecFreq = 0

    if arc164Power and isDCPower then
        -- radio volume * ics master volume * ics switch
        arc164Volume = GetDevice(0):get_argument_value(3089) * GetDevice(0):get_argument_value(401) * GetDevice(0):get_argument_value(405)
        arc164Freq = get_param_handle("VUHFB_FREQ"):get()
        arc164Mod = GetDevice(0):get_argument_value(3094)
        --arc164SecFreq = 243e6
    end
    
    if arc164Mod == 1 then 
        arc164ModCorrected = 0 
    else arc164ModCorrected = 1
    end 

    _data.radios[6].name = "UHF/VHF BACKUP"
    _data.radios[6].freq = arc164Freq * 1000
    _data.radios[6].modulation = arc164ModCorrected
    --_data.radios[6].secFreq = arc164SecFreq
    _data.radios[6].volume = arc164Volume
    _data.radios[6].freqMin = 30e6
    _data.radios[6].freqMax = 399.975e6
    _data.radios[6].volMode = 0
    _data.radios[6].freqMode = 0
    _data.radios[6].rtMode = 0

    _data.selected = radioXMTSelectorValue
    _data.intercomHotMic = GetDevice(0):get_argument_value(402) > 0
    _data.ptt = GetDevice(0):get_argument_value(82) > 0
    _data.control = 1; -- full radio HOTAS control

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'uh60' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'uh60' }
    end

    return _data
end


function SR.exportRadioA4E(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    --local intercom = GetDevice(4) --commented out for now, may be useful in future
    local uhf_radio = GetDevice(5) --see devices.lua or Devices.h

    local mainFreq = 0
    local guardFreq = 0

    -- Can directly check the radio device.
    local hasPower = uhf_radio:is_on()

    -- "Function Select Switch" near the right edge controls radio power
    local functionSelect = SR.getButtonPosition(372)

    -- All frequencies are set by the radio in the A-4 so no extra checking required here.
    if hasPower then
        mainFreq = SR.round(uhf_radio:get_frequency(), 5000)

        -- Additionally, enable guard monitor if Function knob is in position T/R+G
        if 0.15 < functionSelect and functionSelect < 0.25 then
            guardFreq = 243.000e6
        end
    end

    local arc51 = _data.radios[2]
    arc51.name = "AN/ARC-51BX"
    arc51.freq = mainFreq
    arc51.secFreq = guardFreq
    arc51.channel = nil -- what is this used for?
    arc51.modulation = 0  -- AM only
    arc51.freqMin = 220.000e6
    arc51.freqMax = 399.950e6

    -- TODO Check if there are other volume knobs in series
    arc51.volume = SR.getRadioVolume(0, 365, {0.2, 0.8}, false)
    if arc51.volume < 0.0 then
        -- The knob position at startup is 0.0, not 0.2, and it gets scaled to -33.33
        arc51.volume = 0.0
    end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting


    _data.control = 0;
    _data.selected = 1


    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(26)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'A4' }
        else
            _data.ambient = {vol = 0.2,  abType = 'A4' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'A4' }
    end

    return _data
end

function SR.exportRadioSK60(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = 1.0
    _data.radios[1].volMode = 1

    _data.radios[2].name = "UHF Radio AN/ARC-164"
    _data.radios[2].freq = SR.getRadioFrequency(6)
    _data.radios[2].modulation = 1
    _data.radios[2].volume = 1.0
    _data.radios[2].volMode = 1

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-186(V)"
    _data.radios[3].freq = 124.8 * 1000000 --116,00-151,975 MHz
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 121.5 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 116 * 1000000
    _data.radios[3].freqMax = 151.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1

    -- Expansion Radio - Server Side Controlled
    _data.radios[4].name = "AN/ARC-186(V)FM"
    _data.radios[4].freq = 30.0 * 1000000 
    _data.radios[4].modulation = 1
    _data.radios[4].volume = 1.0
    _data.radios[4].freqMin = 30 * 1000000
    _data.radios[4].freqMax = 76 * 1000000
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1
    _data.radios[4].expansion = true

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(38)

        if _door < 0.9 then 
            _data.ambient = {vol = 0.3,  abType = 'sk60' }
        else
            _data.ambient = {vol = 0.2,  abType = 'sk60' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'sk60' }
    end

    return _data

end



function SR.exportRadioT45(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = true, intercomHotMic = true, desc = "" }

    local radio1Device = GetDevice(1)
    local radio2Device = GetDevice(2)
    local mainFreq1 = 0
    local guardFreq1 = 0
    local mainFreq2 = 0
    local guardFreq2 = 0
    
    local comm1Switch = GetDevice(0):get_argument_value(191) 
    local comm2Switch = GetDevice(0):get_argument_value(192) 
    local comm1PTT = GetDevice(0):get_argument_value(294)
    local comm2PTT = GetDevice(0):get_argument_value(294) 
    local intercomPTT = GetDevice(0):get_argument_value(295)    
    local ICSMicSwitch = GetDevice(0):get_argument_value(196) --0 cold, 1 hot
    
    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = GetDevice(0):get_argument_value(198)
    
    local modeSelector1 = GetDevice(0):get_argument_value(256) -- 0:off, 0.25:T/R, 0.5:T/R+G
    if modeSelector1 == 0.5 and comm1Switch == 1 then
        mainFreq1 = SR.round(radio1Device:get_frequency(), 5000)
        if mainFreq1 > 225000000 then
            guardFreq1 = 243.000E6
        elseif mainFreq1 < 155975000 then
            guardFreq1 = 121.500E6
        else
            guardFreq1 = 0
        end
    elseif modeSelector1 == 0.25 and comm1Switch == 1 then
        guardFreq1 = 0
        mainFreq1 = SR.round(radio1Device:get_frequency(), 5000)
    else
        guardFreq1 = 0
        mainFreq1 = 0
    end

    local arc182 = _data.radios[2]
    arc182.name = "AN/ARC-182(V) - 1"
    arc182.freq = mainFreq1
    arc182.secFreq = guardFreq1
    arc182.modulation = radio1Device:get_modulation()  
    arc182.freqMin = 30.000e6
    arc182.freqMax = 399.975e6
    arc182.volume = GetDevice(0):get_argument_value(246)

    local modeSelector2 = GetDevice(0):get_argument_value(280) -- 0:off, 0.25:T/R, 0.5:T/R+G
    if modeSelector2 == 0.5 and comm2Switch == 1 then
        mainFreq2 = SR.round(radio2Device:get_frequency(), 5000)
        if mainFreq2 > 225000000 then
            guardFreq2 = 243.000E6
        elseif mainFreq2 < 155975000 then
            guardFreq2 = 121.500E6
        else
            guardFreq2 = 0
        end
    elseif modeSelector2 == 0.25 and comm2Switch == 1 then
        guardFreq2 = 0
        mainFreq2 = SR.round(radio2Device:get_frequency(), 5000)
    else
        guardFreq2 = 0
        mainFreq2 = 0
    end
    
    local arc182_2 = _data.radios[3]
    arc182_2.name = "AN/ARC-182(V) - 2"
    arc182_2.freq = mainFreq2
    arc182_2.secFreq = guardFreq2
    arc182_2.modulation = radio2Device:get_modulation()  
    arc182_2.freqMin = 30.000e6
    arc182_2.freqMax = 399.975e6
    arc182_2.volume = GetDevice(0):get_argument_value(270)

    if comm1PTT == 1 then
        _data.selected = 1 -- comm 1
        _data.ptt = true
    elseif comm2PTT == -1 then
        _data.selected = 2 -- comm 2
        _data.ptt = true
    elseif intercomPTT == 1 then
        _data.selected = 0 -- intercom
        _data.ptt = true
    else
        _data.selected = -1
        _data.ptt = false
    end
    
    if ICSMicSwitch == 1 then
        _data.intercomHotMic = true
    else
        _data.intercomHotMic = false
    end

    _data.control = 1; -- full radio HOTAS control

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'jet' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'jet' }
    end
    
    return _data
end


function SR.exportRadioPUCARA(_data)
   _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }
   
   _data.radios[1].name = "Intercom"
   _data.radios[1].freq = 100.0
   _data.radios[1].modulation = 2 --Special intercom modulation
   _data.radios[1].volume = GetDevice(0):get_argument_value(764)
    
    local comm1Switch = GetDevice(0):get_argument_value(762) 
    local comm2Switch = GetDevice(0):get_argument_value(763) 
    local comm1PTT = GetDevice(0):get_argument_value(765)
    local comm2PTT = GetDevice(0):get_argument_value(7655) 
    local modeSelector1 = GetDevice(0):get_argument_value(1080) -- 0:off, 0.25:T/R, 0.5:T/R+G
    local amfm = GetDevice(0):get_argument_value(770)

    _data.radios[2].name = "SUNAIR ASB-850 COM1"
    _data.radios[2].modulation = amfm
    _data.radios[2].volume = SR.getRadioVolume(0, 1079, { 0.0, 1.0 }, false)

    if comm1Switch == 0 then 
        _data.radios[2].freq = 246.000e6
        _data.radios[2].secFreq = 0
    elseif comm1Switch == 1 then 
        local one = 100.000e6 * SR.getSelectorPosition(1090, 1 / 4)
        local two = 10.000e6 * SR.getSelectorPosition(1082, 1 / 10)
        local three = 1.000e6 * SR.getSelectorPosition(1084, 1 / 10)
        local four = 0.1000e6 * SR.getSelectorPosition(1085, 1 / 10)
        local five = 0.010e6 * SR.getSelectorPosition(1087, 1 / 10)
        local six = 0.0010e6 * SR.getSelectorPosition(1086, 1 / 10)
        mainFreq =  one + two + three + four + five - six
        _data.radios[2].freq = mainFreq
        _data.radios[2].secFreq = 0
    
    end
    
    _data.radios[3].name = "RTA-42A BENDIX COM2"
    _data.radios[3].modulation = 0
    _data.radios[3].volume = SR.getRadioVolume(0, 1100, { 0.0, 1.0 }, false)

    if comm2Switch == 0 then 
        _data.radios[3].freq = 140.000e6
        _data.radios[3].secFreq = 0
    elseif comm2Switch == 1 then 
        local onea = 100.000e6 * SR.getSelectorPosition(1104, 1 / 4)
        local twoa = 10.000e6 * SR.getSelectorPosition(1103, 1 / 10)
                
        mainFreqa =  onea + twoa 
        _data.radios[3].freq = mainFreqa
        _data.radios[3].secFreq = 0
    
    end
   
    _data.control = 1 -- Hotas Controls radio
    
    
     _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'jet' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'jet' }
    end
     
    return _data
end

function SR.exportRadioA29B(_data)
    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    local com1_freq = 0
    local com1_mod = 0
    local com1_sql = 0
    local com1_pwr = 0
    local com1_mode = 2

    local com2_freq = 0
    local com2_mod = 0
    local com2_sql = 0
    local com2_pwr = 0
    local com2_mode = 1

    local _ufcp = SR.getListIndicatorValue(4)
    if _ufcp then 
        if _ufcp.com1_freq then com1_freq = (_ufcp.com1_freq * 1000000) end
        if _ufcp.com1_mod then com1_mod = _ufcp.com1_mod * 1 end
        if _ufcp.com1_sql then com1_sql = _ufcp.com1_sql end
        if _ufcp.com1_pwr then com1_pwr = _ufcp.com1_pwr end
        if _ufcp.com1_mode then com1_mode = _ufcp.com1_mode * 1 end

        if _ufcp.com2_freq then com2_freq = (_ufcp.com2_freq * 1000000) end
        if _ufcp.com2_mod then com2_mod = _ufcp.com2_mod * 1 end
        if _ufcp.com2_sql then com2_sql = _ufcp.com2_sql end
        if _ufcp.com2_pwr then com2_pwr = _ufcp.com2_pwr end
        if _ufcp.com2_mode then com2_mode = _ufcp.com2_mode * 1 end
    end

    _data.radios[2].name = "XT-6013 COM1"
    _data.radios[2].modulation = com1_mod
    _data.radios[2].volume = SR.getRadioVolume(0, 762, { 0.0, 1.0 }, false)

    if com1_mode == 0 then 
        _data.radios[2].freq = 0
        _data.radios[2].secFreq = 0
    elseif com1_mode == 1 then 
        _data.radios[2].freq = com1_freq
        _data.radios[2].secFreq = 0
    elseif com1_mode == 2 then 
        _data.radios[2].freq = com1_freq
        _data.radios[2].secFreq = 121.5 * 1000000
    end

    _data.radios[3].name = "XT-6313D COM2"
    _data.radios[3].modulation = com2_mod
    _data.radios[3].volume = SR.getRadioVolume(0, 763, { 0.0, 1.0 }, false)

    if com2_mode == 0 then 
        _data.radios[3].freq = 0
        _data.radios[3].secFreq = 0
    elseif com2_mode == 1 then 
        _data.radios[3].freq = com2_freq
        _data.radios[3].secFreq = 0
    elseif com2_mode == 2 then 
        _data.radios[3].freq = com2_freq
        _data.radios[3].secFreq = 243.0 * 1000000
    end

    _data.radios[4].name = "KTR-953 HF"
    _data.radios[4].freq = 15.0 * 1000000 --VHF/FM opera entre 30.000 y 76.000 MHz.
    _data.radios[4].modulation = 1
    _data.radios[4].volume = SR.getRadioVolume(0, 764, { 0.0, 1.0 }, false)
    _data.radios[4].freqMin = 2 * 1000000
    _data.radios[4].freqMax = 30 * 1000000
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1
    _data.radios[4].encKey = 1
    _data.radios[4].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting
    _data.radios[4].rtMode = 1

    _data.control = 0 -- Hotas Controls radio
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(26)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'a29' }
        else
            _data.ambient = {vol = 0.2,  abType = 'a29' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'a29' }
    end

    return _data
end


function SR.exportRadioVSNF4(_data)
    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }
   
    _data.radios[2].name = "AN/ARC-164 UHF"
    _data.radios[2].freq = SR.getRadioFrequency(2)
    _data.radios[2].modulation = 0
    _data.radios[2].secFreq = 0
    _data.radios[2].volume = 1.0
    _data.radios[2].volMode = 1
    _data.radios[2].freqMode = 0


    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-186(V)"
    _data.radios[3].freq = 124.8 * 1000000 --116,00-151,975 MHz
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 121.5 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 116 * 1000000
    _data.radios[3].freqMax = 151.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1

    _data.radios[2].encKey = 1
    _data.radios[2].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'jet' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'jet' }
    end

    return _data
end

function SR.exportRadioHercules(_data)
    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = true, desc = "" }
    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=0,control=1,expansion=false,mic=-1}

    -- Intercom
    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = 1.0
    _data.radios[1].volMode = 1 -- Overlay control

    -- AN/ARC-164(V) Radio
    -- Use the Pilot's volume for any station other
    -- than the copilot.
    local volumeKnob = 1430 -- PILOT_ICS_Volume_Rot
    if SR.lastKnownSeat == 1 then
        volumeKnob = 1432 -- COPILOT_ICS_Volume_Rot
    end
    local arc164 = GetDevice(18)
    _data.radios[2].name = "AN/ARC-164 UHF"
    if arc164:is_on() then
        _data.radios[2].freq = arc164:get_frequency()
        _data.radios[2].secFreq = 243e6
    else
        _data.radios[2].freq = 0
        _data.radios[2].secFreq = 0
    end
    _data.radios[2].modulation = arc164:get_modulation()

    _data.radios[2].volume = SR.getRadioVolume(0, volumeKnob, { -1.0, 1.0 })
    _data.radios[2].freqMin = 225e6
    _data.radios[2].freqMax = 399.975e6
    _data.radios[2].volMode = 0
    _data.radios[2].freqMode = 0

    -- Expansions - Server Side Controlled
    -- VHF AM - 116-151.975MHz
    _data.radios[3].name = "AN/ARC-186(V) AM"
    _data.radios[3].freq = 124.8e6 
    _data.radios[3].modulation = 0 -- AM
    _data.radios[3].secFreq = 121.5e6
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 116e6
    _data.radios[3].freqMax = 151.975e6
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].expansion = false

    -- VHF FM - 30-87.975MHz
    _data.radios[4].name = "AN/ARC-186(V) FM"
    _data.radios[4].freq = 30e6
    _data.radios[4].modulation = 1 -- FM
    _data.radios[4].secFreq = 0
    _data.radios[4].volume = 1.0
    _data.radios[4].freqMin = 30e6
    _data.radios[4].freqMax = 87.975e6
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1
    _data.radios[4].expansion = false

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'hercules' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'hercules' }
    end

    return _data;
end

function SR.exportRadioF15C(_data)

    _data.radios[2].name = "AN/ARC-164 UHF-1"
    _data.radios[2].freq = 251.0 * 1000000 --225 to 399.975MHZ
    _data.radios[2].modulation = 0
    _data.radios[2].secFreq = 243.0 * 1000000
    _data.radios[2].volume = 1.0
    _data.radios[2].freqMin = 225 * 1000000
    _data.radios[2].freqMax = 399.975 * 1000000
    _data.radios[2].volMode = 1
    _data.radios[2].freqMode = 1

    _data.radios[2].encKey = 1
    _data.radios[2].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.radios[3].name = "AN/ARC-164 UHF-2"
    _data.radios[3].freq = 231.0 * 1000000 --225 to 399.975MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1

    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting


    -- Expansion Radio - Server Side Controlled
    _data.radios[4].name = "AN/ARC-186(V)"
    _data.radios[4].freq = 124.8 * 1000000 --116,00-151,975 MHz
    _data.radios[4].modulation = 0
    _data.radios[4].secFreq = 121.5 * 1000000
    _data.radios[4].volume = 1.0
    _data.radios[4].freqMin = 116 * 1000000
    _data.radios[4].freqMax = 151.975 * 1000000
    _data.radios[4].expansion = true
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

     --   local _door = SR.getButtonPosition(181)

  --      if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'f15' }
      --  else
        --    _data.ambient = {vol = 0.2,  abType = 'f15' }
      --  end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'f15' }
    end

    return _data
end

function SR.exportRadioF15ESE(_data)


    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = true, desc = "" }

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume =  1.0
    _data.radios[4].volMode = 0
 

    _data.radios[2].name = "AN/ARC-164 UHF-1"
    _data.radios[2].freq = SR.getRadioFrequency(7)
    _data.radios[2].modulation = SR.getRadioModulation(7)


    _data.radios[3].name = "AN/ARC-164 UHF-2"
    _data.radios[3].freq = SR.getRadioFrequency(8)
    _data.radios[3].modulation = SR.getRadioModulation(8)

    local _seat = SR.lastKnownSeat

    if _seat == 0 then
        _data.radios[2].volume = SR.getRadioVolume(0, 282, { 0.0, 1.0 }, false)
        _data.radios[3].volume = SR.getRadioVolume(0, 283, { 0.0, 1.0 }, false)

        if SR.getButtonPosition(509) >= 0.5 then
            _data.intercomHotMic = true
        end
    else
        _data.radios[2].volume = SR.getRadioVolume(0, 1307, { 0.0, 1.0 }, false)
        _data.radios[3].volume = SR.getRadioVolume(0, 1308, { 0.0, 1.0 }, false)

        if SR.getButtonPosition(1427) >= 0.5 then
            _data.intercomHotMic = true
        end
    end

    _data.control = 0
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(38)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'f15' }
        else
            _data.ambient = {vol = 0.2,  abType = 'f15' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'f15' }
    end

      -- HANDLE TRANSPONDER
    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local _iffDevice = GetDevice(68)

    if _iffDevice:hasPower() then
        _data.iff.status = 1 -- NORMAL

        if _iffDevice:isIdentActive() then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end
    else
        _data.iff.status = -1
    end
    
    
    if _iffDevice:isModeActive(4) then 
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    if _iffDevice:isModeActive(3) then 
        _data.iff.mode3 = string.format("%04d",_iffDevice:getModeCode(3))
    else
        _data.iff.mode3 = -1
    end

    if _iffDevice:isModeActive(2) then 
        _data.iff.mode2 = string.format("%04d",_iffDevice:getModeCode(2))
    else
        _data.iff.mode2 = -1
    end

    if _iffDevice:isModeActive(1) then 
        _data.iff.mode1 = string.format("%02d",_iffDevice:getModeCode(1))
    else
        _data.iff.mode1 = -1
    end

    -- local temp = {}
    -- temp.mode4 = string.format("%04d",_iffDevice:getModeCode(4)) -- mode 4
    -- temp.mode1 = string.format("%02d",_iffDevice:getModeCode(1))
    -- temp.mode3 = string.format("%04d",_iffDevice:getModeCode(3))
    -- temp.mode2 = string.format("%04d",_iffDevice:getModeCode(2))
    -- temp.mode4Active = _iffDevice:isModeActive(4)
    -- temp.mode1Active = _iffDevice:isModeActive(1)
    -- temp.mode3Active = _iffDevice:isModeActive(3)
    -- temp.mode2Active = _iffDevice:isModeActive(2)
    -- temp.ident = _iffDevice:isIdentActive()
    -- temp.power = _iffDevice:hasPower()


    return _data
end


function SR.exportRadioUH1H(_data)

    local intercomOn =  SR.getButtonPosition(27)
    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume =  SR.getRadioVolume(0, 29, { 0.3, 1.0 }, true)

    if intercomOn > 0.5 then
        --- control hot mic instead of turning it on and off
        _data.intercomHotMic = true
    end

    local fmOn =  SR.getButtonPosition(23)
    _data.radios[2].name = "AN/ARC-131"
    _data.radios[2].freq = SR.getRadioFrequency(23)
    _data.radios[2].modulation = 1
    _data.radios[2].volume = SR.getRadioVolume(0, 37, { 0.3, 1.0 }, true)

    if fmOn < 0.5 then
        _data.radios[2].freq = 1
    end

    local uhfOn =  SR.getButtonPosition(24)
    _data.radios[3].name = "AN/ARC-51BX - UHF"
    _data.radios[3].freq = SR.getRadioFrequency(22)
    _data.radios[3].modulation = 0
    _data.radios[3].volume = SR.getRadioVolume(0, 21, { 0.0, 1.0 }, true)

    -- get channel selector
    local _selector = SR.getSelectorPosition(15, 0.1)

    if _selector < 1 then
        _data.radios[3].channel = SR.getSelectorPosition(16, 0.05) + 1 --add 1 as channel 0 is channel 1
    end

    if uhfOn < 0.5 then
        _data.radios[3].freq = 1
        _data.radios[3].channel = -1
    end

    --guard mode for UHF Radio
    local uhfModeKnob = SR.getSelectorPosition(17, 0.1)
    if uhfModeKnob == 2 and _data.radios[3].freq > 1000 then
        _data.radios[3].secFreq = 243.0 * 1000000
    end

    local vhfOn =  SR.getButtonPosition(25)
    _data.radios[4].name = "AN/ARC-134"
    _data.radios[4].freq = SR.getRadioFrequency(20)
    _data.radios[4].modulation = 0
    _data.radios[4].volume = SR.getRadioVolume(0, 9, { 0.0, 0.60 }, false)

    if vhfOn < 0.5 then
        _data.radios[4].freq = 1
    end

    --_device:get_argument_value(_arg)

    local _seat = SR.lastKnownSeat

    if _seat == 0 then

         local _panel = GetDevice(0)

        local switch = _panel:get_argument_value(30)

        if SR.nearlyEqual(switch, 0.1, 0.03) then
            _data.selected = 0
        elseif SR.nearlyEqual(switch, 0.2, 0.03) then
            _data.selected = 1
        elseif SR.nearlyEqual(switch, 0.3, 0.03) then
            _data.selected = 2
        elseif SR.nearlyEqual(switch, 0.4, 0.03) then
            _data.selected = 3
        else
            _data.selected = -1
        end

        local _pilotPTT = SR.getButtonPosition(194)
        if _pilotPTT >= 0.1 then

            if _pilotPTT == 0.5 then
                -- intercom
                _data.selected = 0
            end

            _data.ptt = true
        end

        _data.control = 1; -- Full Radio


        _data.capabilities = { dcsPtt = true, dcsIFF = true, dcsRadioSwitch = true, intercomHotMic = true, desc = "Hot mic on INT switch" }
    else
        _data.control = 0; -- no copilot or gunner radio controls - allow them to switch
        
        _data.radios[1].volMode = 1 
        _data.radios[2].volMode = 1 
        _data.radios[3].volMode = 1 
        _data.radios[4].volMode = 1

        _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = true, desc = "Hot mic on INT switch" }
    end


    -- HANDLE TRANSPONDER
    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}


    local iffPower =  SR.getSelectorPosition(59,0.1)

    local iffIdent =  SR.getButtonPosition(66) -- -1 is off 0 or more is on

    if iffPower >= 2 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end

        -- MODE set to MIC
        if iffIdent == -1 then

            _data.iff.mic = 2

            if _data.ptt and _data.selected == 2 then
                _data.iff.status = 2 -- IDENT due to MIC switch
            end
        end

    end

    local mode1On =  SR.getButtonPosition(61)
    _data.iff.mode1 = SR.round(SR.getSelectorPosition(68,0.33), 0.1)*10+SR.round(SR.getSelectorPosition(69,0.11), 0.1)


    if mode1On ~= 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(63)
    _data.iff.mode3 = SR.round(SR.getSelectorPosition(70,0.11), 0.1) * 1000 + SR.round(SR.getSelectorPosition(71,0.11), 0.1) * 100 + SR.round(SR.getSelectorPosition(72,0.11), 0.1)* 10 + SR.round(SR.getSelectorPosition(73,0.11), 0.1)

    if mode3On ~= 0 then
        _data.iff.mode3 = -1
    elseif iffPower == 4 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(67)

    if mode4On ~= 0 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    local _doorLeft = SR.getButtonPosition(420)

    -- engine on
    if SR.getAmbientVolumeEngine()  > 10 then
        if _doorLeft >= 0 and _doorLeft < 0.5 then
            -- engine on and door closed
            _data.ambient = {vol = 0.2,  abType = 'uh1' }
        else
            -- engine on and door open
            _data.ambient = {vol = 0.35, abType = 'uh1' }
        end
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'uh1' }
    end


    -- SR.log("ambient STATUS"..SR.JSON:encode(_data.ambient).."\n\n")

    return _data

end

function SR.exportRadioSA342(_data)
    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = true, intercomHotMic = true, desc = "" }

    -- Check for version
    local _newVersion = false
    local _uhfId = 31
    local _fmId = 28

    pcall(function() 

        local temp = SR.getRadioFrequency(30, 500)

        if temp ~= nil then
            _newVersion = true
            _fmId = 27
            _uhfId = 30
        end
    end)


    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = 1.0
    _data.radios[1].volMode = 1

    local _seat = SR.lastKnownSeat

    local vhfVolume = 68 -- IC1_VHF
    local uhfVolume = 69 -- IC1_UHF
    local fm1Volume = 70 -- IC1_FM1

    local vhfPush = 452 -- IC1_VHF_Push
    local fm1Push = 453 -- IC1_FM1_Push
    local uhfPush = 454 -- IC1_UHF_Push

    if _seat == 1 then
        -- Copilot.
        vhfVolume = 79 -- IC2_VHF
        uhfVolume = 80 -- IC2_UHF
        fm1Volume = 81 -- IC2_FM1

        vhfPush = 455 -- IC2_VHF_Push
        fm1Push = 456 -- IC2_FM1_Push
        uhfPush = 457 -- IC2_UHF_Push
    end
    

    _data.radios[2].name = "TRAP 138A"
    local MHZ = 1000000
    local _hundreds = SR.round(SR.getKnobPosition(0, 133, { 0.0, 0.9 }, { 0, 9 }), 0.1) * 100 * MHZ
    local _tens = SR.round(SR.getKnobPosition(0, 134, { 0.0, 0.9 }, { 0, 9 }), 0.1) * 10 * MHZ
    local _ones = SR.round(SR.getKnobPosition(0, 136, { 0.0, 0.9 }, { 0, 9 }), 0.1) * MHZ
    local _tenth = SR.round(SR.getKnobPosition(0, 138, { 0.0, 0.9 }, { 0, 9 }), 0.1) * 100000
    local _hundreth = SR.round(SR.getKnobPosition(0, 139, { 0.0, 0.9 }, { 0, 9 }), 0.1) * 10000

    if SR.getSelectorPosition(128, 0.33) > 0.65 then -- Check VHF ON?
        _data.radios[2].freq = _hundreds + _tens + _ones + _tenth + _hundreth
    else
        _data.radios[2].freq = 1
    end
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, vhfVolume, { 1.0, 0.0 }, true)
    _data.radios[2].rtMode = 1

    _data.radios[3].name = "UHF TRA 6031"

    -- deal with odd radio tune & rounding issue... BUG you cannot set frequency 243.000 ever again
    local freq = SR.getRadioFrequency(_uhfId, 500)
    freq = (math.floor(freq / 1000) * 1000)

    _data.radios[3].freq = freq

    _data.radios[3].modulation = 0
    _data.radios[3].volume = SR.getRadioVolume(0, uhfVolume, { 0.0, 1.0 }, false)

    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 3 -- 3 is Incockpit toggle + Gui Enc Key setting
    _data.radios[3].rtMode = 1

    _data.radios[4].name = "TRC 9600 PR4G"
    _data.radios[4].freq = SR.getRadioFrequency(_fmId)
    _data.radios[4].modulation = 1
    _data.radios[4].volume = SR.getRadioVolume(0, fm1Volume, { 0.0, 1.0 }, false)

    _data.radios[4].encKey = 1
    _data.radios[4].encMode = 3 -- Variable Enc key but turned on by sim
    _data.radios[4].rtMode = 1

    --- is UHF ON?
    if SR.getSelectorPosition(383, 0.167) == 0 then
        _data.radios[3].freq = 1
    elseif SR.getSelectorPosition(383, 0.167) == 2 then
        --check UHF encryption
        _data.radios[3].enc = true
    end

    --guard mode for UHF Radio
    local uhfModeKnob = SR.getSelectorPosition(383, 0.167)
    if uhfModeKnob == 5 and _data.radios[3].freq > 1000 then
        _data.radios[3].secFreq = 243.0 * 1000000
    end

    --- is FM ON?
    if SR.getSelectorPosition(272, 0.25) == 0 then
        _data.radios[4].freq = 1
    elseif SR.getSelectorPosition(272, 0.25) == 2 then
        --check FM encryption
        _data.radios[4].enc = true
    end
    
    if _seat < 2 then
        -- Pilot or Copilot have cockpit controls
        
        if SR.getButtonPosition(vhfPush) > 0.5 then
            _data.selected = 1
        elseif SR.getButtonPosition(uhfPush) > 0.5 then
            _data.selected = 2
        elseif SR.getButtonPosition(fm1Push) > 0.5 then
            _data.selected = 3
        end

        _data.control = 1; -- COCKPIT Controls
    else
        -- Neither Pilot nor copilot - everything overlay.
        _data.capabilities.dcsRadioSwitch = false
        _data.radios[2].volMode = 1
        _data.radios[3].volMode = 1
        _data.radios[4].volMode = 1

        _data.control = 0; -- OVERLAY Controls
    end

     -- The option reads 'disable HOT_MIC', true means off.
     _data.intercomHotMic = not SR.getSpecialOption('SA342.HOT_MIC')

    -- HANDLE TRANSPONDER
    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getButtonPosition(246)

    local iffIdent =  SR.getButtonPosition(240) -- -1 is off 0 or more is on

    if iffPower > 0 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end
    end

    local mode1On =  SR.getButtonPosition(248)
    _data.iff.mode1 = SR.round(SR.getSelectorPosition(234,0.1), 0.1)*10+SR.round(SR.getSelectorPosition(235,0.1), 0.1)

    if mode1On == 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(250)
    _data.iff.mode3 = SR.round(SR.getSelectorPosition(236,0.1), 0.1) * 1000 + SR.round(SR.getSelectorPosition(237,0.1), 0.1) * 100 + SR.round(SR.getSelectorPosition(238,0.1), 0.1)* 10 + SR.round(SR.getSelectorPosition(239,0.1), 0.1)

    if mode3On == 0 then
        _data.iff.mode3 = -1
    end

    local mode4On =  SR.getButtonPosition(251)

    if mode4On ~= 0 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'sa342' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'sa342' }
    end

    return _data
end

function SR.exportRadioKA50(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = true, intercomHotMic = false, desc = "" }

    local _panel = GetDevice(0)

    _data.radios[2].name = "R-800L14 VHF/UHF"
    _data.radios[2].freq = SR.getRadioFrequency(48)

    -- Get modulation mode
    local switch = _panel:get_argument_value(417)
    if SR.nearlyEqual(switch, 0.0, 0.03) then
        _data.radios[2].modulation = 1
    else
        _data.radios[2].modulation = 0
    end
    _data.radios[2].volume = SR.getRadioVolume(0, 353, { 0.0, 1.0 }, false) -- using ADF knob for now

    _data.radios[3].name = "R-828"
    _data.radios[3].freq = SR.getRadioFrequency(49, 50000)
    _data.radios[3].modulation = 1
    _data.radios[3].volume = SR.getRadioVolume(0, 372, { 0.0, 1.0 }, false)
    _data.radios[3].channel = SR.getSelectorPosition(371, 0.1) + 1

    -- Expansion Radio - Server Side Controlled
    _data.radios[4].name = "AN/ARC-164 UHF"
    _data.radios[4].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[4].modulation = 0
    _data.radios[4].secFreq = 243.0 * 1000000
    _data.radios[4].volume = 1.0
    _data.radios[4].freqMin = 225 * 1000000
    _data.radios[4].freqMax = 399.975 * 1000000
    _data.radios[4].expansion = true
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1
    _data.radios[4].encKey = 1
    _data.radios[4].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    local switch = _panel:get_argument_value(428)

    if SR.nearlyEqual(switch, 0.0, 0.03) then
        _data.selected = 1
    elseif SR.nearlyEqual(switch, 0.1, 0.03) then
        _data.selected = 2
    elseif SR.nearlyEqual(switch, 0.2, 0.03) then
        _data.selected = 3
    else
        _data.selected = -1
    end

    _data.control = 1;

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(38)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'ka50' }
        else
            _data.ambient = {vol = 0.2,  abType = 'ka50' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'ka50' }
    end

    return _data

end

function SR.exportRadioMI8(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = true, intercomHotMic = false, desc = "" }

    -- Doesnt work but might as well allow selection
    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = 1.0

    _data.radios[2].name = "R-863"
    _data.radios[2].freq = SR.getRadioFrequency(38)

    local _modulation = GetDevice(0):get_argument_value(369)
    if _modulation > 0.5 then
        _data.radios[2].modulation = 1
    else
        _data.radios[2].modulation = 0
    end

    -- get channel selector
    local _selector = GetDevice(0):get_argument_value(132)

    if _selector > 0.5 then
        _data.radios[2].channel = SR.getSelectorPosition(370, 0.05) + 1 --add 1 as channel 0 is channel 1
    end

    _data.radios[2].volume = SR.getRadioVolume(0, 156, { 0.0, 1.0 }, false)

    _data.radios[3].name = "JADRO-1A"
    _data.radios[3].freq = SR.getRadioFrequency(37, 500)
    _data.radios[3].modulation = 0
    _data.radios[3].volume = SR.getRadioVolume(0, 743, { 0.0, 1.0 }, false)

    _data.radios[4].name = "R-828"
    _data.radios[4].freq = SR.getRadioFrequency(39, 50000)
    _data.radios[4].modulation = 1
    _data.radios[4].volume = SR.getRadioVolume(0, 737, { 0.0, 1.0 }, false)

    -- Expansion Radio - Server Side Controlled
    _data.radios[5].name = "AN/ARC-164 UHF"
    _data.radios[5].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[5].modulation = 0
    _data.radios[5].secFreq = 243.0 * 1000000
    _data.radios[5].volume = 1.0
    _data.radios[5].freqMin = 225 * 1000000
    _data.radios[5].freqMax = 399.975 * 1000000
    _data.radios[5].expansion = true
    _data.radios[5].volMode = 1
    _data.radios[5].freqMode = 1
    _data.radios[5].encKey = 1
    _data.radios[5].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    --guard mode for R-863 Radio
    local uhfModeKnob = SR.getSelectorPosition(153, 1)
    if uhfModeKnob == 1 and _data.radios[2].freq > 1000 then
        _data.radios[2].secFreq = 121.5 * 1000000
    end

    -- Get selected radio from SPU-9
    local _switch = SR.getSelectorPosition(550, 0.1)

    if _switch == 0 then
        _data.selected = 1
    elseif _switch == 1 then
        _data.selected = 2
    elseif _switch == 2 then
        _data.selected = 3
    else
        _data.selected = -1
    end

    if SR.getButtonPosition(182) >= 0.5 or SR.getButtonPosition(225) >= 0.5 then
        _data.ptt = true
    end


    -- Radio / ICS Switch
    if SR.getButtonPosition(553) > 0.5 then
        _data.selected = 0
    end

    _data.control = 1; -- full radio


    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _doorLeft = SR.getButtonPosition(216)
        local _doorRight = SR.getButtonPosition(215)

        if _doorLeft > 0.2 or _doorRight > 0.2 then 
            _data.ambient = {vol = 0.35,  abType = 'mi8' }
        else
            _data.ambient = {vol = 0.2,  abType = 'mi8' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'mi8' }
    end

    return _data

end


function SR.exportRadioMI24P(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = true, intercomHotMic = true, desc = "Use Radio/ICS Switch to control Intercom Hot Mic" }

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = 1.0
    _data.radios[1].volMode = 0

    _data.radios[2].name = "R-863"
    _data.radios[2].freq = SR.getRadioFrequency(49)
    _data.radios[2].modulation = SR.getRadioModulation(49)
    _data.radios[2].volume = SR.getRadioVolume(0, 511, { 0.0, 1.0 }, false)
    _data.radios[2].volMode = 0

    local guard = SR.getSelectorPosition(507, 1)
    if guard == 1 and _data.radios[2].freq > 1000 then
        _data.radios[2].secFreq = 121.5 * 1000000
    end


    _data.radios[3].name = "R-828"
    _data.radios[3].freq = SR.getRadioFrequency(51)
    _data.radios[3].modulation = 1 --SR.getRadioModulation(50)
    _data.radios[3].volume = SR.getRadioVolume(0, 339, { 0.0, 1.0 }, false)
    _data.radios[3].volMode = 0

    _data.radios[4].name = "JADRO-1I"
    _data.radios[4].freq = SR.getRadioFrequency(50, 500)
    _data.radios[4].modulation = SR.getRadioModulation(50)
    _data.radios[4].volume = SR.getRadioVolume(0, 426, { 0.0, 1.0 }, false)
    _data.radios[4].volMode = 0

    -- listen only radio - moved to expansion
    _data.radios[5].name = "R-852"
    _data.radios[5].freq = SR.getRadioFrequency(52)
    _data.radios[5].modulation = SR.getRadioModulation(52)
    _data.radios[5].volume = SR.getRadioVolume(0, 517, { 0.0, 1.0 }, false)
    _data.radios[5].volMode = 0
    _data.radios[5].expansion = true

    local _seat = SR.lastKnownSeat

    if _seat == 0 then

         _data.radios[1].volume = SR.getRadioVolume(0, 457, { 0.0, 1.0 }, false)

        --Pilot SPU-8 selection
        local _switch = SR.getSelectorPosition(455, 0.2)
        if _switch == 0 then
            _data.selected = 1            -- R-863
        elseif _switch == 1 then 
            _data.selected = -1          -- No Function
        elseif _switch == 2 then
            _data.selected = 2            -- R-828
        elseif _switch == 3 then
            _data.selected = 3            -- JADRO
        elseif _switch == 4 then
            _data.selected = 4
        else
            _data.selected = -1
        end

        local _pilotPTT = SR.getButtonPosition(738) 
        if _pilotPTT >= 0.1 then

            if _pilotPTT == 0.5 then
                -- intercom
              _data.selected = 0
            end

            _data.ptt = true
        end

        --hot mic 
        if SR.getButtonPosition(456) >= 1.0 then
            _data.intercomHotMic = true
        end

    else

        --- copilot
        _data.radios[1].volume = SR.getRadioVolume(0, 661, { 0.0, 1.0 }, false)
        -- For the co-pilot allow volume control
        _data.radios[2].volMode = 1
        _data.radios[3].volMode = 1
        _data.radios[4].volMode = 1
        _data.radios[5].volMode = 1
        
        local _switch = SR.getSelectorPosition(659, 0.2)
        if _switch == 0 then
            _data.selected = 1            -- R-863
        elseif _switch == 1 then 
            _data.selected = -1          -- No Function
        elseif _switch == 2 then
            _data.selected = 2            -- R-828
        elseif _switch == 3 then
            _data.selected = 3            -- JADRO
        elseif _switch == 4 then
            _data.selected = 4
        else
            _data.selected = -1
        end

        local _copilotPTT = SR.getButtonPosition(856) 
        if _copilotPTT >= 0.1 then

            if _copilotPTT == 0.5 then
                -- intercom
              _data.selected = 0
            end

            _data.ptt = true
        end

        --hot mic 
        if SR.getButtonPosition(660) >= 1.0 then
            _data.intercomHotMic = true
        end
    end
    
    _data.control = 1;

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _doorLeft = SR.getButtonPosition(9)
        local _doorRight = SR.getButtonPosition(849)

        if _doorLeft > 0.2 or _doorRight > 0.2 then 
            _data.ambient = {vol = 0.35,  abType = 'mi24' }
        else
            _data.ambient = {vol = 0.2,  abType = 'mi24' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'mi24' }
    end

    return _data

end

function SR.exportRadioL39(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = true, intercomHotMic = false, desc = "" }

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = SR.getRadioVolume(0, 288, { 0.0, 0.8 }, false)

    _data.radios[2].name = "R-832M"
    _data.radios[2].freq = SR.getRadioFrequency(19)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 289, { 0.0, 0.8 }, false)

    -- Intercom button depressed
    if (SR.getButtonPosition(133) > 0.5 or SR.getButtonPosition(546) > 0.5) then
        _data.selected = 0
        _data.ptt = true
    elseif (SR.getButtonPosition(134) > 0.5 or SR.getButtonPosition(547) > 0.5) then
        _data.selected = 1
        _data.ptt = true
    else
        _data.selected = 1
        _data.ptt = false
    end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting


    _data.control = 1; -- full radio - for expansion radios - DCS controls must be disabled

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _doorLeft = SR.getButtonPosition(139)
        local _doorRight = SR.getButtonPosition(140)

        if _doorLeft > 0.2 or _doorRight > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'l39' }
        else
            _data.ambient = {vol = 0.2,  abType = 'l39' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'mi24' }
    end

    return _data
end

function SR.exportRadioEagleII(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = 1--SR.getRadioVolume(0, 288,{0.0,0.8},false)

    _data.radios[2].name = "KY-197A"
    _data.radios[2].freq = SR.getRadioFrequency(5)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 364, { 0.1, 1.0 }, false)

    if _data.radios[2].volume < 0 then
        _data.radios[2].volume = 0
    end


    -- Intercom button depressed
    -- if(SR.getButtonPosition(133) > 0.5 or SR.getButtonPosition(546) > 0.5) then
    --     _data.selected = 0
    --     _data.ptt = true
    -- elseif (SR.getButtonPosition(134) > 0.5 or SR.getButtonPosition(547) > 0.5) then
    --     _data.selected= 1
    --     _data.ptt = true
    -- else
    --     _data.selected= 1
    --      _data.ptt = false
    -- end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-186(V)"
    _data.radios[3].freq = 124.8 * 1000000 --116,00-151,975 MHz
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 121.5 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 116 * 1000000
    _data.radios[3].freqMax = 151.975 * 1000000
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].expansion = true

    -- Expansion Radio - Server Side Controlled
    _data.radios[4].name = "AN/ARC-164 UHF"
    _data.radios[4].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[4].modulation = 0
    _data.radios[4].secFreq = 243.0 * 1000000
    _data.radios[4].volume = 1.0
    _data.radios[4].freqMin = 225 * 1000000
    _data.radios[4].freqMax = 399.975 * 1000000
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1
    _data.radios[4].expansion = true
    _data.radios[4].encKey = 1
    _data.radios[4].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 0; -- HOTAS

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'ChristenEagle' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'ChristenEagle' }
    end

    return _data
end

function SR.exportRadioYak52(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = 1.0
    _data.radios[1].volMode = 1

    _data.radios[2].name = "Baklan 5"
    _data.radios[2].freq = SR.getRadioFrequency(27)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 90, { 0.0, 1.0 }, false)

    -- Intercom button depressed
    if (SR.getButtonPosition(192) > 0.5 or SR.getButtonPosition(196) > 0.5) then
        _data.selected = 1
        _data.ptt = true
    elseif (SR.getButtonPosition(194) > 0.5 or SR.getButtonPosition(197) > 0.5) then
        _data.selected = 0
        _data.ptt = true
    else
        _data.selected = 1
        _data.ptt = false
    end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 1; -- full radio - for expansion radios - DCS controls must be disabled

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'yak52' }
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'yak52' }
    end

    return _data
end

--for A10C
function SR.exportRadioA10C(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = true, dcsRadioSwitch = true, intercomHotMic = false, desc = "Using cockpit PTT (HOTAS Mic Switch) requires use of VoIP bindings." }

    -- Check if player is in a new aircraft
    if _lastUnitId ~= _data.unitId then
        -- New aircraft; Reset volumes to 100%
        local _device = GetDevice(0)

        if _device then
            _device:set_argument_value(133, 1.0) -- VHF AM
            _device:set_argument_value(171, 1.0) -- UHF
            _device:set_argument_value(147, 1.0) -- VHF FM
        end
    end


    -- VHF AM
    -- Set radio data
    _data.radios[2].name = "AN/ARC-186(V) AM"
    _data.radios[2].freq = SR.getRadioFrequency(55)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 133, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 238, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 225, { 0.0, 1.0 }, false) * SR.getButtonPosition(226)


    -- UHF
    -- Set radio data
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = SR.getRadioFrequency(54)
    
    local modulation = SR.getSelectorPosition(162, 0.1)

    --is HQ selected (A on the Radio)
    if modulation == 2 then
        _data.radios[3].modulation = 4
    else
        _data.radios[3].modulation = 0
    end


    _data.radios[3].volume = SR.getRadioVolume(0, 171, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 238, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 227, { 0.0, 1.0 }, false) * SR.getButtonPosition(228)
    _data.radios[3].encMode = 2 -- Mode 2 is set by aircraft

    -- Check UHF frequency mode (0 = MNL, 1 = PRESET, 2 = GRD)
    local _selector = SR.getSelectorPosition(167, 0.1)
    if _selector == 1 then
        -- Using UHF preset channels
        local _channel = SR.getSelectorPosition(161, 0.05) + 1 --add 1 as channel 0 is channel 1
        _data.radios[3].channel = _channel
    end

    -- Check UHF function mode (0 = OFF, 1 = MAIN, 2 = BOTH, 3 = ADF)
    local uhfModeKnob = SR.getSelectorPosition(168, 0.1)
    if uhfModeKnob == 2 and _data.radios[3].freq > 1000 then
        -- Function dial set to BOTH
        -- Listen to Guard as well as designated frequency
        _data.radios[3].secFreq = 243.0 * 1000000
    else
        -- Function dial set to OFF, MAIN, or ADF
        -- Not listening to Guard secondarily
        _data.radios[3].secFreq = 0
    end


    -- VHF FM
    -- Set radio data
    _data.radios[4].name = "AN/ARC-186(V)FM"
    _data.radios[4].freq = SR.getRadioFrequency(56)
    _data.radios[4].modulation = 1
    _data.radios[4].volume = SR.getRadioVolume(0, 147, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 238, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 223, { 0.0, 1.0 }, false) * SR.getButtonPosition(224)
    _data.radios[4].encMode = 2 -- mode 2 enc is set by aircraft & turned on by aircraft


    -- KY-58 Radio Encryption
    -- Check if encryption is being used
    local _ky58Power = SR.getButtonPosition(784)
    if _ky58Power > 0.5 and SR.getButtonPosition(783) == 0 then
        -- mode switch set to OP and powered on
        -- Power on!

        local _radio = nil
        if SR.round(SR.getButtonPosition(781), 0.1) == 0.2 and SR.getSelectorPosition(149, 0.1) >= 2 then -- encryption disabled when EMER AM/FM selected
            --crad/2 vhf - FM
            _radio = _data.radios[4]
        elseif SR.getButtonPosition(781) == 0 and _selector ~= 2 then -- encryption disabled when GRD selected
            --crad/1 uhf
            _radio = _data.radios[3]
        end

        -- Get encryption key
        local _channel = SR.getSelectorPosition(782, 0.1) + 1

        if _radio ~= nil and _channel ~= nil then
            -- Set encryption key for selected radio
            _radio.encKey = _channel
            _radio.enc = true
        end
    end


    -- Mic Switch Radio Select and Transmit - by Dyram
    -- Check Mic Switch position (UP: 751 1.0, DOWN: 751 -1.0, FWD: 752 1.0, AFT: 752 -1.0)
    -- ED broke this as part of the VoIP work
    if SR.getButtonPosition(752) == 1 then
        -- Mic Switch FWD pressed
        -- Check Intercom panel Rotary Selector Dial (0: INT, 1: FM, 2: VHF, 3: HF, 4: "")
        if SR.getSelectorPosition(239, 0.1) == 2 then
            -- Intercom panel set to VHF
            _data.selected = 1 -- radios[2] VHF AM
            _data.ptt = true
        elseif SR.getSelectorPosition(239, 0.1) == 0 then
            -- Intercom panel set to INT
            -- Intercom not functional, but select it anyway to be proper
            _data.selected = 0 -- radios[1] Intercom
        else
            _data.selected = -1
        end
    elseif SR.getButtonPosition(751) == -1 then
        -- Mic Switch DOWN pressed
        _data.selected = 2 -- radios[3] UHF
        _data.ptt = true
    elseif SR.getButtonPosition(752) == -1 then
        -- Mic Switch AFT pressed
        _data.selected = 3 -- radios[4] VHF FM
        _data.ptt = true
    else
        -- Mic Switch released
        _data.selected = -1
        _data.ptt = false
    end

    _data.control = 1 -- Overlay  

    -- Handle transponder

    _data.iff = {status=0,mode1=0,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getSelectorPosition(200,0.1)

    local iffIdent =  SR.getButtonPosition(207) -- -1 is off 0 or more is on

    if iffPower >= 2 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end

        -- SR.log("IFF iffIdent"..iffIdent.."\n\n")
        -- MIC mode switch - if you transmit on UHF then also IDENT
        -- https://github.com/ciribob/DCS-SimpleRadioStandalone/issues/408
        if iffIdent == -1 then

            _data.iff.mic = 2

            if _data.ptt and _data.selected == 2 then
                _data.iff.status = 2 -- IDENT (BLINKY THING)
            end
        end
    end

    local mode1On =  SR.getButtonPosition(202)

    _data.iff.mode1 = SR.round(SR.getButtonPosition(209), 0.1)*100+SR.round(SR.getButtonPosition(210), 0.1)*10

    if mode1On ~= 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(204)

    _data.iff.mode3 = SR.round(SR.getButtonPosition(211), 0.1) * 10000 + SR.round(SR.getButtonPosition(212), 0.1) * 1000 + SR.round(SR.getButtonPosition(213), 0.1)* 100 + SR.round(SR.getButtonPosition(214), 0.1) * 10

    if mode3On ~= 0 then
        _data.iff.mode3 = -1
    elseif iffPower == 4 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(208)

    if mode4On ~= 0 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end


    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(7)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.3,  abType = 'a10' }
        else
            _data.ambient = {vol = 0.2,  abType = 'a10' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'a10' }
    end

    -- SR.log("ambient STATUS"..SR.JSON:encode(_data.ambient).."\n\n")
    return _data
end


--for A10C2

local _a10c2 = {}
_a10c2.enc = false
_a10c2.encKey = 1

function SR.exportRadioA10C2(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = true, dcsRadioSwitch = true, intercomHotMic = false, desc = "Using cockpit PTT (HOTAS Mic Switch) requires use of VoIP bindings." }

    -- Check if player is in a new aircraft
    if _lastUnitId ~= _data.unitId then
        -- New aircraft; Reset volumes to 100%
        local _device = GetDevice(0)

        if _device then
            _device:set_argument_value(133, 1.0) -- VHF AM
            _device:set_argument_value(171, 1.0) -- UHF
            _device:set_argument_value(147, 1.0) -- VHF FM
            _a10c2.enc = false
            _a10c2.encKey = 1
        end
    end

    -- VHF AM
    -- Set radio data
    _data.radios[2].name = "AN/ARC-210 VHF/UHF"
    _data.radios[2].freq = SR.getRadioFrequency(55)
    _data.radios[2].modulation = SR.getRadioModulation(55)
    _data.radios[2].volume = SR.getRadioVolume(0, 133, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 238, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 225, { 0.0, 1.0 }, false) * SR.getButtonPosition(226)
    _data.radios[2].encMode = 2 -- Mode 2 is set by aircraft

    --18 : {"PREV":"PREV","comsec_mode":"KY-58 VOICE","comsec_submode":"CT","dot_mark":".","freq_label_khz":"000","freq_label_mhz":"124","ky_submode_label":"1","lower_left_corner_arc210":"","modulation_label":"AM","prev_manual_freq":"---.---","txt_RT":"RT1"}
    -- 18 : {"PREV":"PREV","comsec_mode":"KY-58 VOICE","comsec_submode":"CT-TD","dot_mark":".","freq_label_khz":"000","freq_label_mhz":"124","ky_submode_label":"4","lower_left_corner_arc210":"","modulation_label":"AM","prev_manual_freq":"---.---","txt_RT":"RT1"}
    
    pcall(function() 
        local _radioDisplay = SR.getListIndicatorValue(18)

        if _radioDisplay.comsec_submode and _radioDisplay.comsec_submode == "PT" then
            
            _a10c2.encKey = tonumber(_radioDisplay.ky_submode_label)
            _a10c2.enc = false

        elseif _radioDisplay.comsec_submode and (_radioDisplay.comsec_submode == "CT-TD" or _radioDisplay.comsec_submode == "CT") then

            _a10c2.encKey = tonumber(_radioDisplay.ky_submode_label)
            _a10c2.enc = true
         
        end
    end)
    

    _data.radios[2].encKey = _a10c2.encKey
    _data.radios[2].enc = _a10c2.enc

    -- CREDIT: Recoil - thank you!
    -- Check ARC-210 function mode (0 = OFF, 1 = TR+G, 2 = TR, 3 = ADF, 4 = CHG PRST, 5 = TEST, 6 = ZERO)
    local arc210ModeKnob = SR.getSelectorPosition(551, 0.1)
    if arc210ModeKnob == 1 and _data.radios[2].freq > 1000 then
        -- Function dial set to TR+G
        -- Listen to Guard as well as designated frequency
        if (_data.radios[2].freq >= (108.0 * 1000000)) and (_data.radios[2].freq < (156.0 * 1000000)) then
            -- Frequency between 108.0 and 156.0 MHz, using VHF Guard
            _data.radios[2].secFreq = 121.5 * 1000000
        else
            -- Other frequency, using UHF Guard
            _data.radios[2].secFreq = 243.0 * 1000000
        end
    else
        -- Function dial set to OFF, TR, ADF, CHG PRST, TEST or ZERO
        -- Not listening to Guard secondarily
        _data.radios[2].secFreq = 0
    end

    -- UHF
    -- Set radio data
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = SR.getRadioFrequency(54)
    
    local modulation = SR.getSelectorPosition(162, 0.1)

    --is HQ selected (A on the Radio)
    if modulation == 2 then
        _data.radios[3].modulation = 4
    else
        _data.radios[3].modulation = 0
    end

    _data.radios[3].volume = SR.getRadioVolume(0, 171, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 238, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 227, { 0.0, 1.0 }, false) * SR.getButtonPosition(228)
    _data.radios[3].encMode = 2 -- Mode 2 is set by aircraft

    -- Check UHF frequency mode (0 = MNL, 1 = PRESET, 2 = GRD)
    local _selector = SR.getSelectorPosition(167, 0.1)
    if _selector == 1 then
        -- Using UHF preset channels
        local _channel = SR.getSelectorPosition(161, 0.05) + 1 --add 1 as channel 0 is channel 1
        _data.radios[3].channel = _channel
    end

    -- Check UHF function mode (0 = OFF, 1 = MAIN, 2 = BOTH, 3 = ADF)
    local uhfModeKnob = SR.getSelectorPosition(168, 0.1)
    if uhfModeKnob == 2 and _data.radios[3].freq > 1000 then
        -- Function dial set to BOTH
        -- Listen to Guard as well as designated frequency
        _data.radios[3].secFreq = 243.0 * 1000000
    else
        -- Function dial set to OFF, MAIN, or ADF
        -- Not listening to Guard secondarily
        _data.radios[3].secFreq = 0
    end

    -- VHF FM
    -- Set radio data
    _data.radios[4].name = "AN/ARC-186(V)FM"
    _data.radios[4].freq = SR.getRadioFrequency(56)
    _data.radios[4].modulation = 1
    _data.radios[4].volume = SR.getRadioVolume(0, 147, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 238, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 223, { 0.0, 1.0 }, false) * SR.getButtonPosition(224)
    _data.radios[4].encMode = 2 -- mode 2 enc is set by aircraft & turned on by aircraft


    -- KY-58 Radio Encryption
    -- Check if encryption is being used
    local _ky58Power = SR.getButtonPosition(784)
    if _ky58Power > 0.5 and SR.getButtonPosition(783) == 0 then
        -- mode switch set to OP and powered on
        -- Power on!

        local _radio = nil
        if SR.round(SR.getButtonPosition(781), 0.1) == 0.2 and SR.getSelectorPosition(149, 0.1) >= 2 then -- encryption disabled when EMER AM/FM selected
            --crad/2 vhf - FM
            _radio = _data.radios[4]
        elseif SR.getButtonPosition(781) == 0 and _selector ~= 2 then -- encryption disabled when GRD selected
            --crad/1 uhf
            _radio = _data.radios[3]
        end

        -- Get encryption key
        local _channel = SR.getSelectorPosition(782, 0.1) + 1

        if _radio ~= nil and _channel ~= nil then
            -- Set encryption key for selected radio
            _radio.encKey = _channel
            _radio.enc = true
        end
    end

 -- Mic Switch Radio Select and Transmit - by Dyram
    -- Check Mic Switch position (UP: 751 1.0, DOWN: 751 -1.0, FWD: 752 1.0, AFT: 752 -1.0)
    -- ED broke this as part of the VoIP work
    if SR.getButtonPosition(752) == 1 then
        -- Mic Switch FWD pressed
        -- Check Intercom panel Rotary Selector Dial (0: INT, 1: FM, 2: VHF, 3: HF, 4: "")
        if SR.getSelectorPosition(239, 0.1) == 2 then
            -- Intercom panel set to VHF
            _data.selected = 1 -- radios[2] VHF AM
            _data.ptt = true
        elseif SR.getSelectorPosition(239, 0.1) == 0 then
            -- Intercom panel set to INT
            -- Intercom not functional, but select it anyway to be proper
            _data.selected = 0 -- radios[1] Intercom
        else
            _data.selected = -1
        end
    elseif SR.getButtonPosition(751) == -1 then
        -- Mic Switch DOWN pressed
        _data.selected = 2 -- radios[3] UHF
        _data.ptt = true
    elseif SR.getButtonPosition(752) == -1 then
        -- Mic Switch AFT pressed
        _data.selected = 3 -- radios[4] VHF FM
        _data.ptt = true
    else
        -- Mic Switch released
        _data.selected = -1
        _data.ptt = false
    end

    _data.control = 1 -- Overlay  

    -- Handle transponder

    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getSelectorPosition(200,0.1)

    local iffIdent =  SR.getButtonPosition(207) -- -1 is off 0 or more is on

    if iffPower >= 2 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end

        -- SR.log("IFF iffIdent"..iffIdent.."\n\n")
        -- MIC mode switch - if you transmit on UHF then also IDENT
        -- https://github.com/ciribob/DCS-SimpleRadioStandalone/issues/408
        if iffIdent == -1 then

            _data.iff.mic = 2

            if _data.ptt and _data.selected == 2 then
                _data.iff.status = 2 -- IDENT (BLINKY THING)
            end
        end
    end

    local mode1On =  SR.getButtonPosition(202)

    _data.iff.mode1 = SR.round(SR.getButtonPosition(209), 0.1)*100+SR.round(SR.getButtonPosition(210), 0.1)*10

    if mode1On ~= 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(204)

    _data.iff.mode3 = SR.round(SR.getButtonPosition(211), 0.1) * 10000 + SR.round(SR.getButtonPosition(212), 0.1) * 1000 + SR.round(SR.getButtonPosition(213), 0.1)* 100 + SR.round(SR.getButtonPosition(214), 0.1) * 10

    if mode3On ~= 0 then
        _data.iff.mode3 = -1
    elseif iffPower == 4 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(208)

    if mode4On ~= 0 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(7)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.3,  abType = 'a10' }
        else
            _data.ambient = {vol = 0.2,  abType = 'a10' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'a10' }
    end

    -- SR.log("IFF STATUS"..SR.JSON:encode(_data.iff).."\n\n")
    return _data
end

local _fa18 = {}
_fa18.radio1 = {}
_fa18.radio2 = {}
_fa18.radio3 = {}
_fa18.radio4 = {}
_fa18.radio1.guard = 0
_fa18.radio2.guard = 0
_fa18.radio3.channel = 127 --127 is disabled for MIDS
_fa18.radio4.channel = 127
 -- initial IFF status set to -1 to indicate its not initialized, status then set depending on cold/hot start
_fa18.iff = {
    status=-1,
    mode1=-1,
    mode2=-1,
    mode3=-1,
    mode4=true,
    control=0,
    expansion=false,
}
_fa18.enttries = 0
_fa18.mode3opt =  ""    -- to distinguish between 3 and 3/C while ED doesn't fix the different codes for those
_fa18.identEnd = 0      -- time to end IFF ident -(18 seconds)

--[[
From NATOPS - https://info.publicintelligence.net/F18-ABCD-000.pdf (VII-23-2)

ARC-210(RT-1556 and DCS)

Frequency Band(MHz) Modulation  Guard Channel (MHz)
    30 to 87.995        FM
    *108 to 135.995     AM          121.5
    136 to 155.995      AM/FM
    156 to 173.995      FM
    225 to 399.975      AM/FM       243.0 (AM)

*Cannot transmit on 108 thru 117.995 MHz
]]--

function SR.exportRadioFA18C(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    local _ufc = SR.getListIndicatorValue(6)

    --{
    --   "UFC_Comm1Display": " 1",
    --   "UFC_Comm2Display": " 8",
    --   "UFC_MainDummy": "",
    --   "UFC_OptionCueing1": ":",
    --   "UFC_OptionCueing2": ":",
    --   "UFC_OptionCueing3": "",
    --   "UFC_OptionCueing4": ":",
    --   "UFC_OptionCueing5": "",
    --   "UFC_OptionDisplay1": "GRCV",
    --   "UFC_OptionDisplay2": "SQCH",
    --   "UFC_OptionDisplay3": "CPHR",
    --   "UFC_OptionDisplay4": "AM  ",
    --   "UFC_OptionDisplay5": "MENU",
    --   "UFC_ScratchPadNumberDisplay": "257.000",
    --   "UFC_ScratchPadString1Display": " 8",
    --   "UFC_ScratchPadString2Display": "_",
    --   "UFC_mask": ""
    -- }
    --_data.radios[3].secFreq = 243.0 * 1000000
    -- reset state on aircraft switch
    if _lastUnitId ~= _data.unitId then
        _fa18.radio1.guard = 0
        _fa18.radio2.guard = 0
        _fa18.radio3.channel = 127 --127 is disabled for MIDS
        _fa18.radio4.channel = 127
        _fa18.iff = {status=-1,mode1=-1,mode2=-1,mode3=-1,mode4=true,control=0,expansion=false}
        _fa18ent = false
        _fa18.enttries = 0
        _fa18.mode3opt = ""
        _fa18.identEnd = 0
    end

    local getGuardFreq = function (freq,currentGuard,modulation)


        if freq > 1000000 then

            -- check if UFC is currently displaying the GRCV for this radio
            --and change state if so

            if _ufc and _ufc.UFC_OptionDisplay1 == "GRCV" then

                if _ufc.UFC_ScratchPadNumberDisplay then
                    local _ufcFreq = tonumber(_ufc.UFC_ScratchPadNumberDisplay)

                    -- if its the correct radio
                    if _ufcFreq and _ufcFreq * 1000000 == SR.round(freq,1000) then
                        if _ufc.UFC_OptionCueing1 == ":" then

                            -- GUARD changes based on the tuned frequency
                            if freq > 108*1000000
                                    and freq < 135.995*1000000
                                    and modulation == 0 then
                                return 121.5 * 1000000
                            end
                            if freq > 108*1000000
                                    and freq < 399.975*1000000
                                    and modulation == 0 then
                                return 243 * 1000000
                            end

                            return 0
                        else
                            return 0
                        end
                    end
                end
            end

            if currentGuard > 1000 then

                if freq > 108*1000000
                        and freq < 135.995*1000000
                        and modulation == 0 then

                    return 121.5 * 1000000
                end
                if freq > 108*1000000
                        and freq < 399.975*1000000
                        and modulation == 0 then

                    return 243 * 1000000
                end
            end

            return currentGuard

        else
            -- reset state
            return 0
        end

    end

    -- AN/ARC-210 - 1
    -- Set radio data
    local _radio = _data.radios[2]
    _radio.name = "AN/ARC-210 - 1"
    _radio.freq = SR.getRadioFrequency(38)
    _radio.modulation = SR.getRadioModulation(38)
    _radio.volume = SR.getRadioVolume(0, 108, { 0.0, 1.0 }, false)
    -- _radio.encMode = 2 -- Mode 2 is set by aircraft

    _fa18.radio1.guard = getGuardFreq(_radio.freq, _fa18.radio1.guard, _radio.modulation)
    _radio.secFreq = _fa18.radio1.guard

    -- AN/ARC-210 - 2
    -- Set radio data
    _radio = _data.radios[3]
    _radio.name = "AN/ARC-210 - 2"
    _radio.freq = SR.getRadioFrequency(39)
    _radio.modulation = SR.getRadioModulation(39)
    _radio.volume = SR.getRadioVolume(0, 123, { 0.0, 1.0 }, false)
-- _radio.encMode = 2 -- Mode 2 is set by aircraft

_fa18.radio2.guard = getGuardFreq(_radio.freq, _fa18.radio2.guard, _radio.modulation)
_radio.secFreq = _fa18.radio2.guard

-- KY-58 Radio Encryption
local _ky58Power = SR.round(SR.getButtonPosition(447), 0.1)
if _ky58Power == 0.1 and SR.round(SR.getButtonPosition(444), 0.1) == 0.1 then
    -- mode switch set to C and powered on
    -- Power on!

    -- Get encryption key
    local _channel = SR.getSelectorPosition(446, 0.1) + 1
    if _channel > 6 then
        _channel = 6 -- has two other options - lock to 6
    end

    _radio = _data.radios[2 + SR.getSelectorPosition(144, 0.3)]
    _radio.encMode = 2 -- Mode 2 is set by aircraft
    _radio.encKey = _channel
    _radio.enc = true

end


    -- MIDS

    -- MIDS A
    _radio = _data.radios[4]
    _radio.name = "MIDS A"
    _radio.modulation = 6
    _radio.volume = SR.getRadioVolume(0, 362, { 0.0, 1.0 }, false)
    _radio.encMode = 2 -- Mode 2 is set by aircraft

    local midsAChannel = _fa18.radio3.channel
    if midsAChannel < 127 then
        _radio.freq = SR.MIDS_FREQ +  (SR.MIDS_FREQ_SEPARATION * midsAChannel)
        _radio.channel = midsAChannel
    else
        _radio.freq = 1
        _radio.channel = -1
    end

    -- MIDS B
    _radio = _data.radios[5]
    _radio.name = "MIDS B"
    _radio.modulation = 6
    _radio.volume = SR.getRadioVolume(0, 361, { 0.0, 1.0 }, false)
    _radio.encMode = 2 -- Mode 2 is set by aircraft

    local midsBChannel = _fa18.radio4.channel
    if midsBChannel < 127 then
        _radio.freq = SR.MIDS_FREQ +  (SR.MIDS_FREQ_SEPARATION * midsBChannel)
        _radio.channel = midsBChannel
    else
        _radio.freq = 1
        _radio.channel = -1
    end

    -- IFF
    local iff = _fa18.iff

    -- set initial IFF status based on cold/hot start since it can't be read directly off the panel
    if iff.status == -1 then
        local batterySwitch = SR.getButtonPosition(404)

        if batterySwitch == 0 then
            -- cold start, everything off
            _fa18.iff = {status=0,mode1=-1,mode2=-1,mode3=-1,mode4=false,control=0,expansion=false}
        else
            -- hot start, M4 on
            _fa18.iff = {status=1,mode1=-1,mode2=-1,mode3=-1,mode4=true,control=0,expansion=false}
        end

        iff = _fa18.iff
    end

    -- Check if XP UFC is being displayed
    if _ufc and _ufc.UFC_OptionDisplay2 == "2   " then
        -- Check if on XP
        if _ufc.UFC_ScratchPadString1Display == "X" then
            if iff.status <= 0 then
                iff.status = 1
            end
            if _ufc.UFC_OptionCueing1 == ":" then
                local code = string.match(_ufc.UFC_OptionDisplay1, "1-%d%d")    -- actual code is displayed in the option display
                if code then
                    iff.mode1 = code
                end
            else
                iff.mode1 = -1
            end
            if _ufc.UFC_OptionCueing3 == ":" then
                if iff.mode3 == -1 or _fa18.mode3opt ~= _ufc.UFC_OptionDisplay3  then     -- just turned on
                    local code = string.match(_ufc.UFC_ScratchPadNumberDisplay, "3-[0-7][0-7][0-7][0-7]")
                    if code then
                        iff.mode3 = code
                    end
                    _fa18.mode3opt = _ufc.UFC_OptionDisplay3
                end
            else
                iff.mode3 = -1
            end
            iff.mode4 = _ufc.UFC_OptionCueing4 == ":"

        -- Check if on AI
        elseif _ufc.UFC_ScratchPadString1Display == "A" then
            if iff.status <= 0 then
                iff.status = 1
            end
        -- Check if it is OFF
        else
            iff.status = 0
        end
    end

    -- Mode 1/3 IDENT, requires mode 1 or mode 3 to be on and I/P pushbutton press
    if iff.status > 0 then
        if SR.getButtonPosition(99) == 1 and (iff.mode1 ~= -1 or iff.mode3 ~= -1) then
            _fa18.identEnd = LoGetModelTime() + 18
            iff.status = 2
        elseif iff.status == 2 and LoGetModelTime() >= _fa18.identEnd then
            iff.status = 1
        end
    end

    -- set current IFF settings
    _data.iff = _fa18.iff

    -- Parse ENT keypress
    if _fa18ent and _ufc then
        _fa18ent = false
        -- Check if on D/L page and D/L ON
        if _ufc.UFC_OptionDisplay4 == "VOCA" and _ufc.UFC_ScratchPadString1Display == "O" and _ufc.UFC_ScratchPadString2Display == "N" then
            -- Check if setting VOCA
            if _ufc.UFC_OptionCueing4 ==":" then
                local chan = tonumber(_ufc.UFC_ScratchPadNumberDisplay)
                if chan then
                    _fa18.radio3.channel = chan
                else
                    _fa18ent = true     -- wait until UFC scratchpad repopulates
                end
            -- Check if setting VOCB
            elseif _ufc.UFC_OptionCueing5 ==":" then
                local chan = tonumber(_ufc.UFC_ScratchPadNumberDisplay)
                if chan then
                    _fa18.radio4.channel = chan
                else
                    _fa18ent = true     -- wait until UFC scratchpad repopulates
                end
            end
        -- Check if on IFF XP page
        elseif _ufc.UFC_OptionDisplay2 == "2   " and _ufc.UFC_ScratchPadString1Display == "X" then
            local editingMode = string.sub(_ufc.UFC_ScratchPadNumberDisplay, 0, 2)
            if editingMode == "3-" then
                local code = string.match(_ufc.UFC_ScratchPadNumberDisplay, "3-[0-7][0-7][0-7][0-7]")
                if code then
                    _fa18.iff.mode3 = code
                else
                    _fa18ent = true     -- wait until UFC scratchpad repopulates
                end
            elseif editingMode == "" then
                _fa18ent = true     -- wait until UFC scratchpad repopulates
            end
        end

        if _fa18ent then
            _fa18.enttries = _fa18.enttries + 1
            if _fa18.enttries > 5 then
                _fa18ent = 0
                _fa18.enttries = 0
            end
        else
            _fa18.enttries = 0
        end
    end

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(181)

        if _door > 0.5 then 
            _data.ambient = {vol = 0.3,  abType = 'fa18' }
        else
            _data.ambient = {vol = 0.2,  abType = 'fa18' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'fa18' }
    end

    return _data
end

local _f16 = {}
_f16.radio1 = {}
_f16.radio1.guard = 0

function SR.exportRadioF16C(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }
    -- UHF
    _data.radios[2].name = "AN/ARC-164"
    _data.radios[2].freq = SR.getRadioFrequency(36)
    _data.radios[2].modulation = SR.getRadioModulation(36)
    _data.radios[2].volume = SR.getRadioVolume(0, 430, { 0.0, 1.0 }, false)
    _data.radios[2].encMode = 2

    -- C&I Backup/UFC by Raffson, aka Stoner
    local _cni = SR.getButtonPosition(542)
    if _cni == 0 then
        local _buhf_func = SR.getSelectorPosition(417, 0.1)
        if _buhf_func == 2 then
            -- Function set to BOTH --> also listen to guard
            _data.radios[2].secFreq = 243.0 * 1000000
        else
            _data.radios[2].secFreq = 0
        end

        -- Check UHF frequency mode (0 = MNL, 1 = PRESET, 2 = GRD)
        local _selector = SR.getSelectorPosition(416, 0.1)
        if _selector == 1 then
            -- Using UHF preset channels
            local _channel = SR.getSelectorPosition(410, 0.05) + 1 --add 1 as channel 0 is channel 1
            _data.radios[2].channel = _channel
        end
    else
        -- Parse the UFC - LOOK FOR BOTH (OR MAIN)
        local ded = SR.getListIndicatorValue(6)
        --PANEL 6{"Active Frequency or Channel":"305.00","Asterisks on Scratchpad_lhs":"*","Asterisks on Scratchpad_rhs":"*","Bandwidth":"NB","Bandwidth_placeholder":"","COM 1 Mode":"UHF","Preset Frequency":"305.00","Preset Frequency_placeholder":"","Preset Label":"PRE     a","Preset Number":" 1","Preset Number_placeholder":"","Receiver Mode":"BOTH","Scratchpad":"305.00","Scratchpad_placeholder":"","TOD Label":"TOD"}
        
        if ded and ded["Receiver Mode"] ~= nil and  ded["COM 1 Mode"] == "UHF" then
            if ded["Receiver Mode"] == "BOTH" then
                _f16.radio1.guard= 243.0 * 1000000
            else
                _f16.radio1.guard= 0
            end
        else
            if _data.radios[2].freq < 1000 then
                _f16.radio1.guard= 0
            end
        end

        _data.radios[2].secFreq = _f16.radio1.guard
            
     end

    -- VHF
    _data.radios[3].name = "AN/ARC-222"
    _data.radios[3].freq = SR.getRadioFrequency(38)
    _data.radios[3].modulation = SR.getRadioModulation(38)
    _data.radios[3].volume = SR.getRadioVolume(0, 431, { 0.0, 1.0 }, false)
    _data.radios[3].encMode = 2
    _data.radios[3].guardFreqMode = 1
    _data.radios[3].secFreq = 121.5 * 1000000

    -- KY-58 Radio Encryption
    local _ky58Power = SR.round(SR.getButtonPosition(707), 0.1)

    if _ky58Power == 0.5 and SR.round(SR.getButtonPosition(705), 0.1) == 0.1 then
        -- mode switch set to C and powered on
        -- Power on and correct mode selected
        -- Get encryption key
        local _channel = SR.getSelectorPosition(706, 0.1)

        local _cipherSwitch = SR.round(SR.getButtonPosition(701), 1)
        local _radio = nil
        if _cipherSwitch > 0.5 then
            -- CRAD1 (UHF)
            _radio = _data.radios[2]
        elseif _cipherSwitch < -0.5 then
            -- CRAD2 (VHF)
            _radio = _data.radios[3]
        end
        if _radio ~= nil and _channel > 0 and _channel < 7 then
            _radio.encKey = _channel
            _radio.enc = true
            _radio.volume = SR.getRadioVolume(0, 708, { 0.0, 1.0 }, false) * SR.getRadioVolume(0, 432, { 0.0, 1.0 }, false)--User KY-58 volume if chiper is used
        end
    end

    local _cipherOnly =  SR.round(SR.getButtonPosition(443),1) < -0.5 --If HOT MIC CIPHER Switch, HOT MIC / OFF / CIPHER set to CIPHER, allow only cipher
    if _cipherOnly and _data.radios[3].enc ~=true then
        _data.radios[3].freq = 0
    end
    if _cipherOnly and _data.radios[2].enc ~=true then
        _data.radios[2].freq = 0
    end

    _data.control = 0; -- SRS Hotas Controls

    -- Handle transponder

    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getSelectorPosition(540,0.1)

    local iffIdent =  SR.getButtonPosition(125) -- -1 is off 0 or more is on

    if iffPower >= 2 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end

    end

    local modeSelector =  SR.getButtonPosition(553)

    if modeSelector == -1 then

        --shares a dial with the mode 3, limit number to max 3
        local _secondDigit = SR.round(SR.getButtonPosition(548), 0.1)*10

        if _secondDigit > 3 then
            _secondDigit = 3
        end

        _data.iff.mode1 = SR.round(SR.getButtonPosition(546), 0.1)*100 + _secondDigit
    else
        _data.iff.mode1 = -1
    end

    if modeSelector ~= 0 then
        _data.iff.mode3 = SR.round(SR.getButtonPosition(546), 0.1) * 10000 + SR.round(SR.getButtonPosition(548), 0.1) * 1000 + SR.round(SR.getButtonPosition(550), 0.1)* 100 + SR.round(SR.getButtonPosition(552), 0.1) * 10
    else
        _data.iff.mode3 = -1
    end

    if iffPower == 4 and modeSelector ~= 0 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(541)

    local mode4Code = SR.getButtonPosition(543)

    if mode4On == 0 and mode4Code ~= -1 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    -- SR.log("IFF STATUS"..SR.JSON:encode(_data.iff).."\n\n")

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(7)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.3,  abType = 'f16' }
        else
            _data.ambient = {vol = 0.2,  abType = 'f16' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'f16' }
    end

    return _data
end

function SR.exportRadioF86Sabre(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "Only one radio by default" }

    _data.radios[2].name = "AN/ARC-27"
    _data.radios[2].freq = SR.getRadioFrequency(26)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 806, { 0.1, 0.9 }, false)

    -- get channel selector
    local _channel = SR.getSelectorPosition(807, 0.01)

    if _channel >= 1 then
        _data.radios[2].channel = _channel
    end

    _data.selected = 1

    --guard mode for UHF Radio
    local uhfModeKnob = SR.getSelectorPosition(805, 0.1)
    if uhfModeKnob == 2 and _data.radios[2].freq > 1000 then
        _data.radios[2].secFreq = 243.0 * 1000000
    end

    -- Check PTT
    if (SR.getButtonPosition(213)) > 0.5 then
        _data.ptt = true
    else
        _data.ptt = false
    end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 0; -- Hotas Controls

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(181)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.3,  abType = 'f86' }
        else
            _data.ambient = {vol = 0.2,  abType = 'f86' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'f86' }
    end

    return _data;
end

function SR.exportRadioMIG15(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "Only one radio by default" }

    _data.radios[2].name = "RSI-6K"
    _data.radios[2].freq = SR.getRadioFrequency(30)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 126, { 0.1, 0.9 }, false)

    _data.selected = 1

    -- Check PTT
    if (SR.getButtonPosition(202)) > 0.5 then
        _data.ptt = true
    else
        _data.ptt = false
    end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting


    _data.control = 0; -- Hotas Controls radio

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(225)

        if _door > 0.3 then 
            _data.ambient = {vol = 0.3,  abType = 'mig15' }
        else
            _data.ambient = {vol = 0.2,  abType = 'mig15' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'mig15' }
    end

    return _data;
end

function SR.exportRadioMIG19(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "Only one radio by default" }

    _data.radios[2].name = "RSIU-4V"
    _data.radios[2].freq = SR.getRadioFrequency(17)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 327, { 0.0, 1.0 }, false)

    _data.selected = 1

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting


    _data.control = 0; -- Hotas Controls radio

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(433)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.3,  abType = 'mig19' }
        else
            _data.ambient = {vol = 0.2,  abType = 'mig19' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'mig19' }
    end

    return _data;
end

function SR.exportRadioMIG21(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "Only one radio by default" }

    _data.radios[2].name = "R-832"
    _data.radios[2].freq = SR.getRadioFrequency(22)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 210, { 0.0, 1.0 }, false)

    _data.radios[2].channel = SR.getSelectorPosition(211, 0.05)

    _data.selected = 1

    if (SR.getButtonPosition(315)) > 0.5 then
        _data.ptt = true
    else
        _data.ptt = false
    end

   -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting


    _data.control = 0; -- hotas radio

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(1)

        if _door > 0.15 then 
            _data.ambient = {vol = 0.3,  abType = 'mig21' }
        else
            _data.ambient = {vol = 0.2,  abType = 'mig21' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'mig21' }
    end

    return _data;
end

function SR.exportRadioF5E(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = false, desc = "Only one radio by default" }

    _data.radios[2].name = "AN/ARC-164"
    _data.radios[2].freq = SR.getRadioFrequency(23)
    _data.radios[2].volume = SR.getRadioVolume(0, 309, { 0.0, 1.0 }, false)

    local modulation = SR.getSelectorPosition(327, 0.1)

    --is HQ selected (A on the Radio)
    if modulation == 0 then
        _data.radios[2].modulation = 4
    else
        _data.radios[2].modulation = 0
    end

    -- get channel selector
    local _selector = SR.getSelectorPosition(307, 0.1)

    if _selector == 1 then
        _data.radios[2].channel = SR.getSelectorPosition(300, 0.05) + 1 --add 1 as channel 0 is channel 1
    end

    _data.selected = 1

    --guard mode for UHF Radio
    local uhfModeKnob = SR.getSelectorPosition(311, 0.1)

    if uhfModeKnob == 2 and _data.radios[2].freq > 1000 then
        _data.radios[2].secFreq = 243.0 * 1000000
    end

    -- Check PTT - By Tarres!
    --NWS works as PTT when wheels up
    if (SR.getButtonPosition(135) > 0.5 or (SR.getButtonPosition(131) > 0.5 and SR.getButtonPosition(83) > 0.5)) then
        _data.ptt = true
    else
        _data.ptt = false
    end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 0; -- hotas radio

    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getSelectorPosition(200,0.1)

    local iffIdent =  SR.getButtonPosition(207) -- -1 is off 0 or more is on

    if iffPower >= 2 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end

        -- SR.log("IFF iffIdent"..iffIdent.."\n\n")
        -- MIC mode switch - if you transmit on UHF then also IDENT
        -- https://github.com/ciribob/DCS-SimpleRadioStandalone/issues/408
        if iffIdent == -1 then

            _data.iff.mic = 2

            if _data.ptt and _data.selected == 2 then
                _data.iff.status = 2 -- IDENT (BLINKY THING)
            end
        end
    end

    local mode1On =  SR.getButtonPosition(202)

    _data.iff.mode1 = SR.round(SR.getButtonPosition(209), 0.1)*100+SR.round(SR.getButtonPosition(210), 0.1)*10

    if mode1On ~= 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(204)

    _data.iff.mode3 = SR.round(SR.getButtonPosition(211), 0.1) * 10000 + SR.round(SR.getButtonPosition(212), 0.1) * 1000 + SR.round(SR.getButtonPosition(213), 0.1)* 100 + SR.round(SR.getButtonPosition(214), 0.1) * 10

    if mode3On ~= 0 then
        _data.iff.mode3 = -1
    elseif iffPower == 4 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(208)

    if mode4On ~= 0 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(181)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.3,  abType = 'f5' }
        else
            _data.ambient = {vol = 0.2,  abType = 'f5' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'f5' }
    end

    return _data;
end

function SR.exportRadioP51(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "Only one radio by default" }

    _data.radios[2].name = "SCR522A"
    _data.radios[2].freq = SR.getRadioFrequency(24)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 116, { 0.0, 1.0 }, false)

    _data.selected = 1

    if (SR.getButtonPosition(44)) > 0.5 then
        _data.ptt = true
    else
        _data.ptt = false
    end

-- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 0; -- hotas radio

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(162)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.35,  abType = 'p51' }
        else
            _data.ambient = {vol = 0.2,  abType = 'p51' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'p51' }
    end

    return _data;
end


function SR.exportRadioP47(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "Only one radio by default" }

    _data.radios[2].name = "SCR522"
    _data.radios[2].freq = SR.getRadioFrequency(23)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 77, { 0.0, 1.0 }, false)

    _data.selected = 1

    --Cant find the button in the cockpit?
    if (SR.getButtonPosition(44)) > 0.5 then
        _data.ptt = true
    else
        _data.ptt = false
    end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting
    _data.control = 0; -- hotas radio

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(38)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.35,  abType = 'p47' }
        else
            _data.ambient = {vol = 0.2,  abType = 'p47' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'p47' }
    end

    return _data;
end

function SR.exportRadioFW190(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[2].name = "FuG 16ZY"
    _data.radios[2].freq = SR.getRadioFrequency(15)
    _data.radios[2].modulation = 0

    local _volRaw = GetDevice(0):get_argument_value(83)
    if _volRaw >= 0 and _volRaw <= 0.25 then
        _data.radios[2].volume = (1.0 - SR.getRadioVolume(0, 83,{0,0.5},true)) + 0.5 -- Volume knob is not behaving..
    else
        _data.radios[2].volume = ((1.0 - SR.getRadioVolume(0, 83,{0,0.5},true)) - 0.5) * -1.0 -- ABS
    end

    _data.selected = 1


    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting
    _data.control = 0; -- hotas radio

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(194)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.35,  abType = 'fw190' }
        else
            _data.ambient = {vol = 0.2,  abType = 'fw190' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'fw190' }
    end

    return _data;
end

function SR.exportRadioBF109(_data)
    _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }
    
    _data.radios[2].name = "FuG 16ZY"
    _data.radios[2].freq = SR.getRadioFrequency(14)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 130, { 0.0, 1.0 }, false)

    if (SR.getButtonPosition(150)) > 0.5 then
        _data.ptt = true
    else
        _data.ptt = false
    end

    _data.selected = 1

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting
    _data.control = 0; -- hotas radio

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(95)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.35,  abType = 'bf109' }
        else
            _data.ambient = {vol = 0.2,  abType = 'bf109' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'bf109' }
    end

    return _data;
end

function SR.exportRadioSpitfireLFMkIX (_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[2].name = "A.R.I. 1063" --minimal bug in the ME GUI and in the LUA. SRC5222 is the P-51 radio.
    _data.radios[2].freq = SR.getRadioFrequency(15)
    _data.radios[2].modulation = 0
    _data.radios[2].volMode = 1
    _data.radios[2].volume = 1.0 --no volume control

    _data.selected = 1

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting
    _data.control = 0; -- no ptt, same as the FW and 109. No connector.

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(138)

        if _door > 0.1 then 
            _data.ambient = {vol = 0.35,  abType = 'spitfire' }
        else
            _data.ambient = {vol = 0.2,  abType = 'spitfire' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'spitfire' }
    end

    return _data;
end

function SR.exportRadioMosquitoFBMkVI (_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[1].name = "INTERCOM"
    _data.radios[1].freq = 100
    _data.radios[1].modulation = 2
    _data.radios[1].volume = 1.0
    _data.radios[1].volMode = 1

    _data.radios[2].name = "SCR522A" 
    _data.radios[2].freq = SR.getRadioFrequency(24)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 364, { 0.0, 1.0 }, false)

    local _seat = SR.lastKnownSeat

    if _seat == 0 then

         _data.capabilities = { dcsPtt = true, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

        local ptt =  SR.getButtonPosition(4)

        if ptt == 1 then
            _data.ptt = true
        end
    else
         _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }
    end

    _data.radios[3].name = "R1155" 
    _data.radios[3].freq = SR.getRadioFrequency(27,500,true)
    _data.radios[3].modulation = 0
    _data.radios[3].volume = SR.getRadioVolume(0, 229, { 0.0, 1.0 }, false)

    _data.radios[4].name = "T1154" 
    _data.radios[4].freq = SR.getRadioFrequency(26,500,true)
    _data.radios[4].modulation = 0
    _data.radios[4].volume = 1
    _data.radios[4].volMode = 1


    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting
    _data.control = 0; -- no ptt, same as the FW and 109. No connector.
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _doorLeft = SR.getButtonPosition(250)
        local _doorRight = SR.getButtonPosition(252)

        if _doorLeft > 0.7 or _doorRight > 0.7 then 
            _data.ambient = {vol = 0.35,  abType = 'mosquito' }
        else
            _data.ambient = {vol = 0.2,  abType = 'mosquito' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'mosquito' }
    end

    return _data;
end


function SR.exportRadioC101EB(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = true, intercomHotMic = true, desc = "Pull the HOT MIC breaker up to enable HOT MIC" }

    _data.radios[1].name = "INTERCOM"
    _data.radios[1].freq = 100
    _data.radios[1].modulation = 2
    _data.radios[1].volume = SR.getRadioVolume(0, 403, { 0.0, 1.0 }, false)

    _data.radios[2].name = "AN/ARC-164 UHF"
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 234, { 0.0, 1.0 }, false)

    local _selector = SR.getSelectorPosition(232, 0.25)

    if _selector ~= 0 then
        _data.radios[2].freq = SR.getRadioFrequency(11)
    else
        _data.radios[2].freq = 1
    end

    -- UHF Guard
    if _selector == 2 then
        _data.radios[2].secFreq = 243.0 * 1000000
    end

    _data.radios[3].name = "AN/ARC-134"
    _data.radios[3].modulation = 0
    _data.radios[3].volume = SR.getRadioVolume(0, 412, { 0.0, 1.0 }, false)

    _data.radios[3].freq = SR.getRadioFrequency(10)

    local _seat = GetDevice(0):get_current_seat()

    local _selector

    if _seat == 0 then
        _selector = SR.getSelectorPosition(404, 0.5)
    else
        _selector = SR.getSelectorPosition(947, 0.5)
    end

    if _selector == 1 then
        _data.selected = 1
    elseif _selector == 2 then
        _data.selected = 2
    else
        _data.selected = 0
    end

    --TODO figure our which cockpit you're in? So we can have controls working in the rear?

    -- Handle transponder

    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getSelectorPosition(347,0.25)

   -- SR.log("IFF iffPower"..iffPower.."\n\n")

    local iffIdent =  SR.getButtonPosition(361) -- -1 is off 0 or more is on

    if iffPower <= 2 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end

        -- SR.log("IFF iffIdent"..iffIdent.."\n\n")
        -- MIC mode switch - if you transmit on UHF then also IDENT
        -- https://github.com/ciribob/DCS-SimpleRadioStandalone/issues/408
        if iffIdent == -1 then

            _data.iff.mic = 1

            if _data.ptt and _data.selected == 2 then
                _data.iff.status = 2 -- IDENT (BLINKY THING)
            end
        end
    end

    local mode1On =  SR.getButtonPosition(349)

    _data.iff.mode1 = SR.round(SR.getButtonPosition(355), 0.1)*100+SR.round(SR.getButtonPosition(356), 0.1)*10

    if mode1On == 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(351)

    _data.iff.mode3 = SR.round(SR.getButtonPosition(357), 0.1) * 10000 + SR.round(SR.getButtonPosition(358), 0.1) * 1000 + SR.round(SR.getButtonPosition(359), 0.1)* 100 + SR.round(SR.getButtonPosition(360), 0.1) * 10

    if mode3On == 0 then
        _data.iff.mode3 = -1
    elseif iffPower == 0 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(354)

    if mode4On ~= 0 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end
    _data.control = 1; -- full radio

    local frontHotMic =  SR.getButtonPosition(287)
    local rearHotMic =   SR.getButtonPosition(891)
    -- only if The hot mic talk button (labeled TALK in cockpit) is up
    if frontHotMic == 1 or rearHotMic == 1 then
       _data.intercomHotMic = true
    end

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _doorLeft = SR.getButtonPosition(1)
        local _doorRight = SR.getButtonPosition(301)

        if _doorLeft > 0.7 or _doorRight > 0.7 then 
            _data.ambient = {vol = 0.3,  abType = 'c101' }
        else
            _data.ambient = {vol = 0.2,  abType = 'c101' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'c101' }
    end

    return _data;
end

function SR.exportRadioC101CC(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = true, intercomHotMic = true, desc = "The hot mic talk button (labeled TALK in cockpit) must be pulled out" }

    -- TODO - figure out channels.... it saves state??
    -- figure out volume
    _data.radios[1].name = "INTERCOM"
    _data.radios[1].freq = 100
    _data.radios[1].modulation = 2
    _data.radios[1].volume = SR.getRadioVolume(0, 403, { 0.0, 1.0 }, false)

    _data.radios[2].name = "V/TVU-740"
    _data.radios[2].freq = SR.getRadioFrequency(11)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = 1.0--SR.getRadioVolume(0, 234,{0.0,1.0},false)
    _data.radios[2].volMode = 1

    local _channel = SR.getButtonPosition(231)

    -- SR.log("Channel SELECTOR: ".. SR.getButtonPosition(231).."\n")


    local uhfModeKnob = SR.getSelectorPosition(232, 0.1)
    if uhfModeKnob == 2 and _data.radios[2].freq > 1000 then
        -- Function dial set to BOTH
        -- Listen to Guard as well as designated frequency
        _data.radios[2].secFreq = 243.0 * 1000000
    else
        -- Function dial set to OFF, MAIN, or ADF
        -- Not listening to Guard secondarily
        _data.radios[2].secFreq = 0
    end

    _data.radios[3].name = "VHF-20B"
    _data.radios[3].modulation = 0
    _data.radios[3].volume = 1.0 --SR.getRadioVolume(0, 412,{0.0,1.0},false)
    _data.radios[3].volMode = 1

    --local _vhfPower = SR.getSelectorPosition(413,1.0)
    --
    --if _vhfPower == 1 then
    _data.radios[3].freq = SR.getRadioFrequency(10)
    --else
    --    _data.radios[3].freq = 1
    --end
    --
    local _seat = GetDevice(0):get_current_seat()
    local _selector

    if _seat == 0 then
        _selector = SR.getSelectorPosition(404, 0.05)
    else
        _selector = SR.getSelectorPosition(947, 0.05)
    end

    if _selector == 0 then
        _data.selected = 0
    elseif _selector == 2 then
        _data.selected = 2
    elseif _selector == 12 then
        _data.selected = 1
    else
        _data.selected = -1
    end

    --TODO figure our which cockpit you're in? So we can have controls working in the rear?

    -- Handle transponder

    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getSelectorPosition(347,0.25)

    --SR.log("IFF iffPower"..iffPower.."\n\n")

    local iffIdent =  SR.getButtonPosition(361) -- -1 is off 0 or more is on

    if iffPower <= 2 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end

        -- SR.log("IFF iffIdent"..iffIdent.."\n\n")
        -- MIC mode switch - if you transmit on UHF then also IDENT
        -- https://github.com/ciribob/DCS-SimpleRadioStandalone/issues/408
        if iffIdent == -1 then

            _data.iff.mic = 1

            if _data.ptt and _data.selected == 2 then
                _data.iff.status = 2 -- IDENT (BLINKY THING)
            end
        end
    end

    local mode1On =  SR.getButtonPosition(349)

    _data.iff.mode1 = SR.round(SR.getButtonPosition(355), 0.1)*100+SR.round(SR.getButtonPosition(356), 0.1)*10

    if mode1On == 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(351)

    _data.iff.mode3 = SR.round(SR.getButtonPosition(357), 0.1) * 10000 + SR.round(SR.getButtonPosition(358), 0.1) * 1000 + SR.round(SR.getButtonPosition(359), 0.1)* 100 + SR.round(SR.getButtonPosition(360), 0.1) * 10

    if mode3On == 0 then
        _data.iff.mode3 = -1
    elseif iffPower == 0 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(354)

    if mode4On ~= 0 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    _data.control = 1;


    local frontHotMic =  SR.getButtonPosition(287)
    local rearHotMic =   SR.getButtonPosition(891)
    -- only if The hot mic talk button (labeled TALK in cockpit) is up
    if frontHotMic == 1 or rearHotMic == 1 then
       _data.intercomHotMic = true
    end

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _doorLeft = SR.getButtonPosition(1)
        local _doorRight = SR.getButtonPosition(301)

        if _doorLeft > 0.7 or _doorRight > 0.7 then 
            _data.ambient = {vol = 0.3,  abType = 'c101' }
        else
            _data.ambient = {vol = 0.2,  abType = 'c101' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'c101' }
    end

    return _data;
end


function SR.exportRadioMB339A(_data)
    _data.capabilities = { dcsPtt = true, dcsIFF = true, dcsRadioSwitch = true, intercomHotMic = false, desc = "To enable the Intercom HotMic pull the INT knob located on ICS" }

    local main_panel = GetDevice(0)

    local intercom_device_id = main_panel:get_srs_device_id(0)
    local comm1_device_id = main_panel:get_srs_device_id(1)
    local comm2_device_id = main_panel:get_srs_device_id(2)
    local iff_device_id = main_panel:get_srs_device_id(3)
    
    local ARC150_device = GetDevice(comm1_device_id)
    local SRT_651_device = GetDevice(comm2_device_id)
    local intercom_device = GetDevice(intercom_device_id)
    local iff_device = GetDevice(iff_device_id)

    -- Intercom Function
    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100
    _data.radios[1].modulation = 2
    _data.radios[1].volume = intercom_device:get_volume()

    -- AN/ARC-150(V)2 - COMM1 Radio
    _data.radios[2].name = "AN/ARC-150(V)2 - UHF COMM1"
    _data.radios[2].freqMin = 225 * 1000000
    _data.radios[2].freqMax = 399.975 * 1000000
    _data.radios[2].freq = ARC150_device:is_on() and SR.round(ARC150_device:get_frequency(), 5000) or 0
    _data.radios[2].secFreq = ARC150_device:is_on_guard() and 243.0 * 1000000 or 0
    _data.radios[2].modulation = ARC150_device:get_modulation()
    _data.radios[2].volume = ARC150_device:get_volume()

    -- SRT-651/N - COMM2 Radio
    _data.radios[3].name = "SRT-651/N - V/UHF COMM2"
    _data.radios[3].freqMin = 30 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].freq = SRT_651_device:is_on() and SR.round(SRT_651_device:get_frequency(), 5000) or 0
    _data.radios[3].secFreq = SRT_651_device:is_on_guard() and 243.0 * 1000000 or 0
    _data.radios[3].modulation = SRT_651_device:get_modulation()
    _data.radios[3].volume = SRT_651_device:get_volume()

    _data.intercomHotMic = intercom_device:is_hot_mic()

    if intercom_device:is_ptt_pressed() then
        _data.selected = 0
        _data.ptt = true
    elseif ARC150_device:is_ptt_pressed() then
        _data.selected = 1
        _data.ptt = true
    elseif SRT_651_device:is_ptt_pressed() then
        _data.selected = 2
        _data.ptt = true
    else
        _data.ptt = false
    end

    _data.control = 1 -- enables complete radio control

    -- IFF status depend on ident switch as well
    local iff_status
    if iff_device:is_identing() then
        iff_status = 2 -- IDENT
    elseif iff_device:is_working() then
        iff_status = 1 -- NORMAL
    else
        iff_status = 0 -- OFF
    end

    -- IFF trasponder
    _data.iff = {
        status = iff_status,
        mode1 = iff_device:get_mode1_code(),
        mode2=-1,
        mode3 = iff_device:get_mode3_code(),
        -- Mode 4 - not available in real MB-339 but we have decided to include it for gameplay
        mode4 = iff_device:is_mode4_working(),
        control = 0,
        expansion = false
    }

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'MB339' }
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'MB339' }
    end

    return _data;
end

function SR.exportRadioHawk(_data)

    local MHZ = 1000000

    _data.radios[2].name = "AN/ARC-164 UHF"

    local _selector = SR.getSelectorPosition(221, 0.25)

    if _selector == 1 or _selector == 2 then

        local _hundreds = SR.getSelectorPosition(226, 0.25) * 100 * MHZ
        local _tens = SR.round(SR.getKnobPosition(0, 227, { 0.0, 0.9 }, { 0, 9 }), 0.1) * 10 * MHZ
        local _ones = SR.round(SR.getKnobPosition(0, 228, { 0.0, 0.9 }, { 0, 9 }), 0.1) * MHZ
        local _tenth = SR.round(SR.getKnobPosition(0, 229, { 0.0, 0.9 }, { 0, 9 }), 0.1) * 100000
        local _hundreth = SR.round(SR.getKnobPosition(0, 230, { 0.0, 0.3 }, { 0, 3 }), 0.1) * 10000

        _data.radios[2].freq = _hundreds + _tens + _ones + _tenth + _hundreth
    else
        _data.radios[2].freq = 1
    end
    _data.radios[2].modulation = 0
    _data.radios[2].volume = 1

    _data.radios[3].name = "ARI 23259/1"
    _data.radios[3].freq = SR.getRadioFrequency(7)
    _data.radios[3].modulation = 0
    _data.radios[3].volume = 1

    --guard mode for UHF Radio
    local _uhfKnob = SR.getSelectorPosition(221, 0.25)
    if _uhfKnob == 2 and _data.radios[2].freq > 1000 then
        _data.radios[2].secFreq = 243.0 * 1000000
    end

    --- is VHF ON?
    if SR.getSelectorPosition(391, 0.2) == 0 then
        _data.radios[3].freq = 1
    end
    --guard mode for VHF Radio
    local _vhfKnob = SR.getSelectorPosition(391, 0.2)
    if _vhfKnob == 2 and _data.radios[3].freq > 1000 then
        _data.radios[3].secFreq = 121.5 * 1000000
    end

    -- Radio Select Switch
    if (SR.getButtonPosition(265)) > 0.5 then
        _data.selected = 2
    else
        _data.selected = 1
    end

    _data.control = 1; -- full radio

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on
        _data.ambient = {vol = 0.2,  abType = 'jet' }
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'jet' }
    end

    return _data;
end

local _mirageEncStatus = false
local _previousEncState = 0

function SR.exportRadioM2000C(_data)

    local RED_devid = 20
    local GREEN_devid = 19
    local RED_device = GetDevice(RED_devid)
    local GREEN_device = GetDevice(GREEN_devid)
    
    local has_cockpit_ptt = false;
    
    local RED_ptt = false
    local GREEN_ptt = false
    local GREEN_guard = 0
    
    pcall(function() 
        RED_ptt = RED_device:is_ptt_pressed()
        GREEN_ptt = GREEN_device:is_ptt_pressed()
        has_cockpit_ptt = true
        end)
        
    pcall(function() 
        GREEN_guard = tonumber(GREEN_device:guard_standby_freq())
        end)

        
    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }
    _data.control = 0 
    
    -- Different PTT/select control if the module version supports cockpit PTT
    if has_cockpit_ptt then
        _data.control = 1
        _data.capabilities.dcsPtt = true
        _data.capabilities.dcsRadioSwitch = true
        if (GREEN_ptt) then
            _data.selected = 1 -- radios[2] GREEN V/UHF
            _data.ptt = true
        elseif (RED_ptt) then
            _data.selected = 2 -- radios[3] RED UHF
            _data.ptt = true
        else
            _data.selected = -1
            _data.ptt = false
        end
    end
    
    

    _data.radios[2].name = "TRT ERA 7000 V/UHF"
    _data.radios[2].freq = SR.getRadioFrequency(19)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 707, { 0.0, 1.0 }, false)

    --guard mode for V/UHF Radio
    if GREEN_guard>0 then
        _data.radios[2].secFreq = GREEN_guard
    end
    

    -- get channel selector
    local _selector = SR.getSelectorPosition(448, 0.50)

    if _selector == 1 then
        _data.radios[2].channel = SR.getSelectorPosition(445, 0.05)  --add 1 as channel 0 is channel 1
    end

    _data.radios[3].name = "TRT ERA 7200 UHF"
    _data.radios[3].freq = SR.getRadioFrequency(20)
    _data.radios[3].modulation = 0
    _data.radios[3].volume = SR.getRadioVolume(0, 706, { 0.0, 1.0 }, false)

    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 3 -- 3 is Incockpit toggle + Gui Enc Key setting

    --  local _switch = SR.getButtonPosition(700) -- remmed, the connectors are being coded, maybe soon will be a full radio.

    --    if _switch == 1 then
    --      _data.selected = 0
    --  else
    --     _data.selected = 1
    -- end



    -- reset state on aircraft switch
    if _lastUnitId ~= _data.unitId then
        _mirageEncStatus = false
        _previousEncState = 0
    end

    -- handle the button no longer toggling...
    if SR.getButtonPosition(432) > 0.5 and _previousEncState < 0.5 then
        --431

        if _mirageEncStatus then
            _mirageEncStatus = false
        else
            _mirageEncStatus = true
        end
    end

    _data.radios[3].enc = _mirageEncStatus

    _previousEncState = SR.getButtonPosition(432)



    -- Handle transponder

    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}


    local _iffDevice = GetDevice(42)

    if _iffDevice:hasPower() then
        _data.iff.status = 1 -- NORMAL

        if _iffDevice:isIdentActive() then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end
    else
        _data.iff.status = -1
    end
    
    
    if _iffDevice:isModeActive(4) then 
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    if _iffDevice:isModeActive(3) then 
        _data.iff.mode3 = string.format("%04d",_iffDevice:getModeCode(3))
    else
        _data.iff.mode3 = -1
    end

    if _iffDevice:isModeActive(2) then 
        _data.iff.mode2 = string.format("%04d",_iffDevice:getModeCode(2))
    else
        _data.iff.mode2 = -1
    end

    if _iffDevice:isModeActive(1) then 
        _data.iff.mode1 = string.format("%02d",_iffDevice:getModeCode(1))
    else
        _data.iff.mode1 = -1
    end
    
      --  SR.log(JSON:encode(_data.iff)..'\n\n')

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(38)

        if _door > 0.3 then 
            _data.ambient = {vol = 0.3,  abType = 'm2000' }
        else
            _data.ambient = {vol = 0.2,  abType = 'm2000' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'm2000' }
    end

    return _data
end

function SR.exportRadioF1CE(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[2].name = "V/UHF TRAP-136"
    _data.radios[2].freq = SR.getRadioFrequency(6)
    _data.radios[2].modulation = 0
    _data.radios[2].volume = SR.getRadioVolume(0, 311,{0.0,1.0},false)
    _data.radios[2].volMode = 0

    if SR.getSelectorPosition(280,0.2) == 0 and _data.radios[2].freq > 1000 then
        _data.radios[2].secFreq = 121.5 * 1000000
    end

    if SR.getSelectorPosition(282,0.5) == 1 then
        _data.radios[2].channel = SR.getNonStandardSpinner(283, {[0.000]= "1", [0.050]= "2",[0.100]= "3",[0.150]= "4",[0.200]= "5",[0.250]= "6",[0.300]= "7",[0.350]= "8",[0.400]= "9",[0.450]= "10",[0.500]= "11",[0.550]= "12",[0.600]= "13",[0.650]= "14",[0.700]= "15",[0.750]= "16",[0.800]= "17",[0.850]= "18",[0.900]= "19",[0.950]= "20"},0.05,3)
    end

    _data.radios[3].name = "UHF TRAP-137B"
    _data.radios[3].freq = SR.getRadioFrequency(8)
    _data.radios[3].modulation = 0
    _data.radios[3].volume = SR.getRadioVolume(0, 314,{0.0,1.0},false)
    _data.radios[3].volMode = 0
    _data.radios[3].channel = SR.getNonStandardSpinner(348, {[0.000]= "1", [0.050]= "2",[0.100]= "3",[0.150]= "4",[0.200]= "5",[0.250]= "6",[0.300]= "7",[0.350]= "8",[0.400]= "9",[0.450]= "10",[0.500]= "11",[0.550]= "12",[0.600]= "13",[0.650]= "14",[0.700]= "15",[0.750]= "16",[0.800]= "17",[0.850]= "18",[0.900]= "19",[0.950]= "20"},0.05,3)


    -- Handle transponder

    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}


    local _iffDevice = GetDevice(7)

    if _iffDevice:hasPower() then
        _data.iff.status = 1 -- NORMAL

        if _iffDevice:isIdentActive() then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end
    else
        _data.iff.status = -1
    end
    
    
    if _iffDevice:isModeActive(4) then 
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end

    if _iffDevice:isModeActive(3) then 
        _data.iff.mode3 = string.format("%04d",_iffDevice:getModeCode(3))
    else
        _data.iff.mode3 = -1
    end

    if _iffDevice:isModeActive(2) then 
        _data.iff.mode2 = string.format("%04d",_iffDevice:getModeCode(2))
    else
        _data.iff.mode2 = -1
    end

    if _iffDevice:isModeActive(1) then 
        _data.iff.mode1 = string.format("%02d",_iffDevice:getModeCode(1))
    else
        _data.iff.mode1 = -1
    end

    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 0;

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(1)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'f1' }
        else
            _data.ambient = {vol = 0.2,  abType = 'f1' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'f1' }
    end

    return _data
end


function SR.exportRadioF1BE(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    -- Intercom Function
    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100
    _data.radios[1].modulation = 2
    _data.radios[1].volume = 1.0
    _data.radios[1].volMode = 1.0


    _data.radios[2].name = "V/UHF TRAP-136"
    _data.radios[2].freq = SR.getRadioFrequency(6)
    _data.radios[2].modulation = 0
    _data.radios[2].volMode = 0


    _data.radios[3].name = "UHF TRAP-137B"
    _data.radios[3].freq = SR.getRadioFrequency(8)
    _data.radios[3].modulation = 0
    _data.radios[3].volMode = 0
    _data.radios[3].channel = SR.getNonStandardSpinner(348, {[0.000]= "1", [0.050]= "2",[0.100]= "3",[0.150]= "4",[0.200]= "5",[0.250]= "6",[0.300]= "7",[0.350]= "8",[0.400]= "9",[0.450]= "10",[0.500]= "11",[0.550]= "12",[0.600]= "13",[0.650]= "14",[0.700]= "15",[0.750]= "16",[0.800]= "17",[0.850]= "18",[0.900]= "19",[0.950]= "20"},0.05,3)

    _data.iff = {status=0,mode1=0,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getSelectorPosition(739,0.1)

    local iffIdent =  SR.getButtonPosition(744) -- -1 is off 0 or more is on

    if iffPower >= 7 then
        _data.iff.status = 1 -- NORMAL

        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end
    end

    local mode1On =  SR.getButtonPosition(750)

    local _lookupTable = {[0.000]= "0", [0.125] = "1", [0.250] = "2", [0.375] = "3", [0.500] = "4", [0.625] = "5", [0.750] = "6", [0.875] = "7", [1.000] = "0"}
    _data.iff.mode1 = SR.getNonStandardSpinner(732,_lookupTable, 0.125,3) .. SR.getNonStandardSpinner(733,{[0.000]= "0", [0.125] = "1", [0.250] = "2", [0.375] = "3", [0.500] = "0", [0.625] = "1", [0.750] = "2", [0.875] = "3", [1.000] = "0"},0.125,3)

    if mode1On ~= 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(752)

    _data.iff.mode3 = SR.getNonStandardSpinner(734,_lookupTable, 0.125,3) .. SR.getNonStandardSpinner(735,_lookupTable,0.125,3).. SR.getNonStandardSpinner(736,_lookupTable,0.125,3).. SR.getNonStandardSpinner(737,_lookupTable,0.125,3)

    if mode3On ~= 0 then
        _data.iff.mode3 = -1
    elseif iffPower == 10 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(745)

    if mode4On ~= 0 then
        _data.iff.mode4 = true
    else
        _data.iff.mode4 = false
    end
    
    -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-164 UHF"
    _data.radios[3].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 243.0 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 225 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].encKey = 1
    _data.radios[3].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

   -- SR.lastKnownSeat = 1

    if SR.lastKnownSeat == 0 then
        _data.radios[2].volume = SR.getRadioVolume(0, 311,{0.0,1.0},false)

        if SR.getSelectorPosition(280,0.2) == 0 and _data.radios[2].freq > 1000 then
            _data.radios[2].secFreq = 121.5 * 1000000
        end

        if SR.getSelectorPosition(282,0.5) == 1 then
            _data.radios[2].channel = SR.getNonStandardSpinner(283, {[0.000]= "1", [0.050]= "2",[0.100]= "3",[0.150]= "4",[0.200]= "5",[0.250]= "6",[0.300]= "7",[0.350]= "8",[0.400]= "9",[0.450]= "10",[0.500]= "11",[0.550]= "12",[0.600]= "13",[0.650]= "14",[0.700]= "15",[0.750]= "16",[0.800]= "17",[0.850]= "18",[0.900]= "19",[0.950]= "20"},0.05,3)
        end

        _data.radios[3].volume = SR.getRadioVolume(0, 314,{0.0,1.0},false)
    else
        _data.radios[2].volume = SR.getRadioVolume(0, 327,{0.0,1.0},false)

        if SR.getSelectorPosition(298,0.2) == 0 and _data.radios[2].freq > 1000 then
            _data.radios[2].secFreq = 121.5 * 1000000
        end

        if SR.getSelectorPosition(300,0.5) == 1 then
            _data.radios[2].channel = SR.getNonStandardSpinner(303, {[0.000]= "1", [0.050]= "2",[0.100]= "3",[0.150]= "4",[0.200]= "5",[0.250]= "6",[0.300]= "7",[0.350]= "8",[0.400]= "9",[0.450]= "10",[0.500]= "11",[0.550]= "12",[0.600]= "13",[0.650]= "14",[0.700]= "15",[0.750]= "16",[0.800]= "17",[0.850]= "18",[0.900]= "19",[0.950]= "20"},0.05,3)
        end

        _data.radios[3].volume = SR.getRadioVolume(0, 330,{0.0,1.0},false)

    end

    _data.control = 0;

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _doorLeft = SR.getButtonPosition(1)
        local _doorRight = SR.getButtonPosition(6)

        if _doorLeft > 0.2 or _doorRight > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'f1' }
        else
            _data.ambient = {vol = 0.2,  abType = 'f1' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'f1' }
    end

    return _data
end

local newJF17Interface = nil

function SR.exportRadioJF17(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[2].name = "COMM1 VHF Radio"
    _data.radios[2].freq = SR.getRadioFrequency(25)
    _data.radios[2].modulation = SR.getRadioModulation(25)
    _data.radios[2].volume = SR.getRadioVolume(0, 934, { 0.0, 1.0 }, false)
    _data.radios[2].secFreq = GetDevice(25):get_guard_plus_freq()

    _data.radios[3].name = "COMM2 UHF Radio"
    _data.radios[3].freq = SR.getRadioFrequency(26)
    _data.radios[3].modulation = SR.getRadioModulation(26)
    _data.radios[3].volume = SR.getRadioVolume(0, 938, { 0.0, 1.0 }, false)
    _data.radios[3].secFreq = GetDevice(26):get_guard_plus_freq()


    _data.selected = 1
    _data.control = 0; -- partial radio, allows hotkeys



    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local _iff = GetDevice(15)

    if _iff:is_m1_trs_on() or _iff:is_m2_trs_on() or _iff:is_m3_trs_on() or _iff:is_m6_trs_on() then
        _data.iff.status = 1
    end

    if _iff:is_m1_trs_on() then
        _data.iff.mode1 = _iff:get_m1_trs_code()
    else
        _data.iff.mode1 = -1
    end

    if _iff:is_m3_trs_on() then
        _data.iff.mode3 = _iff:get_m3_trs_code()
    else
        _data.iff.mode3 = -1
    end

    _data.iff.mode4 =  _iff:is_m6_trs_on()

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(181)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'jf17' }
        else
            _data.ambient = {vol = 0.2,  abType = 'jf17' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'jf17' }
    end

    return _data
end

local _av8 = {}
_av8.radio1 = {}
_av8.radio2 = {}
_av8.radio1.guard = 0
_av8.radio1.encKey = -1
_av8.radio1.enc = false
_av8.radio2.guard = 0
_av8.radio2.encKey = -1
_av8.radio2.enc = false

function SR.exportRadioAV8BNA(_data)
    
    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    local _ufc = SR.getListIndicatorValue(6)

    --{
    --    "ODU_DISPLAY":"",
    --    "ODU_Option_1_Text":TR-G",
    --    "ODU_Option_2_Text":" ",
    --    "ODU_Option_3_Slc":":",
    --    "ODU_Option_3_Text":"SQL",
    --    "ODU_Option_4_Text":"PLN",
    --    "ODU_Option_5_Text":"CD 0"
    -- }

    --SR.log("UFC:\n"..SR.JSON:encode(_ufc).."\n\n")
    local _ufcScratch = SR.getListIndicatorValue(5)

    --{
    --    "UFC_DISPLAY":"",
    --    "ufc_chnl_1_m":"M",
    --    "ufc_chnl_2_m":"M",
    --    "ufc_right_position":"127.500"
    -- }

    --SR.log("UFC Scratch:\n"..SR.JSON:encode(SR.getListIndicatorValue(5)).."\n\n")

    if _lastUnitId ~= _data.unitId then
        _av8.radio1.guard = 0
        _av8.radio2.guard = 0
    end

    local getGuardFreq = function (freq,currentGuard)


        if freq > 1000000 then

            -- check if LEFT UFC is currently displaying the TR-G for this radio
            --and change state if so

            if _ufcScratch and _ufc and _ufcScratch.ufc_right_position then
                local _ufcFreq = tonumber(_ufcScratch.ufc_right_position)

                if _ufcFreq and _ufcFreq * 1000000 == SR.round(freq,1000) then
                    if _ufc.ODU_Option_1_Text == "TR-G" then
                        return 243.0 * 1000000
                    else
                        return 0
                    end
                end
            end


            return currentGuard

        else
            -- reset state
            return 0
        end

    end

    local getEncryption = function ( freq, currentEnc,currentEncKey )
    if freq > 1000000 then

            -- check if LEFT UFC is currently displaying the encryption for this radio
 

            if _ufcScratch and _ufcScratch and _ufcScratch.ufc_right_position then
                local _ufcFreq = tonumber(_ufcScratch.ufc_right_position)

                if _ufcFreq and _ufcFreq * 1000000 == SR.round(freq,1000) then
                    if _ufc.ODU_Option_4_Text == "CIPH" then

                        -- validate number
                        -- ODU_Option_5_Text
                        if string.find(_ufc.ODU_Option_5_Text, "CD",1,true) then

                          local cduStr = string.gsub(_ufc.ODU_Option_5_Text, "CD ", ""):gsub("^%s*(.-)%s*$", "%1")

                            --remove CD and trim
                            local encNum = tonumber(cduStr)

                            if encNum and encNum > 0 then 
                                return true,encNum
                            else
                                return false,-1
                            end
                        else
                            return false,-1
                        end
                    else
                        return false,-1
                    end
                end
            end


            return currentEnc,currentEncKey

        else
            -- reset state
            return false,-1
        end
end



    _data.radios[2].name = "ARC-210 COM 1"
    _data.radios[2].freq = SR.getRadioFrequency(2)
    _data.radios[2].modulation = SR.getRadioModulation(2)
    _data.radios[2].volume = SR.getRadioVolume(0, 298, { 0.0, 1.0 }, false)
    _data.radios[2].encMode = 2 -- mode 2 enc is set by aircraft & turned on by aircraft

    local radio1Guard = getGuardFreq(_data.radios[2].freq, _av8.radio1.guard)

    _av8.radio1.guard = radio1Guard
    _data.radios[2].secFreq = _av8.radio1.guard

    local radio1Enc, radio1EncKey = getEncryption(_data.radios[2].freq, _av8.radio1.enc, _av8.radio1.encKey)

    _av8.radio1.enc = radio1Enc
    _av8.radio1.encKey = radio1EncKey

    if _av8.radio1.enc then
        _data.radios[2].enc = _av8.radio1.enc 
        _data.radios[2].encKey = _av8.radio1.encKey 
    end

    
    -- get channel selector
    --  local _selector  = SR.getSelectorPosition(448,0.50)

    --if _selector == 1 then
    --_data.radios[2].channel =  SR.getSelectorPosition(178,0.01)  --add 1 as channel 0 is channel 1
    --end

    _data.radios[3].name = "ARC-210 COM 2"
    _data.radios[3].freq = SR.getRadioFrequency(3)
    _data.radios[3].modulation = SR.getRadioModulation(3)
    _data.radios[3].volume = SR.getRadioVolume(0, 299, { 0.0, 1.0 }, false)
    _data.radios[3].encMode = 2 -- mode 2 enc is set by aircraft & turned on by aircraft

    local radio2Guard = getGuardFreq(_data.radios[3].freq, _av8.radio2.guard)

    _av8.radio2.guard = radio2Guard
    _data.radios[3].secFreq = _av8.radio2.guard

    local radio2Enc, radio2EncKey = getEncryption(_data.radios[3].freq, _av8.radio2.enc, _av8.radio2.encKey)

    _av8.radio2.enc = radio2Enc
    _av8.radio2.encKey = radio2EncKey

    if _av8.radio2.enc then
        _data.radios[3].enc = _av8.radio2.enc 
        _data.radios[3].encKey = _av8.radio2.encKey 
    end

    --https://en.wikipedia.org/wiki/AN/ARC-210

    -- EXTRA Radio - temporary extra radio
    --https://en.wikipedia.org/wiki/AN/ARC-210
    --_data.radios[4].name = "ARC-210 COM 3"
    --_data.radios[4].freq = 251.0*1000000 --225-399.975 MHZ
    --_data.radios[4].modulation = 0
    --_data.radios[4].secFreq = 243.0*1000000
    --_data.radios[4].volume = 1.0
    --_data.radios[4].freqMin = 108*1000000
    --_data.radios[4].freqMax = 512*1000000
    --_data.radios[4].expansion = false
    --_data.radios[4].volMode = 1
    --_data.radios[4].freqMode = 1
    --_data.radios[4].encKey = 1
    --_data.radios[4].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting


    _data.selected = 1
    _data.control = 0; -- partial radio, allows hotkeys

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(38)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.35,  abType = 'av8bna' }
        else
            _data.ambient = {vol = 0.2,  abType = 'av8bna' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'av8bna' }
    end

    return _data
end

--for F-14
function SR.exportRadioF14(_data)

    _data.capabilities = { dcsPtt = true, dcsIFF = true, dcsRadioSwitch = true, intercomHotMic = true, desc = "" }

    local ics_devid = 2
    local arc159_devid = 3
    local arc182_devid = 4

    local ICS_device = GetDevice(ics_devid)
    local ARC159_device = GetDevice(arc159_devid)
    local ARC182_device = GetDevice(arc182_devid)

    local intercom_transmit = ICS_device:intercom_transmit()
    local ARC159_ptt = ARC159_device:is_ptt_pressed()
    local ARC182_ptt = ARC182_device:is_ptt_pressed()

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = ICS_device:get_volume()

    _data.radios[2].name = "AN/ARC-159(V)"
    _data.radios[2].freq = ARC159_device:is_on() and SR.round(ARC159_device:get_frequency(), 5000) or 1
    _data.radios[2].modulation = ARC159_device:get_modulation()
    _data.radios[2].volume = ARC159_device:get_volume()
    if ARC159_device:is_guard_enabled() then
        _data.radios[2].secFreq = 243.0 * 1000000
    else
        _data.radios[2].secFreq = 0
    end
    _data.radios[2].freqMin = 225 * 1000000
    _data.radios[2].freqMax = 399.975 * 1000000
    _data.radios[2].encKey = ICS_device:get_ky28_key()
    _data.radios[2].enc = ICS_device:is_arc159_encrypted()
    _data.radios[2].encMode = 2

    _data.radios[3].name = "AN/ARC-182(V)"
    _data.radios[3].freq = ARC182_device:is_on() and SR.round(ARC182_device:get_frequency(), 5000) or 1
    _data.radios[3].modulation = ARC182_device:get_modulation()
    _data.radios[3].volume = ARC182_device:get_volume()
    if ARC182_device:is_guard_enabled() then
        _data.radios[3].secFreq = SR.round(ARC182_device:get_guard_freq(), 5000)
    else
        _data.radios[3].secFreq = 0
    end
    _data.radios[3].freqMin = 30 * 1000000
    _data.radios[3].freqMax = 399.975 * 1000000
    _data.radios[3].encKey = ICS_device:get_ky28_key()
    _data.radios[3].enc = ICS_device:is_arc182_encrypted()
    _data.radios[3].encMode = 2

    local _seat = SR.lastKnownSeat

 --   RADIO_ICS_Func_RIO = 402,
--   RADIO_ICS_Func_Pilot = 2044,
    
    local _hotMic = false
    if _seat == 0 then
        if SR.getButtonPosition(2044) > -1 then
            _hotMic = true
        end

    else
        if SR.getButtonPosition(402) > -1 then
            _hotMic = true
        end
     end

    _data.intercomHotMic = _hotMic 

    if (ARC182_ptt) then
        _data.selected = 2 -- radios[3] ARC-182
        _data.ptt = true
    elseif (ARC159_ptt) then
        _data.selected = 1 -- radios[2] ARC-159
        _data.ptt = true
    elseif (intercom_transmit and not _hotMic) then

        -- CHECK ICS Function Selector
        -- If not set to HOT MIC - switch radios and PTT
        -- if set to hot mic - dont switch and ignore
        
        _data.selected = 0 -- radios[1] intercom
        _data.ptt = true
    else
        _data.selected = -1
        _data.ptt = false
    end

    -- handle simultaneous transmission
    if _data.selected ~= 0 and _data.ptt then
        local xmtrSelector = SR.getButtonPosition(381) --402

        if xmtrSelector == 0 then
            _data.radios[2].simul =true
            _data.radios[3].simul =true
        end

    end

    _data.control = 1 -- full radio

    -- Handle transponder

    _data.iff = {status=0,mode1=0,mode2=-1,mode3=0,mode4=false,control=0,expansion=false}

    local iffPower =  SR.getSelectorPosition(184,0.25)

    local iffIdent =  SR.getButtonPosition(167)

    if iffPower >= 2 then
        _data.iff.status = 1 -- NORMAL


        if iffIdent == 1 then
            _data.iff.status = 2 -- IDENT (BLINKY THING)
        end

        if iffIdent == -1 then
            if ARC159_ptt then -- ONLY on UHF radio PTT press
                _data.iff.status = 2 -- IDENT (BLINKY THING)
            end
        end
    end

    local mode1On =  SR.getButtonPosition(162)
    _data.iff.mode1 = SR.round(SR.getSelectorPosition(201,0.11111), 0.1)*10+SR.round(SR.getSelectorPosition(200,0.11111), 0.1)


    if mode1On ~= 0 then
        _data.iff.mode1 = -1
    end

    local mode3On =  SR.getButtonPosition(164)
    _data.iff.mode3 = SR.round(SR.getSelectorPosition(199,0.11111), 0.1) * 1000 + SR.round(SR.getSelectorPosition(198,0.11111), 0.1) * 100 + SR.round(SR.getSelectorPosition(2261,0.11111), 0.1)* 10 + SR.round(SR.getSelectorPosition(2262,0.11111), 0.1)

    if mode3On ~= 0 then
        _data.iff.mode3 = -1
    elseif iffPower == 4 then
        -- EMERG SETTING 7770
        _data.iff.mode3 = 7700
    end

    local mode4On =  SR.getButtonPosition(181)

    if mode4On == 0 then
        _data.iff.mode4 = false
    else
        _data.iff.mode4 = true
    end

    -- SR.log("IFF STATUS"..SR.JSON:encode(_data.iff).."\n\n")

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(403)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'f14' }
        else
            _data.ambient = {vol = 0.2,  abType = 'f14' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'f14' }
    end

    return _data
end

function SR.exportRadioAJS37(_data)

    _data.capabilities = { dcsPtt = false, dcsIFF = false, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    _data.radios[2].name = "FR 22"
    _data.radios[2].freq = SR.getRadioFrequency(30)
    _data.radios[2].modulation = SR.getRadioModulation(30)
    _data.radios[2].volume =  SR.getRadioVolume(0, 385,{0.0, 1.0},false)
    _data.radios[2].volMode = 0

    _data.radios[3].name = "FR 24"
    _data.radios[3].freq = SR.getRadioFrequency(31)
    _data.radios[3].modulation = SR.getRadioModulation(31)
    _data.radios[3].volume = 1.0
    _data.radios[3].volMode = 1

    -- Expansion Radio - Server Side Controlled
    _data.radios[4].name = "AN/ARC-164 UHF"
    _data.radios[4].freq = 251.0 * 1000000 --225-399.975 MHZ
    _data.radios[4].modulation = 0
    _data.radios[4].secFreq = 243.0 * 1000000
    _data.radios[4].volume = 1.0
    _data.radios[4].freqMin = 225 * 1000000
    _data.radios[4].freqMax = 399.975 * 1000000
    _data.radios[4].expansion = true
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1
    _data.radios[4].encKey = 1
    _data.radios[4].encMode = 1 -- FC3 Gui Toggle + Gui Enc key setting

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(10)

        if _door > 0.2 then 
            _data.ambient = {vol = 0.3,  abType = 'ajs37' }
        else
            _data.ambient = {vol = 0.2,  abType = 'ajs37' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'ajs37' }
    end

    return _data
end

function SR.getRadioVolume(_deviceId, _arg, _minMax, _invert)

    local _device = GetDevice(_deviceId)

    if not _minMax then
        _minMax = { 0.0, 1.0 }
    end

    if _device then
        local _val = tonumber(_device:get_argument_value(_arg))
        local _reRanged = SR.rerange(_val, _minMax, { 0.0, 1.0 })  --re range to give 0.0 - 1.0

        if _invert then
            return SR.round(math.abs(1.0 - _reRanged), 0.005)
        else
            return SR.round(_reRanged, 0.005);
        end
    end
    return 1.0
end

function SR.getKnobPosition(_deviceId, _arg, _minMax, _mapMinMax)

    local _device = GetDevice(_deviceId)

    if _device then
        local _val = tonumber(_device:get_argument_value(_arg))
        local _reRanged = SR.rerange(_val, _minMax, _mapMinMax)

        return _reRanged
    end
    return -1
end

function SR.getSelectorPosition(_args, _step)
    local _value = GetDevice(0):get_argument_value(_args)
    local _num = math.abs(tonumber(string.format("%.0f", (_value) / _step)))

    return _num

end

function SR.getButtonPosition(_args)
    local _value = GetDevice(0):get_argument_value(_args)

    return _value

end

function SR.getNonStandardSpinner(_deviceId, _range, _step, _round)
    local _value = GetDevice(0):get_argument_value(_deviceId)
    -- round to x decimal places
    _value = SR.advRound(_value,_round)

    -- round to nearest step
    -- then round again to X decimal places
    _value = SR.advRound(SR.round(_value, _step),_round)

    --round to the step of the values
    local _res = _range[_value]

    if not _res then
        return 0
    end

    return _res

end

function SR.getAmbientVolumeEngine()

    local _res = 0
    
    pcall(function()
    
        local engine = LoGetEngineInfo()

        --{"EngineStart":{"left":0,"right":0},"FuelConsumption":{"left":1797.9623832703,"right":1795.5901498795},"HydraulicPressure":{"left":0,"right":0},"RPM":{"left":97.268943786621,"right":97.269966125488},"Temperature":{"left":746.81764087677,"right":745.09023532867},"fuel_external":0,"fuel_internal":0.99688786268234}
        --SR.log(JSON:encode(engine))
        if engine.RPM and engine.RPM.left > 1 then
            _res = engine.RPM.left 
        end

        if engine.RPM and engine.RPM.right > 1 then
            _res = engine.RPM.right
        end
    end )

    return SR.round(_res,1)
end


function SR.getRadioFrequency(_deviceId, _roundTo, _ignoreIsOn)
    local _device = GetDevice(_deviceId)

    if not _roundTo then
        _roundTo = 5000
    end

    if _device then
        if _device:is_on() or _ignoreIsOn then
            -- round as the numbers arent exact
            return SR.round(_device:get_frequency(), _roundTo)
        end
    end
    return 1
end


function SR.getRadioModulation(_deviceId)
    local _device = GetDevice(_deviceId)

    local _modulation = 0

    if _device then

        pcall(function()
            _modulation = _device:get_modulation()
        end)

    end
    return _modulation
end

function SR.rerange(_val, _minMax, _limitMinMax)
    return ((_limitMinMax[2] - _limitMinMax[1]) * (_val - _minMax[1]) / (_minMax[2] - _minMax[1])) + _limitMinMax[1];

end

function SR.round(number, step)
    if number == 0 then
        return 0
    else
        return math.floor((number + step / 2) / step) * step
    end
end


function SR.advRound(number, decimals, method)
    if string.find(number, "%p" ) ~= nil then
        decimals = decimals or 0
        local lFactor = 10 ^ decimals
        if (method == "ceil" or method == "floor") then
            -- ceil: Returns the smallest integer larger than or equal to number
            -- floor: Returns the smallest integer smaller than or equal to number
            return math[method](number * lFactor) / lFactor
        else
            return tonumber(("%."..decimals.."f"):format(number))
        end
    else
        return number
    end
end

function SR.nearlyEqual(a, b, diff)
    return math.abs(a - b) < diff
end

-- SOURCE: DCS-BIOS! Thank you! https://dcs-bios.readthedocs.io/
-- The function return a table with values of given indicator
-- The value is retrievable via a named index. e.g. TmpReturn.txt_digits
function SR.getListIndicatorValue(IndicatorID)
    local ListIindicator = list_indication(IndicatorID)
    local TmpReturn = {}

    if ListIindicator == "" then
        return nil
    end

    local ListindicatorMatch = ListIindicator:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    while true do
        local Key, Value = ListindicatorMatch()
        if not Key then
            break
        end
        TmpReturn[Key] = Value
    end

    return TmpReturn
end


function SR.basicSerialize(var)
    if var == nil then
        return "\"\""
    else
        if ((type(var) == 'number') or
                (type(var) == 'boolean') or
                (type(var) == 'function') or
                (type(var) == 'table') or
                (type(var) == 'userdata') ) then
            return tostring(var)
        elseif type(var) == 'string' then
            var = string.format('%q', var)
            return var
        end
    end
end

function SR.debugDump(o)
    if o == nil then
        return "~nil~"
    elseif type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. SR.debugDump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end

end


function SR.tableShow(tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
    tableshow_tbls = tableshow_tbls or {} --create table of tables
    loc = loc or ""
    indent = indent or ""
    if type(tbl) == 'table' then --function only works for tables!
        tableshow_tbls[tbl] = loc

        local tbl_str = {}

        tbl_str[#tbl_str + 1] = indent .. '{\n'

        for ind,val in pairs(tbl) do -- serialize its fields
            if type(ind) == "number" then
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = tostring(ind)
                tbl_str[#tbl_str + 1] = '] = '
            else
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = SR.basicSerialize(ind)
                tbl_str[#tbl_str + 1] = '] = '
            end

            if ((type(val) == 'number') or (type(val) == 'boolean')) then
                tbl_str[#tbl_str + 1] = tostring(val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'string' then
                tbl_str[#tbl_str + 1] = SR.basicSerialize(val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'nil' then -- won't ever happen, right?
                tbl_str[#tbl_str + 1] = 'nil,\n'
            elseif type(val) == 'table' then
                if tableshow_tbls[val] then
                    tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
                else
                    tableshow_tbls[val] = loc ..    '[' .. SR.basicSerialize(ind) .. ']'
                    tbl_str[#tbl_str + 1] = tostring(val) .. ' '
                    tbl_str[#tbl_str + 1] = SR.tableShow(val,  loc .. '[' .. SR.basicSerialize(ind).. ']', indent .. '        ', tableshow_tbls)
                    tbl_str[#tbl_str + 1] = ',\n'
                end
            elseif type(val) == 'function' then
                if debug and debug.getinfo then
                    local fcnname = tostring(val)
                    local info = debug.getinfo(val, "S")
                    if info.what == "C" then
                        tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
                    else
                        if (string.sub(info.source, 1, 2) == [[./]]) then
                            tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) ..',\n'
                        else
                            tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..',\n'
                        end
                    end

                else
                    tbl_str[#tbl_str + 1] = 'a function,\n'
                end
            else
                tbl_str[#tbl_str + 1] = 'unable to serialize value type ' .. SR.basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
            end
        end

        tbl_str[#tbl_str + 1] = indent .. '}'
        return table.concat(tbl_str)
    end
end



---- Exporters init ----
SR.exporters["UH-1H"] = SR.exportRadioUH1H
SR.exporters["Ka-50"] = SR.exportRadioKA50
SR.exporters["Ka-50_3"] = SR.exportRadioKA50
SR.exporters["Mi-8MT"] = SR.exportRadioMI8
SR.exporters["Mi-24P"] = SR.exportRadioMI24P
SR.exporters["Yak-52"] = SR.exportRadioYak52
SR.exporters["FA-18C_hornet"] = SR.exportRadioFA18C
SR.exporters["FA-18E"] = SR.exportRadioFA18C
SR.exporters["FA-18F"] = SR.exportRadioFA18C
SR.exporters["EA-18G"] = SR.exportRadioFA18C
SR.exporters["F-86F Sabre"] = SR.exportRadioF86Sabre
SR.exporters["MiG-15bis"] = SR.exportRadioMIG15
SR.exporters["MiG-19P"] = SR.exportRadioMIG19
SR.exporters["MiG-21Bis"] = SR.exportRadioMIG21
SR.exporters["F-5E-3"] = SR.exportRadioF5E
SR.exporters["FW-190D9"] = SR.exportRadioFW190
SR.exporters["FW-190A8"] = SR.exportRadioFW190
SR.exporters["Bf-109K-4"] = SR.exportRadioBF109
SR.exporters["C-101EB"] = SR.exportRadioC101EB
SR.exporters["C-101CC"] = SR.exportRadioC101CC
SR.exporters["MB-339A"] = SR.exportRadioMB339A
SR.exporters["MB-339APAN"] = SR.exportRadioMB339A
SR.exporters["Hawk"] = SR.exportRadioHawk
SR.exporters["Christen Eagle II"] = SR.exportRadioEagleII
SR.exporters["M-2000C"] = SR.exportRadioM2000C
SR.exporters["M-2000D"] = SR.exportRadioM2000C
SR.exporters["Mirage-F1CE"] = SR.exportRadioF1CE  
SR.exporters["Mirage-F1EE"]   = SR.exportRadioF1CE
SR.exporters["Mirage-F1BE"]   = SR.exportRadioF1BE
--SR.exporters["Mirage-F1M-EE"] = SR.exportRadioF1
SR.exporters["JF-17"] = SR.exportRadioJF17
SR.exporters["AV8BNA"] = SR.exportRadioAV8BNA
SR.exporters["AJS37"] = SR.exportRadioAJS37
SR.exporters["A-10A"] = SR.exportRadioA10A
SR.exporters["UH-60L"] = SR.exportRadioUH60L
SR.exporters["MH-60R"] = SR.exportRadioUH60L
SR.exporters["SH60B"] = SR.exportRadioSH60B
SR.exporters["AH-64D_BLK_II"] = SR.exportRadioAH64D
SR.exporters["A-4E-C"] = SR.exportRadioA4E
SR.exporters["SK-60"] = SR.exportRadioSK60
SR.exporters["PUCARA"] = SR.exportRadioPUCARA
SR.exporters["T-45"] = SR.exportRadioT45
SR.exporters["A-29B"] = SR.exportRadioA29B
SR.exporters["VSN_F4C"] = SR.exportRadioVSNF4
SR.exporters["VSN_F4B"] = SR.exportRadioVSNF4
SR.exporters["Hercules"] = SR.exportRadioHercules
SR.exporters["F-15C"] = SR.exportRadioF15C
SR.exporters["F-15ESE"] = SR.exportRadioF15ESE
SR.exporters["MiG-29A"] = SR.exportRadioMiG29
SR.exporters["MiG-29S"] = SR.exportRadioMiG29
SR.exporters["MiG-29G"] = SR.exportRadioMiG29
SR.exporters["Su-27"] = SR.exportRadioSU27
SR.exporters["J-11A"] = SR.exportRadioSU27
SR.exporters["Su-33"] = SR.exportRadioSU27
SR.exporters["Su-25"] = SR.exportRadioSU25
SR.exporters["Su-25T"] = SR.exportRadioSU25
SR.exporters["F-16C_50"] = SR.exportRadioF16C
SR.exporters["F-16D_50_NS"] = SR.exportRadioF16C
SR.exporters["F-16D_52_NS"] = SR.exportRadioF16C
SR.exporters["F-16D_50"] = SR.exportRadioF16C
SR.exporters["F-16D_52"] = SR.exportRadioF16C
SR.exporters["F-16D_Barak_40"] = SR.exportRadioF16C
SR.exporters["F-16D_Barak_30"] = SR.exportRadioF16C
SR.exporters["F-16I"] = SR.exportRadioF16C
SR.exporters["SA342M"] = SR.exportRadioSA342
SR.exporters["SA342L"] = SR.exportRadioSA342
SR.exporters["SA342Mistral"] = SR.exportRadioSA342
SR.exporters["SA342Minigun"] = SR.exportRadioSA342
SR.exporters["L-39C"] = SR.exportRadioL39
SR.exporters["L-39ZA"] = SR.exportRadioL39
SR.exporters["F-14B"] = SR.exportRadioF14
SR.exporters["F-14A-135-GR"] = SR.exportRadioF14
SR.exporters["A-10C"] = SR.exportRadioA10C
SR.exporters["A-10C_2"] = SR.exportRadioA10C2
SR.exporters["P-51D"] = SR.exportRadioP51
SR.exporters["P-51D-30-NA"] = SR.exportRadioP51
SR.exporters["TF-51D"] = SR.exportRadioP51
SR.exporters["P-47D-30"] = SR.exportRadioP47
SR.exporters["P-47D-30bl1"] = SR.exportRadioP47
SR.exporters["P-47D-40"] = SR.exportRadioP47
SR.exporters["SpitfireLFMkIX"] = SR.exportRadioSpitfireLFMkIX
SR.exporters["SpitfireLFMkIXCW"] = SR.exportRadioSpitfireLFMkIX
SR.exporters["MosquitoFBMkVI"] = SR.exportRadioMosquitoFBMkVI


--- DCS EXPORT FUNCTIONS
LuaExportActivityNextEvent = function(tCurrent)
    -- we only want to send once every 0.2 seconds
    -- but helios (and other exports) require data to come much faster
    if _tNextSRS - tCurrent < 0.01 then   -- has to be written this way as the function is being called with a loss of precision at times
        _tNextSRS = tCurrent + 0.2

        local _status, _result = pcall(SR.exporter)

        if not _status then
            SR.log('ERROR: ' ..  SR.debugDump(_result))
        end
    end

    local tNext = _tNextSRS

    -- call previous
    if _prevLuaExportActivityNextEvent then
        local _status, _result = pcall(_prevLuaExportActivityNextEvent, tCurrent)
        if _status then
            -- Use lower of our tNext (0.2s) or the previous export's
            if _result and _result < tNext and _result > tCurrent then
                tNext = _result
            end
        else
            SR.log('ERROR Calling other LuaExportActivityNextEvent from another script: ' .. SR.debugDump(_result))
        end
    end

    if terrain == nil then
        SR.log("Terrain Export is not working")
        --SR.log("EXPORT CHECK "..tostring(terrain.isVisible(1,100,1,1,100,1)))
        --SR.log("EXPORT CHECK "..tostring(terrain.isVisible(1,1,1,1,-100,-100)))
    end

     --SR.log(SR.tableShow(_G).."\n\n")

    return tNext
end

LuaExportBeforeNextFrame = function()

    -- read from socket
    local _status, _result = pcall(SR.readLOSSocket)

    if not _status then
        SR.log('ERROR LuaExportBeforeNextFrame readLOSSocket SRS: ' .. SR.debugDump(_result))
    end

    _status, _result = pcall(SR.readSeatSocket)

    if not _status then
        SR.log('ERROR LuaExportBeforeNextFrame readSeatSocket SRS: ' .. SR.debugDump(_result))
    end

    -- Check F/A-18C ENT keypress (needs to be checked in LuaExportBeforeNextFrame not to be missed)
    if _lastUnitType == "FA-18C_hornet" 
        or _lastUnitType == "FA-18E"
        or _lastUnitType == "FA-18F"
        or _lastUnitType == "EA-18G" then
        if not _fa18ent then
            local st, rv = pcall(SR.getButtonPosition, 122)     -- pcall to prevent dcs.log error after ejection
            if st and rv > 0 then
                _fa18ent = true
            end
        end
    end

    -- call original
    if _prevLuaExportBeforeNextFrame then
        _status, _result = pcall(_prevLuaExportBeforeNextFrame)
        if not _status then
            SR.log('ERROR Calling other LuaExportBeforeNextFrame from another script: ' .. SR.debugDump(_result))
        end
    end
end

-- Load mods' SRS plugins
SR.LoadModsPlugins()

SR.log("Loaded SimpleRadio Standalone Export version: 2.1.0.2")
