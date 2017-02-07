HorseRace = inherit(Singleton)

addRemoteEvents{"startPferdeRennenClient", "stopPferdeRennenClient", "getPferdePositionen", "startProgTimerPferdeRennenClient", "stopProgTimerPferdeRennenClient"}

function HorseRace:constructor()
	self.m_Left = screenWidth/2-646/2
	self.m_Top = screenHeight/2-338/2

	self.m_RightText = ""
	self.m_Speed = 0.4
	self.m_ProgressSended = false

	self.m_CountdownBind = bind(self.startCountdown, self)
	self.m_renderRaceBind = bind(self.renderRace, self)
	self.m_renderProgressBind = bind(self.renderProgress, self)

	self:resetHorses()

	addEventHandler("startPferdeRennenClient", root, bind(self.startRace, self))
	addEventHandler("stopPferdeRennenClient", root, bind(self.stopRace, self))
	addEventHandler("getPferdePositionen", root, bind(self.receivePositions, self))
	addEventHandler("startProgTimerPferdeRennenClient", root, bind(self.startProgress, self))
	addEventHandler("stopProgTimerPferdeRennenClient", root, bind(self.stopProgress, self))

end

function HorseRace:startRace()
	self:resetHorses()
	addEventHandler("onClientRender", root, self.m_renderRaceBind)
end

function HorseRace:stopRace()
	outputChatBox("Die Live-Übertragung wird in 5 Sekunden beendet!",255,0,0)

	setTimer(function()
		removeEventHandler("onClientRender", root, self.m_renderRaceBind)
	end, 5000, 1)
end

function HorseRace:resetHorses()
	self.m_Horses = {
		[1] = {["Pos"] = 0, ["Finish"] = 0},
		[2] = {["Pos"] = 0, ["Finish"] = 0},
		[3] = {["Pos"] = 0, ["Finish"] = 0},
		[4] = {["Pos"] = 0, ["Finish"] = 0},
	}
end

function HorseRace:startCountdown()
	self.m_RightText = "Countdown: "..self.m_Countdown..""

	self.m_Countdown = self.m_Countdown - 1

	if self.m_Countdown == 0 then

		self.m_RightText = "Rennen läuft!"
		r_sCount = getTickCount()
		r_eCount = r_sCount + 60000
		self.m_MoveX = 0
		self.m_Progress = 0


		addEventHandler("onClientRender", root, self.m_renderProgressBind)
	end
end

function HorseRace:receivePositions(horse1, horse2, horse3, horse4)
	self.m_Horses[1]["Finish"] = horse1
	self.m_Horses[2]["Finish"] = horse2
	self.m_Horses[3]["Finish"] = horse3
	self.m_Horses[4]["Finish"] = horse4
end

function HorseRace:startProgress()
	self.m_MoveX = 0
	self.m_Progress = 0
	self.m_Countdown = 10
	self.m_RightText = ""
	self.m_ProgressSended = false

	setTimer(self.m_CountdownBind, 1000, 10)
end

function HorseRace:stopProgress()
	removeEventHandler("onClientRender", root, self.m_renderProgressBind)
end

function HorseRace:renderProgress()

	local now = getTickCount()
	local elapsed = now - r_sCount
	local duration = r_eCount - r_sCount
	self.m_Progress = elapsed / duration
	self.m_MoveX = interpolateBetween(0,0,0,1270,0,0,self.m_Progress,'Linear')
	if self.m_Progress >=1 and self.m_ProgressSended == false then
		self.m_ProgressSended = true
		triggerServerEvent('horseRaceReceiveProgress', root, true)
	end
end


function HorseRace:renderRace()
	local offset = 50

	if self.m_ProgressSended == true then self.m_Speed = 0.8 end

	if self.m_Horses[1]["Pos"] < self.m_Horses[1]["Finish"] then self.m_Horses[1]["Pos"] = self.m_Horses[1]["Pos"] + self.m_Speed end
	if self.m_Horses[2]["Pos"] < self.m_Horses[2]["Finish"] then self.m_Horses[2]["Pos"] = self.m_Horses[2]["Pos"] + self.m_Speed end
	if self.m_Horses[3]["Pos"] < self.m_Horses[3]["Finish"] then self.m_Horses[3]["Pos"] = self.m_Horses[3]["Pos"] + self.m_Speed end
	if self.m_Horses[4]["Pos"] < self.m_Horses[4]["Finish"] then self.m_Horses[4]["Pos"] = self.m_Horses[4]["Pos"] + self.m_Speed end


	dxDrawRectangle(screenWidth/2-646/2, (screenHeight/2-338/2)-20, 646, 338, tocolor(0, 0, 0, 200), false)

	dxDrawImage(self.m_Left+20, self.m_Top, 160, 35, ":exo/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText(" - Pferdewetten", self.m_Left+175, self.m_Top, 200, 20,tocolor(50,200,255), 2, "default-bold")
	dxDrawText(self.m_RightText, self.m_Left+450, self.m_Top, 200, 20,tocolor(255,255,255), 2, "default-bold")

	--BAHN Beginn
--	dxDrawImage(self.m_Left+20, self.m_Top+offset, 90, 250, "games/pferderennen/images/start.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
--	dxDrawImageSection(self.m_Left+110, self.m_Top+offset, 400, 250,0,0,250,200, "games/pferderennen/images/bahn.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
--	dxDrawImage(self.m_Left+450, self.m_Top+offset, 180, 250, "games/pferderennen/images/ziel.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawImageSection(self.m_Left+20, self.m_Top+offset, 610, 250, self.m_MoveX, 0, 400, 200, "games/pferderennen/images/bahn.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	--BAHN ENDE

	offset = offset+55
	dxDrawImage(self.m_Left+20+self.m_Horses[1]["Pos"], self.m_Top+offset, 70, 58, "games/pferderennen/images/pferd1.png", 0, 0, 0, tocolor(255, 255, 255, 255), true) --PFERD1
	offset = offset+40
	dxDrawImage(self.m_Left+20+self.m_Horses[2]["Pos"], self.m_Top+offset, 70, 58, "games/pferderennen/images/pferd2.png", 0, 0, 0, tocolor(255, 255, 255, 255), true) --PFERD2
	offset = offset+40
	dxDrawImage(self.m_Left+20+self.m_Horses[3]["Pos"], self.m_Top+offset, 70, 58, "games/pferderennen/images/pferd3.png", 0, 0, 0, tocolor(255, 255, 255, 255), true) --PFERD3
	offset = offset+40
	dxDrawImage(self.m_Left+20+self.m_Horses[4]["Pos"], self.m_Top+offset, 70, 58, "games/pferderennen/images/pferd4.png", 0, 0, 0, tocolor(255, 255, 255, 255), true) --PFERD4



end

