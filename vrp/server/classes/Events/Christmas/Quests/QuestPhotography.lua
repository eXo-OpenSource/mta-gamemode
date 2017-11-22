QuestPhotography = inherit(Quest)

QuestPhotography.Targets = {
	[2] = {
		["SantaClaus"] = 1,
	},
	[3] = {
		["Players"] = 10,
	},
	[16] = {
		["PlayersWithHat"] = 5,
	}
}

function QuestPhotography:constructor(id)
	Quest.constructor(self, id)

	self.m_Target = QuestPhotography.Targets[id]

	if id == 2 then
		setGarageOpen(9, true)
		self.m_NPC = NPC:new(244, 2505.30, -1695.86, 13.55, 0)
		self.m_NPC:setImmortal(true)
		self.m_NPC:setFrozen(true)
	end

	self.m_TakePhotoBind = bind(self.onTakePhoto, self)

	addRemoteEvents{"questPhotograpyTakePhoto"}
	addEventHandler("questPhotograpyTakePhoto", root, self.m_TakePhotoBind)
end

function QuestPhotography:destructor(id)
	Quest.destructor(self)
	if self.m_NPC and isElement(self.m_NPC) then
		setGarageOpen(9, false)
		self.m_NPC:destroy()
	end
	removeEventHandler("questPhotograpyTakePhoto", root, self.m_TakePhotoBind)
end

function QuestPhotography:addPlayer(player)
	Quest.addPlayer(self, player)
	player:giveWeapon(43, 50)
end

function QuestPhotography:onTakePhoto(playersOnPhoto, pedsOnPhoto)

	if self.m_Target["SantaClaus"] then
		for index, ped in pairs(pedsOnPhoto) do
			if ped:getModel() == 244 then
				client:sendSuccess(_("Glückwunsch! Du hast den Weihnachtsmann fotografiert!", client))
				self:success(client)
				return
			end
		end
		client:sendError(_("Auf deinem Foto ist kein Weihnachtsmann!", client))
		return
	elseif self.m_Target["Players"] then
		if #playersOnPhoto >= self.m_Target["Players"] then
			client:sendSuccess(_("Du hast erfolgreich 10 Spieler fotografiert!", client))
			self:success(client)
			return
		else
			client:sendError(_("Auf deinem Foto sind zuwenig Spieler (%d/%d)", client, #playersOnPhoto, self.m_Target["Players"]))
			return
		end
	elseif self.m_Target["PlayersWithHat"] then
		local count = 0
		for index, player in pairs(playersOnPhoto) do
			if player.m_IsWearingHelmet and player.m_IsWearingHelmet == "Weihnachtsmütze" then
				count = count +1
			end
		end
		if count > self.m_Target["PlayersWithHat"] then
			client:sendSuccess(_("Du hast erfolgreich 5 Spieler mit Weihnachtsmütze fotografiert!", client))
			self:success(client)
			return
		else
			client:sendError(_("Auf deinem Foto sind zuwenig Spieler mit Weihnachtsmütze! (%d/%d)", client, count, self.m_Target["PlayersWithHat"]))
			return
		end
	end

	client:sendError(_("Dein Foto entspricht nicht der Questaufgabe!", client))
end
