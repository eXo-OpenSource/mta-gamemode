-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionWTBoxHoverGUI.lua
-- *  PURPOSE:     FactionWTBoxHoverGUI class
-- *
-- ****************************************************************************

FactionWTBoxHoverGUI = inherit(GUIForm)
inherit(Singleton, FactionWTBoxHoverGUI)

function FactionWTBoxHoverGUI:constructor()

	GUIForm.constructor(self, screenWidth-220, screenHeight/2-100/2, 180, 200, false)
	self.m_CurrentHoverElement = false
	self.m_Background = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0,0,0,150), self)
	GUILabel:new(0, 0, self.m_Width, 30, "Kisteninhalt:", self):setAlignX("center"):setAlignY("center"):setColor(Color.LightBlue)
	self.m_ContentLabels = {}
	addEventHandler("onClientCursorMove", root,bind(self.onClientCursorMove,self))

end

function FactionWTBoxHoverGUI:destructor()

end

function FactionWTBoxHoverGUI:onShow()
	self:clearContentLabels()
	local i = 1
	local info
	if self.m_CurrentHoverElement then
		local weaponTable = getElementData(self.m_CurrentHoverElement,"content")
		if weaponTable then
			for weaponID,v in pairs(weaponTable) do
				for typ,amount in pairs(weaponTable[weaponID]) do
					if amount > 0 then
						if typ == "Munition" then info = " Magazin/e" else info = "" end
						self.m_ContentLabels[i] = GUILabel:new(5, 30+i*25, self.m_Width, 25, amount.." "..getWeaponNameFromID(weaponID)..info, self)
						i = i+1
					end
				end
			end
		end
	end
end

function FactionWTBoxHoverGUI:clearContentLabels()
	for index,label in pairs(self.m_ContentLabels) do
		label:delete()
	end
end

function FactionWTBoxHoverGUI:alignContentLabels()
	for index,label in pairs(self.m_ContentLabels) do
		label:setPosition(5, 30+index*25)
	end
end

function FactionWTBoxHoverGUI:onHide()

	if self.m_CurrentHoverElement then
		Cursor:show()
	end
end

setElementData(localPlayer,"lastHoverElement",nil)
setElementData(localPlayer,"hoverElement",nil)

function FactionWTBoxHoverGUI:onClientCursorMove(cursorX, cursorY, absX, absY, worldX, worldY, worldZ)
	if not isCursorShowing() then
		if self:isVisible() then
			self.m_CurrentHoverElement = false
			self:close()
		end
		return
	end

	local element = getElementBehindCursor(worldX, worldY, worldZ)
	if isElement(element) then
		if getElementData(element,"weaponBox")  then
			if self.m_CurrentHoverElement == false or self.m_CurrentHoverElement ~= element then
				self.m_CurrentHoverElement = element
				self:open()
			end
		end
	else
		if self.m_CurrentHoverElement then
			if self:isVisible() then
				self:close()
				self.m_CurrentHoverElement = false
			end
		end
	end
	if self:isVisible() then
	--	self:setAbsolutePosition(absX, absY) -- ToDo Works not Correctly on hover and unhover - Labels are failed at second hover
	--	self:alignContentLabels() -- Tried to fix it, not success
	end
end
