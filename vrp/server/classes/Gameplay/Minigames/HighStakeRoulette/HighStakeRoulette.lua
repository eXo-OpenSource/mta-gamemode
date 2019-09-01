HighStakeRoulette = inherit(Object)

function HighStakeRoulette:constructor(player, custombank)
    self.m_Player = player
    self.m_Player:triggerEvent("highStakeRouletteOpen")
    self.m_Player:setFrozen(true)
    if custombank then 
        self.m_BankAccountServer = BankServer.get(custombank)
    else
        self.m_BankAccountServer = BankServer.get("gameplay.highstakeroulette") 
    end
end

function HighStakeRoulette:destructor()
	self.m_Player:setFrozen(false)
    self.m_Player:triggerEvent("highStakeRouletteClose")
end

function HighStakeRoulette:spin(bets)
    self.m_Bets = bets
	local bet = self:calcBet()

	if (bet > HighStakeRouletteManager.MaxBet)  then
        self.m_Player:sendError(_("Maximal-Einsatz überschritten! (%s)", self.m_Player, toMoneyString(HighStakeRouletteManager.MaxBet)))
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

    self.m_Player:transferMoney(self.m_BankAccountServer, bet, "High-Stake Roulette-Einsatz", "Gameplay", "Roulett")
    PlayHouse:getSingleton():onPlayerMoney(self.m_Player, -bet)
	HighStakeRouletteManager:getSingleton():setStats(-bet, true)
	self.m_Random = math.random(0, 36)
	self.m_Player:triggerEvent("highStakeRouletteStartSpin", self.m_Random)
end

--[[
function Roulette:cheatSpin(bets, target)
    self.m_Bets = bets
    self.m_Random = target
	self.m_Player:triggerEvent("rouletteStartSpin", self.m_Random)
end
]]

function HighStakeRoulette:spinDone(clientNumber)
    if not self.m_Random or not clientNumber == self.m_Random then
        outputChatBox("Server: CHEATER!!!", self.m_Player)
        return false
    end

    if not self.m_Bets then
		self.m_Player:sendError(_("Du hast nichts gesetzt!", self.m_Player))
        return false
    end

    local win = 0
    local winFields = {}
    for field, tokens in pairs(self.m_Bets) do
        if table.find(ROULETTE_WINNUMBERS[field], self.m_Random) then
            win = win + self:calcBetWinOnField(field) + self:calcBetOnField(field)
            if self:calcBetWinOnField(field) > 0 then 
                table.insert(winFields, field)
            end 
            --outputChatBox("Einsatz aus Feld "..field.." "..self:calcBetOnField(field).."$", self.m_Player)
            --outputChatBox("Gewinn aus Feld "..field.." "..self:calcBetWinOnField(field).."$", self.m_Player)
        end
    end
    local winString = "["
    for i = 1, #winFields do 
        if i == #winFields then
            winString = winString .. winFields[i] .. "]"
        else 
            winString = winString .. winFields[i] .. " & "
        end
    end

	if win > 0 then
		self.m_Player:sendShortMessage(_("Du hast %s gewonnen!", self.m_Player, toMoneyString(win)), "Roulette")
        self.m_BankAccountServer:transferMoney(self.m_Player, win, "Roulette-Gewinn "..winString , "Gameplay", "Roulett")
        PlayHouse:getSingleton():onPlayerMoney(self.m_Player, win)
		HighStakeRouletteManager:getSingleton():setStats(win, false)
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

function HighStakeRoulette:calcBetWinOnField(field)
    local total = 0
    if self.m_Bets[field] then
        for color, amount in pairs(self.m_Bets[field]) do
            total = total + ROULETTE_TOKENS[color] * amount * ROULETTE_WIN_MULTIPLIKATOR[field]
        end
    end
    return total
end

function HighStakeRoulette:calcBetOnField(field)
    local total = 0
    if self.m_Bets[field] then
        for color, amount in pairs(self.m_Bets[field]) do
            total = total + ROULETTE_TOKENS[color]*amount
        end
    end
    return total
end

function HighStakeRoulette:calcBet()
    local total = 0
    for field, fieldElement in pairs(self.m_Bets) do
        total = total + self:calcBetOnField(field)
    end
    return total
end
