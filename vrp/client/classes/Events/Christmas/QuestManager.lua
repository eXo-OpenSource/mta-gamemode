QuestManager = inherit(Singleton)


function QuestManager:constructor()
	-- Only add if clientside script is necessary
	self.m_Quests = {
		[2] = QuestPhotography,
		[3] = QuestPhotography,
		[4] = QuestDraw,
		[10] = QuestDraw,
		[16] = QuestPhotography
	}

	self.m_CurrentQuest = false

	addRemoteEvents{"questAddPlayer", "questRemovePlayer", "questOpenGUI"}
	addEventHandler("questAddPlayer", root, bind(self.addPlayer, self))
	addEventHandler("questRemovePlayer", root, bind(self.removePlayer, self))
	addEventHandler("questOpenGUI", root, bind(self.openGUI, self))

end

function QuestManager:addPlayer(questId, name, description)
	self.m_ShortMessage = ShortMessage:new(description.."\nKlicke hier um den Quest abzubrechen!", "Quest: "..name, {150, 0, 0}, -1, function() triggerServerEvent("questShortMessageClick", localPlayer) end)

	if not self.m_Quests[questId] then return end
	self.m_CurrentQuest = self.m_Quests[questId]:new(questId, name, description)
end

function QuestManager:removePlayer()
	if self.m_ShortMessage then self.m_ShortMessage:delete() end
	if not self.m_CurrentQuest then return end
	delete(self.m_CurrentQuest)
end

function QuestManager:openGUI(Id, Name, Description, Packages)
	QuestGUI:new(Id, Name, Description, Packages)
end

