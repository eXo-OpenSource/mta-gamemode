addEvent("onClientFireworkStart", true)
addEventHandler("onClientFireworkStart", root, function(firework, position, rnd)
	if isElementStreamedIn(source) then
		local pos   = normaliseVector(position);
		if firework == "Rakete" then
			ItemFireworkRocket:new(pos)
		elseif firework == "Rohrbombe" then
			ItemPipeBomb:new(pos);
		elseif firework == "Raketen Batterie" then
			ItemFireworkBattery:new(pos, rnd);
		elseif firework == "Römische Kerze" then
			ItemFireworkRomanCandle:new(pos, rnd);
		elseif firework == "Römische Kerzen Batterie" then
			ItemFireworkRomanCandleBattery:new(pos, rnd);
		elseif firework == "Kugelbombe" then
			ItemFireworkGroundShell:new(pos)
		elseif firework == "Böller" then
			ItemFireworkBanger:new(pos)
		end
	end
end)


