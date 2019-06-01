Quest = inherit(Object)

function Quest:constructor(Id)
	self.m_Players = {}
	self.m_QuestId = Id

	self.m_Name = QuestManager.Quests[Id]["Name"]
	self.m_Description = QuestManager.Quests[Id]["Description"]
	self.m_Packages = QuestManager.Quests[Id]["Packages"]

end

function Quest:destructor()
	for index, player in pairs(self:getPlayers()) do
		self:removePlayer(player)
	end
end


function Quest:addPlayer(player, ...)
	table.insert(self.m_Players, player)
	player:triggerEvent("questAddPlayer", self.m_QuestId, self.m_Name, self.m_Description, ...)
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
end

function Quest:success(player)
	if table.find(self:getPlayers(), player) then
		outputDebug("success")
		player:sendSuccess(_("Quest bestanden! Du erhälst %d Päckchen!", player, self.m_Packages))
		sql:queryExec("INSERT INTO ??_quest (UserId, QuestId, Date) VALUES(?, ?, NOW())", sql:getPrefix(), player:getId(), self.m_QuestId)
		player:getInventoryOld():giveItem("Päckchen", self.m_Packages)
		self:removePlayer(player)
		outputDebug(self.m_Players)
	end
end
