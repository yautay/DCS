do
  -- This demo creates a menu structure for the two clients of planes.
  -- Each client will receive a different menu structure.
  -- To test, join the planes, then look at the other radio menus (Option F10).
  -- Then switch planes and check if the menu is still there.
  -- And play with the Add and Remove menu options.
  
  -- Note that in multi player, this will only work after the DCS clients bug is solved.

  local F_14_CVN = CLIENT:FindByName( "C-F14-CVN71" )
  local F_18_CVN = CLIENT:FindByName( "C-F18-CVN71" )

  local F_16_LTAG = CLIENT:FindByName( "C-F16-LTAG" )
  local F_18_LTAG = CLIENT:FindByName( "C-F14-LTAG" )


  local MenuCoalitionBlue = MENU_COALITION:New( coalition.side.BLUE, "Scripted Menu" )

  local function ShowStatus( StatusText )

   F_14_CVN:Message( StatusText, 15 )
   F_18_CVN:Message( StatusText, 15 )
   F_16_LTAG:Message( StatusText, 15 )
   F_18_LTAG:Message( StatusText, 15 )
 




 end


  local function ShowStatus( PlaneClient, StatusText, Coalition )

    MESSAGE:New( Coalition, 15 ):ToAll()
    PlaneClient:Message( StatusText, 15 )
  end

  local MenuStatus = {}

  local function RemoveStatusMenu( MenuClient )
    local MenuClientName = MenuClient:GetName()
    MenuStatus[MenuClientName]:Remove()
  end

  --- @param Wrapper.Client#CLIENT MenuClient
  local function AddStatusMenu( MenuClient )
    local MenuClientName = MenuClient:GetName()
    -- This would create a menu for the red coalition under the MenuCoalitionRed menu object.
    MenuStatus[MenuClientName] = MENU_CLIENT:New( MenuClient, "Status for Planes" )
    MENU_CLIENT_COMMAND:New( MenuClient, "Show Status", MenuStatus[MenuClientName], ShowStatus, MenuClient, "Status of planes is ok!", "Message to Red Coalition" )
  end

  SCHEDULER:New(nil,
    function()
      local Client_F14_CVN71 = CLIENT:FindByName("C-F14-CVN71")
      if Client_F14_CVN71 and Client_F14_CVN71:IsAlive() then
        local MenuManage = MENU_CLIENT:New( Client_F14_CVN71, "Mission Info" )
        MENU_CLIENT_COMMAND:New( Client_F14_CVN71, "Add Status Menu Plane 1", MenuManage, AddStatusMenu, Client_F14_CVN71 )
      end
    end, {}, 10, 10 )
end
