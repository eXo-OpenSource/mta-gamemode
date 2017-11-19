Christmas = inherit(Singleton)

function Christmas:constructor()
	self.m_QuestManager = QuestManager:new()
	WheelOfFortune:new(Vector3(1479, -1700.3, 14.2), 0)
end


