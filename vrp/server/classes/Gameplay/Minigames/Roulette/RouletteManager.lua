RouletteManager = inherit(Singleton)
RouletteManager.Map = {}

function RouletteManager:constructor()
	self.m_Stats = StatisticsLogger:getSingleton():getGameStats("Roulette")

	addRemoteEvents{"rouletteCreateNew", "rouletteSpin", "rouletteOnSpinDone", "rouletteCheatSpin", "rouletteDelete"}

	addEventHandler("rouletteCreateNew", root, bind(self.Event_createRoulette, self))
	addEventHandler("rouletteDelete", root, bind(self.Event_delete, self))

	addEventHandler("rouletteSpin", root, bind(self.Event_spinRoulette, self))
	addEventHandler("rouletteOnSpinDone", root, bind(self.Event_onSpinDone, self))

	addEventHandler("rouletteCheatSpin", root, bind(self.Event_cheatSpinRoulette, self))
end

function RouletteManager:destructor()

end

function RouletteManager:Event_delete()
	if not RouletteManager.Map[client] then return end
	delete(RouletteManager.Map[client])
	RouletteManager.Map[client] = nil
end

function RouletteManager:Event_createRoulette()
	RouletteManager.Map[client] = Roulette:new(client)
end

function RouletteManager:Event_spinRoulette(bets)
	if not RouletteManager.Map[client] then return end
	RouletteManager.Map[client]:spin(bets)
end

function RouletteManager:Event_onSpinDone(clientNumber)
	if not RouletteManager.Map[client] then return end
	RouletteManager.Map[client]:spinDone(clientNumber)
end

function RouletteManager:Event_cheatSpinRoulette(bets, target)
	if not RouletteManager.Map[client] then return end
	RouletteManager.Map[client]:cheatSpin(bets, target)
end

function RouletteManager:setStats(sum, played)
	if played then
		self.m_Stats["Played"] = self.m_Stats["Played"]+1
	end

	if sum < 0 then
		self.m_Stats["Incoming"] = self.m_Stats["Incoming"] + math.abs(sum)
	elseif sum > 0 then
		self.m_Stats["Outgoing"] = self.m_Stats["Outgoing"] + sum
	end
end
