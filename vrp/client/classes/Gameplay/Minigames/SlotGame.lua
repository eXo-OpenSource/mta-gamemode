-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/CrashGame.lua
-- *  PURPOSE:     Crash Game Casino
-- *
-- ****************************************************************************
SlotGame = inherit(GUIForm)
inherit(Singleton, SlotGame)
SlotGame.Path = "files/images/Radar/Blips/"
SlotGame.Images = 
{

	"PoliceRob",
	"Horse",
	"Bank",
	"Alarm",
	"CluckinBell",
	"Donut",
	"Lumberjack",
	"Gardener",
	"Evil",
	"Ghost",
	"Casino",
	"Bar",
	"Turtle"
}

SlotGame.Colors = 
{
	tocolor(212, 244, 66, 255),
	tocolor(244, 65, 152, 255),
	tocolor(200, 0, 0, 255),
	Color.Red, 
	Color.Green,
	tocolor(244, 181, 65),
	tocolor(65, 121, 244),
	Color.LightBlue,
	Color.White,
	Color.Orange, 
	Color.Purple,
	tocolor(60, 200, 200, 255),
	Color.Yellow,
}


SlotGame.LinesColor  = 
{
    Color.changeAlpha(Color.Yellow, 100), --yellow
	Color.changeAlpha(Color.Red, 100), -- red
    Color.changeAlpha(Color.Green, 100), -- green #2
	Color.changeAlpha(Color.Yellow, 100), --yellow
	Color.changeAlpha(Color.Red, 100), -- red
    Color.changeAlpha(Color.Green, 100), -- green #2
	Color.changeAlpha(Color.Yellow, 100), --yellow
	Color.changeAlpha(Color.Red, 100), -- red
    Color.changeAlpha(Color.Green, 100), -- green #2
	Color.changeAlpha(Color.Yellow, 100), --yellow
	Color.changeAlpha(Color.Red, 100), -- red
    Color.changeAlpha(Color.Green, 100), -- green #2
	Color.changeAlpha(Color.Yellow, 100), --yellow
	Color.changeAlpha(Color.Red, 100), -- red
    Color.changeAlpha(Color.Green, 100), -- green #2
}


SlotGame.Lines  = 
{
    {{1,1}, {2,2}, {3,3}, {4,2}, {5,1}}, --yellow
    {{1,3}, {2,2}, {3,1}, {4,2}, {5,3}}, -- red
    {{1,1}, {2,1}, {3,1}, {4,1}, {5,1}}, -- green #2
	{{1,1}, {2,1}, {3,1}, {4,1}, {5,1}}, -- green top
    {{1,3}, {2,3}, {3,3}, {4,3}, {5,3}}, -- green bottom
}

SlotGame.HelpText = "Drehe mit dem Button >>Play<< \nAchtung! Dein Gewinn wird nicht sofort ausgezahlt erst wenn du den Button >Cash out< drückst!\nDein Gewinn steht oben im Feld >Win<.\nDein aktueller Einsatz im Feld >Credits<.\nDu kannst diesen mit dem Button >Bet up< und >Bet down< erhöhen/vermindern.\nGelbe Linie = 1xGewinn |Rote Linie = 2xGewinn\nObere Grüne =3xGewinn | Untere Grüne = 4x Gewinn | Mittlere Grüne = 5x Gewinn\nSymbole = Alarm < Haken < Blume < Geist < Würfel < Schildkröte (< heisst weniger Wert)"
SlotGame.BetAmount = 
{
	[1] = 50, 
	[2] = 100, 
	[3] = 200, 
	[4] = 500, 
	[5] = 1000, 
	[6] = 1500, 
	[7] = 2000,
	[8] = 4000,
	[9] = 8000,
	[10] = 50000,
	[11] = 100000,
	[12] = 500000, 
	[13] = 1000000,
}

addRemoteEvents{"onOnlineCasinoShow", "onOnlineCasinoHide", "onGetOnlineCasinoResults", "onShowWinOnlineCasino", "onOnlineSlotMachineEffect"}
function SlotGame:constructor()
	GUIForm.constructor(self, screenWidth/2 - 1024/2, screenHeight/2-506/2, 1024, 506, false)
	self.m_Fields = {}
	GUIRectangle:new(0, 0, self.m_Width, self.m_Height, Color.Black, self)

	for i = 1, 5 do 
		self:createColumn()
	end
	
	self.m_Bet = 1
	self.m_Table = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/OnlineCasino/overlay.png", self)

	self.m_BetLabel = GUILabel:new(self.m_Width*0.09, self.m_Height*0.054, self.m_Width*0.2, self.m_Height*0.07, "$50", self):setColor(Color.Green)
	self.m_BetLabel:setFont(VRPFont(30, Fonts.Mario256))
	self.m_PayLabel = GUILabel:new(self.m_Width*0.81, self.m_Height*0.056, self.m_Width*0.2, self.m_Height*0.07, "$0", self):setColor(Color.Green)
	self.m_PayLabel:setFont(VRPFont(24, Fonts.Mario256))
	self.m_BetLabel:setText(("$ %s"):format(self.BetAmount[self.m_Bet]))
	self.m_Help = GUIRectangle:new(self.m_Width*0.02, self.m_Height-self.m_Height*0.15, self.m_Width*0.11, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_Help.onLeftClick = function()  ShortMessage:new(self.HelpText, "Spielo-Automat", nil, -1) end
	self.m_Help.onHover = function() self.m_Help:setColor(tocolor(244, 206, 66, 100)) end
	self.m_Help.onUnhover = function() self.m_Help:setColor(tocolor(255, 255, 255, 0)) end
	
	self.m_PayOut = GUIRectangle:new(self.m_Width*0.14, self.m_Height-self.m_Height*0.15, self.m_Width*0.15, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_PayOut.onLeftClick = function() triggerServerEvent("onOnlineSlotmachineRequestPay", localPlayer) end
	self.m_PayOut.onHover = function() self.m_PayOut:setColor(tocolor(244, 206, 66, 100)) end
	self.m_PayOut.onUnhover = function() self.m_PayOut:setColor(tocolor(255, 255, 255, 0)) end
	
	self.m_BetDown = GUIRectangle:new(self.m_Width*0.51, self.m_Height-self.m_Height*0.15, self.m_Width*0.07, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_BetDown.onLeftClick = function() self.m_Bet = self.m_Bet-1; if self.m_Bet < 1 then self.m_Bet = 1; end self.m_BetLabel:setText(("$%s"):format(addComas(tostring(self.BetAmount[self.m_Bet])))) end
	self.m_BetDown.onHover = function() self.m_BetDown:setColor(tocolor(244, 206, 66, 100)) end
	self.m_BetDown.onUnhover = function() self.m_BetDown:setColor(tocolor(255, 255, 255, 0)) end
	
		
	self.m_BetUp = GUIRectangle:new(self.m_Width*0.65, self.m_Height-self.m_Height*0.15, self.m_Width*0.06, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_BetUp.onLeftClick = function() self.m_Bet = self.m_Bet+1;  if self.m_Bet > 10 then self.m_Bet = 13; end self.m_BetLabel:setText(("$%s"):format(addComas(tostring(self.BetAmount[self.m_Bet])))) end
	self.m_BetUp.onHover = function() self.m_BetUp:setColor(tocolor(244, 206, 66, 100)) end
	self.m_BetUp.onUnhover = function() self.m_BetUp:setColor(tocolor(255, 255, 255, 0)) end
	

	self.m_Play = GUIRectangle:new(self.m_Width*0.86, self.m_Height-self.m_Height*0.15, self.m_Width*0.12, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_Play.onLeftClick = function() self:turn() end
	self.m_Play.onHover = function() if not self.m_Disable then self.m_Play:setColor(tocolor(244, 206, 66, 100)) else self.m_Play:setColor(tocolor(200, 0, 0, 100))  end end
	self.m_Play.onUnhover = function() self.m_Play:setColor(tocolor(255, 255, 255, 0)) end
	
	self.m_CloseBtn = GUIButton:new(self.m_Width-self.m_Width*0.03, 0, self.m_Width*0.03, self.m_Width*0.03, FontAwesomeSymbols.Close, self)
    self.m_CloseBtn:setFont(FontAwesome(15)):setFontSize(1)
    self.m_CloseBtn:setBarEnabled(false)
    self.m_CloseBtn:setBackgroundColor(Color.Red)
	self.m_CloseBtn.onLeftClick = function() self:forceOut() end
	
	localPlayer:setFrozen(true)
	self.m_ResultBind = bind(self.Event_GetTurnResults, self)
	addEventHandler("onGetOnlineCasinoResults", root, self.m_ResultBind)
	setElementData(localPlayer, "slotMachineIsOpen", false, true)
end

function SlotGame:createColumn()
	self.m_Fields[#self.m_Fields+1] = {}
	local col = #self.m_Fields
	local mark
	local sx, sy = self.m_Width*0.05+(self.m_Width*((col-1)*0.005)), self.m_Height*0.2
	if col > 3 then 
		sx = sx - (self.m_Width*0.002*(col-1))
	end
	for i = 1, 3 do 
		self.m_Fields[col][i] = { GUIImage:new(sx*col+ (self.m_Width*(0.12)*(col-1)), sy+((i-1)*self.m_Height*0.2), self.m_Width*(0.16),  self.m_Height*0.2, self:getPath(i), self), i}
		self.m_Fields[col][i][1]:setColor(self.Colors[i])
		mark = GUIRectangle:new( sx*col+ (self.m_Width*(0.12)*(col-1)), sy+((i-1)*self.m_Height*0.2), self.m_Width*(0.16),  self.m_Height*0.2, tocolor(0, 0, 0, 0), self)
		mark:setColor(tocolor(0, 0, 0, 0))
		self.m_Fields[col][i][3] = mark
	end
end

function SlotGame:mark(col, row, color)
	if self.m_Fields[col][row] then 
		self.m_Fields[col][row][3]:setColor(color) 
	end
end

function SlotGame:unmarkAll()
	for i = 1, 5 do 
		for i2 = 1, 3 do 
			self:unmark(i, i2)
		end
	end
end

function SlotGame:unmark(col, row)
	if self.m_Fields[col][row] then 
		self.m_Fields[col][row][3]:setColor(tocolor(0, 0, 0, 0)) 
	end
end



function SlotGame:setNextImage(col)
	if self.m_Fields[col] then 
		for i = 3, 1, -1 do 
			local tile = self.m_Fields[col][i]
			local image, index = unpack(tile)
			index = (index - 1)
			if index < 1 then 
				index = 13
			end
			tile[2] = index
			image:setColor(self.Colors[index])
			image:setImage(self:getPath(index))
		end
	end
end

function SlotGame:Event_GetTurnResults(data, win, pay, lastpay)
	self.m_Spins = {}
	self.m_Wins = win
	for col = 1, #data do 
		self.m_Spins[col] = data[col]
		self:spin(col, data[col])
	end	
	self.m_Pay = pay
	self.m_LastPay = lastpay
	self.m_Disable = true
	self.m_Play:setColor(tocolor(200, 0, 0, 100))
end

function SlotGame:showWinCondition() 
	self.m_Wins = self.Lines
	self:showWin()
end

function SlotGame:showWin() 
	playSound("files/audio/Pong/shot.mp3"):setVolume(1.4)
	if self.m_WinTimer then 
		if isTimer(self.m_WinTimer) then 
			killTimer(self.m_WinTimer)
		end
	end
	self.m_WinTimers = {}
	self.m_CurrentWinIndex = 1
	local col, row
	self.m_ShowCount = 0
	for line, subdata in pairs(self.m_Wins) do 
		if #subdata > 1 then
			self.m_ShowCount = self.m_ShowCount + 1
			self:showWinLine(line)
		end
	end
	if self.m_PlaySound and isElement(self.m_PlaySound) then stopSound(self.m_PlaySound) end
	self:showWinLines()
	if self.m_StopDisable and isTimer(self.m_StopDisable) then killTimer(self.m_StopDisable) end

	if self.m_LastPay > 0 then
		self.m_StopDisable = setTimer(function() self.m_Disable = false; self.m_Play:setColor(tocolor(244, 206, 66, 100)) end, 2500, 1)
		if self.m_WinSound and isElement(self.m_WinSound) then stopSound(self.m_WinSound) end
		if self.m_LastPay < self.BetAmount[self.m_Bet]*2 then 
			self.m_WinSound = playSound("files/audio/GoJump/average.wav")
		elseif self.m_LastPay >= self.BetAmount[self.m_Bet]*2  and self.m_LastPay < self.BetAmount[self.m_Bet]*4 then 
			self.m_WinSound = playSound("files/audio/GoJump/highscore.wav")
		else 
			self.m_WinSound = playSound("files/audio/arcade-sfx/win.ogg")
		end
		setSoundEffectEnabled(self.m_WinSound, "reverb", true)
		outputChatBox(("#FFFF00[Spielothekok]#FFFFFF Du hast #00FF00$%s#FFFFFF gewonnen!"):format(self.m_LastPay), 255, 255, 255, true)
	else 
		self.m_StopDisable = setTimer(function() self.m_Disable = false; self.m_Play:setColor(tocolor(244, 206, 66, 100)) end, 1000, 1)
	end
	self.m_PayLabel:setText(("$%s"):format(self.m_Pay))
end

function SlotGame:showWinLine(index)
	self.m_WinTimers[#self.m_WinTimers+1] = index
end

function SlotGame:showWinLines()
	if self.m_WinTimers and #self.m_WinTimers > 0 then 
		self.m_WinTimer = setTimer(function() 
			self.m_CurrentWinIndex = self.m_CurrentWinIndex + 1 
			if self.m_CurrentWinIndex > #self.m_WinTimers then 
				self.m_CurrentWinIndex = 1
			end
			self:markWinLine(self.m_WinTimers[self.m_CurrentWinIndex])
		end, 1000, 0)
	end
end

function SlotGame:markWinLine(index) 
	self:unmarkAll()
	if self.m_Wins[index] then 
		for i = 1, #self.m_Wins[index] do
			col, row = unpack(self.m_Wins[index][i])
			self:mark(col, row, self.LinesColor[index])
		end
	end
end

function SlotGame:spin(col, times)
	self:unmarkAll()
	if self.m_WinTimer and isTimer(self.m_WinTimer) then killTimer(self.m_WinTimer) end
	local delayTime = 100
	for i = 1, col-1 do 
		delayTime = delayTime + (self.m_Spins[i]*50) + 100
	end
	setTimer(
		function() 
			setTimer(function() playSound("files/audio/GoJump/button.wav"):setVolume(1.4) end, 50*times+200, 1)
			setTimer(bind(self.setNextImage, self), 50, times, col) 
		end, delayTime, 1)

	if self.m_WinSound and isElement(self.m_WinSound) then stopSound(self.m_WinSound) end
	if self.m_PlaySound and isElement(self.m_PlaySound) then stopSound(self.m_PlaySound) end
	self.m_PlaySound = playSound("files/audio/online_casino_roll.mp3", true)
	setSoundSpeed(self.m_PlaySound, 1)
	setSoundEffectEnabled(self.m_PlaySound, "reverb", true)
end

function SlotGame:forceOut() 
	triggerServerEvent("onOnlineSlotmachineRequestPay", localPlayer)
	triggerServerEvent("onOnlineSlotMachineForceOut", localPlayer)
	if self.m_PlaySound and isElement(self.m_PlaySound) then stopSound(self.m_PlaySound) end
	if self.m_WinSound and isElement(self.m_WinSound) then stopSound(self.m_WinSound) end
end

function SlotGame:turn()
	if not self.m_Disable then
		self:unmarkAll()
		playSound("files/audio/Pong/shot.mp3"):setVolume(1.4)
		triggerServerEvent("onOnlineSlotmachineUse", localPlayer, self.m_Fields, self.BetAmount[self.m_Bet])
	end
end

function SlotGame:getPath(index) 
	return ("%s%s.png"):format(self.Path, self.Images[index])
end

function SlotGame:destructor()
	GUIForm.destructor(self)
	localPlayer:setFrozen(false)
	setElementData(localPlayer, "slotMachineIsOpen", false, true)
	if self.m_WinSound and isElement(self.m_WinSound) then stopSound(self.m_WinSound) end
	removeEventHandler("onGetOnlineCasinoResults", root, self.m_ResultBind)
end

addEventHandler("onOnlineCasinoShow", root, function() 
	if SlotGame:isInstantiated() then 
		delete(SlotGame:getSingleton())
	end
	SlotGame:new()
end)

addEventHandler("onOnlineCasinoHide", root, function() 
	if SlotGame:isInstantiated() then 
		delete(SlotGame:getSingleton())
	end
end)

addEventHandler("onShowWinOnlineCasino", root, function() 
	if SlotGame:isInstantiated() then 
		SlotGame:getSingleton():showWin()
	end
end)

addEventHandler("onOnlineSlotMachineEffect", localPlayer, function(effect, x, y, z)
	local effectstrength = 3*effect
	setTimer(function()
		
		for i = 1, effectstrength, 1 do
			fxAddSparks(x, y, z, 0, 0, 2, 5, 20, 0, 0, 0, false, 0.5, 5)
		end
	end, 300, effectstrength)
	if effect == 2 then 
		local winSound = playSound3D("files/audio/Slotmachines/win_stuff.mp3", x, y, z)
		winSound:setVolume(1.5)
		winSound:setInterior(18)
		winSound:setDimension(3)
		setSoundEffectEnabled(winSound, "reverb", true)
	elseif effect == 3 then
		local winSound = playSound3D("files/audio/Race/countdown_start.mp3", x, y, z)
		winSound:setVolume(1.5)
		winSound:setInterior(18)
		winSound:setDimension(3)
		setSoundEffectEnabled(winSound, "reverb", true)
	end
end)