-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolTheoryGUI.lua
-- *  PURPOSE:     DrivingSchoolTheoryGUI
-- *
-- ****************************************************************************
DrivingSchoolTheoryGUI = inherit(GUIForm)
inherit(Singleton, DrivingSchoolTheoryGUI)

addRemoteEvents{ "showDrivingSchoolTest" }

--// CONSTANTS //
local width,height = screenWidth*0.4,screenHeight*0.4
local TEXT_INFO = "Prüfungsablauf:\nWillkommen zur theoretischen Fahrprüfung für die Führerscheinklasse B. Es werden 10 Fragen folgen, welche mit einer maximal Fehlerpunktzahl von 10 beantwortet werden müssen. Das Ergebnis wird sofort danach angezeigt."
local QUESTIONS =
{
	{"Wie schnell darf innerorts normalerweise auf einer Vorfahrtstraße gefahren werden?","30","60","120","50",3,4},
	{"Wann darf rechts überholt werden?","Auf einer Autobahn","Innerorts auf einer Mehrspurigen Straße","Überall","Außerorts",3,2},
	{"Ab welchen Promille-Wert für Alkohol müssen Sie mit Strafen rechnen ( mit Probezeit )?","0.3","0.5","0.9","1.2",3,1},
	{"Was gilt an einer Kreuzung ohne Beschilderung oder Ampel?","Wer zuerst kommt fährt","Wer am schnellsten ankommt fährt","Rechts vor Links","Wer hupt fährt zuerst",5,3},
	{"Was gilt auf Parkplätzen?","Mittig fahren um sichtbar zu sein","Rechtsfahrgebot","Es gibt keine Regelung","Linksfahrgebot",4,2},
	{"Auf welche Verkehrsteilnehmer muss besonders geachtet werden?","LKW-Fahrer","PKW-Fahrer","Passanten",nil,5,3},
	{"Was müssen Sie bei schlechten Lichtverhältnissen beachten?","Ausreichend Frühstücken","Ausreichende Beleuchtung am Fahrzeug","Laute Musik um wach zu bleiben","Schnell fahren",3,2},
	{"Warum sollten Sie nicht zu langsam fahren?", "Um Auffahrunfälle zu vermeiden", "Um Sprit zu sparen", nil,nil,5,1},
	{"Was gilt bei einem Stopp-Schild?","an der Sichtlinie halten","Durchfahren sofern keiner Sie behindert","An der Haltelinie komplett anhalten","Nicht an der Haltelinie halten wenn die Straße frei ist",4,3},
	{"Wozu dienen Blinker?","Zur Beleuchtung des Fahrzeuges","Als Indikatoren der Fahrtrichtung","Als Sirene",nil,4,2},
	{"Wo dürfen Sie parken?", "Auf Kraftfahrstraßen", "Außerorts auf der rechten Seite", "An gekennzeichneten Stellen",nil,4,3},
	{"Wie viel Abstand müssen Sie beim Parken vor einem Stoppschild einhalten?","5 m","10 m","15 m","20 m",4,2},
	{"Wie viel Abstand müssen Sie beim Parken vor einem Zebrastreifen einhalten?","5 m","10 m","15 m","20 m",4,1},
	{"Wie viel Abstand müssen Sie beim Parken vor einer Haltestelle einhalten?","5 m","10 m","15 m","20 m",4,3},
}

function DrivingSchoolTheoryGUI:constructor(type)
	GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2 - height/2, width,height, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Theoretische Prüfung"), true, true, self)
	self.m_Window:setCloseOnClose(true)
	self.m_Text = GUILabel:new( self.m_Width*0.05, self.m_Height*0.2, self.m_Width*0.9,self.m_Height, TEXT_INFO, self):setFont(VRPFont(24))
	self.m_Text:setAlignX( "left" )
	self.m_Text:setAlignY( "top" )
	self.m_StartButton = GUIButton:new( self.m_Width*0.3, self.m_Height*0.7 , self.m_Width*0.4,self.m_Height*0.1, "Starten", self)
	self.m_StartButton.onLeftClick = function() self.m_Text:delete(); self.m_StartButton:delete(); self:nextQuestion(); end
	self.m_QuestionsDone = {	}
	self.m_QuestionCounter = 0
	self.m_ErrPoints = 0
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
		self.m_QuestionPoints = GUILabel:new( self.m_Width*0.025, self.m_Height*0.15, self.m_Width*0.9,self.m_Height, QUESTIONS[randomInt][6].." Punkte" ,self):setFont(VRPFont(22))
		self.m_QuestionPoints:setAlignX( "left" )
		self.m_QuestionPoints:setAlignY( "top" )
		self.m_QuestionText = GUILabel:new( self.m_Width*0.05, self.m_Height*0.2, self.m_Width*0.9,self.m_Height, self.m_QuestionCounter..". "..question ,self):setFont(VRPFont(28))
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
		triggerServerEvent("drivingSchoolPassTheory",localPlayer)
	else
		self.m_ResultText = GUILabel:new( self.m_Width*0.05, self.m_Height*0, self.m_Width*0.9,self.m_Height,"Sie sind durchgefallen! Fehlerpunkte:".." "..self.m_ErrPoints,self ):setFont(VRPFont(30))
		self.m_ResultText:setAlignX( "center" )
		self.m_ResultText:setAlignY( "center" )
		self.m_ResultText:setColor(Color.Red)
	end
end


addEventHandler("showDrivingSchoolTest", root,
	function(type)
		DrivingSchoolTheoryGUI:new(type)
	end
)

addEventHandler("hideDrivingSchoolTheoryGUI", root,
	function()
		DrivingSchoolTheoryGUI:getSingleton():delete()
	end
)
