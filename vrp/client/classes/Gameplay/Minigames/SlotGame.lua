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
	"Alarm",
	"Fishing",
	"Gardener",
	"Ghost",
	"Casino",
	"Turtle"
}

SlotGame.Colors = 
{
	Color.Red, 
	Color.Blue,
	Color.Green,
	Color.Orange, 
	Color.Purple,
	Color.Yellow,
}


SlotGame.LinesColor  = 
{
    Color.changeAlpha(Color.Yellow, 100), --yellow
	Color.changeAlpha(Color.Red, 100), -- red
	Color.changeAlpha(Color.Green, 100), -- green #1
    Color.changeAlpha(Color.Green, 100), -- green #2
    Color.changeAlpha(Color.Green, 100),  -- green #3
}


SlotGame.Lines  = 
{
    {{1,1}, {2,2}, {3,3}, {4,2}, {5,1}}, --yellow
    {{1,3}, {2,2}, {3,1}, {4,2}, {5,3}}, -- red
    {{1,2}, {2,2}, {3,2}, {4,2}, {5,2}}, -- green #1
    {{1,1}, {2,1}, {3,1}, {4,1}, {5,1}}, -- green #2
    {{1,3}, {2,3}, {3,3}, {4,3}, {5,3}},  -- green #3
}

addRemoteEvents{"onGetOnlineCasinoResults"}
function SlotGame:constructor()
	GUIForm.constructor(self, screenWidth/2 - 1024/2, screenHeight/2-506/2, 1024, 506, false)
	self.m_Fields = {}
	GUIRectangle:new(0, 0, self.m_Width, self.m_Height, Color.Black, self)

	for i = 1, 5 do 
		self:createColumn()
	end
	
	self.m_Table = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/OnlineCasino/overlay.png", self)

	self.m_Bet = GUILabel:new(self.m_Width*0.09, self.m_Height*0.04, self.m_Width*0.2, self.m_Height*0.08, "50$", self):setColor(Color.Green)
	self.m_Pay = GUILabel:new(self.m_Width*0.81, self.m_Height*0.04, self.m_Width*0.2, self.m_Height*0.08, "0$", self):setColor(Color.Green)

	self.m_Help = GUIRectangle:new(self.m_Width*0.02, self.m_Height-self.m_Height*0.15, self.m_Width*0.11, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_Help.onLeftClick = function() outputChatBox("help") end
	self.m_Help.onHover = function() self.m_Help:setColor(tocolor(244, 206, 66, 100)) end
	self.m_Help.onUnhover = function() self.m_Help:setColor(tocolor(255, 255, 255, 0)) end
	
	self.m_PayOut = GUIRectangle:new(self.m_Width*0.14, self.m_Height-self.m_Height*0.15, self.m_Width*0.15, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_PayOut.onHover = function() self.m_PayOut:setColor(tocolor(244, 206, 66, 100)) end
	self.m_PayOut.onUnhover = function() self.m_PayOut:setColor(tocolor(255, 255, 255, 0)) end
	
	self.m_BetDown = GUIRectangle:new(self.m_Width*0.51, self.m_Height-self.m_Height*0.15, self.m_Width*0.07, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_BetDown.onHover = function() self.m_BetDown:setColor(tocolor(244, 206, 66, 100)) end
	self.m_BetDown.onUnhover = function() self.m_BetDown:setColor(tocolor(255, 255, 255, 0)) end
	
		
	self.m_BetUp = GUIRectangle:new(self.m_Width*0.65, self.m_Height-self.m_Height*0.15, self.m_Width*0.06, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_BetUp.onHover = function() self.m_BetUp:setColor(tocolor(244, 206, 66, 100)) end
	self.m_BetUp.onUnhover = function() self.m_BetUp:setColor(tocolor(255, 255, 255, 0)) end
	

	self.m_Play = GUIRectangle:new(self.m_Width*0.86, self.m_Height-self.m_Height*0.15, self.m_Width*0.12, self.m_Height*0.1, tocolor(100, 100, 100, 0), self)
	self.m_Play.onHover = function() self.m_Play:setColor(tocolor(244, 206, 66, 100)) end
	self.m_Play.onUnhover = function() self.m_Play:setColor(tocolor(255, 255, 255, 0)) end
	


	addEventHandler("onGetOnlineCasinoResults", root, bind(self.Event_GetTurnResults, self))
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
				index = 6
			end
			tile[2] = index
			image:setColor(self.Colors[index])
			image:setImage(self:getPath(index))
		end
	end
end

function SlotGame:Event_GetTurnResults(data, win)
	self.m_Spins = {}
	self.m_Wins = win
	for col = 1, #data do 
		self.m_Spins[col] = data[col]
		self:spin(col, data[col])
	end
end

function SlotGame:showWinCondition() 
	self.m_Wins = self.Lines
	self:showWin()
end

function SlotGame:showWin() 
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
		if #subdata > 2 then
			self.m_ShowCount = self.m_ShowCount + 1
			self:showWinLine(line)
		end
	end
	self:showWinLines()
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
	local delayTime = 100
	for i = 1, col-1 do 
		delayTime = delayTime + (self.m_Spins[i]*50) + 100
	end
	setTimer(function() setTimer(bind(self.setNextImage, self), 50, times, col) end, delayTime, 1)
	if col == 5 then 
		setTimer(function() self:showWin() end, delayTime+500, 1)
	end
end

function SlotGame:Event()

end

function SlotGame:turn()
	self:unmarkAll()
	triggerServerEvent("onOnlineSlotmachineUse", localPlayer, self.m_Fields)
end

function SlotGame:getPath(index) 
	return ("%s%s.png"):format(self.Path, self.Images[index])
end

function SlotGame:destructor()
	GUIForm.destructor(self)
end
