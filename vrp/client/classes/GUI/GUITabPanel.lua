-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUITabPanel.lua
-- *  PURPOSE:     GUITabPanel class
-- *
-- ****************************************************************************
GUITabPanel = inherit(GUITabControl)

function GUITabPanel:constructor(posX, posY, width, height, parent)
	checkArgs("GUITabControl:constructor", "number", "number", "number", "number")
	GUITabControl.constructor(self, posX, posY, width, height, parent)

end

function GUITabPanel:addTab(tabName)
	local tabButton = GUIButton:new(#self * 100, 0, 110, 30, tabName or "", self)
	
	tabButton:setColor(Color.White)
	tabButton:setBackgroundColor(Color.Black)
	tabButton:setFontSize(1)
	tabButton:setFont(VRPFont(26))
	
	local id = #self+1
	tabButton.onLeftClick = function()
		self:setTab(id)
		
		for k, v in ipairs(self.m_Children) do
			if instanceof(v, GUIButton) then
				v:setColor(Color.White)
				v:setBackgroundColor(Color.Black)
			end
		end
		
		tabButton:setColor(Color.Black)
		tabButton:setBackgroundColor(Color.White)
	end

	self[id] = GUIElement:new(0, 30, self.m_Width, self.m_Height-30, self)
	self[id].TabIndex = id
	if id ~= 1 then
		self[id]:setVisible(false)
	else
		self.m_CurrentTab = 1
		tabButton:setColor(Color.Black)
		tabButton:setBackgroundColor(Color.White)
	end
	
	return self[#self]
end

function GUITabPanel:drawThis()
	-- Draw the border
	--dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.White)

	-- Draw the background
	dxDrawRectangle(self.m_AbsoluteX+2, self.m_AbsoluteY+2, self.m_Width-4, self.m_Height-4, tocolor(0, 0, 0, 150) --[[tocolor(255, 255, 255, 40)]])
	
	-- Draw a seperator line
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + 30, self.m_Width, 2, Color.White)
end
