Fishing = inherit(Singleton)
Fishing.Positions = {
	Vector3(350.64, -2072.44, 7.2)
}

Fishing.Result = {
	[1] = {["value"] = 0, ["text"] = "miserabel"},
	[2] = {["value"] = 10, ["text"] = "schlecht"},
	[3] = {["value"] = 25, ["text"] = "mäßig"},
	[4] = {["value"] = 50, ["text"] = "gut"},
	[5] = {["value"] = 75, ["text"] = "sehr gut"},
	[6] = {["value"] = 95, ["text"] = "ausgezeichnet"}
}

Fishing.Win = {
	[1] = {["value"] = 50, 	["money"] = 5, ["text"] = "ein Hufeisen", ["model"] = 954, ["scale"] = 0.5, ["z"] = 0.2},
	[2] = {["value"] = 75, 	["money"] = 10, ["text"] = "eine Makrele", ["model"] = 1599, ["scale"] = 0.6, ["rotation"] = Vector3(90, 0, 0), ["z"] = 0.2},
	[3] = {["value"] = 100, ["money"] = 15, ["text"] = "eine Qualle", ["model"] = 1603, ["scale"] = 0.5, ["rotation"] = Vector3(180, 0, 0), ["z"] = 0.1},
	[4] = {["value"] = 125, ["money"] = 20, ["text"] = "einen Seestern", ["model"] = 902, ["scale"] = 0.2, ["rotation"] = Vector3(90, 0, 0), ["z"] = 0.2 },
	[5] = {["value"] = 150, ["money"] = 40, ["text"] = "eine Schildkröte", ["model"] = 1609, ["scale"] = 0.2, ["rotation"] = Vector3(90, 0, 0), ["z"] = 0.3 },
	[6] = {["value"] = 175, ["money"] = 50, ["text"] = "einen Goldfisch", ["model"] = 1600, ["scale"] = 0.6, ["rotation"] = Vector3(90, 90, 0), ["z"] = 0.2},
	[7] = {["value"] = 195, ["money"] = 150, ["text"] = "einen Clownfisch", ["model"] = 1604, ["scale"] = 0.6, ["rotation"] = Vector3(90, 90, 0), ["z"] = 0.2}
}

function Fishing:constructor()

	self.m_Markers = {}
	for index, pos in pairs(Fishing.Positions) do
		self.m_Markers[index] = createMarker(pos, "cylinder", 1, 0,255, 0, 125)

		self.m_Markers[index].id = index
		addEventHandler("onMarkerHit", self.m_Markers[index], bind(self.onMarkerHit, self))
	end

	self.m_Players = {}

	addRemoteEvents{"startFishing", "fishingStepFinished", "fishingPedClick"}
	addEventHandler("startFishing", root, bind(self.start, self))
	addEventHandler("fishingStepFinished", root, bind(self.stepFinished, self))
	addEventHandler("fishingPedClick", root, bind(self.pedClicked, self))



end

function Fishing:onMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim and not hitElement.vehicle then
		if not hitElment.win then
			hitElement:triggerEvent("questionBox", _("Möchtest du eine Runde angeln? Ein Köder kostet 10$!", hitElement), "startFishing", nil, source)
		else
			client:sendError(_("Bring deinen Fang erst zu Lutz um nochmal zu angeln!", client))
		end
	end
end

function Fishing:start(marker)
	if client:getMoney() > 10 then
		if not hitElment.win then
			client:takeMoney(10, "Angeln")
			setPedAnimation(client, "Gun_stand", "ped", 0, true, true, true)
			local pos = marker:getPosition()
			client:setPosition(pos)
			client:setRotation(0, 0, 90, "default", true)
			client:setFrozen(true)
			client:triggerEvent("startFishingClient", 1, marker.id)
			self.m_Players[client] = {}
		else
			client:sendError(_("Bring deinen Fang erst zu Lutz um nochmal zu angeln!", client))
		end
	else
		client:sendError(_("Du hast keine 10$ dabei!", client))
	end
end

function Fishing:stepFinished(id, step, value)
	local text = ""
	for index, key in ipairs(Fishing.Result) do
		if value > key["value"] then
			text = key["text"]
		end
	end

	self.m_Players[client][step] = value

	if step == 1 then
		client:sendShortMessage(_("Du hast %s ausgeworfen! Warte bis etwas anbeißt", client, text), _("Angeln", client))
		setTimer(function(client)
			client:sendShortMessage(_("Es hat etwas angebissen!", client, text), _("Angeln", client))
			client:triggerEvent("startFishingClient", 2, id)
		end, math.random(3000,6000), 1, client)
	else
		local value = self.m_Players[client][1] + self.m_Players[client][2]
		if value > 50 then
			local win, winIndex
			for index, key in ipairs(Fishing.Win) do
				if value > key["value"] then
					win = key
					winIndex = index
				end
			end

			local pos = Fishing.Positions[id]
			pos.x = pos.x-5.7
			local winObject = createObject(win["model"], pos.x, pos.y, pos.z-3)
			winObject:setDoubleSided(true)
			winObject:setScale(win["scale"] or 0)
			winObject:move(4000, pos.x, pos.y, pos.z+1, 0, 0, 0, "OutQuad")

			setTimer(function(client, winObject, text, win, winIndex)
				client:sendShortMessage(_("Du hast die Schnur %s eingeholt!", client, text), _("Angeln", client))
				local rot = win["rotation"] or Vector3(0, 0, 0)
				local x,y,z = rot.x, rot.y, rot.z
				exports.bone_attach:attachElementToBone(winObject, client, 12, 0, 0, win["z"], x, y, z)
				client.win = Fishing.Win[winIndex]
				client.winObject = winObject
				client:sendInfo(_("Du hast %s geangelt! Bringe deinen Fang zu Angler Lutz!", client, win["text"]))
				self:stop(client)
			end, 5000, 1, client, winObject, text, win, winIndex)
		else
			client:sendInfo(_("Deine Schnur ist gerissen!", client))
		end
	end
end

function Fishing:stop(player)
	self.m_Players[player] = nil
	player:setFrozen(false)
end


function Fishing:pedClicked()
	if client.win then
		client:sendSuccess(_("Wow, %s! Ich gebe dir dafür %d Dollar!", client, client.win["text"], client.win["money"]))
		client:giveMoney(client.win["money"], "Angeln")
		client.win = false
		client.winObject:destroy()
	else
		client:sendInfo(_("Hallo, du hast nichts gefangen, bitte Angle erst etwas!", client))
	end
end

addCommandHandler("fish", function(player, cmd, win)
	local key = Fishing.Win[tonumber(win)]
	local text, money, model, scale, rot
	if winObject then winObject:destroy() end
	text = key["text"]
	money = key["money"]
	model = key["model"]
	scale = key["scale"] or 1
	rot = key["rotation"] or Vector3(0, 0, 0)
	zoffset = key["z"] or 0
	winObject = createObject(model, 0, 0, 0)
	winObject:setDoubleSided(true)
	winObject:setScale(scale)
	local x,y,z = rot.x, rot.y, rot.z
	exports.bone_attach:attachElementToBone(winObject, player, 12, 0, 0, zoffset, x, y, z)
end)
