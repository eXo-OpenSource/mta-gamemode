SlotGame = inherit(Object)
addRemoteEvents{"onOnlineSlotmachineUse"}

SlotGame.Lines  = 
{
    {{1,1}, {2,2}, {3,3}, {4,2}, {5,1}}, --yellow
    {{1,3}, {2,2}, {3,1}, {4,2}, {5,3}}, -- red
    {{1,1}, {2,1}, {3,1}, {4,1}, {5,1}}, -- green #2
    {{1,2}, {2,2}, {3,2}, {4,2}, {5,2}}, -- green #1
    {{1,3}, {2,3}, {3,3}, {4,3}, {5,3}},  -- green #3
}

function SlotGame:constructor(object)

    self.m_BankAccountServer = BankServer.get("gameplay.computerSlotmachine")
    self.m_UseBind = bind(self.Event_onUse, self)    
    self.m_Rolls = {}
    addEventHandler("onOnlineSlotmachineUse", root, self.m_UseBind)
end

function SlotGame:Event_onUse(data, bet)
    local spin
    self:setup(data)
    self.m_Bet = bet or 200
    self:spin()
    self:evaluate()
    self:evaluatePay()
    client:triggerEvent("onGetOnlineCasinoResults", self.m_Spins, self.m_Wins, self.m_Pay)
end

function SlotGame:Event_onClientRequestPay()

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
    self.m_Pay = 0
    for i = 1, #self.Lines do 
        if self.m_Wins[i] then
            index, data = unpack(self.m_Wins[i])
            if #data > 2 then
                self.m_Pay = self.m_Pay + (self.m_Bet * (index+i+#data))
            end
        end
    end
    return self.m_Pay
end


function SlotGame:destructor()

end
