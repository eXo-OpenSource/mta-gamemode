Roulette = inherit(Object)

function Roulette:constructor(player)
    self.m_Player = player
    self.m_Player:triggerEvent("rouletteOpen")
    self.m_Player:setFrozen(true)
    self.m_BankAccountServer = BankServer.get("gameplay.roulett")   
    if not RouletteManager.Bets[player:getId()] then RouletteManager.Bets[player:getId()] = 0 end
end

function Roulette:destructor()
	self.m_Player:setFrozen(false)
    self.m_Player:triggerEvent("rouletteClose")
end

function Roulette:spin(bets)
    self.m_Bets = bets
	local bet = self:calcBet()

	if bet > ROULETTE_MAX_BET then
        self.m_Player:sendError(_("Maximal-Einsatz überschritten! (%s)", self.m_Player, toMoneyString(ROULETTE_MAX_BET)))
        self.m_Bets = nil
        return
    elseif bet == 0 then
		self.m_Player:sendError(_("Du hast nichts gesetzt!", self.m_Player))
        self.m_Bets = nil
        return
	end

	if self.m_Player:getMoney() < bet then
		self.m_Player:sendError(_("Du hast nicht genug Geld für deinen Einsatz dabei!", self.m_Player))
		self.m_Bets = nil
		return false
	end
    RouletteManager.Bets[self.m_Player:getId()] = RouletteManager.Bets[self.m_Player:getId()] + bet
    self.m_Player:transferMoney(self.m_BankAccountServer, bet, "Roulette-Einsatz", "Gameplay", "Roulett")
	RouletteManager:getSingleton():setStats(-bet, true)
	self.m_Random = math.random(0, 36)
	self.m_Player:triggerEvent("rouletteStartSpin", self.m_Random)
end

--[[
function Roulette:cheatSpin(bets, target)
    self.m_Bets = bets
    self.m_Random = target
	self.m_Player:triggerEvent("rouletteStartSpin", self.m_Random)
end
]]

function Roulette:spinDone(clientNumber)
    if not self.m_Random or not clientNumber == self.m_Random then
        outputChatBox("Server: CHEATER!!!", self.m_Player)
        return false
    end

    if not self.m_Bets then
		self.m_Player:sendError(_("Du hast nichts gesetzt!", self.m_Player))
        return false
    end

    local win = 0
    for field, tokens in pairs(self.m_Bets) do
        if table.find(ROULETTE_WINNUMBERS[field], self.m_Random) then
            win = win + self:calcBetWinOnField(field) + self:calcBetOnField(field)
            --outputChatBox("Einsatz aus Feld "..field.." "..self:calcBetOnField(field).."$", self.m_Player)
            --outputChatBox("Gewinn aus Feld "..field.." "..self:calcBetWinOnField(field).."$", self.m_Player)
        end
    end

	if win > 0 then
		self.m_Player:sendShortMessage(_("Du hast %s gewonnen!", self.m_Player, toMoneyString(win)), "Roulette")
        self.m_BankAccountServer:transferMoney(self.m_Player, win, "Roulette-Gewinn", "Gameplay", "Roulett")
		RouletteManager:getSingleton():setStats(win, false)
	else
		self.m_Player:sendShortMessage(_("Du hast nichts gewonnen!", self.m_Player), "Roulette")
	end

	--[[
	--local bet = self:calcBet()
		local real = win-bet
		outputChatBox("Du hast insgesamt "..win.."$ gewonnen!", self.m_Player)
		if real > 0 then
			outputChatBox("Real-Gewinn: "..real.."$", self.m_Player, 0, 255, 0)
		elseif real < 0 then
			outputChatBox("Du hast insgesamt "..math.abs(real).."$ verloren!", self.m_Player, 255, 0, 0)
		else
			outputChatBox("Du bist mit 0$ Verlust/Gewinn ausgestiegen!", self.m_Player, 255, 125, 0)
		end
	]]
    self.m_Random = nil
    self.m_Bets = nil
end

function Roulette:calcBetWinOnField(field)
    local total = 0
    if self.m_Bets[field] then
        for color, amount in pairs(self.m_Bets[field]) do
            total = total + ROULETTE_TOKENS[color] * amount * ROULETTE_WIN_MULTIPLIKATOR[field]
        end
    end
    return total
end

function Roulette:calcBetOnField(field)
    local total = 0
    if self.m_Bets[field] then
        for color, amount in pairs(self.m_Bets[field]) do
            total = total + ROULETTE_TOKENS[color]*amount
        end
    end
    return total
end

function Roulette:calcBet()
    local total = 0
    for field, fieldElement in pairs(self.m_Bets) do
        total = total + self:calcBetOnField(field)
    end
    return total
end
