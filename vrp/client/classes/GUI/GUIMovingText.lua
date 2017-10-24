-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMovingText.lua
-- *  PURPOSE:     GUI moving text
-- *
-- ****************************************************************************
GUIMovetext = inherit(DxElement)
inherit(GUIFontContainer, GUIMovetext)

function GUIMovetext:constructor(posX, posY, width, height, text, title, scrollspeed, startoffset, icon, postgui)
	checkArgs("GUIMovetext:constructor", "number", "number", "number", "number","string","string" ,"number","number")
	DxElement.constructor(self, posX, posY, width, height)
	GUIFontContainer.constructor(self, text,1)

	self.m_NormalColor = Color.White
	self.m_HoverColor = Color.Black
	self.m_BackgroundColor = tocolor(0,0,0,220)
	self.m_BackgroundHoverColor = Color.White
	self.m_Color = self.m_NormalColor
	self.m_Start = startoffset or 0
	self.m_Text = text
	self.m_Title = title
	self:setFont(VRPFont(height))
	self.m_ScrollSpeed = scrollspeed
	self.m_FontHeight = dxGetFontHeight(self:getFontSize(), self:getFont())
	self.m_bindFunc = function() self:renderThis() end
	self.m_Icon = icon
	self.m_PostGUI = postgui
	addEventHandler("onClientRender",root,self.m_bindFunc)
end

function GUIMovetext:renderThis()
	self.m_Start = self.m_Start + self.m_ScrollSpeed
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY,self.m_AbsoluteX+self.m_Width,self.m_FontHeight,self.m_BackgroundColor,self.m_PostGUI)
	if self.m_Title then
		dxDrawText(self.m_Title,self.m_AbsoluteX, self.m_AbsoluteY,self.m_AbsoluteX+self.m_Width,self.m_AbsoluteY+self.m_FontHeight,self.m_Color,self:getFontSize(), self:getFont(),"left","top",false,false,self.m_PostGUI)
	end
	if self.m_Icon then
		dxDrawImage((self.m_AbsoluteX+self.m_Width)- self.m_Width*0.03, self.m_AbsoluteY,self.m_Width*0.03,self.m_FontHeight,self.m_Icon,0,0,0,tocolor(255,255,255,255),self.m_PostGUI)
	end
	dxDrawText(self.m_Text,self.m_Width - (self.m_AbsoluteX+ self.m_Start), self.m_AbsoluteY,(self.m_AbsoluteX+ self.m_Start),self.m_AbsoluteY+self.m_FontHeight,self.m_Color,self:getFontSize(), self:getFont(),"left","top",false,false,self.m_PostGUI)
	if self.m_Start >= self.m_AbsoluteX+(self.m_Width*1.5) then
		self:removeEvents( )
		self:anyChange()
		delete(self)

	end
end

function GUIMovetext:removeEvents( )
	removeEventHandler("onClientRender",root,self.m_bindFunc)
end
