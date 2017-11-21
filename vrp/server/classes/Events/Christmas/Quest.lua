Quest = inherit(Object)

function Quest:constructor(Id)
	self.m_Players = {}
	self.m_QuestId = Id

	self.m_Name = QuestManager.Quests[Id]["Name"]
	self.m_Description = QuestManager.Quests[Id]["Description"]
	self.m_Packages = QuestManager.Quests[Id]["Packages"]
end

function Quest:addPlayer(player)
	table.insert(self.m_Players, player)
	player:sendShortMessage(self.m_Description, "Quest: "..self.m_Name, {255, 0, 0}, -1)
	player:triggerEvent("questAddPlayer", self.m_QuestId)
end

function Quest:getPlayers()
	return self.m_Players
end

function Quest:isQuestDone(player)
	local row = sql:queryFetchSingle("SELECT Id FROM ??_quest WHERE UserId = ? and QuestId = ?", sql:getPrefix(), player:getId(), self.m_QuestId)
	return row and true or false
end

function Quest:removePlayer(player)
	table.remove(self.m_Players, table.find(self.m_Players, player))
	player:triggerEvent("questRemovePlayer", self.m_QuestId)
end

function Quest:onClick(player)
	player:triggerEvent("questOpenGUI", self.m_QuestId, self.m_Name, self.m_Description, self.m_Packages)
	--QuestionBox:new(client, client, "Development: Möchtest du den Quest "..self.m_CurrentQuest.m_Name.." starten?", function()
	--	self:startQuestForPlayer(client)
	--end)
end

function Quest:success(player)
	player:sendSuccess(_("Quest bestanden! Du erhälst %d Päckchen!", player, self.m_Packages))
	sql:queryExec("INSERT INTO ??_quest (UserId, QuestId, Date) VALUES(?, ?, NOW())", sql:getPrefix(), player:getId(), self.m_QuestId)
	player:getInventory():giveItem("Paeckchen", self.m_Packages)
end
