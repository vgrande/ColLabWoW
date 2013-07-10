local addon = ...
local MAJOR, MINOR = "LibSyncTime-1.0", tonumber("7") or math.huge
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- no upgrade req

-- fetch functions to upvalues
-- core functions
local time, select, tonumber =
      time, select, tonumber
-- api functions
local GetGameTime, CalendarGetDate =
      GetGameTime, CalendarGetDate

lib.eframe = CreateFrame("Frame")
local eframe = lib.eframe
eframe:SetScript("OnUpdate", function(self)
	local TimeMins=(select(2,GetGameTime()))
	if TimeMins ~= lib.lastTimeMins then
		if lib.lastTimeMins then
			lib.lastMinuteChange = time()
		end
		lib.lastTimeMins = TimeMins
	end
end)
eframe:SetScript("OnEvent", function(self, event, a, msg, c, auth)
	if event == "CHAT_MSG_ADDON" then
		if a == "LibSyncTimeRQ" and auth ~= (UnitName("player")) and lib.lastMinuteChange then
			SendAddonMessage("LibSyncTimeSC", tonumber(time()-lib.lastMinuteChange), "WHISPER", auth)
		elseif a == "LibSyncTimeSC" then
			local stime = tonumber(msg)
			if stime and (not lib.lastMinuteChange) then
				lib.lastMinuteChange = time()-stime
			end
		end
	elseif (event == "ADDON_LOADED") and (a == addon) then
		if IsInGuild() then
			SendAddonMessage("LibSyncTimeRQ", "", "GUILD")
		end
		if IsInRaid() then
			SendAddonMessage("LibSyncTimeRQ", "", "RAID")
		elseif IsInGroup() then
			SendAddonMessage("LibSyncTimeRQ", "", "PARTY")
		end
	end
end)
eframe:RegisterEvent("CHAT_MSG_ADDON")
eframe:RegisterEvent("ADDON_LOADED")

function lib:synctime()
	local secs = self.lastMinuteChange and (time()-self.lastMinuteChange) or 0
	local hrs, mins = GetGameTime()
	local month, day, yr = select(2, CalendarGetDate())
	return time({hour=hrs, min=mins, month=month, day=day, year=yr, sec=secs}), (not self.lastMinuteChange)
end
local meta = getmetatable(lib)
if meta then
	meta.__call = lib.synctime
else
	setmetatable(lib, {__call=lib.synctime})
end
RegisterAddonMessagePrefix("LibSyncTimeSC")
RegisterAddonMessagePrefix("LibSyncTimeRQ")