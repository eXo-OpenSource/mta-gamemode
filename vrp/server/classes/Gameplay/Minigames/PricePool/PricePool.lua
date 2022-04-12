-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/PricePool/PricePool.lua
-- *  PURPOSE:     PricePool class
-- *
-- ****************************************************************************

PricePool = inherit(Object)

function PricePool:constructor(id, name, entryPrice, raffleDate, priceTable)
    self.m_Id = id
    self.m_Name = name
    self.m_EntryPrice = entryPrice
    self.m_RaffleDate = raffleDate
    self.m_Prices = priceTable
    self.m_EntryBuyCallback = false
    self.m_DailyEntryBuyLimit = false
    self.m_AdminsAllowedToWin = false
    self.m_Active = true
    self.m_Entries = {}
    self.m_TodaysEntries = {}

    self:addRaffleCountdown()
end

function PricePool:destructor()
    self:saveEntries()
end

function PricePool:createPed(id, position, rotation)
    self.m_Ped = NPC:new(id, position.x, position.y, position.z, rotation)
	self.m_Ped:setImmortal(true)
    self.m_Ped:setData("clickable", true, true)
    self.m_Ped:setFrozen(true)
    ElementInfo:new(self.m_Ped, "NPC", 1.2, "DoubleDown", true)
    addEventHandler("onElementClicked", self.m_Ped, function(button, state, player)
        if button == "left" and state == "down" then
            PricePoolManager:getSingleton():openEntryWindow(self, player, self.m_Active)
        end
    end)
end

function PricePool:getName()
    return self.m_Name
end

function PricePool:getEntryPrice()
    return self.m_EntryPrice
end

function PricePool:getRaffleDate()
    return self.m_RaffleDate
end

function PricePool:getPriceList()
    return self.m_Prices
end

function PricePool:getDailyEntryBuyLimit()
    return self.m_DailyEntryBuyLimit
end

function PricePool:setDailyEntryBuyLimit(limit)
    self.m_DailyEntryBuyLimit = limit
end

function PricePool:addBuyCallback(callback)
    self.m_EntryBuyCallback = callback
end

function PricePool:getTodaysEntryAmount(id)
    return self.m_TodaysEntries[id] or 0
end

function PricePool:addEntry(playerId, amount, isEntryLoading)
    if not self.m_Entries[playerId] then
        self.m_Entries[playerId] = {entries = 0, name = Account.getNameFromId(playerId)}
    end
    if not self.m_TodaysEntries[playerId] then
        self.m_TodaysEntries[playerId] = 0
    end
    self.m_Entries[playerId].entries = self.m_Entries[playerId].entries + amount

    if not isEntryLoading and self.m_EntryBuyCallback then
        self.m_EntryBuyCallback(playerId, amount)
        self.m_TodaysEntries[playerId] = self.m_TodaysEntries[playerId] + amount
    end
end

function PricePool:addEntries(entryTable, isEntryLoading)
    for playerId, amount in pairs(entryTable) do
        self:addEntry(playerId, amount, isEntryLoading)
    end
end

function PricePool:getEntryAmount()
    local entryAmount = 0
    for playerId, entry in pairs(self.m_Entries) do
        entryAmount = entryAmount + entry.entries
    end
    return entryAmount
end

function PricePool:getEntriesByName()
    local entryTable = {}
    for playerId, entry in pairs(self.m_Entries) do
        entryTable[entry.name] = entry.entries
    end
    return entryTable
end

function PricePool:saveEntries()
    for playerId, entry in pairs(self.m_Entries) do
        sql:queryExec("INSERT INTO ??_pricepool_entries (PoolId, UserId, Entries) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE Entries = ?", sql:getPrefix(), self.m_Id, playerId, entry.entries, entry.entries)
    end
end

function PricePool:addRaffleCountdown()
    if getRealTime(self.m_RaffleDate).monthday == getRealTime().monthday then
        if getRealTime(self.m_RaffleDate).month == getRealTime().month then
            if getRealTime(self.m_RaffleDate).year == getRealTime().year then
                local hour = getRealTime(self.m_RaffleDate).hour
                local minute = getRealTime(self.m_RaffleDate).minute
                GlobalTimer:getSingleton():registerEvent(bind(self.onCountdownExpire, self), ("PricePoolRaffleTimer:%s"):format(self.m_Id), nil, hour, minute)
            end
        end
    end
end

function PricePool:getWinner(entryTable)
    local totalEntries = 0
    for playerId, entry in pairs(entryTable) do
        totalEntries = totalEntries + entry.entries
    end

    local admins = {}

    if not DEBUG and not self.m_AdminsAllowedToWin then
        local result = sql:queryFetch("SELECT Id, Name FROM ??_account WHERE Rank > 1", sql:getPrefix())
        for key, row in pairs(result) do
            admins[row.Id] = true
        end
    end

    local winner

    repeat
        local random = math.random(1, totalEntries)
        local entryAmount = 0
        for playerId, entry in pairs(entryTable) do
            entryAmount = entryAmount + entry.entries
            if random <= entryAmount then
                winner = playerId
                break
            end
        end
    until not admins[winner]

    return winner
end

function PricePool:raffle()
    self:saveEntries()

    local draws = {}
    local entryTable = table.deepcopy(self.m_Entries)

    for key, priceTable in pairs(self.m_Prices) do
        local priceType = priceTable[1]
        local priceIndexOrAmount = priceTable[2]

        local winner = self:getWinner(entryTable)
        local players = {}
        for player, entry in pairs(entryTable) do
            players[#players+1] = entry.name
        end
        table.insert(draws, {winner, players, entryTable[winner].entries, priceTable})
        self.m_Prices[key][3] = entryTable[winner].name

        entryTable[winner] = nil
    end
    
    return draws
end

function PricePool:onCountdownExpire()
    local winners = self:raffle()
    local firstWinner = winners[1]

    table.remove(winners, 1)
    self:presentWinner(firstWinner)

    local index = 1
    for key, winner in pairs(winners) do
        setTimer(function() self:presentWinner(winner) end, 25000*index, 1)
        index = index + 1
    end

    self.m_Active = false
    sql:queryExec("UPDATE ??_pricepools SET Active = 0 WHERE Id = ?", sql:getPrefix(), self.m_Id)
end

function PricePool:presentWinner(winnerTable)
    local winner = winnerTable[1]
    local players = winnerTable[2]
    local entries = winnerTable[3]
    local winType = winnerTable[4][1]
    local winIndex = winnerTable[4][2]
    local price = ""

    if winType == "vehicle" then
        price = VehicleCategory:getSingleton():getModelName(winIndex)
    elseif winType == "money" then
        price = ("%d$"):format(winIndex)
    elseif winType == "points" then
        price = ("%d Punkte"):format(winIndex)
    else
        price = ("%dx %s"):format(winIndex, winType)
    end

    StatisticsLogger:getSingleton():addPricePoolLog(self.m_Id, winner, entries, self.m_EntryPrice, price)
    
    local winnerName = self.m_Entries[winner].name
    for key, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
        player:triggerEvent("openPricePoolRaffleWindow", self.m_Id, players, winnerName, price)
    end
end