-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIPaydayBox.lua
-- *  PURPOSE:     Payday box class
-- *
-- ****************************************************************************
GUIPaydayBox = inherit(DxElement)
inherit(GUIPaydayBox)
GUIPaydayBox.GUIPaydayBoxes = {}

function GUIPaydayBox:constructor(texts)
	DxElement.constructor(self, screenWidth/2-400/2, -200, 400, 200)

	self.m_PaydayTexts = texts

	playSound("files/audio/Payday.mp3")

	self.m_Close = bind(self.endPayday, self)

	setTimer(function()
		bindKey("space", "down", self.m_Close)
	end,1500,1)

	self.m_Animation = Animation.Move:new(self, 1500, self.m_AbsoluteX, 10)
end

function GUIPaydayBox:endPayday()
	unbindKey("space", "down", self.m_Close)
	self.m_Animation = Animation.Move:new(self, 1500, self.m_AbsoluteX, -200)
	setTimer(function() delete(self) end, 2000, 1)
end

function GUIPaydayBox:drawThis()
	local left = self.m_AbsoluteX
	local right = self.m_AbsoluteX + self.m_Width
	local top = self.m_AbsoluteY
	dxDrawRectangle(left, top, 400, 200, tocolor ( 0, 0, 0, 150 ) )
	dxDrawText("e#32c8ffX#FFFFFFo Payday", left, top, right, 30, tocolor(255,255,255,255), 1.7,"default", "center", "top", false, false,false, true)
	dxDrawText("Leertaste zum\nSchließen drücken", left, top+5, right-5, 30, tocolor(255,255,255,255), 0.9,"default", "right", "top", false, false,false, true)
	top = top+30
	left = left+10
	dxDrawText ( "Einkommen:", left, top, left+100, top+10, tocolor(0,255,0,255), 1,"default-bold", "left", "top", false, false,false, true)
	top = top+15
	self:outputPaydayLine("faction",left,top,1,"default")
	top = top+15
	self:outputPaydayLine("company",left,top,1,"default")
	top = top+15
	self:outputPaydayLine("group",left,top,1,"default")
	top = top+15
	self:outputPaydayLine("interest",left,top,1,"default")
	top = top+15
	self:outputPaydayLine("totalIncome",left,top,1,"default-bold")
	--SPALTE 2
	top = self.m_AbsoluteY+30
	left = self.m_AbsoluteX+self.m_Width/2
	dxDrawText ( "Ausgaben:", left, top, left+100, top+10, tocolor(255,0,0,255), 1,"default-bold", "left", "top", false, false,false, true)
	top = top+15
	self:outputPaydayLine("vehicleTax",left,top,1,"default")
	top = top+15
	self:outputPaydayLine("miete",left,top,1,"default")
	top = top+15
	self:outputPaydayLine("einkommenssteuer",left,top,1,"default")
	top = top+15
	self:outputPaydayLine("totalOutgoing",left,top,1,"default-bold")

	--Allgemein
	top = self.m_AbsoluteY+130
	left = self.m_AbsoluteX+10
	self:outputPaydayLine("payday",left,top,1,"default-bold")
	top = top+20
	self:outputPaydayLine("levelEP",left,top,1,"default-bold")
	top = top+15
	self:outputPaydayLine("levelUp",left,top,1,"default-bold")
end

function GUIPaydayBox:outputPaydayLine(text,left,top,size,font)
	if self.m_PaydayTexts[text] then
		dxDrawText ( self.m_PaydayTexts[text]["text"], left, top, left+100, top+10, tocolor(self.m_PaydayTexts[text]["r"],self.m_PaydayTexts[text]["g"],self.m_PaydayTexts[text]["b"],255), size,font,"left","top",false,false,false,true)
	end
end

addEvent("paydayBox", true)
addEventHandler("paydayBox", root,function(...)	GUIPaydayBox:new(...) end)
