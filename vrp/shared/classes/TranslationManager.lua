-- ****************************************************************************
-- *
-- *  PROJECT:     	vRoleplay
-- *  FILE:        	shared/classes/TranslationManager.lua
-- *  PURPOSE:     	Class to manage translations
-- *
-- ****************************************************************************
TranslationManager = inherit(Singleton)
SERVER = triggerServerEvent == nil

function TranslationManager:constructor()
	self.m_Translations = {}
	self.m_AddonTranslations = {}
	
	-- Load standard translations
	self:loadTranslation("de")
end

function TranslationManager:loadTranslation(locale, poFile)
	if not poFile then	
		local path = "files/translation/"..(SERVER and "server" or "client").."."..locale..".po"
		if fileExists(path) then
			self.m_Translations[locale] = POParser:new(path)
			outputDebug("Locale \'"..locale.."\' has been loaded!")
			return true
		end
	else
		poFile = pathConform(poFile)
		if not fileExists(poFile) then
			return false
		end
		
		if not self.m_AddonTranslations[locale] then
			self.m_AddonTranslations[locale] = {}
		end
		local poParser = POParser:new(poFile)
		if poParser then -- Todo: Collect garbage if addon resource will be stopped
			table.insert(self.m_AddonTranslations[locale], poParser)
			outputDebug("Locale \'"..locale.."\' has been loaded!")
			return true
		end		
	end
	return false
end

function TranslationManager:translate(message, locale)
	if locale == "en" then
		return message
	end
	
	if not self.m_Translations[locale] and not self.m_AddonTranslations[locale] then
	--	outputDebugString("The translation has not been loaded yet")
		return message
	end
	
	if self.m_Translations[locale] then
		local translatedMsg = self.m_Translations[locale]:translate(message)
		if not translatedMsg then
			outputDebugString("There's a missing translation. Please update the .po files")
			outputDebugString("Missing string: "..message)
			return message
		end
		return translatedMsg
	else	
		-- Look up in loaded addon translations
		for k, poParser in ipairs(self.m_AddonTranslations[locale] or {}) do
			translatedMsg = poParser:translate(message)
			if translatedMsg then
				return translatedMsg
			end
		end
	end
	
	return message
end

if SERVER then
	function _(message, player, ...)
		return TranslationManager:getSingleton():translate(message:format(...), player:getLocale())
	end
else
	function _(message, ...)
		return TranslationManager:getSingleton():translate(message:format(...), localPlayer:getLocale())
	end
end
