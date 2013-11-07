-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIRadioButtonGroup.lua
-- *  PURPOSE:     GUI image class
-- *
-- ****************************************************************************
GUIRadioButtonGroup = inherit(GUIElement)

function CGUIRadioButtonGroup:constructor(posX, posY, width, height, parent)
	checkArgs("GUIRadioButtonGroup:constructor", "number", "number", "number", "number")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	self.m_pCheckedRadio = false
end

function GUIRadioButtonGroup:getCheckedRadioButton()
	return self.m_pCheckedRadio
end

function GUIRadioButtonGroup:setCheckedRadioButton(radio)
	self.m_pCheckedRadio = radio

	for k, v in ipairs(self:getChildren()) do
		if radio ~= v then
			v:setChecked(false)
		end
	end	
end
