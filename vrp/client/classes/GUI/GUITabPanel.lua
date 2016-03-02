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
	local tabButton = GUIButton:new(#self * 110, 0, 110, 30, tabName or "", self)

	tabButton:setColor(Color.White)
	tabButton:setBackgroundColor(Color.Grey)
	tabButton:setFontSize(1)
	tabButton:setFont(VRPFont(26))

	local id = #self+1
	tabButton.onLeftClick = function()
		self:setTab(id)

		for k, v in ipairs(self.m_Children) do
			if instanceof(v, GUIButton) then
				v:setColor(Color.White)
				v:setBackgroundColor(Color.Grey)
			end
		end

		tabButton:setColor(Color.Grey)
		tabButton:setBackgroundColor(Color.LightBlue)
	end

	self[id] = GUIElement:new(0, 30, self.m_Width, self.m_Height-30, self)
	self[id].TabIndex = id
	if id ~= 1 then
		self[id]:setVisible(false)
	else
		self.m_CurrentTab = 1
		tabButton:setColor(Color.Grey)
		tabButton:setBackgroundColor(Color.LightBlue)
	end

	return self[id]
end

function GUITabPanel:drawThis()
	-- Draw the background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150) --[[tocolor(255, 255, 255, 40)]])

	-- Draw a seperator line
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + 30, self.m_Width, 2, Color.White)
end
