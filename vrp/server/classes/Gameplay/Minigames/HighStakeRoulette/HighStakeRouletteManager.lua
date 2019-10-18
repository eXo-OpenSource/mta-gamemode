HighStakeRouletteManager = inherit(Singleton)
HighStakeRouletteManager.Map = {}
HIGHSTAKE_MAX_BET = 500000
setElementData(root, "HighStakeMaxBet", HIGHSTAKE_MAX_BET)

function HighStakeRouletteManager:constructor()
	self.m_Stats = StatisticsLogger:getSingleton():getGameStats("Roulette")

	local result = sql:queryFetch("SELECT * FROM ??_roulette_limits", sql:getPrefix())
	for _, row in ipairs(result) do
		RouletteManager.Limits[row["UserId"]] = {Limit=row["Limit"], Bets=0}
	end

	addRemoteEvents{"highStakeRouletteCreateNew", "highStakeRouletteSpin", "highStakeRouletteOnSpinDone", "highStakeRouletteCheatSpin", "highStakeRouletteDelete"}

	addEventHandler("highStakeRouletteCreateNew", root, bind(self.Event_createRoulette, self))
	addEventHandler("highStakeRouletteDelete", root, bind(self.Event_delete, self))

	addEventHandler("highStakeRouletteSpin", root, bind(self.Event_spinRoulette, self))
	addEventHandler("highStakeRouletteOnSpinDone", root, bind(self.Event_onSpinDone, self))

	addEventHandler("highStakeRouletteCheatSpin", root, bind(self.Event_cheatSpinRoulette, self))
end

function HighStakeRouletteManager:destructor()

end

function HighStakeRouletteManager:Event_delete()
	if not HighStakeRouletteManager.Map[client] then return end
	delete(HighStakeRouletteManager.Map[client])
	HighStakeRouletteManager.Map[client] = nil
end

function HighStakeRouletteManager:Event_createRoulette(custombank)
	HighStakeRouletteManager.Map[client] = HighStakeRoulette:new(client, custombank)
end

function HighStakeRouletteManager:Event_spinRoulette(bets)
	if not HighStakeRouletteManager.Map[client] then return end
	HighStakeRouletteManager.Map[client]:spin(bets)
end

function HighStakeRouletteManager:Event_onSpinDone(clientNumber)
	if not HighStakeRouletteManager.Map[client] then return end
	HighStakeRouletteManager.Map[client]:spinDone(clientNumber)
end

function HighStakeRouletteManager:Event_cheatSpinRoulette(bets, target)
	if not HighStakeRouletteManager.Map[client] then return end
	HighStakeRouletteManager.Map[client]:cheatSpin(bets, target)
end

function HighStakeRouletteManager:setStats(sum, played)
	if not self.m_Stats then return end -- development server fix
	if played then
		self.m_Stats["Played"] = self.m_Stats["Played"]+1
	end

	if sum < 0 then
		self.m_Stats["Incoming"] = self.m_Stats["Incoming"] + math.abs(sum)
	elseif sum > 0 then
		self.m_Stats["Outgoing"] = self.m_Stats["Outgoing"] + sum
	end
end
