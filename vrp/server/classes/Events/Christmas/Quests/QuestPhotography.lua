QuestPhotography = inherit(Quest)

function QuestPhotography:constructor(id)
	Quest.constructor(self, id)
	addRemoteEvents{"questPhotograpyTakePhoto"}
	addEventHandler("questPhotograpyTakePhoto", root, bind(self.onTakePhoto, self))
end

function QuestPhotography:addPlayer(player)
	Quest.addPlayer(self, player)
	player:giveWeapon(43, 50)
end

function QuestPhotography:onTakePhoto(playersOnPhoto)
	if #playersOnPhoto >= 10 then
		client:sendShortMessage("Du hast erfolgreich 10 Spieler fotografiert!")
		self:success(client)
	end
end
