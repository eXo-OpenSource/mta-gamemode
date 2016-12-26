-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIRadioButtonGroup.lua
-- *  PURPOSE:     GUI image class
-- *
-- ****************************************************************************
GUIRadioButtonGroup = inherit(GUIElement)

function GUIRadioButtonGroup:constructor(posX, posY, width, height, parent)
	----checkArgs("GUIRadioButtonGroup:constructor", "number", "number", "number", "number")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	self.m_CheckedRadio = false
end

function GUIRadioButtonGroup:getCheckedRadioButton()
	return self.m_CheckedRadio
end

function GUIRadioButtonGroup:setCheckedRadioButton(radio)
	self.m_CheckedRadio = radio

	for k, v in ipairs(self:getChildren()) do
		if radio ~= v then
			v:setChecked(false)
		end
	end	
	return self
end
