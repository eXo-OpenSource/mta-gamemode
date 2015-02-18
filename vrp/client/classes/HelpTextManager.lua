-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HelpTextManager.lua
-- *  PURPOSE:     Responsible for managing help texts
-- *
-- ****************************************************************************
HelpTextManager = inherit(Singleton)

function HelpTextManager:constructor()
	self.m_Texts = {}

	-- General purpose texts here
	self:addText(_"Allgemein", "Team", HelpTexts.General.Team)
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


HelpTexts = {
	General = {
		LoginRegister = [[
			Dies ist das Login Fenster. Im Tab 'Login' kannst Du dich einloggen, im Tab 'Registrieren' demzufolge registrieren.
			
			Tipp:
			Wenn du den Server erst einmal testen möchtest, kannst du als Gast spielen und dich während des Spielens registrieren.
			Für ein optimales Spielerlebnis und um Verluste zu vermeiden, empfehlen wir Dir jedoch eine sofortige Registration.
		]];
		Team = [[
			Entwicklung und Administration:
			Jusonex <jusonex@v-roleplay.net>
			sbx320 <sbx320@v-roleplay.net>
			Revelse <revelse@v-roleplay.net>
			StiviK <stivik@v-roleplay.net>

			Administration:
			Doneasty <doneasty@v-roleplay.net> (außerdem verantwortlich für Grafik und Design)
			Sarcasm <sarcasm@v-roleplay.net> (außerdem verantwortlich für den Webauftritt)

			Moderation:
			Toxsi <toxsi@v-roleplay.net> (außerdem verantwortlich für Mapping)

			Vielen Dank an:
			thlefleshpound (für seine Zeit als Grafiker)
			Schlumpf (für seine kurze Zeit als Mapper)
			ReZ (für seine kurze Zeit als Mapper)
			Alex (für seine Zeit als Mapper)
		]];
	};
	Jobs = {
		Trashman = [[Todo]];
	};
};
