-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebUI/VRPWebWindow.lua
-- *  PURPOSE:     vRP's FrameWebWindow implementation
-- *
-- ****************************************************************************
VRPWebWindow = inherit(FrameWebWindow)

function VRPWebWindow:constructor(pos, size, initialPage, transparent)
	FrameWebWindow.constructor(self, pos, size, initialPage, transparent, pos+Vector2(2, 2+30), size-Vector2(4, 4))

	self.m_HasCloseButton = true
end

function VRPWebWindow:destructor()
	-- Wraps WebWindow/FrameWebWindow:destroy
	self:destroy()
end

function VRPWebWindow:draw()
	local posX, posY = self.m_Position.x, self.m_Position.y
	local width, height = self.m_Size.x, self.m_Size.y

	-- Draw background
	dxDrawRectangle(posX+1, posY+1, width-2, height-2, tocolor(0, 0, 0, 150))

	-- Draw titlebar background
	dxDrawRectangle(posX, posY, width, 30, tocolor(0x23, 0x23, 0x23, 230))

	-- Draw titlebar text
	dxDrawText(self.m_Title, posX, posY, posX + width, posY + 30, Color.White, 1, VRPFont(30), "center", "center")

	-- Draw titlebar line
	dxDrawRectangle(posX, posY + 30, width, 1, Color.White)

	-- Draw close button if available
	if self.m_HasCloseButton then
		dxDrawText("[x]", posX + width - 28, posY, nil, nil, Color.White, 1, VRPFont(35))
	end

	-- Draw web view
	dxDrawImage(self.m_BrowserPos, self.m_BrowserSize, self.m_Browser, 0, 0, 0, -1)
end

function VRPWebWindow:processTitleBarClick(pos)
	-- Test if the click pos is in the range of the close button
	if self.m_HasCloseButton and pos.x > self.m_Size.x-28 then -- We only have to do this check as the button is flushed with the edge
		delete(self)
	end
end
