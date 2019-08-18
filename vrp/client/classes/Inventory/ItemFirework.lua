addEvent("onClientFireworkStart", true)
addEventHandler("onClientFireworkStart", root, function(firework, position, rnd)
	if isElementStreamedIn(source) then
		if source ~= localPlayer and not core:get("Sounds", "Fireworks", true) then
			if not localPlayer.m_FireWorkMessageCooldown or timestampCoolDown(localPlayer.m_FireWorkMessageCooldown, 20) then
				ShortMessage:new("In deiner Nähe wurde ein Feuerwerk abgefeuert! Aktiviere diese in den Einstellungen um sie zu sehen!")
				localPlayer.m_FireWorkMessageCooldown = getRealTime().timestamp
			end
			return
		end
		local pos   = normaliseVector(position);
		if firework == "fireworksRocket" then
			ItemFireworkRocket:new(pos)
		elseif firework == "fireworksPipeBomb" then
			ItemPipeBomb:new(pos);
		elseif firework == "fireworksBattery" then
			ItemFireworkBattery:new(pos, rnd);
		elseif firework == "fireworksRoman" then
			ItemFireworkRomanCandle:new(pos, rnd);
		elseif firework == "fireworksRomanBattery" then
			ItemFireworkRomanCandleBattery:new(pos, rnd);
		elseif firework == "fireworksBomb" then
			ItemFireworkGroundShell:new(pos)
		elseif firework == "fireworksCracker" then
			ItemFireworkBanger:new(pos)
		end
	end
end)


