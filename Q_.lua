local addonName, addon = ...
 local TEXT  = true
 local BUTTON = false
function addon:getQTable(Qtitle)
 ------------------------------------------------------------------------------------------------------------------------
    if(Qtitle == "Default") then -- STEP 1 - CHANGE TITLE
        local questionTable = {
            [1] = "Question 1", -- STEP 2 - CHANGE EACH QUESTION
            [2] =  "Question 2",
            [3] = " Question 3",
            [4] =  "Question 4",
            textNums = 
              {
                [1] = TEXT, -- STEP 3 (Last step) - CHANGE INDIVIDUAL QUESTION TYPE (TEXT or BUTTON). ADD MORE OR TAKE AWAY SOME IF NEEDED
                [2] = BUTTON,
                [3] = TEXT,
                [4] = BUTTON, 

              }
            }
         
        local returnTable = 
        {
        	title = Qtitle,
        	numQuestions = #questionTable,
        	qTable = questionTable,
        }
        if(#returnTable.qTable.textNums ~= #returnTable.qTable) then
          print("Warning: #returnTable.textNums ~= #returnTable.questionTable")
        end
        return returnTable
    end
------------------------------------------------------------------------------------------------------------------------
    if(Qtitle == "Secondary") then -- STEP 1 - CHANGE TITLE
        local questionTable = {
            [1] = "Secondary Question 1", -- STEP 2 - CHANGE EACH QUESTION
            [2] =  "Secondary Question 1",
            [3] = "Secondary Question",
            [4] =  "Secondary Question",
            textNums = 
              {
                [1] = TEXT, -- STEP 3 (Last step) - CHANGE INDIVIDUAL QUESTION TYPE (TEXT or BUTTON).  ADD MORE OR TAKE AWAY SOME IF NEEDED
                [2] = TEXT,
                [3] = TEXT,
                [4] = TEXT,

              }
            }
         
        local returnTable = 
        {
          title = Qtitle,
          numQuestions = #questionTable,
          qTable = questionTable,
        }
        if(#returnTable.qTable.textNums ~= #returnTable.qTable) then
          print("Warning: #returnTable.textNums ~= #returnTable.questionTable")
        end
        return returnTable
    end
------------------------------------------------------------------------------------------------------------------------
end
