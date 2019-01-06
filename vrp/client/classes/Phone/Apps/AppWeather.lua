-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
AppWeather = inherit(PhoneApp)
addRemoteEvents{"skribbleReceiveLobbys"}

function AppWeather:constructor()
	PhoneApp.constructor(self, "Wetter", "IconWeather.png")
end

function AppWeather:onOpen(form)
	GUILabel:new(10, 10, 200, 50, _"Wetter", form):setColor(Color.Black)

	GUILabel:new(10, 70, 200, 30, _"Guten Tag liebe Spieler von eXo, das Wetter wird scheiße.\nBis bald!", form):setColor(Color.Black)
end
