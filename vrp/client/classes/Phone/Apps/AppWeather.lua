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

	if Weather:getSingleton():getAllWeather() then
		local x_offs = 70
		for i, v in pairs(Weather:getSingleton():getAllWeather()) do
			GUILabel:new(10, x_offs, 200, 30, i, form):setColor(Color.Black)
			GUILabel:new(10, x_offs+5, 240, 20, WEATHER_ID_DESCRIPTION[v.Id].info, form):setAlignX("right"):setColor(Color.Grey)
			x_offs = x_offs + 40
		end
	else 
		GUILabel:new(10, 70, 200, 30, _"Guten Tag liebe Spieler von eXo, das Wetter wird scheiße.\nBis bald!", form):setColor(Color.Black)
	end
end
