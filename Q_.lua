local addonName, addon = ...
 
function addon:getQTable(Qtitle)
 
    if(Qtitle == "Default") then
        local questionTable = {
            "Question 123123",
            "Question 2",
            "Question 3",
            "Question 4",
 
            }
        local returnTable = 
        {
        	title = "Default",
        	numQuestions = #questionTable,
        	qTable = questionTable,
        }
        return returnTable
    end
    if(Qtitle == "Secondary") then
           local questionTable = {
               "Secondary 1",
               "Secondary 2",
               "Secondary 3",
               "Secondary 4",
               "Secondary 5",
 
               }
          local returnTable = 
      	 	{
        	title = "Secondary",
        	numQuestions = #questionTable,
        	qTable = questionTable,
        	}
           return returnTable
       end
end