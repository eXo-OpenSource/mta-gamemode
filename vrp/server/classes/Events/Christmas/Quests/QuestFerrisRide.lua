QuestFerrisRide = inherit(Quest)

addEvent("onFerrisWheelRide")

function QuestFerrisRide:constructor(id)
	Quest.constructor(self, id)
	self.m_FortuneBind = bind(self.onFerrisRide, self)
	self.m_WheelPlayed = {}

	addEventHandler("onFerrisWheelRide", root, self.m_FortuneBind)
end

function QuestFerrisRide:destructor(id)
	Quest.destructor(self)
	removeEventHandler("onFerrisWheelRide", root, self.m_FortuneBind)
end

function QuestFerrisRide:addPlayer(player)
	Quest.addPlayer(self, player)
end

function QuestFerrisRide:removePlayer(player)
	Quest.removePlayer(self, player)
end

function QuestFerrisRide:onFerrisRide()
	local player = source
	if table.find(self:getPlayers(), player) then
		self:success(player)
	end
end

