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

-- Upper limit to random number generation for channel prefix generation
local upper_limit = 10000 


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------- Auxiliary functions --------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


-- (see http://www.wowwiki.com/AddOn_communications_protocol for more details)

-- Creates a name for the communication channel, based on the name and kind of group (raid, guild, ...?)
-- and a random numeric sufix that prevents collisions -to a certain extent-.
-- @param name: name of the group
-- @param grouptype: kind of group (raid, guild, ...?)
function GenerateChannelName (name) --, grouptype) -- Testing
  -- TODO cut name (three letters instead of whole group name, for instance)
  -- TODO change generation of name so that it does not matter if the player is drunk when sending
  local sufix = tostring(math.random(upper_limit)) -- upper_limit is a constant defined above
  --return grouptype .. name .. sufix
  return name .. sufix
end



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-------------------------------------- Data Storage --------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


-- ... = values of interests
function add_stakeholders( conflict_data, name, interests_names, ... )

  table.insert(conflict_data["stakeholders_names"], name)
  -- Create + and - cells
  for j=1, (#conflict_data["options"]*2) do -- *2 because each option is divided in + and -
    if (j % 2 ~= 0) then
      conflict_data.posneg[j] = "+"
    else
      conflict_data.posneg[j] = "-"
    end
  end
  table.insert(conflict_data["stakeholders_interests_names"], interests_names)

  local interest = {}
  local interests = {}
  for i=1, #interests_names do
    if (... ~= nil) then
      -- TODO asign values to empty strings interest[j]
      print "Assigning values"
    else
      -- Create empty values for each cell of the row of that interest
      for j=1, (#conflict_data["options"]*2) do -- *2 because each option is divided in + and -
        interest[j] = {}
        for consequence=1, 2 do -- TODO change to a variable number
          table.insert(interest[j], "Empty")
        end
      end
    end
    table.insert(interests, interest)
  end
  table.insert(conflict_data["stakeholders_interests_values"], interests)

  return conflict_data
end




-- Default values for the conflict
function setDefaultValues( conflict )

  conflict.conflict_data["options"] = {}
  conflict.conflict_data["posneg"] = {}
  conflict.conflict_data["stakeholders_names"]  = {}
  conflict.conflict_data["stakeholders_interests_names"] = {}
  conflict.conflict_data["stakeholders_interests_values"]= {}

  conflict.conflict_data["description"] = "Conflict: Player2 feels bullied by Axelsonn"
  table.insert(conflict.conflict_data["options"], "Ban Axelsonn")
  table.insert(conflict.conflict_data["options"], "Give warning to Axelsonn")
  table.insert(conflict.conflict_data["options"], "Do nothing")

  conflict.conflict_data = add_stakeholders(conflict.conflict_data, "Guild", {"IntGuild1", "IntGuild2"})
  conflict.conflict_data = add_stakeholders(conflict.conflict_data, "Guild Leaders", {"IntGuildLead1", "IntGuildLead2"})
  conflict.conflict_data = add_stakeholders(conflict.conflict_data, UnitName("player"), {"IntPlay1", "IntPlay2"})

  return conflict
end



function updateTableValue(type, data, ... )
  local match = false
  local prefix, message, channel, sender = ...
  local master = addon.conflicts_active_testing[prefix].master
  if type == "tit" then -- Title
    if (data ~= nil and sender == master) then
      match = true
      addon.conflicts_active_testing[prefix].conflict_data["description"] = data
      -- If UI is already created, update the value of the text box
      if (addon.conflicts_active_testing[prefix].conflict_ui["description"] ~= nil) then
        addon.conflicts_active_testing[prefix].conflict_ui["description"]:SetText(data)
      end
    end

  elseif type == "par" then -- Participant
    if (data ~= nil and sender == master) then
      match = true
      local ready
      local participant, readystring = data:match("(.+)=(.+)")
      --TODO improve this chapuza!
      if (readystring == "true") then
        ready = true
      else
        ready = false
      end
      addon.conflicts_active_testing[prefix].participants[participant] = ready
    end


  elseif (type == "opt" and data ~= nil) then -- "Option"
    local optionNumber, option_value = data:match("(%d)=(.+)")

    if (optionNumber ~= nil and option_value ~= nil and sender == master) then
      match = true
      local option_number = tonumber(optionNumber)
      addon.conflicts_active_testing[prefix].conflict_data["options"][option_number] = option_value
      -- If UI is already created, update the value of the text box
      if (addon.conflicts_active_testing[prefix].conflict_ui["options"] ~= nil) then
        addon.conflicts_active_testing[prefix].conflict_ui["options"][option_number]:SetText(option_value)
      end
    end
      
  elseif (type == "sta" and data ~= nil) then -- Stakeholder
    local stakeholderNumber, stakeholder_name = data:match("(%d)=(.+)")
    if (stakeholderNumber ~= nil and stakeholder_name ~= nil and sender == master) then
      match = true
      local stakeholder_number = tonumber(stakeholderNumber)
      addon.conflicts_active_testing[prefix].conflict_data["stakeholders_names"][stakeholder_number] = stakeholder_name
      addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_values"][stakeholder_number] = {}
      addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_names"][stakeholder_number] = {}
      -- If UI is already created, update the value of the text box
      if (addon.conflicts_active_testing[prefix].conflict_ui["stakeholders"] ~= nil) then
        addon.conflicts_active_testing[prefix].conflict_ui["stakeholders"][stakeholder_number]:SetText(stakeholder_name)
      end
    end

  elseif (type == "pos" and data ~= nil) then -- Positive/Negative
    local posnegNumber, posneg_value = data:match("(%d)=(.+)")
    if (posnegNumber ~= nil and posneg_value ~= nil and sender == master) then
      match = true
      local posneg_number = tonumber(posnegNumber)
      addon.conflicts_active_testing[prefix].conflict_data["posneg"][posneg_number] = posneg_value
      -- If UI is already created, update the value of the text box
      if (addon.conflicts_active_testing[prefix].conflict_ui["posneg"] ~= nil) then
        addon.conflicts_active_testing[prefix].conflict_ui["posneg"][posneg_number]:SetText(posneg_value)
      end
    end

  elseif (type == "int" and data ~= nil) then -- Interest
    local interestNumber, stakeholderNumber, interest_name = data:match("(%d),(%d)=(.+)")
    if (interestNumber ~= nil and stakeholderNumber ~= nil and interest_name ~= nil and sender == master) then
      match = true
      local stakeholder_number = tonumber(stakeholderNumber)
      local interest_number = tonumber(interestNumber)
      addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_names"][stakeholder_number][interest_number] = interest_name
      addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_values"][stakeholder_number][interest_number] = {}
      -- If UI is already created, update the value of the text box
      if (addon.conflicts_active_testing[prefix].conflict_ui["interests"] ~= nil) then
        addon.conflicts_active_testing[prefix].conflict_ui["interests"][stakeholder_number][interest_number]:SetText(interest_name)
      end
    end

  elseif (type == "con" and data ~= nil) then -- Index
    local consequenceNumber, posnegNumber, interestNumber, stakeholderNumber, consequence_value = data:match("(%d),(%d),(%d),(%d)=(.+)")
    if (consequenceNumber ~= nil and posnegNumber ~= nil and interestNumber ~= nil and stakeholderNumber ~= nil and consequence_value ~= nil and sender == master) then
      match = true
      local stakeholder_number = tonumber(stakeholderNumber)
      local interest_number = tonumber(interestNumber)
      local posneg_number = tonumber(posnegNumber)
      local consequence_number = tonumber(consequenceNumber)
      if (addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_values"][stakeholder_number][interest_number][posneg_number] == nil) then
        addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_values"][stakeholder_number][interest_number][posneg_number] = {}
      end
      addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_values"][stakeholder_number][interest_number][posneg_number][consequence_number] = consequence_value
      -- If UI is already created, update the value of the text box
      if (addon.conflicts_active_testing[prefix].conflict_ui["consequences"] ~= nil) then
        addon.conflicts_active_testing[prefix].conflict_ui["consequences"][stakeholder_number][interest_number][posneg_number][consequence_number]:SetText(consequence_value)
      end
    end
  end
  return match
end





function addon:createTableReceived ( ... )
  local match = false
  local prefix, message, channel, sender = ...
  local master = addon.conflicts_active_testing[prefix].master
  --if conflict then
  local type, data = message:match("^(...)(.*)$")
  if type == "ini" then -- Starting data sending
    match = true
    addon.conflicts_active_testing[prefix].conflict_data["options"] = {}
    addon.conflicts_active_testing[prefix].conflict_data["posneg"] = {}
    addon.conflicts_active_testing[prefix].conflict_data["stakeholders_names"] = {}
    addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_values"] = {}
    addon.conflicts_active_testing[prefix].conflict_data["stakeholders_interests_names"] = {}
    addon.conflicts_active_testing[prefix].summary = {}
  elseif type == "end" then -- Data sent
    match = true
    -- Creation of main window for the discussion
    addon.conflicts_active_testing[prefix]= addon:createEditionWindow(prefix)
    --addon:createParticipantsWindow(prefix)
  elseif (type == "upd" and (UnitName("player") == master)) then -- Send order to update a value of the table
    match = true
    SendAddonMessage(prefix, data, "WHISPER", sender) -- Testing, should be sent to the group
  else
    match = updateTableValue(type, data, ...)
  end
  return match
end




function addon:initializeVotesStructure()
  --[[ addon.conflicts_active[prefix]["votes"] = {}
  for player_number in (#conflict.participants) do
    table.insert(addon.conflicts_active[prefix].votes, "")
  end
  --]]
end


function summary ( prefix )
  local consequenceNumber, posnegNumber, interestNumber, stakeholderNumber, rest
  summary = {}
 -- print (#addon.conflicts_active[prefix].votes)
  for voter, votes in pairs(addon.conflicts_active[prefix].votes) do
    repeat
      consequenceNumber, posnegNumber, interestNumber, stakeholderNumber, rest  = votes:match("(%d),(%d),(%d),(%d),(.*)")
      if (consequenceNumber ~= nil and posnegNumber ~= nil and interestNumber ~= nil and stakeholderNumber ~= nil and rest ~= nil) then 
        vote = consequenceNumber .. "," .. posnegNumber .. "," .. interestNumber .. "," .. stakeholderNumber 
        if (summary[vote] == nil) then
          summary[vote] = 1
        else
          summary[vote] = summary[vote] + 1
        end     
      end
      votes = rest
    until rest == nil -- Until there are no more votes in the string
  end
  for vote, number_of_votes in pairs(summary) do
    SendAddonMessage(prefix, ("sum%s=%d"):format(vote, number_of_votes), "WHISPER", UnitName("player")) -- Testing, change to group (broadcast summary)
  end
  SendAddonMessage(prefix, "Voting finished", "WHISPER", UnitName("player")) -- Testing, change to group (broadcast summary)
end



function checkVotes( ... )
  local match = false
  local prefix, message, channel, sender = ...
  local master = addon.conflicts_active_testing[prefix].master
  local type, data = message:match("^(...)(.*)$")  
  if (type == "vot" and data ~= nil and UnitName("player") == master) then -- Votes
    match = true
    addon.conflicts_active[prefix].votes[sender] = data
    -- Check if all participants are finished voting and broadcast summary data
    local number_participants, number_of_votes = 0, 0
    for index, vote in pairs(addon.conflicts_active[prefix].votes ) do
      number_of_votes = number_of_votes + 1
    end
    for participant, ready in pairs(addon.conflicts_active_testing[prefix].participants) do
      number_participants = number_participants + 1
    end
    if (number_of_votes == number_participants) then
      summary(prefix)
    end

  elseif (type == "sum" and data ~= nil and sender == master) then
    local votecode, number_of_votes  = data:match("(.+)=(%d)")
    addon.conflicts_active_testing[prefix].summary[votecode] = number_of_votes
  end
  return match
end


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
---------------------------------------- Conflicts ---------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


function continueCreateDiscussion( prefix, group )
  local success = RegisterAddonMessagePrefix(prefix)
  if (success) then
    ColLabWoW:RegisterEvent("CHAT_MSG_ADDON")
    print ("Group is " .. group)
    addon.conflicts_active[prefix] = { master = (UnitName("player")), -- who has the master copy of the data
                              group = group, -- Guild, Raid, Party
                              participants = {}, -- who is in the discussion
                              conflict_data = {}, -- raw data: options, stakeholders, consequences
                              conflict_ui = {}, -- graphical data: options, stakeholders, ... editboxes, buttons, etc.
                              votes = {}, -- List of the votes, only on the master's copy
                              summary = {},
    }
	-- TODO Store timestamp for participants
    addon.conflicts_active[prefix].participants[(UnitName("player"))] = false -- Join discussion and false that it has finished the first stage (editing stage)
    -- Inform other clients to what prefix to subscribe
    -- SendChatMessage("I want to start a conflict using prefix " .. addon_prefix, group) -- Testing below
    SendChatMessage("I want to start a discussion using prefix " .. prefix, "WHISPER", "Common", (UnitName("player")))

    addon.conflicts_active[prefix] = setDefaultValues(addon.conflicts_active[prefix])

    -- Creation of main window for the discussion
	-- Activate this when Testing with more than one account
    --conflicts_active[prefix] = addon:createEditionWindow(prefix)
    --conflicts_active[prefix] = addon:createParticipantsWindow(prefix)
  else
    print ("Error: the prefix registration failed")
  end
end



function addon:startDiscussion ( )

  ColLabWoW:RegisterEvent("CHAT_MSG_CHANNEL")
  addon:createDiscussionWindow()
end




  ---------------------------------------------------------------------------------------
  ------------------------------- Join a conflict ---------------------------------------
  ---------------------------------------------------------------------------------------
function addon:joinConflict ( prefix, sender )
 -- if (conflicts_active[prefix] == nil) then -- Testing: uncomment
    addon.conflicts_active_testing[prefix] = {}
    local success = RegisterAddonMessagePrefix(prefix)
    if (success) then
      addon.conflicts_active_testing[prefix] = { master = sender,
                                          participants = {},
                                          conflict_data = {}, 
                                          conflict_ui = {},
                                          summary = {} 
      }
      ColLabWoW:RegisterEvent("CHAT_MSG_ADDON")
       -- Ask client with master copy for data
      print ("Data request sent to " .. sender)

      SendAddonMessage(prefix, "Joined discussion", "WHISPER", sender) -- Testing, change to group
      SendAddonMessage(prefix, "Data request", "WHISPER", sender)

    else
      print ("Error: the prefix registration failed")
    end
--  end -- Testing: uncomment
end


  ---------------------------------------------------------------------------------------
  --------------------------- Send data of a conflict -----------------------------------
  ---------------------------------------------------------------------------------------

-- The master sends the state of the conflict
function addon:sendData( prefix, recipient )
  SendAddonMessage(prefix, "init", "WHISPER", recipient)
  local conflict = addon.conflicts_active[prefix]
   -- TODO split the description/title string  if it is too long and send it in several messages
  SendAddonMessage(prefix, "tit".. conflict.conflict_data["description"], "WHISPER", recipient)
  -- Send the options information
  for option_number=1, (#conflict.conflict_data["options"]) do
    -- TODO split the string option if it is too long and send in different messages
    SendAddonMessage(prefix, ("opt%d=%s"):format(option_number,conflict.conflict_data["options"][option_number]), "WHISPER", recipient)

    -- Create positive/negative consequences indicators boxes (non editable)
    for counter = 1, 2 do
      -- Calculate column (even or odd and option number)
      local posneg_index = option_number*2
      if counter == 1 then
        posneg_index = posneg_index -1
      end
      SendAddonMessage(prefix, ("pos%d=%s"):format(posneg_index, conflict.conflict_data["posneg"][posneg_index]), "WHISPER", recipient)
    end
  end -- End of creation of options boxes
  conflict.conflict_ui["options"] = option_boxes
  conflict.conflict_ui["posneg"] = posneg_boxes


  -- Send the stakeholders information (also their interests and the values of those)
  for stakeholder_number=1, (#conflict.conflict_data["stakeholders_names"]) do
    -- TODO split the string if it is too long and send in different messages
    SendAddonMessage(prefix, ("sta%d=%s"):format(stakeholder_number, conflict.conflict_data["stakeholders_names"][stakeholder_number]), "WHISPER", recipient)
    for interest_number, interestlist in pairs (conflict.conflict_data["stakeholders_interests_values"][stakeholder_number]) do
     SendAddonMessage(prefix, 
        ("int%d,%d=%s"):format(interest_number,stakeholder_number,conflict.conflict_data["stakeholders_interests_names"][stakeholder_number][interest_number]),
        "WHISPER", recipient)
      -- Send row of values (columns of consequences) for each interest
      for index_number, indexes in pairs(interestlist) do
        for consequence_number, consequence_value in pairs(indexes) do
          SendAddonMessage(prefix, ("con%d,%d,%d,%d=%s"):format(consequence_number,index_number, interest_number,stakeholder_number,consequence_value), "WHISPER", recipient)
        end
      end
    end
  end
  for participant, ready in pairs(conflict.participants) do
    SendAddonMessage(prefix, ("par%s=%s"):format(participant, tostring(ready)), "WHISPER", recipient)
  end
  SendAddonMessage(prefix, "end", "WHISPER", recipient)
end




