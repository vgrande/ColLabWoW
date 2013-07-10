------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
---------------------------------- ColLab for Wow ----------------------------------------
------------------------------ Uppsala University 2013 -----------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
---------------------------------- Variable declarations ---------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- To be able to use several files. This way functions can be stored in the table "addon"
-- and accessed from any file, as this table will be the same for every single file in 
-- the same addon
local addonName, addon = ...

addon.conflicts_pending  = {} -- Conflicts that have been created but the player has not joined yet
addon.conflicts_active = {} -- Conflicts created by anyone and joined by the player
addon.conflicts_active_testing = {} -- Conflicts created by anyone and joined by the player (communication testing)



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--------------------------------- Functions declarations ---------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

---[[

local ColLabEventChat_Msg_Addon

-- Data storage
local checkParticipantsUpdate

--]]



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------ Scripts ---------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Run each time the screen is drawn by the game engine (wowprogramming.com)
function ColLabWoW_Update( )
--  print("Updating content")
end


-- Run whenever an event fires for which the frame is registered (wowprogramming.com)
 function ColLabWoW_OnEvent (frame, event, ...)
  -- For messages received through an addon channel
  if (event == "CHAT_MSG_ADDON") then
    ColLabEventChat_Msg_Addon(frame,event,...)
    
  -- For messages received through a standard channel
  elseif (event == "CHAT_MSG_WHISPER") then -- Testing, should be changed to PARTY, etc.
    -- Event signature ("message", "sender", "language", "channelString", "target", "flags", 
    -- unknown, channelNumber, "channelName", unknown, counter, "guid")
    local message = select (1, ...)
    local sender = select (2, ...)
    local prefix = message:match("I want to start a discussion using prefix (.+)")
    -- If it matched and the message comes from another player (not from this client)
    if (prefix ~= nil) then -- Testing, add later: and sender ~= (UnitName("player")) ) then
      -- It is the player who has to decide if he/she joins, don't do it automatically here
      print ("discussion invitation received. You may join by running /clwj")
      addon.conflicts_pending[prefix]= sender
    end
  end

end



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------ Main execution --------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

ColLabWoW = CreateFrame("Frame", "ColLabWoW", UIParent)
ColLabWoW:SetWidth(384)
ColLabWoW:SetHeight(512)
ColLabWoW:SetPoint("CENTER", UIParent, "CENTER")

ColLabWoW:SetScript("OnEvent", ColLabWoW_OnEvent)
ColLabWoW:SetScript("OnUpdate", ColLabWoW_Update)
ColLabWoW:RegisterEvent("CHAT_MSG_WHISPER") -- Testing, should be changed to PARTY, etc. (or not? What happens with invitations?)




------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------ Slash commands and aliases --------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

SLASH_COLLABWOWCREATE1 = "/clwc"
SLASH_COLLABWOWCREATE2 = "/collabwowcreate"
SlashCmdList["COLLABWOWCREATE"] = function ()
  addon:startConflict()
 end

SLASH_COLLABWOWJOIN1 = "/clwj"
SLASH_COLLABWOWJOIN2 = "/collabwowjoin"
SlashCmdList["COLLABWOWJOIN"] = function ()
  if (next(addon.conflicts_pending ) == nil) then -- table is empty
    print ("There are no conflicts pending")
  else
    for prefix, sender in pairs(addon.conflicts_pending ) do
      print ("There are conflicts, joining " .. prefix)
      addon:joinConflict(prefix, sender)
    end
  end
end

-- Shows a column in another window with the participants of the discussion
SLASH_PARTICIPANTS1 = "/clwpar"
SLASH_PARTICIPANTS2 = "/clwparticipants"
SlashCmdList["PARTICIPANTS"] = function ()
-- TODO old function, update
  Participants:Show()
end


-- Old command to create private channel
--[[
  if (chosen_name == "") then
    print ("You need to provide a name for the channel. Type /clw <name> to join your
     group's channel")
  else
    channel_type, channel_name = JoinChannelByName(chosen_name, "secretPassword")
    , ChatFrame1:GetID(), 1);
    print (string.format("Joined channel %s for decision making", channel_name))
    sendChatMessage ("testiiiing", "WHISPER", "Common", "Axelsonn")
--]]






------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
----------------------------- Communication functions ------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------



ColLabEventChat_Msg_Addon = function (frame, event, ... )
  local prefix_received, message, channel, sender = ...
    -- Check if there is an active conflict with that prefix. Otherwise, ignore
    for prefix, _ in pairs(addon.conflicts_active) do 
      if (prefix_received == prefix) then
        -- print ("Message caught = ".. message)
        local master = addon.conflicts_active[prefix].master
       -- print ("Message is " .. message)
        if (message == "Test Message") then
          print ("Test message received")
        
        elseif (message == "Wrong master") then
          print ("Error: Wrong master")

        elseif (message == "Data request") then
          print ("Data requested from " .. sender)
          if (master == UnitName("player")) then-- This client has the master copy
            addon:sendData(prefix, sender)
          else
            SendAddonMessage(prefix, "Wrong master", "WHISPER", sender) -- Error: the sender has a wrong value for "master" TODO reaction to this
          end

        elseif (message == "Joined discussion") then
          print ("Player " .. sender .. " joined the discussion")
          print("Participants: " .. tostring(#addon.conflicts_active[prefix].participants))
          if (addon.conflicts_active[prefix].participants[(UnitName(sender))] == nil) then
            addon.conflicts_active[prefix].participants[(UnitName(sender))] = false -- Joins discussion and false that it has finished the first stage
          end
          if (master == UnitName("player")) then-- This client has the master copy
            SendAddonMessage(prefix, "Update participants: " .. UnitName(sender), "WHISPER", sender) -- Testing, change to group (broadcast new participant)
          end

        elseif (message == "Player to voting") then
          if (master == UnitName("player")) then-- This client has the master copy
            SendAddonMessage(prefix, UnitName(sender) .. " edit ready", "WHISPER", sender) -- Testing, change to group (broadcast new participant)
            -- Check if all participants are finished editing and broadcast command to load new stage
            local ready = 0
            for i=1, #addon.conflicts_active_testing[prefix].participants do
              if (addon.conflicts_active_testing[prefix].participants[i]) then
                ready = ready + 1
              end
            end
            if (ready == #addon.conflicts_active_testing[prefix].participants) then
              SendAddonMessage(prefix, "Go to voting", "WHISPER", sender) -- Testing, change to group (broadcast new stage)
            end
          else
            SendAddonMessage(prefix, "Wrong master", "WHISPER", sender) -- Error: the sender has a wrong value for "master" TODO reaction to this
          end

        elseif (message == "Go to voting") then
          addon:startVoting(prefix)

        elseif (message == "Player to summary") then
          if (master == UnitName("player")) then-- This client has the master copy
            SendAddonMessage(prefix, UnitName(sender) .. " summary ready", "WHISPER", sender) -- Testing, change to group (broadcast new participant)
          else
            SendAddonMessage(prefix, "Wrong master", "WHISPER", sender) -- Error: the sender has a wrong value for "master" TODO reaction to this
          end

        elseif (message == "Voting finished") then
          addon:startSummary(prefix)

        -- Receiving data for creation of personal copy of the conflict (when joining)
        elseif (addon:createTableReceived(...) == false) then
          if ( not checkParticipantsUpdate(...)) then
            checkVotes(...)
          end
        end

        break -- Conflict found => stop iterating
      end
    end
end






------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-------------------------------------- Data Storage --------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


checkParticipantsUpdate = function ( ... )
  local match = false
  local prefix, message, channel, sender = ...
  local master = addon.conflicts_active_testing[prefix].master
  local participant = message:match("Update participants: (.+)")
  if ( participant ~= nil and sender == master) then
    match = true
    addon.conflicts_active[prefix].participants[(UnitName(participant))] = false -- Joins discussion and false that it has finished the first stage
  end

  local participant = message:match("(.+) edit ready")
  if ( participant ~= nil and sender == master) then
    match = true
    addon.conflicts_active[prefix].participants[(UnitName(participant))] = true -- Participant has finished the first stage (editing) and is ready to vote
  end

  return match
end



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
----------------------------------  Stages transitions -----------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


function addon:proceedToVoting ( button )
  print("Proceed to voting clicked")
  local prefix = button:GetName():match("ProcB:(.+)")
  -- Player cannot edit the boxes anymore but it is possible to see the changes other may make
  for option_number, option in pairs(addon.conflicts_active_testing[prefix].conflict_ui.options) do
    option:Disable()
  end

  for stakeholder_number, stakeholder in pairs(addon.conflicts_active_testing[prefix].conflict_ui.stakeholders) do
    stakeholder:Disable()
    for interest_number, interest in pairs(addon.conflicts_active_testing[prefix].conflict_ui.interests[stakeholder_number]) do
      interest:Disable()
      for posneg_number, consequences_list in pairs(addon.conflicts_active_testing[prefix].conflict_ui.consequences[stakeholder_number][interest_number]) do
        for consequence_number = 1, #consequences_list do
          consequences_list[consequence_number]:Disable()
        end
      end
    end
  end

  -- TODO Change to "Go back to editing"
  button:Hide() -- The button is no needed anymore. If needed, it will be set again

  SendAddonMessage(prefix, "Player to voting", "WHISPER", addon.conflicts_active_testing[prefix].master)
  --TODO add way for the master to go to voting even though not everybody is finished
end



function addon:sendVotes( button )
  print("Send votes clicked")
  local prefix = button:GetName():match("SendB:(.+)")
  local votes = "vot"
  -- Player cannot edit the boxes anymore but it is possible to see the changes other may make
  for stakeholder_number, stakeholder in pairs(addon.conflicts_active_testing[prefix].conflict_data.stakeholders_names) do
    --stakeholder:Disable()
    for interest_number, interest_list in pairs(addon.conflicts_active_testing[prefix].conflict_data.stakeholders_interests_values[stakeholder_number]) do
      --interest:Disable()
      for posneg_number, consequences_list in pairs(addon.conflicts_active_testing[prefix].conflict_ui.consequences_boxes[stakeholder_number][interest_number]) do
        for consequence_number, consequence_box in pairs (addon.conflicts_active_testing[prefix].conflict_ui.consequences_boxes[stakeholder_number][interest_number][posneg_number]) do
          if (consequence_box.active) then
            print ("Voted " .. consequence_box:GetText())
            votes = votes .. ("%d,%d,%d,%d,"):format(consequence_number, posneg_number, interest_number, stakeholder_number)
          end
        end
      end
    end
  end
  SendAddonMessage(prefix, votes, "WHISPER", addon.conflicts_active_testing[prefix].master)
  print (votes)
  button:Hide() -- The button is no needed anymore. If needed, it will be set again
  -- TODO Set symbol to show which players have already voted
  SendAddonMessage(prefix, "Player to summary", "WHISPER", addon.conflicts_active_testing[prefix].master)
  --TODO add way for the master to go to summary even though not everybody is finished
end



