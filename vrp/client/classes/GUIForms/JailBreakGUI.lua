JailBreakGUI = inherit(GUIForm)
inherit(Singleton, JailBreakGUI)
addEvent("jailQuestionsRetrieve", true)

function JailBreakGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3*0.5, screenHeight/2-screenHeight*0.3*0.5, screenWidth*0.3, screenHeight*0.4)--screenHeight*0.3
	self.m_Questions = false
	self.m_CurrentQuestionId = false
	self.m_Answers = {}

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Gefängnistor hacken", true, true, self)
	self.m_QuestionLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.12, self.m_Width*0.9, self.m_Height*0.25, "Wie ist das Wetter heute?", self.m_Window):setFont(VRPFont(self.m_Height*0.07))
	self.m_AnswerGroup = GUIRadioButtonGroup:new(self.m_Width*0.02, self.m_Height*0.35, self.m_Width*0.9, self.m_Height*0.55, self.m_Window)
	self.m_AnswersRadio = {}
	self.m_AnswersRadio[1] = GUIRadioButton:new(0, 0, self.m_Width, self.m_Height*0.07, "", self.m_AnswerGroup)
	self.m_AnswersRadio[2] = GUIRadioButton:new(0, self.m_Height*0.12, self.m_Width, self.m_Height*0.07, "", self.m_AnswerGroup)
	self.m_AnswersRadio[3] = GUIRadioButton:new(0, self.m_Height*0.24, self.m_Width, self.m_Height*0.07, "", self.m_AnswerGroup)
	self.m_AnswersRadio[4] = GUIRadioButton:new(0, self.m_Height*0.36, self.m_Width, self.m_Height*0.07, "", self.m_AnswerGroup)

	self.m_BackButton = GUIButton:new(self.m_Width*0.3, self.m_Height*0.85, self.m_Width*0.3, self.m_Height*0.1, _"Zurück", true, self.m_Window):setBackgroundColor(Color.Red):setBarEnabled(true)
	self.m_NextButton = GUIButton:new(self.m_Width*0.65, self.m_Height*0.85, self.m_Width*0.3, self.m_Height*0.1, _"Weiter", true, self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)

	self.m_BackButton.onLeftClick = function()
		if not self.m_Questions or self.m_CurrentQuestion == 1 then
			return
		end

		-- Save current
		local radio = self.m_AnswerGroup:getCheckedRadioButton()
		if radio then
			local index = table.find(self.m_AnswersRadio, radio)
			if index then
				self.m_Answers[self.m_CurrentQuestionId] = {index = index, text = radio:getText()}
			end
		end

		self.m_CurrentQuestion = self.m_CurrentQuestion - 1
		self:setQuestion(self.m_Questions[self.m_CurrentQuestion])

		-- Get current
		if self.m_Answers[self.m_CurrentQuestionId] then
			self.m_AnswerGroup:setCheckedRadioButton(self.m_AnswersRadio[self.m_Answers[self.m_CurrentQuestionId].index])
		end
	end
	self.m_NextButton.onLeftClick = function()
		if not self.m_Questions then
			return
		end

		-- Save current
		local radio = self.m_AnswerGroup:getCheckedRadioButton()
		if radio then
			local index = table.find(self.m_AnswersRadio, radio)
			if index then
				self.m_Answers[self.m_CurrentQuestionId] = {index = index, text = radio:getText()}
			end
		end

		if #self.m_Questions == self.m_CurrentQuestion then
			local temp = {}
			for k, v in pairs(self.m_Answers) do
				temp[k] = v.text
			end
			triggerServerEvent("jailAnswersRetrieve", root, temp, self.m_CurrentGateId)
			delete(self)
			return
		end

		self.m_CurrentQuestion = self.m_CurrentQuestion + 1
		self:setQuestion(self.m_Questions[self.m_CurrentQuestion])

		-- Get current
		if self.m_Answers[self.m_CurrentQuestionId] then
			self.m_AnswerGroup:setCheckedRadioButton(self.m_AnswersRadio[self.m_Answers[self.m_CurrentQuestionId].index])
		end
	end
end

function JailBreakGUI:setQuestions(questions, gateId)
	self.m_Questions = questions
	self.m_CurrentQuestion = 1
	self.m_CurrentGateId = gateId
	self:setQuestion(self.m_Questions[1])
	self.m_Answers = {}
end

function JailBreakGUI:setQuestion(questionInfo)
	local question, answer1, answer2, answer3, answer4, questionId = unpack(questionInfo)
	self.m_QuestionLabel:setText(question)

	-- Todo: Move this to the server
	local order = Randomizer:getRandomOf(4, {answer1, answer2, answer3, answer4})
	self.m_AnswersRadio[1]:setText(order[1])
	self.m_AnswersRadio[2]:setText(order[2])
	self.m_AnswersRadio[3]:setText(order[3])
	self.m_AnswersRadio[4]:setText(order[4])
	self.m_CurrentQuestionId = questionId
end

addEventHandler("jailQuestionsRetrieve", root,
	function(gate, questions)
		local self = JailBreakGUI:getSingleton()
		self:setQuestions(questions, gate)
	end
)
