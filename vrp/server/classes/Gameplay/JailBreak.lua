-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/JailBreak.lua
-- *  PURPOSE:     Jailbreak class
-- *
-- ****************************************************************************
JailBreak = inherit(Singleton)
addEvent("keypadClick", true)
addEvent("jailAnswersRetrieve", true)
local TIME_BETWEEN_JAILBREAKS = 30*60*1000

function JailBreak:constructor()
	self.m_LastJailBreakTime = 0
	self.m_OpenCellsKeypad = getElementByID("object (sec_keypad) (1)") -- TODO: Replace name by a proper name
	self.m_ShutterDoor = getElementByID("ShutterDoor")
	self.m_BombArea = BombArea:new(Vector3(3459.85, -2073.16, 16.82), function(area, player) player:triggerEvent("bankRobberyCountdown", 10) end, bind(self.Bomb_Explode, self), 10000)

	self.m_GuardPed = getElementByID("JailGuardPed")
	addEventHandler("onPedWasted", self.m_GuardPed, bind(self.GuardPed_Wasted, self))

	self.m_ControlPed = getElementByID("JailControlPed")
	addEventHandler("onPedWasted", self.m_ControlPed, bind(self.ControlPed_Wasted, self))

	self.m_MainGateLeft = getElementByID("MainGateLeft")
	self.m_MainGateRight = getElementByID("MainGateRight")
	self.m_MainGateState = true

	self.m_CellGates = {}
	for i = 1, 4 do
		self.m_CellGates[i] = getElementByID("CellGate"..i)
	end

	addEventHandler("keypadClick", root, bind(self.Keypad_Click, self))
	addEventHandler("jailAnswersRetrieve", root, bind(self.KeypadAnswers_Retrieve, self))
end

function JailBreak:toggleMainGate(state) -- true: closed; false: open
	self.m_MainGateState = state

	if state then
		self.m_MainGateLeft:move(1500, 3444.2002, -2150, 17.8)
		self.m_MainGateRight:move(1500, 3449.6006, -2150, 17.8)
	else
		self.m_MainGateLeft:move(1500, 3437.6, -2150, 17.8)
		self.m_MainGateRight:move(1500, 3455.9, -2150, 17.8)
	end
end

function JailBreak:toggleCellGate(i, state)
	if state then
		self.m_CellGates[i]:move(1500, self.m_CellGates[i]:getPosition() - Vector3(2, 0, 0))
	else
		self.m_CellGates[i]:move(1500, self.m_CellGates[i]:getPosition() + Vector3(2, 0, 0))
	end
end

function JailBreak:toggleCellGates(state)
	for i in pairs(self.m_CellGates) do
		self:toggleCellGate(i, state)
	end
end

function JailBreak:getRandomQuestion()
	return JailBreak.Questions[Randomizer:get(1, #JailBreak.Questions)]
end

function JailBreak:getQuestionSet(numQuestions)
	return Randomizer:getRandomOf(numQuestions, JailBreak.Questions)
end

function JailBreak:checkAnswers(answers)
	local wrongQuestionCount = 0
	for questionId, answer in pairs(answers) do
		if not JailBreak.Questions[questionId] then
			return false
		end
		if JailBreak.Questions[questionId][3] ~= answer then
			wrongQuestionCount = wrongQuestionCount + 1
		end
	end
	return wrongQuestionCount <= 1
end

function JailBreak:GuardPed_Wasted(totalAmmo, killer)
	if killer and killer:getKarma() < 0 then
		self:toggleMainGate(false)
	end
end

function JailBreak:ControlPed_Wasted(totalAmmo, killer)

end

function JailBreak:Bomb_Explode()
	self.m_ShutterDoor:move(500, self.m_ShutterDoor:getPosition() + Vector3(0, 0, 6))
end

function JailBreak:Keypad_Click()
	if source == self.m_OpenCellsKeypad and self.m_LastJailBreakTime + TIME_BETWEEN_JAILBREAKS > getTickCount() then
		client:sendError(_("Du kannst den Gefängnisausbruch zurzeit nicht starten", client))
		return
	end

	if source == self.m_OpenCellsKeypad then
		local questions = self:getQuestionSet(5)
		client:triggerEvent("jailQuestionsRetrieve", 1, questions)
	end
end

function JailBreak:KeypadAnswers_Retrieve(answers, gateId)
	if self:checkAnswers(answers) then
		if gateId == 1 then
			-- Open all cells
			self:toggleCellGates(false)
		end
		client:sendSuccess("ACCESS GRANTED")
	else
		client:sendError(_("ACCESS DENIED. Zu viele falsche Fragen!", client))
	end
end


-- TODO: the first field is not necessary
JailBreak.Questions = {
	{1, "Wer ist Alex_Stone?", "Alex_Stone", "Johnny_Walker", "Gibaex", "thefleshpound"},
	{2, "Nenne den Satz des Pythagoras! (c: Hypotenuse)", "c² = a² + b²", "a² = b² + c²", "c² = a² - b²", "b² = c² + b²"},
	{3, "Was ist am besten?", "MTA", "Company of Heroes", "DayZ", "Call of Duty: Modern Warface 3"},
	{4, "Welche der folgenden Programmiersprachen ist keine Programmiersprache?", "HTML", "C++", "C#", "Java"},
	{5, "Welchen Zweck hat das IRC-Protokoll?", "Chat", "Routing", "Dateiübertragungen", "Media-Streaming"},
}
