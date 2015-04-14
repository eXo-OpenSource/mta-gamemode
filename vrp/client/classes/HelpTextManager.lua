-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HelpTextManager.lua
-- *  PURPOSE:     Responsible for managing help texts
-- *
-- ****************************************************************************
HelpTextManager = inherit(Singleton)

function HelpTextManager:constructor()
	self.m_Texts = {}

	-- General purpose texts here
	self:addText(_"Allgemein", _(HelpTextTitles.General.Team), _(HelpTexts.General.Team))
end

function HelpTextManager:addText(category, title, text)
	-- First, translate all parameters
	category, title, text = _(category), _(title), _(text)

	if not self.m_Texts[category] then
		self.m_Texts[category] = {}
	end

	self.m_Texts[category][title] = text
end

function HelpTextManager:getTexts()
	return self.m_Texts
end
