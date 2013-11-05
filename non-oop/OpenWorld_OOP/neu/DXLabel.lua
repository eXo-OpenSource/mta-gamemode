DXLabel = inherit(DXElement)


function isCursorOnElement(x,y,w,h)
	local mx,my = getCursorPosition ()
	local fullx,fully = guiGetScreenSize()
	cursorx,cursory = mx*fullx,my*fully
	if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
		return true
	else
		return false
	end
end

gtaonlinefont = {
	[30] = dxCreateFont("gtafont.ttf", 30),
	[23] = dxCreateFont("gtafont.ttf", 23),
	[12] = dxCreateFont("gtafont.ttf", 12),
	[15] = dxCreateFont("gtafont.ttf", 15),
	[120] = dxCreateFont("gtafont.ttf", 120),
	[50] = dxCreateFont("gtafont.ttf", 50)
}

gtaonlinefont1 = dxCreateFont("gtafont.ttf", 30)


function DXLabel:constructor(text, x, y, width, height)
	DXElement.constructor(self, x, y, width, height)

	self.m_Text = text or ""
	self.m_Color = tocolor(255, 255, 255, 255)
	self.m_Font = "default-bold"
	self.m_AlignX = "left"
	self.m_AlignY = "top"
	
	self.m_X = screenW*(self.m_X/1600)
	self.m_Y = screenH*(self.m_Y/900)
	self.m_Width = screenW*(self.m_Width/1600)
	self.m_Height = screenH*(self.m_Height/900)

	

	addEventHandler("onClientRender", root, bind(self.render, self))
end

function DXLabel:render()
	dxDrawText(self.m_Text, self.m_X, self.m_Y, self.m_Width, self.m_Height, self.m_Color, 1.00, self.m_Font, self.m_AlignX, self.m_AlignY, false, false, true, false, false)
end

function DXLabel:setText(cmd, text)
	self.m_Text = text
end

function DXLabel:setColor(r, g, b, a)
	self.m_Color = tocolor(r, g, b, a)
end

function DXLabel:setFont(font)
	self.m_Font = font
end

function DXLabel:setAlignX(alignx)
	self.m_AlignX = alignx
end

function DXLabel:setAlignY(aligny)
	self.m_AlignY = aligny
end