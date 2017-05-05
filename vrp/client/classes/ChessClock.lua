ChessClock = inherit(Object)
local w, h = guiGetScreenSize()
-- test2
function ChessClock:constructor( super ) 
	self.m_Super = super
	self.m_X = CHESS_CONSTANT.CLOCK_X
	self.m_Y = CHESS_CONSTANT.CLOCK_Y
	self.m_Width = CHESS_CONSTANT.CLOCK_WIDTH
	self.m_Height = CHESS_CONSTANT.CLOCK_HEIGHT
	self.m_ActiveColor = tocolor(196, 98, 16)
	self.m_InactiveColor = tocolor(128, 128, 128)
	self.m_TimeData = {}
	self.m_Turn = false
	if w >= 1600 and h >= 720 then 
		self.m_FontScale = 2
	else 
		self.m_FontScale = 1
	end
end

function ChessClock:destructor()

end
function ChessClock:update( turn, timeData )
	if isElement(timeData[1][1]) and isElement(timeData[2][1]) then
		self.m_TimeData = timeData
		self.m_Turn = turn
	end
end
function ChessClock:draw()
	if self.m_TimeData and self.m_Turn then
		self:drawBody()
		self:drawTime()
	end
end

function ChessClock:drawBody()
	dxDrawRectangle(self.m_X+self.m_Width*0.01, self.m_Y+self.m_Height*0.05, self.m_Width, self.m_Height, tocolor(10,10,10,150))
	dxDrawRectangle( self.m_X, self.m_Y, self.m_Width, self.m_Height, CHESS_CONSTANT.CLOCK_BG_COLOR)
end

function ChessClock:drawTime()
	local time, active, name
	local x, y
	for i = 1,#self.m_TimeData do 
		active, time = self.m_TimeData[i][1] == self.m_Turn, self.m_TimeData[i][2]
		time = string.format("%.2d:%.2d", time/60%60, time%60)
		if isElement( self.m_TimeData[i][1] ) then
			name = getPlayerName(self.m_TimeData[i][1])
		else 
			name = "-/-"
		end
		if #name >= 8 then 
			name = string.sub(name,1,8).."."
		end
		x = self.m_X+(self.m_Width*0.05*i)+self.m_Width*0.4*(i-1)+self.m_Width*0.05*(i-1)
		y = self.m_Y+self.m_Height*0.1
		if active then
			dxDrawRectangle( x, y, self.m_Width*0.4, self.m_Height*0.8, self.m_ActiveColor)
		else 
			dxDrawRectangle( x, y, self.m_Width*0.4, self.m_Height*0.8, self.m_InactiveColor)
		end
		if active then
			dxDrawText(name,x, y, x+self.m_Width*0.4, y+self.m_Height*0.8,tocolor(200,200,200,255),1,CHESS_CONSTANT.FONT_CHAPAZA,"center","top")
			dxDrawText(time,x, y, x+self.m_Width*0.4, y+self.m_Height*0.8,tocolor(200,200,200,255),self.m_FontScale,"default-bold","center","bottom")
		else 
			dxDrawText(name,x, y, x+self.m_Width*0.4, y+self.m_Height*0.8,tocolor(0,0,0,255),1,CHESS_CONSTANT.FONT_CHAPAZA,"center","top")
			dxDrawText(time,x, y, x+self.m_Width*0.4, y+self.m_Height*0.8,tocolor(0,0,0,255),self.m_FontScale,"default-bold","center","bottom")
		end
	end
end
