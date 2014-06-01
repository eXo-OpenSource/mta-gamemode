-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUICursor.lua
-- *  PURPOSE:     GUI custom cursor class
-- *
-- ****************************************************************************
GUICursor = inherit(Object)

function GUICursor:constructor()
	bindKey("b", "down",
		function()
			if isCursorShowing() then
				self.m_Counter = 0
				showCursor(false)
			else
				showCursor(true)
			end
		end
	)
	self.m_Counter = 0
	
	-- Hide the old cursor
	setCursorAlpha(0)

	-- Draw a new
	self.m_FuncDraw = bind(GUICursor.draw, self)
	addEventHandler("onClientRender", root, self.m_FuncDraw)
end

function GUICursor:destructor()
	setCursorAlpha(255)
	removeEventHandler("onClientRender", root, self.m_FuncDraw)
end

function GUICursor:draw()
	local cursorX, cursorY = getCursorPosition()
	if cursorX then
		cursorX, cursorY = cursorX*screenWidth, cursorY*screenHeight
		dxDrawImage(cursorX, cursorY, 12, 20, "files/images/GUI/Cursor.png", 0, 0, 0, Color.White, true)
	end
end

function GUICursor:check()
	if self.m_Counter == 0 then
		showCursor(false)
	else
		showCursor(true)
	end
end

function GUICursor:show()
	self.m_Counter = self.m_Counter + 1
	self:check()
end

function GUICursor:hide()
	self.m_Counter = self.m_Counter - 1
	self:check()
end
