
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
---------------------------------- Variable declarations ---------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


-- To be able to use several files. This way functions can be stored in the table "addon"
-- and accessed from any file, as this table will be the same for every single file in 
-- the same addon
local addonName, addon = ...


function addon:showQuestionnaire()
	print "Test"
end

