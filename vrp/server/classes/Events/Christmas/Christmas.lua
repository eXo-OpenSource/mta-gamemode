Christmas = inherit(Singleton)

function Christmas:constructor()
	self.m_QuestManager = QuestManager:new()
end


