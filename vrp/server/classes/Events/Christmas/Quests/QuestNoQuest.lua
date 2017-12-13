QuestNoQuest = inherit(Quest)

function QuestNoQuest:constructor(id)
	Quest.constructor(self, id)
end

function QuestNoQuest:destructor(id)
	Quest.destructor(self)
end

function QuestNoQuest:addPlayer(player)
	Quest.addPlayer(self, player)
	self:success()
end

function QuestNoQuest:removePlayer(player)
	Quest.removePlayer(self, player)
end
