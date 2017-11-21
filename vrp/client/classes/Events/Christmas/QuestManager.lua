QuestManager = inherit(Singleton)


function QuestManager:constructor()
	self.m_Quests = {
		[2] = QuestPhotography
	}

	self.m_CurrentQues = false

	addRemoteEvents{"questAddPlayer", "questRemovePlayer", "questOpenGUI"}
	addEventHandler("questAddPlayer", root, bind(self.addPlayer, self))
	addEventHandler("questRemovePlayer", root, bind(self.removePlayer, self))
	addEventHandler("questOpenGUI", root, bind(self.openGUI, self))




end

function QuestManager:addPlayer(questId, ...)
	if not self.m_Quests[questId] then return end
	self.m_CurrentQuest = self.m_Quests[questId]:new(...)
end

function QuestManager:removePlayer()
	if not self.m_CurrentQuest then return end
	delete(self.m_CurrentQuest)
end

function QuestManager:openGUI(Id, Name, Description, Packages)
	QuestGUI:new(Id, Name, Description, Packages)
end

