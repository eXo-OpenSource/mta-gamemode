-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/InventoryTradingManager.lua
-- *  PURPOSE:     InventoryTradingManager Class
-- *
-- ****************************************************************************

InventoryTradingManager = inherit(Singleton)
addRemoteEvents{"onServerReceiveTradingInfo", "onServerRequestTrade", "onServerStartTrade", "onServerStopTrade", "onServerPlayerReadyTrading"}

function InventoryTradingManager:constructor()
    self.m_TradingSessions = {} --{ Player1, Player2 }
    addEventHandler("onServerReceiveTradingInfo", resourceRoot, bind(self.onServerReceiveTradingInfo, self))
    addEventHandler("onServerRequestTrade", resourceRoot, bind(self.requestTrade, self))
    addEventHandler("onServerStartTrade", resourceRoot, bind(self.startTrade, self))
    addEventHandler("onServerStopTrade", resourceRoot, bind(self.stopTrade, self))
    addEventHandler("onServerPlayerReadyTrading", resourceRoot, bind(self.onPlayerReady, self))

    Player.getQuitHook():register(bind(self.onPlayerQuit, self))
end

function InventoryTradingManager:onServerReceiveTradingInfo(tradingInfo)
    if self:isPlayerTrading(client) then
        local sessionId = self:getPlayerTradingSessionId(client)
        local tradingPartner = self:getPlayerTradingPartner(client)

        self.m_TradingSessions[sessionId][client] = {ready = false, tradingInfo = tradingInfo}

        tradingPartner:triggerEvent("onClientReceiveTradingInfo", tradingInfo)
    end
end

function InventoryTradingManager:isPlayerTrading(player)
    for key, session in pairs(self.m_TradingSessions) do
        if session[1] == player or session[2] == player then
            return true
        end
    end
    return false
end

function InventoryTradingManager:getPlayerTradingPartner(player)
    for key, session in pairs(self.m_TradingSessions) do
        if session[1] == player then
            return session[2]
        elseif session[2] == player then
            return session[1]
        end
    end
    return false
end

function InventoryTradingManager:getTradingPartners(sessionId)
    if self.m_TradingSessions[sessionId] then
        local traders = {}
        for trader, tradingInfo in pairs(self.m_TradingSessions[sessionId]) do
            table.insert(traders, trader)
        end
        return traders
    end
    return false
end

function InventoryTradingManager:getPlayerTradingSessionId(player)
    for key, session in pairs(self.m_TradingSessions) do
        if session[1] == player or session[2] == player then
            return key
        end
    end
    return false
end

function InventoryTradingManager:requestTrade(player)
    ShortMessageQuestion:new(client, player, _("%s möchte mit Dir handeln!", player, client:getName()), bind(self.startTrade, self), false, Color.Red, client, player)
end

function InventoryTradingManager:startTrade(player1, player2)
    if not self:isPlayerTrading(player1) and not self:isPlayerTrading(player2) then
        table.insert(self.m_TradingSessions, {player1 = {}, player2 = {}})

        player1:triggerEvent("onClientStartTrading", player2)
        player2:triggerEvent("onClientStartTrading", player1)
    end
end

function InventoryTradingManager:stopTrade()
    if self:isPlayerTrading(client) then
        local sessionId = self:getPlayerTradingSessionId(client)
        local tradingPartner = self:getPlayerTradingPartner(client)

        client:triggerEvent("onClientStopTrading")
        tradingPartner:triggerEvent("onClientStopTrading")
    end
end

function InventoryTradingManager:onPlayerQuit(player)
    if self:isPlayerTrading(player) then
        local sessionId = self:getPlayerTradingSessionId(player)
        local tradingPartner = self:getPlayerTradingPartner(player)

        self.m_TradingSessions[sessionId] = nil
        tradingPartner:triggerEvent("onClientStopTrading")
        tradingPartner:sendError(_("%s hat die Verbindung getrennt! Der Handel wurde abgebrochen!", tradingPartner, player:getName()))
    end
end

function InventoryTradingManager:onPlayerReady()
    if self:isPlayerTrading(client) then
        local sessionId = self:getPlayerTradingSessionId(client)
        local tradingPartner = self:getPlayerTradingPartner(client)
        if self.m_TradingSessions[sessionId][tradingPartner].ready then
            local success, error = self:trade(sessionId)
            if success then
                client:sendSuccess(_("Handel erfolgreich!", client))
                tradingPartner:sendSuccess(_("Handel erfolgreich!", tradingPartner))
            else
                error:sendError(_("Du hast nicht genug Platz im Inventar oder nicht genug Geld!", error))
                local partner = error == client and tradingPartner or client
                partner:sendError(_("%s hat nicht genug Platz im Inventar oder nicht genug Geld!", partner, error:getName()))
            end
            self.m_TradingSessions[sessionId] = nil
            client:triggerEvent("onClientStopTrading")
            tradingPartner:triggerEvent("onClientStopTrading")
        else
            tradingPartner:triggerEvent("onClientPlayerReadyTrading")
        end
    end
end

function InventoryTradingManager:trade(sessionId)
    if self.m_TradingSessions[sessionId] then
        local trader1 = self:getTradingPartners(sessionId)[1]
        local money1 = self.m_TradingSessions[sessionId][trader1].tradingInfo["money"]
        self.m_TradingSessions[sessionId][trader1].tradingInfo["money"] = nil
        local info1 = self.m_TradingSessions[sessionId][trader1].tradingInfo
        local inventorySlots1 = InventoryManager:getSingleton():getFreeSlots(trader1:getInventory())

        local trader2 = self:getTradingPartners(sessionId)[2]
        local money2 = self.m_TradingSessions[sessionId][trader2].tradingInfo["money"]
        self.m_TradingSessions[sessionId][trader2].tradingInfo["money"] = nil
        local info2 = self.m_TradingSessions[sessionId][trader2].tradingInfo
        local inventorySlots2 = InventoryManager:getSingleton():getFreeSlots(trader2:getInventory())

        if #inventorySlots1 >= #info1 and trader1:getMoney() >= money1 then
            if #inventorySlots2 >= #info2 and trader2:getMoney() >= money2 then
                for itemId, item in pairs(info1) do
                    local slot = table.remove(inventorySlots1, 1)
                    InventoryManager:getSingleton():moveItem(trader1:getInventory():getId(), itemId, trader2:getInventory():getId(), slot)
                end
                trader1:transferMoney(trader2, money1, ("Handel mit %s"):format(trader2:getName()), "Inventory", "Trade")

                for itemId, item in pairs(info2) do
                    local slot = table.remove(inventorySlots2, 1)
                    InventoryManager:getSingleton():moveItem(trader2:getInventory():getId(), itemId, trader1:getInventory():getId(), slot)
                end
                trader2:transferMoney(trader1, money2, ("Handel mit %s"):format(trader1:getName()), "Inventory", "Trade")

                return true
            else
                return false, trader2
            end
        else
            return false, trader1
        end
    end
    return false
end