-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HelpBar.lua
-- *  PURPOSE:     Static class containg all help texts (used by help bar as well as menu)
-- *
-- ****************************************************************************
HelpTexts = {}

function HelpTexts.translateAll()
	for k, v in pairs(HelpTexts) do
		if type(v) == "string" then
			HelpTexts[k] = _(v)
		end
	end
end

HelpTexts.LoginRegister = [[
	Dies ist das Login Fenster. Im Tab 'Login' kannst Du dich einloggen, im Tab 'Registrieren' demzufolge registrieren.
	
	Tipp:
	Wenn du den Server erst einmal testen möchtest, kannst du als Gast spielen und dich während des Spielens registrieren.
	Für ein optimales Spielerlebnis und um Verluste zu vermeiden, empfehlen wir Dir jedoch eine sofortige Registration
]]
