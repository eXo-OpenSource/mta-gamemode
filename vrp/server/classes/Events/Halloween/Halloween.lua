Halloween = inherit(Singleton)

function Halloween:constructor()
	DrawContest:new()

	self.m_EventSign = createObject(1903, 1484.80, -1710.70, 12.4, 0, 0, 90)
	self.m_EventSign:setDoubleSided(true)
end
