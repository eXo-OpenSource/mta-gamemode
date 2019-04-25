SlotGame = inherit(Object)
addRemoteEvents{"onOnlineSlotmachineUse", "onOnlineSlotmachineRequest"}

SlotGame.Bonus = 1
SlotGame.HighStake = false
SlotGame.Lines  = 
{
    {{1,1}, {2,2}, {3,3}, {4,2}, {5,1}}, --yellow
    {{1,3}, {2,2}, {3,1}, {4,2}, {5,3}}, -- red
    {{1,2}, {2,2}, {3,2}, {4,2}, {5,2}}, -- green #1
}

function SlotGame:constructor(object)

    self.m_BankAccountServer = BankServer.get("gameplay.computerSlotmachine")
    self.m_Rolls = {}
    self.m_Pay = 0
    self.m_Player = nil
    self.m_LastPay = 0
    self.m_Object = object
    object:setData("clickable", true, true)
    addEventHandler("onElementClicked", object, function(button, state, player)
        if getElementData(player, "slotMachineisOpen") then return end
		if button == "left" and state == "down" then
			if not self.m_Player and not player.m_OnlineSlotMachine then
				player:triggerEvent("onOnlineCasinoShow")
                self.m_Player = player
                player.m_OnlineSlotMachine = self
                if SlotGame.Bonus ~= 1 then
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
        if client:transferMoney(self.m_BankAccountServer, bet, "Spielothek-Einsatz", "Gameplay", "Spielothek-Automat", {silent = true}) then
            local spin
            self:setup(data)
            self.m_Bet = bet or 200
            self:spin()
            self:evaluate()
            self:evaluatePay()
            client:triggerEvent("onGetOnlineCasinoResults", self.m_Spins, self.m_Wins, self.m_Pay, self.m_Pay - self.m_LastPay)
        else 
            client:sendError(_("Du hast nicht genug Geld!", client))
        end
    else 
        client:sendError(_("High-Stake Wetten sind zurzeit nicht erlaubt!", client))
    end
end

function SlotGame:requestPay()
    if self.m_Player == client then 
        self.m_BankAccountServer:transferMoney(client, self.m_Pay, "Spielothek-Gewinn", "Gameplay", "Spielothek-Automat", {allowNegative = true, silent = true})
        if SlotGame.Bonus ~= 1 then 
            client:sendShortMessage(("Dir wurden $%s ausgezahlt! (Bonus-Faktor: %s)"):format(self.m_Pay, SlotGame.Bonus), "Spielothek")
        else
            client:sendShortMessage(("Dir wurden $%s ausgezahlt!"):format(self.m_Pay), "Spielothek")
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
    for i = 1, 5 do 
        spin = math.random(2, 12)
        self.m_Spins[i] = spin
        for i2 = 3, 1, -1 do
            for i3 = 1, spin do 
                self.m_Rolls[i][i2] = self.m_Rolls[i][i2] - 1
                if self.m_Rolls[i][i2] < 1 then 
                    self.m_Rolls[i][i2] = 6
                end
            end
        end
    end
end

function SlotGame:evaluate() 
    local col, row
    local icon
    local strings = {}
    self.m_Wins = {}
    self.m_WinIcon = {}
    for index, data in ipairs(self.Lines) do 
        strings[index] = {}
        for subindex, subdata in ipairs(data) do 
            col, row = unpack(subdata)
            icon = self.m_Rolls[col][row]
            table.insert(strings[index], icon)
        end
    end

    local last, count, chain, done, skip
    for index, data in ipairs(strings) do
        chain = 0
        last = nil
        count = 0
        done = false
        skip = false
        for subindex, icon in ipairs(data) do 
            if not skip then
                if chain == 0 then 
                    chain = subindex
                end
                if icon == last then 
                    count = count + 1
                    if count > 1 then 
                        self.m_Wins[index] = {}
                        for iter = chain, subindex do 
                            table.insert(self.m_Wins[index], self.Lines[index][iter])
                            self.m_WinIcon[index] = icon
                        end
                        done = true
                    end
                else 
                    if not done then
                        chain = subindex
                        count = 0
                    else 
                        skip = true
                    end
                end
                last = icon
            end
        end
    end
    --[[

    --]]
end

function SlotGame:evaluatePay()
    local index, data, pay
    self.m_LastPay = self.m_Pay
    for i = 1, #self.Lines do 
        if self.m_Wins[i] then
            local x, y, z = getElementPosition(self.m_Object)
            if self.m_Bet >= 8000 then
                setTimer(function() triggerClientEvent(getRootElement(), "onSlotmachineJackpot", getRootElement(), x, y, z) end, 2000, 1)
            end
            if #self.m_Wins[i] > 2 then
                self.m_Pay = math.floor(self.m_Pay + (self.m_Bet * ((self.m_WinIcon[i]+i+#self.m_Wins[i])*0.25) * SlotGame.Bonus)) 
            end
        end
    end
end

function SlotGame:endPlayer(player) 
    if self.m_Player == player then 
        self.m_Player = nil 
        self.m_Pay = 0
        self.m_LastPay = 0
        player.m_OnlineSlotMachine = nil
        player:triggerEvent("onOnlineCasinoHide")
    end
end

function SlotGame:destructor()

end
