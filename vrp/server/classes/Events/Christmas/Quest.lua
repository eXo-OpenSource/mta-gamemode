Quest = inherit(Object)

function Quest:constructor(Id)
	self.m_Players = {}
	self.m_QuestId = Id

	self.m_Name = QuestManager.Quests[Id]["Name"]
	self.m_Description = QuestManager.Quests[Id]["Description"]
end

function Quest:addPlayer(player)
	table.insert(self.m_Players, player)
	player:sendShortMessage(self.m_Description, self.m_Name, {255, 0, 0})
	player:triggerEvent("questAddPlayer", self.m_QuestId)
end

function Quest:getPlayers()
	return self.m_Players
end

function Quest:removePlayer(player)
	table.remove(self.m_Players, table.find(self.m_Players, player))
	player:triggerEvent("questRemovePlayer", self.m_QuestId)
end

function Quest:success(player)
	player:sendSuccess("Quest bestanden!")
end
