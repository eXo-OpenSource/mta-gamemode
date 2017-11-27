QuestSantaKill = inherit(Quest)

QuestSantaKill.Positions = {
	{2170.53, -110.03, 3.26},
	{2037.72, -23.08, 1.77},
	{1926.29, 163.61, 42.64},
	{1791.63, -453.51, 83.32},
	{-558.92, -1486.90, 22.23},
	{420.09, -1751.28, 6.79},
	{-971.37, -2251.21, 51.64},
	{-144.36, -2457.85, 36.37},
	{-265.66, -2222.73, 28.64},
	{-1447.38, -1470.68, 101.76},
	{ -1888.98, -1688.01, 23.02},
	{-2154.63, -2449.41, 33.90},
	{ -2243.97, -2795.57, 11.31},
	{-1354.82, 2048.56, 52.52},
	{ -1273.64, 2723.18, 50.27,},
	{-2912.11, 1040.22, 36.29},
	
}

function QuestSantaKill:constructor(id)
	self.m_KilledSantas = { }
	Quest.constructor(self, id)

	self.m_KillSantaBind = bind(self.Event_onSantaKilled, self)

	addRemoteEvents{"onQuestSantaKilled"}
	addEventHandler("onQuestSantaKilled", root, self.m_KillSantaBind)
end

function QuestSantaKill:destructor(id)
	Quest.destructor(self)
	removeEventHandler("onQuestSantaKilled", root, self.m_KillSantaBind)
end

function QuestSantaKill:addPlayer(player)
	self.m_KilledSantas[getPlayerName(player)] = 0
	Quest.addPlayer(self, player)
	player:triggerEvent("onQuestSantaKillStart", QuestSantaKill.Positions)
end

function QuestSantaKill:Event_onSantaKilled( )

	local santaCount = self.m_KilledSantas[getPlayerName(client)]
	santaCount = santaCount + 1
	if santaCount >= 3 then
		client:sendSuccess(_("Glückwunsch! Du hast alle Kobolde getötet!", client))
		self:success(client)
		return
	else 
		self.m_KilledSantas[getPlayerName(client)] = self.m_KilledSantas[getPlayerName(client)] + 1
		client:sendSuccess(_("Noch "..(3-santaCount).." Einbrecher müssen getötet werden!", client))
	end

end
