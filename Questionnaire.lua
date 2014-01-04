
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
---------------------------------- Variable declarations ---------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


-- To be able to use several files. This way functions can be stored in the table "addon"
-- and accessed from any file, as this table will be the same for every single file in
-- the same addon
local addonName, addon = ...
local max_X = 600
local max_Y = 400 --values for width and height of QFrame.

    local questions =
    {} -- an ARRAY holding each question  and its data
local qText = {}
local questionnaire_title = nil
local nextPageExists = false
local nextQuestion = 1
local currentPage = 1
local data = ""
local numPagesLeft = 0
local NUM_QUESTIONS = 0
local QPP = 0 --questions per page
------------------------------------------------------------------------------------------------------------------------------------
function initQuestionnaire(Qtitle)
	
    local rTable = addon:getQTable(Qtitle)
	NUM_QUESTIONS = rTable.numQuestions
	question_table =rTable.qTable
    if(NUM_QUESTIONS >=5) then
		QPP = 5
	else
		QPP = NUM_QUESTIONS
	end
    numPagesLeft = (NUM_QUESTIONS - (NUM_QUESTIONS%5))/5 + 1

    for i = 1, NUM_QUESTIONS do
       local question = { --a table to hold the question/answer format
            prompt = question_table[i],
            firstSelection = true,
            buttonSet = {[1] = nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil,},
            bText = {1,2,3,4,5,},
            buttonLogic = {
            [1] = false,
            [2] = false,
            [3] = false,
            [4] = false,
            [5] = false,
            } --array of boolean values to store button states
        }
      table.insert(questions, i,question) -- inserts a new "question" into our array of "questions"
   end
end
-----------------------------------------------------------------------------------------------------------------------------------------
function RadioButton_OnClick(self)

    local name, questionNumber, buttonNumber = self:GetName():match("(.+)(%d),(%d)")
    questionNumber = tonumber(questionNumber)
    buttonNumber = tonumber(buttonNumber)
    buttonIterator = nil
    if not questions[questionNumber].firstSelection then
        for i=1, 5 do
            if (questions[questionNumber].buttonLogic[i]) then -- since buttonLogic stores our old button, we need to get that iterator so we
            -- can set the old button to unselected and then select the new button stored in returnTable or "table"

            --the reason we don't use getChecked instead of our buttonLogic table is b/c in order to prevent the automatic
            --unchecking of every button, we need to manually store a button once we have handl ed it in our system
                questions[questionNumber].buttonSet[i]:SetChecked(false)
                questions[questionNumber].buttonLogic[i] = false
                questions[questionNumber].buttonLogic[buttonNumber] = true
                break
            end
        end

    else
        questions[questionNumber].firstSelection=false
        questions[questionNumber].buttonLogic[buttonNumber]=true
    end

end
-------------------------------------------------------------------------------------------------------------------------------------
function submit(self)
    self:GetParent():Hide()
    print("Thanks for participating!  Please open your mailbox and ColLab will automatically send your results to a collection point") --TODO: fix wording?
    mailEventFrame = CreateFrame("Frame","MailEventFrame", QFrame)
    mailEventFrame:RegisterEvent("MAIL_INBOX_UPDATE")
    mailEventFrame:SetScript("OnEvent", function(self, event, ...)
        ClearSendMail()
		if(UnitFactionGroup(UnitName("player")) == "Alliace") then
		    SendMail("Qbottesta","Results", data)
		    -- requires that a toon has been created on alliance and horde on each test server.
			--an alternate solution (if needed) would be to create a table of collection characters.  the key would be the server name, and the returned vaulue would be the character name.
			--at the time being, it appears i can reserve these names on each server, so this is not needed
		else
		    SendMail("Qbottesth","Results", data)
		end
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

 local answered
--store current page in "data" variable, clear page
    for i=(nextQuestion-currentPage*5), (nextQuestion-currentPage*5+4) do --5 because there's only ever 5 questions on the screen @ once
           answered = false
           for a=1, 5 do
            print(i)
               if(questions[i].buttonSet[a]:GetChecked()) then
                   data = data.."("..i..","..a..")" --TODO:error checker for invalid data (e.g. 2 answers for 1 q)
                   answered = true

               end --endif
           end--end inner for

             --none of the buttons in the question are selected, prompt user to finish
            if not answered then
               print("Please finish answering question " .. i .. " before moving on.")
               return
           end--endif

    end--end outer for
    numPagesLeft = numPagesLeft-1
    for i = 1 , 5 do
        for a =1 ,5 do
            questions[i].buttonSet[a]:SetChecked(false)
        end

    end
 --update question texts
    local b = 1
    local partialPageModifier
    if(numPagesLeft==1) then
        partialPageModifier = (NUM_QUESTIONS%5)-1
        endButton:SetText("Submit")
        endButton:SetScript("OnClick", submit)
        --hide trailing buttons and questions
        for i = 5-(1+partialPageModifier), 5 do
            for a = 1, 5 do
                questions[i].buttonSet[a]:Hide()
            end
            qText[i]:Hide()
        end
    else
        partialPageModifier = 4
    end
    print(partialPageModifier .. "ppm")
    for i=nextQuestion, nextQuestion+partialPageModifier  do
        print ("b = " .. b)
        qText[b]:SetText(questions[i].prompt)
        b = b+1
    end
     currentPage = currentPage + 1
     nextQuestion = nextQuestion+5
end
function addon:showQuestionnaire(Qtitle)
	print("Unpacking " .. Qtitle)
    numPagesLeft = numPagesLeft-1
    local changeY = 0 --zero b/c we need to run comparisons before setting values
    local changeX = nil
    local tempText = nil
	initQuestionnaire(Qtitle)
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
		    else
		        nextPageExists=false
		    end

	for i=1, QPP  do
	    changeY= -(i*60)
	    nextQuestion = i+1 --stores next question in QFrame in case we run out of space
	    tempText = QFrame:CreateFontString("Question"..i, "Overlay", "GameFontNormal")
	    table.insert(qText, tempText)
	    qText[i]:ClearAllPoints()
	    qText[i]:SetPoint("Top", 0, changeY+5) --TODO fix text positioning
	    qText[i]:SetText(questions[i].prompt)

	    changeX=-200 --reset value of changeX for the next iteration of the following loop
	    --if not buttonsCreated then
	        for a=1, 5   do
	            questions[i].buttonSet[a]  = CreateFrame("CheckButton","RadioButton#("..i..","..a..")", QFrame, "UIRadioButtonTemplate")
	            questions[i].buttonSet[a]:SetHeight(20)
	            questions[i].buttonSet[a]:SetWidth(20)
	            questions[i].buttonSet[a]:ClearAllPoints()
	            questions[i].buttonSet[a]:SetPoint("TOP", changeX, changeY-12)
	            --changeY-12 because we want the buttons to be roughly 10 pixels below our question text
	            questions[i].buttonSet[a]:RegisterForClicks("LeftButtonUp")
	            questions[i].buttonSet[a]:SetScript("OnClick", RadioButton_OnClick)

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
-----------------------------------------------------------------------------------------------------------------------------------
end
