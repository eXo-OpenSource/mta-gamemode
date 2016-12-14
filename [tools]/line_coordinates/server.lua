local settings = {
	["amount"] = 10,
	["max"] = 200,
	["start"] = false,
	["end"] = false
}

local r, g, b

function set_cmd(player, cmd, amount)
	if amount and tonumber(amount) then
		settings["amount"] = tonumber(amount)
		outputChatBox("Anzahl auf "..amount.." gesetzt!", player, 0, 255, 0)
	else
		outputChatBox("Fehler! Syntax: /set [int]", player, 255, 0, 0)
	end
end
addCommandHandler("set", set_cmd)

function setstart_cmd(player, cmd)
	settings["start"] = player:getPosition()
	outputChatBox("Startpunkt gesetzt!", player, 0, 255, 0)
end
addCommandHandler("setstart", setstart_cmd)

function setend_cmd(player, cmd)
	settings["end"] = player:getPosition()
	outputChatBox("Endpunkt gesetzt!", player, 0, 255, 0)
end
addCommandHandler("setend", setend_cmd)


function calc(player, cmd, comment)
	comment = comment and " -- "..comment or ""
	local amount = settings["amount"]/10

	r = math.random(0, 255)
	g = math.random(0, 255)
	b = math.random(0, 255)

	output(settings["start"], comment)
	for i = 0.1, amount, 0.1 do
 	 	pos = i*(settings["end"] - settings["start"]) + settings["start"]
		output(pos, comment)
	end
end
addCommandHandler("calc", calc)

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function output(pos, comment)


	local x, y, z = round(pos.x, 2), round(pos.y, 2), round(pos.z, 2)
	outputChatBox("{"..x..", "..y..", "..z.."},"..comment, player, r, g, b)
	createMarker(pos, "cylinder", 1.5, r, g, b)
end
