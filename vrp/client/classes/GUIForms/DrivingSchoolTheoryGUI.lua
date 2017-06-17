-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolTheoryGUI.lua
-- *  PURPOSE:     DrivingSchoolTheoryGUI
-- *
-- ****************************************************************************
DrivingSchoolTheoryGUI = inherit(GUIForm)
inherit(Singleton, DrivingSchoolTheoryGUI)

addRemoteEvents{"showDrivingSchoolTest","addDrivingSchoolSpeechBubble"}

--// CONSTANTS //
local width,height = screenWidth*0.4,screenHeight*0.4
local TEXT_INFO = "Prüfungsablauf:\nWillkommen zur theoretischen Fahrprüfung für die Führerscheinklasse B. Es werden 10 Fragen folgen, welche mit einer maximal Fehlerpunktzahl von 10 beantwortet werden müssen. Das Ergebnis wird sofort danach angezeigt."
local QUESTIONS =
{
	{"Wie schnell darf hier auf eXo-Reallife in Los Santos gefahren werden?","30 km/H","50 km/H","80 km/H","120 km/H",3,3},
	{"Wann darf rechts überholt werden?","Auf einer Autobahn","Innerorts auf einer Mehrspurigen Straße","Überall","Außerorts",3,2},
	{"In welchem Zustand dürfen Sie fahren?","alkoholisiert","Nüchtern","auf Drogen",nil, 3,2},
	{"Was gilt an einer Kreuzung ohne Beschilderung oder Ampel?","Wer zuerst kommt fährt","Wer am schnellsten ankommt fährt","Rechts vor Links","Wer hupt fährt zuerst",5,3},
	{"Wo darf auf eXo-Reallife geparkt werden?","Auf der Straße","Vor Gebäude-Eingängen","Es gibt keine Regelung","auf Parkplätzen",4,4},
	{"Auf welche Verkehrsteilnehmer muss besonders geachtet werden?","LKW-Fahrer","PKW-Fahrer","Passanten",nil,5,3},
	{"Was müssen Sie bei schlechten Lichtverhältnissen beachten?","Ausreichend Frühstücken","Ausreichende Beleuchtung am Fahrzeug","Laute Musik um wach zu bleiben","Schnell fahren",3,2},
	{"Wie dürfen Sie Pesonen mit Ihrem Fahrzeug NICHT befördern?", "Auf dem Dach oder Motorhaube", "Auf Sitzplätzen im Fahrzeug", nil,nil,5,1},
	{"Was gilt bei gefährlichen Kreuzungen?","schnell durchfahren","langsam und vorsichtig durchfahren","durchgehend hupen","keine Kreuzungen befahren",4,2},
	{"Was ist in der StVO verboten?","rechts abbiegen","gemütlich fahren","hupen","Burn-outs (Räder durchdrehen)",4,4},
	{"Was machen Sie bei einem Unfall?", "Ich bleibe stehen und kläre den Sachverhalt", "Ich fahre einfach weiter", "Ich beschimpfe den Unfallgegner",nil,4,1},
	{"Was machen Sie wenn ein Streifenwagen Sie auffordert anzuhalten?","langsam weiter fahren","schneller Fahren","rechts anhalten","ignorieren",4,3},
	{"Wie verhalten Sie sich bei einer Verkehrskontrolle?","höflich gegenüber dem Beamten","mit wüsten Beschimpfungen","Waffengebrauch","Ich laufe weg",4,1},
	{"Was machen Sie wenn ein Beamter Sie auffordert Ihren Führerschein zu zeigen?","Ich lehne ab","Ich zeige ihm den Führerschein",nil,nil,4,2},
}

function DrivingSchoolTheoryGUI:constructor(type )
	GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2 - height/2, width,height, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Theoretische Prüfung"), true, true, self)
	self.m_Window:toggleMoving(false)
	self.m_Window:deleteOnClose(true)
	self.m_Text = GUILabel:new( self.m_Width*0.05, self.m_Height*0.2, self.m_Width*0.9,self.m_Height, TEXT_INFO, self):setFont(VRPFont(24))
	self.m_Text:setAlignX( "left" )
	self.m_Text:setAlignY( "top" )
	self.m_StartButton = GUIButton:new( self.m_Width*0.3, self.m_Height*0.7 , self.m_Width*0.4,self.m_Height*0.1, "Starten", self)
	self.m_StartButton.onLeftClick = function()

		self.m_Text:delete(); self.m_StartButton:delete(); self:nextQuestion();
	end
	self.m_QuestionsDone = {	}
	self.m_QuestionCounter = 0
	self.m_ErrPoints = 0

end

function DrivingSchoolTheoryGUI:destructor()
	GUIForm.destructor(self)
	if not self.m_Success then
		triggerServerEvent("drivingSchoolPassTheory",localPlayer, false)
	end
end

function DrivingSchoolTheoryGUI:submitQuestion( pQuestion )
	self.m_QuestionsDone[pQuestion] = true
	local iAnswer = QUESTIONS[pQuestion][7]
	local iChecked
	for i = 1,4 do
		if self.m_QuestionButtons[i]:isChecked() then
			iChecked = i
			break
		end
	end
	if iAnswer ~= iChecked then
		self.m_ErrPoints = self.m_ErrPoints + QUESTIONS[pQuestion][6]
	end
	if self.m_QuestionCounter < 10 then
		self:nextQuestion()
	else
		self:showResult()
	end
end

function DrivingSchoolTheoryGUI:nextQuestion()
	if not self.m_SubmitButton then
		self.m_SubmitButton = GUIButton:new( self.m_Width*0.3, self.m_Height*0.9 , self.m_Width*0.4,self.m_Height*0.08, "Weiter", self)
	end
	if self.m_QuestionText then
		self.m_QuestionText:delete()
		self.m_QuestionPoints:delete()
		self.m_RBGroup:delete()
	end
	local randomInt = math.random( 1,#QUESTIONS )
	if not self.m_QuestionsDone[randomInt] then
		self.m_QuestionButtons = {	}
		self.m_QuestionCounter = self.m_QuestionCounter + 1
		local question = QUESTIONS[randomInt][1]
		self.m_QuestionPoints = GUILabel:new( self.m_Width*0.025, self.m_Height*0.15, self.m_Width*0.9,self.m_Height, QUESTIONS[randomInt][6].." Punkte" ,self.m_Window):setFont(VRPFont(22))
		self.m_QuestionPoints:setAlignX( "left" )
		self.m_QuestionPoints:setAlignY( "top" )
		self.m_QuestionText = GUILabel:new( self.m_Width*0.05, self.m_Height*0.2, self.m_Width*0.9,self.m_Height, self.m_QuestionCounter..". "..question ,self.m_Window):setFont(VRPFont(28))
		self.m_QuestionText:setAlignX( "center" )
		self.m_QuestionText:setAlignY( "top" )
		self.m_RBGroup = GUIRadioButtonGroup:new(self.m_Width*0.1, self.m_Height*0.4, self.m_Width*0.09, self.m_Height*0.4 ,self)
		for i =1,4 do
			if QUESTIONS[randomInt][1+i] then
				self.m_QuestionButtons[i] = GUIRadioButton:new(0, self.m_Height*0.11*(i-1), self.m_Width*0.9,  self.m_Height*0.1,QUESTIONS[randomInt][1+i]  , self.m_RBGroup)
			end
		end
		self.m_SubmitButton.onLeftClick = function() self:submitQuestion( randomInt ) end
	else return self:nextQuestion()
	end
end

function DrivingSchoolTheoryGUI:showResult()
	if self.m_SubmitButton then
		self.m_SubmitButton:delete()
	end
	if self.m_QuestionText then
		self.m_QuestionText:delete()
		self.m_RBGroup:delete()
	end
	if self.m_ErrPoints <= 10 then
		self.m_ResultText = GUILabel:new( self.m_Width*0.05, self.m_Height*0, self.m_Width*0.9,self.m_Height,"Glückwunsch, Bestanden! Fehlerpunkte:".." "..self.m_ErrPoints,self):setFont(VRPFont(30))
		self.m_ResultText:setAlignX( "center" )
		self.m_ResultText:setAlignY( "center" )
		self.m_ResultText:setColor(Color.Green)
		triggerServerEvent("drivingSchoolPassTheory",localPlayer, true)
		self.m_Success = true
	else
		self.m_ResultText = GUILabel:new( self.m_Width*0.05, self.m_Height*0, self.m_Width*0.9,self.m_Height,"Sie sind durchgefallen! Fehlerpunkte:".." "..self.m_ErrPoints,self ):setFont(VRPFont(30))
		self.m_ResultText:setAlignX( "center" )
		self.m_ResultText:setAlignY( "center" )
		self.m_ResultText:setColor(Color.Red)
		triggerServerEvent("drivingSchoolPassTheory",localPlayer, false)
	end
end


addEventHandler("showDrivingSchoolTest", localPlayer,
	function(type )
		DrivingSchoolTheoryGUI:new(type, ped)
	end
)

addEventHandler("hideDrivingSchoolTheoryGUI", localPlayer,
	function()
		DrivingSchoolTheoryGUI:getSingleton():delete()
	end
)

addEventHandler("addDrivingSchoolSpeechBubble", localPlayer,
	function( ped )
		local name = _"Fahrschule Theorietest"
		local description = _"Für mehr Infos klicke mich an!"
		ped.SpeakBubble = SpeakBubble3D:new(ped, name, description, -90)
	end
)
