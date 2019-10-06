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
	self.m_DefaultLocale = "de"

	-- Load standard translations
	self:loadTranslation("en")
end

function TranslationManager:loadTranslation(locale, poFile)
	if not poFile then
		local path = ("files/translation/%s.%s.po"):format(SERVER and "server" or "client", locale)
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
	if locale == "de" then
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
		if player and isElement(player) then
			if DEBUG then
				local status, errOrReturn = pcall(function(...) return TranslationManager:getSingleton():translate(message, player:getLocale()):format(...) end, ...)
				if not status then
					outputDebug(errOrReturn)
					outputDebug(debug.traceback())
				end
				return errOrReturn
			else
				if player.getLocale then
					return TranslationManager:getSingleton():translate(message, player:getLocale()):format(...)
				else
					outputDebug(debug.traceback())
				end
			end
		else
			return TranslationManager:getSingleton():translate(message, TranslationManager:getSingleton().m_DefaultLocale):format(...)
		end
	end
else
	function _(message, ...)
		if DEBUG then
			local status, errOrReturn = pcall(function(...) return TranslationManager:getSingleton():translate(message, localPlayer:getLocale()):format(...) end, ...)
			if not status then
				outputDebug(errOrReturn)
				outputDebug(debug.traceback())
			end
			return errOrReturn
		else
			return TranslationManager:getSingleton():translate(message, localPlayer:getLocale()):format(...)
		end
	end
end
