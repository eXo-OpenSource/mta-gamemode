SlotGame = inherit(Object)
addRemoteEvents{"onOnlineSlotmachineUse", "onOnlineSlotmachineRequest"}

SlotGame.Bonus = 1 -- public
SlotGame.RealtimeFactor = 1 -- hidden ;)


SlotGame.HighStake = false
SlotGame.Lines  = 
{
    {{1,1}, {2,2}, {3,3}, {4,2}, {5,1}}, --yellow
    {{1,3}, {2,2}, {3,1}, {4,2}, {5,3}}, -- red
    {{1,2}, {2,2}, {3,2}, {4,2}, {5,2}}, -- green #1
    {{1,1}, {2,1}, {3,1}, {4,1}, {5,1}}, -- green top
    {{1,3}, {2,3}, {3,3}, {4,3}, {5,3}}, -- green bottom
}

SlotGame.LinesWinMultiplier = 
{
    [1] = 1.2, 
    [2] = 1.2,
    [3] = 1.5,
    [4] = 1.1, 
    [5] = 1.1,

}

SlotGame.ChainCountMultiplier = 
{
    [2] = 0.25, 
    [3] = 2, 
    [4] = 3, 
    [5] = 4,
}

SlotGame.SymbolMultiplier = 
{
    [13] = 0.3, 
    [12] = 0.45, 
    [11] = 0.5,
    [10] = 0.65,
    [9] = 0.7,
    [8] = 0.8,
    [7] = 0.9, 
    [6] = 0.95,
    [5] = 1, 
    [4] = 1.2, 
    [3] = 2, 
    [2] = 2.5,
    [1] = 3, 
}

function SlotGame:constructor(object)

    self.m_BankAccountServer = BankServer.get("gameplay.computerSlotmachine")
    self.m_Rolls = {}
    self.m_Pay = 0
    self.m_TotalPaid = 0
    self.m_Player = nil
    self.m_Spinning = false
    self.m_LastPay = 0
    self.m_LastSpin = getTickCount()
    self.m_Object = object
    object:setData("clickable", true, true)
    addEventHandler("onElementClicked", object, function(button, state, player)
        if getElementData(player, "slotMachineisOpen") then return end
        if Vector3(source:getPosition()-player:getPosition()):getLength() > 3 then return end
		if button == "left" and state == "down" then
			if not self.m_Player and not player.m_OnlineSlotMachine then
				player:triggerEvent("onOnlineCasinoShow")
                self.m_Player = player
                player.m_OnlineSlotMachine = self
                if SlotGame.Bonus ~= 1 then
                    self.m_TotalPaid = 0
                    outputChatBox(("[BONUS]#FFFFFF Aktuell ist der Bonus beim Spielen bei Faktor %s"):format(SlotGame.Bonus), player, 200, 200, 0, true)
                    player:sendInfo(_("Aktuell ist der Bonus beim Spielen bei Faktor: %s!", player, SlotGame.Bonus))
                end
			else
				player:sendError(_("Der Automat ist schon in Benutzung!", player))
			end
		end
	end)
end

function SlotGame:use(data, bet)
    if bet <= 2000 or SlotGame.HighStake then
        if (getTickCount() - self.m_LastSpin) > 1000 then
            if client:transferMoney(self.m_BankAccountServer, bet, "Spielothek-Einsatz", "Gameplay", "Spielothek-Automat", {silent = true}) then
                local spin
                self.m_Spinning = true
                self.m_LastSpin = getTickCount()
                self:setup(data)
                self.m_Bet = bet or 200
                self:spin()
                self:evaluate()
                self:evaluatePay()
                local sendWin = 0
                if self.m_Pay > 0 then
                    self.m_TotalPaid = self.m_TotalPaid + self.m_Pay
                    setTimer(function() self:forcePay(self.m_Player, self.m_Pay) end, self.m_SpinTime+500, 1)
                    if self.m_Pay < self.m_Bet*2 and self.m_Pay > 0 then 
		                sendWin = 1
	                elseif self.m_Pay >= self.m_Bet*2 and self.m_Pay < self.m_Bet*4 then 
		                sendWin = 2
	                elseif self.m_Pay >= self.m_Bet*4 then
		                sendWin = 3
	                end
                end
                setTimer(function() 
                            local x, y, z = getElementPosition(self.m_Object)
                            self.m_Player:triggerEvent("onShowWinOnlineCasino");
                            self.m_Spinning = false
                            if sendWin > 1 and self.m_Bet >= 50000 then 
                                triggerClientEvent(getRootElement(), "onOnlineSlotMachineEffect", getRootElement(), sendWin, x, y, z)
                            end
                        end, 
                        self.m_SpinTime+500, 1)

                client:triggerEvent("onGetOnlineCasinoResults", self.m_Spins, self.m_WinFields, self.m_TotalPaid, self.m_Pay - self.m_LastPay)
            else 
                client:sendError(_("Du hast nicht genug Geld!", client))
            end
        end
    else 
        client:sendError(_("High-Stake Wetten sind zurzeit nicht erlaubt!", client))
    end
end

function SlotGame:requestPay(player)
    if not self.m_Spinning then
        if self.m_Player == client then 
            self.m_BankAccountServer:transferMoney(client, self.m_Pay, "Spielothek-Gewinn", "Gameplay", "Spielothek-Automat", {allowNegative = true, silent = true})
            if SlotGame.Bonus ~= 1 then 
                client:sendShortMessage(("Dir wurden $%s ausgezahlt! (Bonus-Faktor: %s)"):format(self.m_Pay, SlotGame.Bonus), "Spielothek")
            else
                client:sendShortMessage(("Dir wurden $%s ausgezahlt!"):format(self.m_Pay), "Spielothek")
            end
            self.m_Pay = 0
        end
    else 
        client:sendError(_("Warte bis es zu Ende gedreht ist!", client))
    end
end

function SlotGame:forcePay(player, amount)
    if self.m_Player == player then 
        self.m_BankAccountServer:transferMoney(player, amount, "Spielothek-Gewinn", "Gameplay", "Spielothek-Automat", {allowNegative = true, silent = true})
        if SlotGame.Bonus ~= 1 then 
            player:sendShortMessage(("Dir wurden $%s ausgezahlt! (Bonus-Faktor: %s)"):format(amount, SlotGame.Bonus), "Spielothek")
        else
            player:sendShortMessage(("Dir wurden $%s ausgezahlt!"):format(amount), "Spielothek")
        end
        self.m_Pay = 0
    end
end


function SlotGame:setup(data) 
    self.m_Rolls ={}
    for i = 1, 5 do 
        self.m_Rolls[i] = {}
        for i2 = 1, 3 do 
            self.m_Rolls[i][i2] = data[i][i2][2]
        end
    end
end

function SlotGame:spin() 
    self.m_Spins = {}
    self.m_SpinTime = 0
    for i = 1, 5 do 
        spin = math.random(2, 13*2)
        self.m_SpinTime = self.m_SpinTime + spin
        self.m_Spins[i] = spin
        for i2 = 3, 1, -1 do
            for i3 = 1, spin do 
                self.m_Rolls[i][i2] = self.m_Rolls[i][i2] - 1
                if self.m_Rolls[i][i2] < 1 then 
                    self.m_Rolls[i][i2] = 13
                end
            end
        end
    end
    self.m_SpinTime = ((self.m_SpinTime) * 50) + 200
end


function SlotGame:evaluate() 
    local chaincount = 0
    local symbol = false
    self.m_WinCount = 0
    self.m_Wins = {}
    self.m_WinFields = {}
    local insertedIndexes ={}
    for winline, data in ipairs(SlotGame.Lines) do 
        self.m_Wins[winline] = {}
        self.m_WinFields[winline] = {}
        symbol = false
        chaincount = 0
        insertedIndexes ={}
        for field, subdata in ipairs(data) do
            col, row = unpack(subdata)
            if not symbol then 
                symbol = self.m_Rolls[col][row]
                chaincount = 1
                table.insert(self.m_WinFields[winline], {col, row})
                table.insert(insertedIndexes, #self.m_WinFields[winline])
            elseif symbol == self.m_Rolls[col][row] then 
                chaincount = chaincount + 1
                table.insert(self.m_WinFields[winline], {col, row})
                table.insert(insertedIndexes, #self.m_WinFields[winline])
            else 
                if chaincount > 1 then 
                    self.m_Wins[winline][symbol] = chaincount
                    self.m_WinCount = self.m_WinCount + 1
                else 
                    for lastIndexes = 1, #insertedIndexes do -- go back and remove every marked win field
                        table.remove(self.m_WinFields[winline], insertedIndexes[lastIndexes])
                    end
                end
                chaincount = 1
                symbol = self.m_Rolls[col][row]
                insertedIndexes = {}
                table.insert(self.m_WinFields[winline], {col, row})
                table.insert(insertedIndexes, #self.m_WinFields[winline])
            end
        end
        if chaincount > 1 then 
            self.m_Wins[winline][symbol] = chaincount
            self.m_WinCount = self.m_WinCount + 1
        else 
            for lastIndexes = 1, #insertedIndexes do  -- go back and remove every marked win field
                table.remove(self.m_WinFields[winline], insertedIndexes[lastIndexes])
            end
        end
    end
end

function SlotGame:evaluatePay()
    local index, data, pay
    self.m_LastPay = self.m_Pay
    local payout = 0
    local prepayout
    if self.m_WinCount > 0 then 
        for winline, symbols in pairs(self.m_Wins) do 
            for symbol, chaincount in pairs(symbols) do 
                prepayout = math.floor((((SlotGame.SymbolMultiplier[symbol]  * SlotGame.ChainCountMultiplier[chaincount]) * SlotGame.LinesWinMultiplier[winline] * self.m_Bet) * SlotGame.RealtimeFactor) * SlotGame.Bonus) 
                if self.m_Bet >= 100000 then prepayout = prepayout*1.5 end
                payout = payout + math.floor(prepayout)
            end
        end

    end
    self.m_Pay = payout
end

function SlotGame:endPlayer(player) 
    if self.m_Player == player then 
        self.m_Player = nil 
        self.m_Pay = 0
        self.m_LastPay = 0
        self.m_TotalPaid = 0
        player.m_OnlineSlotMachine = nil
        player:triggerEvent("onOnlineCasinoHide")
    end
end

function SlotGame:destructor()

end
