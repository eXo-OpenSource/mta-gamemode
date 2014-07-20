GUIScrollbarHorizontal = inherit(GUIElement)

local dxDrawRectangle = dxDrawRectangle

local GUISCROLL_THICKNESS = 40

function GUIScrollbarHorizontal:constructor(posX,posY,width,height,parent)
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	self.m_Position = 0
	self.m_Scrolling = false
	self.m_Movehandler = bind(self.onMove,self)
	
	self:anyChange()
end

function GUIScrollbarHorizontal:onInternalLeftClickDown()
	if isCursorOverArea(self.m_Width*self.m_Position+self.m_PosX,self.m_PosY,GUISCROLL_THICKNESS,self.m_Height) then
		addEventHandler("onClientCursorMove",root,self.m_Movehandler) 
		self.m_Scrolling = true
	end
end

function GUIScrollbarHorizontal:onInternalLeftClick()
	if self.m_Scrolling then
		removeEventHandler("onClientCursorMove",root,self.m_Movehandler) 
		self.m_Scrolling = false		
	end
end

function GUIScrollbarHorizontal:onMove()
	local currentCursor = getCursorPosition()*screenWidth
	local currentPos = self.m_PosX+(self.m_Position*self.m_Width)
	self.m_Position = math.max(1,math.min(0,(currentCursor-self.m_PosX)/self.m_Width))
	self:anyChange()
end

function GUIScrollbarHorizontal:getPositionAbsolute()
	return self.m_Position*self.m_Width
end

function GUIScrollbarHorizontal:getPosition()
	return self.m_Position
end

function GUIScrollbarHorizontal:drawThis()
	dxDrawRectangle(self.m_PosX,self.m_PosY,self.m_Width,self.m_Height,tocolor(0,0,0,125))
	dxDrawRectangle(math.min(self.m_Width*self.m_Position+self.m_PosX,self.m_PosX+self.m_Width-GUISCROLL_THICKNESS),self.m_PosY,GUISCROLL_THICKNESS,self.m_Height,tocolor(0,0,125))
end