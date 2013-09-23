
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
---------------------------------- Variable declarations ---------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


-- To be able to use several files. This way functions can be stored in the table "addon"
-- and accessed from any file, as this table will be the same for every single file in
-- the same addon
local addonName, addon = ...
local fuckme = true
local max_X = 600
local max_Y = 400 --values for width and height of QFrame.
local question = { --a table to hold the question/answer format
            prompt = nil,
            firstSelection = true,
            buttonSet = {[1] = nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil,questionIterator = nil, },
            bText = {1,2,3,4,5,},
            buttonLogic = {
            [1] = false,
            [2] = false,
            [3] = false,
            [4] = false,
            [5] = false,
            } --array of boolean values to store button states
        }
    local questions =
    {} -- an ARRAY holding each question  and its data
local qText = {}
    local questionnaire_title = nil
local nextPageExists = false -- false default intended
local nextQuestion = 1

------------------------------------------------------------------------------------------------------------------------------------
function initQuestionnaire()
   local NUM_QUESTIONS = 4
   local question_table = {
        "Question 1",
        "Question 2",
        "Question 3",
        "Question 4",
    }
   for i = 1, NUM_QUESTIONS do
   local Q = {} --we do this INSIDE the for loop to reset Q's v  alue and reset the metatable
    setmetatable(Q, {__index = question}) -- bases table Q off of question table (basically instantiating an object of type question)
    Q.prompt= question_table[i]
    table.insert(questions, i,Q) -- inserts a new "question" into our array of "questions"
   end
end
-----------------------------------------------------------------------------------------------------------------------------------------
function RadioButton_OnClick(self)
    QI=self.questionIterator
    print ("QI = " .. QI)


    buttonIterator = nil
    if not questions[QI].firstSelection then
        for i=1, 5 do
            if (questions[QI].buttonLogic[i]) then -- since buttonLogic stores our old button, we need to get that iterator so we
            -- can set the old button to unselected and then select the new button stored in returnTable or "table"

            --the reason we don't use getChecked instead of our buttonLogic table is b/c in order to prevent the automatic
            --unchecking of every button, we need to manually store a button once we have handl ed it in our system
                print(questions[QI].buttonSet[i]:GetName())
                questions[QI].buttonSet[i]:SetChecked(false)
                print (i)
                questions[QI].buttonLogic[i] = false
                break
            end
        end

    else
        questions[QI].firstSelection=false
        questions[QI].buttonLogic[self.bNumber]=true
    end

end
-------------------------------------------------------------------------------------------------------------------------------------
function submit(self)
    self:GetParent():Hide()
    print("Thanks for participating!  Please open your mailbox and ColLab will automatically send your results to a collection point") --TODO: fix wording?
    local data = "Results: "
    for i=1, #questions do
        for a=1, 5 do
            if(questions[i].buttonSet[a]:GetChecked()) then
                data = data.."("..i..","..a..")" --TODO:error checker for invalid data (e.g. 2 answers for 1 q)
            end
        end
    end
    mailEventFrame = CreateFrame("Frame","MailEventFrame",QFrame)
    mailEventFrame:RegisterForEvent("MAIL_INBOX_UPDATE")
    mailEventFrame:SetScript("OnEvent", function(self, event, ...)
        SendMail("QuestionnaireBot","Results", data) --DON'T FORGET TO CHANGE RECIPIENT TO ACTUAL RECIPIENT NAME LOL
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------
function getLikertString(selection)
    if (selection==1) then
        return "Strongly Agree"
    elseif(selection==2) then
        return "Agree"
    elseif(selection==3) then
        return "Neutral"
    elseif(selection==4) then
        return "Disagree"
    elseif(selection==5) then
        return "Strongly Disagree"
    else
        print ("Error: Radio button value out of likert index (ColLabWoW/Questionnaire.lua: function getLikertString)")
    end
end
function updateQuestions()
    for i=nextQuestion,#questions do
        print (i.."    :    " .. questions[i].prompt)
        qText[i-5]:SetText(questions[i].prompt)
    end
end
function addon:showQuestionnaire()
    local changeY = 0 --zero b/c we need to run comparisons before setting values
    local changeX = nil
    local tempText = nil
	initQuestionnaire()
	if(not QFrame) then
	    local QFrame = CreateFrame("Frame", "QFrame", QFrame)
	    QFrame:SetWidth(max_X)
	    QFrame:SetHeight(max_Y)
	    QFrame:ClearAllPoints()
	    QFrame:SetPoint("CENTER", UIParent, "CENTER")
	    QFrame:SetFrameStrata("BACKGROUND")
	    QFrame:SetFrameLevel(5)
	    backdropTable = {
		bgFile = "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-ACHIEVEMENTBACKGROUND.png",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize=16,
		tile = true,
		tileSize=800,
		insets = {
		    left = 5,
		    right = 5,
		    top = 5,
		    bottom = 5,
		}
		}
	    QFrame:SetBackdrop(backdropTable)
	    -----------------------------
	    QFrame.title = QFrame:CreateFontString("Questionnaire_Title","Overlay","GameFontNormal")
	    QFrame.title:SetPoint("TOP",0,-18)
	    QFrame.title:SetText("Please answer the following questions to the best of your ability.")
	else
	    QFrame:Show()
	    print ("showing qframe")
	end
	if (#questions>5) then
		        nextPageExists=true
		        print ("debug")
		    else
		        nextPageExists=false
		    end

	for i=1, #questions do
	    changeY= -(i*60)
	    if (changeY< -359) then --if we've run out of space in our current frame
	        print ("out of space!!")
	        break
	    end
	    nextQuestion = i+1 --stores next question in QFrame in case we run out of space
	    tempText = QFrame:CreateFontString("Question"..i, "Overlay", "GameFontNormal")
	    table.insert(qText, tempText)
	    qText[i]:ClearAllPoints()
	    qText[i]:SetPoint("Top", 0, changeY) --TODO fix text positioning
	    qText[i]:SetText(questions[i].prompt)

	    changeX=-200 --reset value of changeX for the next iteration of the following loop
	    --if not buttonsCreated then
	        for a=1, 5   do --5 buttons per question
	            --VIRGINIA: this is the debug printout I showed you in the email.
	            --This section creates a new set of buttons for every value in the "questions" array, but for some reason
	            --it seems to vertically override the old buttons.
	            --Happy hunting :\
	            print (questions[i].buttonSet[a])
	            questions[i].buttonSet[a]  = CreateFrame("CheckButton", "RadioButton#("..i..","..a..")", QFrame, "UIRadioButtonTemplate")
	            print (questions[i].buttonSet[a])
	            print ("------------------")
	            questions[i].buttonSet[a].questionIterator = i
	            questions[i].buttonSet[a]:SetHeight(20)
	            questions[i].buttonSet[a]:SetWidth(20)
	            questions[i].buttonSet[a]:ClearAllPoints()
	            questions[i].buttonSet[a]:SetPoint("TOP", changeX, changeY-12)
	            questions[i].buttonSet[a]:RegisterForClicks("LeftButtonUp")
	            questions[i].buttonSet[a].bNumber = a
	            questions[i].buttonSet[a]:SetScript("OnClick", RadioButton_OnClick)

	            --changeY-12 because we want the buttons towwwwwww be roughly 10 pixels below our question text

	            questions[i].bText[a] = questions[i].buttonSet[a]:CreateFontString("ButtonSubtext#("..i..","..a..")", "Overlay", "GameFontNormal")
	            questions[i].bText[a]:ClearAllPoints()
	            questions[i].bText[a]:SetPoint("Bottom",0, -13) --TODO Fix text positioning
	            questions[i].bText[a]:SetText(getLikertString(a))
	            questions[i].bText[a]:SetTextColor(0,0,0,.65)


	            --changeX increases each iteration of this loop to space out each radio button
	            changeX = changeX + 100  --is += a thing in lua?
	        end -- end radio-button creation (inner for loop)
	    --end
	end -- end text creation(outer for loop)
	print(questions[1].buttonSet[3] )
	questions[1].buttonSet[3]:SetChecked(true)
	endButton = CreateFrame("Button", "EndButton", QFrame, "GameMenuButtonTemplate")
	endButton:ClearAllPoints()
	endButton:SetPoint("BOTTOM", 0, 10)
	endButton:RegisterForClicks("LeftButtonUp")
	if (nextPageExists) then
	    endButton:SetText("Next")
	    endButton:SetScript("OnClick", updateQuestions)
	else
	    endButton:SetText("Submit")
	    endButton:SetScript("OnClick", submit)
	end--endif
	exitButton = CreateFrame("Button", "ExitButton", QFrame, "UIPanelCloseButton")
	exitButton:ClearAllPoints()
	exitButton:SetPoint("TOPRIGHT", 0, 0)
	--end of initialization section
-----------------------------------------------------------------------------------------------------------------------------------
end



--button info @ 1164
--MAIL FUNCTIONS @1074
--SENDMAIL FUNCTION @911
--TODO: write error handler function that passes an error code as arg.
