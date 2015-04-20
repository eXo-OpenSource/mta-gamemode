-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/JailBreak.lua
-- *  PURPOSE:     Jailbreak class
-- *
-- ****************************************************************************
JailBreak = inherit(Singleton)
addEvent("keypadClick", true)
addEvent("jailAnswersRetrieve", true)
local TIME_BETWEEN_JAILBREAKS = 1*60*60*1000
local JAIL_PIPES_DIMENSION = 5

function JailBreak:constructor()
	self.m_CanBeStarted = true
	self.m_OpenCellsKeypad = getElementByID("OpenCellKeypad")
	self.m_CellRoomDoor = getElementByID("CellRoomDoor")
	self.m_BombArea = BombArea:new(Vector3(3459.85, -2073.16, 16.82), bind(self.Bomb_Place, self), bind(self.Bomb_Explode, self), 10000)

	self:respawnGuardPed()

	self.m_ControlPed = getElementByID("JailControlPed")
	addEventHandler("onPedWasted", self.m_ControlPed, bind(self.ControlPed_Wasted, self))

	self.m_MainGateLeft = getElementByID("MainGateLeft")
	self.m_MainGateRight = getElementByID("MainGateRight")
	self.m_MainGateState = true

	self.m_CellGates = {}
	for i = 1, 6 do
		self.m_CellGates[i] = getElementByID("CellGate"..i)
	end
	self.m_BreakFreeDoor = getElementByID("BreakFreeDoor")
	self.m_HallDoorLeft = getElementByID("HallDoorLeft")
	self.m_HallDoorRight = getElementByID("HallDoorRight")

	addEventHandler("keypadClick", root, bind(self.Keypad_Click, self))
	addEventHandler("jailAnswersRetrieve", root, bind(self.KeypadAnswers_Retrieve, self))

	self.m_PipeOutShape = createColSphere(3490.72, -2093.12, 16.87, 3)
	addEventHandler("onColShapeHit", self.m_PipeOutShape, bind(self.PipeOutShape_Hit, self))
	self.m_PipeExit1Shape = createColSphere(3039.1006, -2069.7002, 1216.2, 3)
	self.m_PipeExit2Shape = createColSphere(3073.9004, -2226.3994, 1208.2, 3)
	self.m_PipeExit1Shape:setDimension(5)
	self.m_PipeExit2Shape:setDimension(5)
	addEventHandler("onColShapeHit", self.m_PipeExit1Shape, bind(self.PipeExitShape_Hit, self))
	addEventHandler("onColShapeHit", self.m_PipeExit2Shape, bind(self.PipeExitShape_Hit, self))
	self.m_PipeExitTrollShape = createColSphere(3010.5, -2126.0996, 1, 3)
	self.m_PipeExitTrollShape:setDimension(5)
	addEventHandler("onColShapeHit", self.m_PipeExitTrollShape, bind(self.PipeExitTrollShape_Hit, self))

	-- Exit doors
	createObject(3109, 311.79999, -1520.9, 25.1, 0, 0, 324)
    createObject(3109, 2701.6001, -1111.3, 69.8, 0, 0, 0)

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

	if state then
		self.m_BreakFreeDoor:move(1500, self.m_BreakFreeDoor:getPosition() + Vector3(0, 0, 5))
		self.m_HallDoorLeft:move(1500, self.m_HallDoorLeft:getPosition() + Vector3(2, 0, 0))
		self.m_HallDoorRight:move(1500, self.m_HallDoorLeft:getPosition() - Vector3(2, 0, 0))
	else
		self.m_BreakFreeDoor:move(1500, self.m_BreakFreeDoor:getPosition() - Vector3(0, 0, 5))
		self.m_HallDoorLeft:move(1500, self.m_HallDoorLeft:getPosition() - Vector3(2, 0, 0))
		self.m_HallDoorRight:move(1500, self.m_HallDoorLeft:getPosition() + Vector3(2, 0, 0))
	end
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
		if JailBreak.Questions[questionId][2] ~= answer then
			wrongQuestionCount = wrongQuestionCount + 1
		end
	end
	return wrongQuestionCount <= 1
end

function JailBreak:respawnGuardPed()
	if self.m_GuardPed then
		self.m_GuardPed:destroy()
	end
	self.m_GuardPed = GuardActor:new(3453.9004, -2153.8994, 17.1, 180)
	addEventHandler("onPedWasted", self.m_GuardPed, bind(self.GuardPed_Wasted, self))
end

function JailBreak:reset()
	self:respawnGuardPed()
	self:toggleCellGates(true)

	self.m_CellRoomDoor:move(500, self.m_CellRoomDoor:getPosition() + Vector3(0, 0, 6))
	self.m_CanBeStarted = true
end

function JailBreak:GuardPed_Wasted(totalAmmo, killer)
	if killer and killer:getKarma() < 0 then
		-- Prevent new jail breaks for the specified time
		self.m_CanBeStarted = false

		-- Open main gate
		self:toggleMainGate(false)

		-- Report the kill crime, but do not report jailbreak yet
		killer:reportCrime(Crime.Kill)

		setTimer(
			function()
				-- Report jailbreak after a short delay
				for k, player in pairs(getPlayersInRange(self.m_GuardPed:getPosition(), 100)) do
					if player:getKarma() < 0 then
						player:reportCrime(Crime.JailBreak)
						player:sendShortMessage(_("ACHTUNG! Ihr wurdet entdeckt!", player))
					end
				end

				-- Report special crime
				JobPolice:getSingleton():reportSpecialCrime(Crime.JailBreak, "Unbekannte sind in das Gefängnis eingebrochen und dabei Gefangene zu befreien") -- TODO: Mark up for translation

				-- Tell all clients that we started jailbreak (this also invokes the siren)
				triggerClientEvent("jailBreakStart", resourceRoot)

				-- Close main gate | TODO: How does the police enter the interior? ==> Clicksystem
				self:toggleMainGate(true)

			end, 60*1000, 1
		)

		-- Reset everything after 1h, jailbreak can now be started again
		setTimer(bind(self.reset, self), TIME_BETWEEN_JAILBREAKS, 1)
	else
		-- Respawn immediately
		self:respawnGuardPed()
	end
end

function JailBreak:ControlPed_Wasted(totalAmmo, killer)

end

function JailBreak:Bomb_Place(bombArea, player)
	player:triggerEvent("bankRobberyCountdown", 10)
end

function JailBreak:Bomb_Explode()
	self.m_CellRoomDoor:move(500, self.m_CellRoomDoor:getPosition() - Vector3(0, 0, 6))
end

function JailBreak:Keypad_Click()
	if source == self.m_OpenCellsKeypad and self.m_CanBeStarted then -- CanBeStarted is false when the jailbreak has started recently
		client:sendError(_("Du kannst den Gefängnisausbruch zurzeit nicht starten", client))
		return
	end

	if source == self.m_OpenCellsKeypad then
		local questions = self:getQuestionSet(5)
		client:triggerEvent("jailQuestionsRetrieve", 1, questions)
	end
end

function JailBreak:KeypadAnswers_Retrieve(answers, gateId)
	if self:checkAnswers(answers) and not self.m_CanBeStarted then
		if gateId == 1 then
			-- Open all cells
			self:toggleCellGates(false)
		end
		client:sendSuccess("ACCESS GRANTED")
	else
		client:sendError(_("ACCESS DENIED. Zu viele falsche Fragen!", client))
	end
end

function JailBreak:PipeOutShape_Hit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		hitElement:setPosition(2971.4004, -2132, 1211.4)
		hitElement:setDimension(5)
	end
end

function JailBreak:PipeExitShape_Hit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		hitElement:setDimension(0)

		local positions = {
			{1489, -1720.8, 8.2, 166},
			{1412.7, -1305, 9.5, 185},
			{2699.8999, -1110.6, 69.6, 90},
			{311.89999, -1520.1, 24.9, 0},
			{2263.5, -755.5, 38, 116},
			{1271.5, 295.29999, 20.7, 0}
		}
		local x, y, z, rot = unpack(Randomizer:getRandomTableValue(positions))
		hitElement:setPosition(x, y, z)
		hitElement:setRotation(0, 0, rot)
	end
end

function JailBreak:PipeExitTrollShape_Hit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		hitElement:setDimension(0)
		hitElement:setPosition(2868.82, -2125.05, 5.30)
		hitElement:setRotation(0, 0, 270)
	end
end


JailBreak.Questions = {
	{"Nenne den Satz des Pythagoras! (c: Hypotenuse)", "c² = a² + b²", "a² = b² + c²", "c² = a² - b²", "b² = c² + b²"},
	{"Welche der folgenden Sprachen ist keine Programmiersprache?", "HTML", "C++", "C#", "Java"},
	{"Welchen Zweck hat das IRC-Protokoll?", "Chat", "Routing", "Dateiübertragungen", "Media-Streaming"},
	{"Wofür steht CPU?", "Central Processing Unit", "Cheese Proccess Undertakings", "Central Programming Unit", "Central Progress Unit"},
	{"Wofür steht RAM?", "Random Access Memory", "Röchelhusten am Mittelbauch", "Right Access Memory", "Rare Access Memory"},
	{"Wer gilt als Entwickler von C++?", "Bjarne Stroustrup", "Dennis Ritchie", "Linus Torvalds", "Bill Gates"},
	{"Wer gilt als Gründer von Microsoft?", "Bill Gates", "Linus Torvalds", "Steve Jobs", "Dennis Ritchie"},
	{"Wie hoch ist die Lichtgeschwindigkeit?",  "299 792.458 m/s", "299.792458 m/s", "2 997 924.58 m/s", "29 792.458 m/s"},
}
-- Add unique IDs
for index in ipairs(JailBreak.Questions) do
	JailBreak.Questions[index][6] = index
end
