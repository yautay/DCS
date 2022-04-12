do  
  
  local presets_f14 = info_preset_f14_159() .. info_preset_f14_182()
  local presets_f16 = info_preset_f16_164() .. info_preset_f16_222()
  local presets_f18 = info_preset_f18_210_1() .. info_preset_f18_210_2()

  local F_14_CVN = CLIENT:FindByName( "C-F14-CVN71" )
  local F_18_CVN = CLIENT:FindByName( "C-F18-CVN71" )
  local F_16_LTAG = CLIENT:FindByName( "C-F16-LTAG" )
  local F_18_LTAG = CLIENT:FindByName( "C-F18-LTAG" )
  local F_16_LCPH = CLIENT:FindByName( "C-F16-LCPH" )

  local clients = {{F_14_CVN, presets_f14}, {F_18_CVN, presets_f18}, {F_16_LTAG, presets_f16}, {F_18_LTAG, presets_f18}, {F_16_LCPH, presets_f16}}

  local MenuCoalitionBlue = MENU_COALITION:New( coalition.side.BLUE, "Scripted Menu" )

  local function ShowStatus( PlaneClient, StatusText)
    PlaneClient:Message( StatusText, 15 )
  end
  local ClientInfoMenu = {}


  SCHEDULER:New(nil,
    function()
      for index, value in ipairs(clients) do
        if value[1] and value[1]:IsAlive() then
          local ClientInfoMenu = MENU_CLIENT:New( value[1], "Client Info" )
          MENU_CLIENT_COMMAND:New( value[1], "Radio Presets", ClientInfoMenu, ShowStatus, value[1], value[2])
        end
    end, {}, 30, 120 )
end
