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

function JailBreak:constructor()
	self.m_MainGate = getElementByID("jail_maingate")
	self.m_IntGateRight = getElementByID("jail_intgate_right")
	self.m_IntGateLeft = getElementByID("jail_intgate_left")
	self.m_CellGates = {} -- Todo
	self.m_MainGateState, self.m_InteriorGateState = true, true
	
	self.m_MainGateKeypad = createObject(2886, 77.7, -234.5, 2.5, 0, 0, 180)
	self.m_IntGateKeypad = createObject(2886, 98.3, -262.6, 6.2, 0, 0, 180)
	
	addEventHandler("keypadClick", root,
		function()
			if source == self.m_MainGateKeypad then
				local questions = self:getQuestionSet(5)
				client:triggerEvent("jailQuestionsRetrieve", 1, questions)
			elseif source == self.m_IntGateKeypad then
				local questions = self:getQuestionSet(5)
				client:triggerEvent("jailQuestionsRetrieve", 2, questions)
			end
		end
	)
	addEventHandler("jailAnswersRetrieve", root,
		function(answers, gateId)
			if self:checkAnswers(answers) then
				if gateId == 1 then
					if self.m_MainGateState then
						self:toggleMainGate(false)
						setTimer(function() self:toggleMainGate(true) end, 60000, 1)
					end
				elseif gateId == 2 then
					if self.m_InteriorGateState then
						self:toggleInteriorGate(false)
						setTimer(function() self:toggleInteriorGate(true) end, 60000, 1)
					end
				end
				client:sendSuccess("ACCESS GRANTED")
			else
				client:sendError(_("ACCESS DENIED. Zu viele falsche Fragen!", client))
			end
		end
	)
end

function JailBreak:toggleMainGate(state) -- true: closed; false: open
	self.m_MainGateState = state
	
	if state then
		moveObject(self.m_MainGate, 1000, 76.7, -234.5, 0.6)
	else
		moveObject(self.m_MainGate, 1000, 69.5, -234.5, 0.6)
	end
end

function JailBreak:toggleInteriorGate(state)
	self.m_InteriorGateState = state
	
	if state then
		moveObject(self.m_IntGateLeft, 1000, 98.1, -262.7, 7.5)
		moveObject(self.m_IntGateRight, 1000, 96.4, -262.76, 7.5)
	else
		moveObject(self.m_IntGateLeft, 1000, 99.6, -262.7, 7.5)
		moveObject(self.m_IntGateRight, 1000, 95, -262.8, 7.5)
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

-- Todo: the first field is not necessary
JailBreak.Questions = {
	--[[{1, "Wer ist der Großmeister?", "Jusonex", "Doneasty", "LarSoWiTsH", "Alex_Stone"},
	{2, "Wer ist Alex_Stone?", "Alex_Stone", "Johnny_Walker", "Gibaex", "thefleshpound"},
	{3, "Nenne den Satz des Pythagoras! (c: Hypotenuse)", "c² = a² + b²", "a² = b² + c²", "c² = a² - b²", "b² = c² + b²"},
	{4, "Wie ist das Wetter heute?", "Regnerisch", "Sonnig", "Gewitter", "Klarer Himmel"},
	{5, "Was ist am besten?", "MTA", "Company of Heroes", "DayZ", "Call of Duty: Modern Warface 3"}]]
	{1, "Berechne den elektrischen Widerstand R aus U = 34V, I = 500mA!", "68Ω", "17Ω", "34mΩ", "68MΩ"},
	{2, "Nenne den Satz des Pythagoras! (c: Hypotenuse)", "c² = a² + b²", "a² = b² + c²", "c² = a² - b²", "b² = c² + b²"},
	{3, "Was gibt die Kategorie eines Ethernetkabels an (Beispiel: Cat. 7)", "Die höchstmögliche Frequenz", "Die höchstmögliche Bandbreite", "Den Biegeradius", "Den Steckertyp"},
	{4, "Wie viele nutzbare IP Adressen sind im Subnetz der IP 192.168.1.16 und Netzmaske 255.255.255.240?", "14", "16", "240", "1"},
	{5, "Gegeben ist ein SFUTP Kabel. Wofür steht das U?", "Keine Adernschirmung", "Keine Gesamtschirmung", "Folienschirmung um die Adernschirmung", "Gesamtschirmung übernimmt ein Geflecht"},
	{6, "Welches Protokoll befindet sich auf dem Application Layer des TCP/IP Models?", "FTP", "IP", "ICMP", "ARP"},
	{7, "Was trifft auf TCP zu?", "TCP ist ein verbindungsorientiertes Protokoll", "TCP ist ein verbindungsloses Protokoll", "Die PDU von TCP wird Datagramm genannt", "TCP prüft nicht auf fehlende Segmente"},
	{8, "Welcher Algorithmus liegt dem Routingprotokoll OSPF zugrunde?", "Shortest Path First", "Satz des Pythagoras", "Advanced Encryption Standard", "Routing Information Protocol"},
	{9, "Welche der folgenden Programmiersprachen ist keine Programmiersprache?", "HTML", "C++", "C#", "Java"},
	{10, "Welche Beziehung sollte in der objektorientierten Programmierung zwischen Klasse und Basisklasse vorliegen?", "Ist-ein Beziehung", "Hat-ein Beziehung", "Ehe", "War-ein Beziehung"},
	{11, "Welchen Zweck hat das IRC-Protokoll?", "Chat", "Routing", "Dateiübertragungen", "Media-Streaming"},
}
