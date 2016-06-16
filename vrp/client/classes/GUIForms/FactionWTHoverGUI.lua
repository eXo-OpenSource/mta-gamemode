-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionWTBoxHoverGUI.lua
-- *  PURPOSE:     FactionWTBoxHoverGUI class
-- *
-- ****************************************************************************

FactionWTBoxHoverGUI = inherit(GUIForm)
inherit(Singleton, FactionWTBoxHoverGUI)

function FactionWTBoxHoverGUI:constructor(box)

	GUIForm.constructor(self, screenWidth-220, screenHeight/2-100/2, 180, 200, false)
	self.m_Background = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0,0,0,150), self)
	GUILabel:new(0, 0, self.m_Width, 30, "Kisteninhalt:", self):setAlignX("center"):setAlignY("center"):setColor(Color.LightBlue)
	self.m_ContentLabels = {}
	self.m_CurrentBox = box
	self:loadContent()
end

function FactionWTBoxHoverGUI:destructor()
	self:close()
end

function FactionWTBoxHoverGUI:loadContent()

	self:clearContentLabels()
	local i = 1
	local info
	if self.m_CurrentBox then
		local weaponTable = getElementData(self.m_CurrentBox,"content")
		if weaponTable then
			for weaponID,v in pairs(weaponTable) do
				for typ,amount in pairs(weaponTable[weaponID]) do
					if amount > 0 then
						if typ == "Munition" then info = " Magazin/e" else info = "" end
						self.m_ContentLabels[i] = GUILabel:new(5, 30+i*25, self.m_Width, 25, amount.." "..WEAPON_NAMES[weaponID]..info, self)
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
