-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/InventoryTradingManager.lua
-- *  PURPOSE:     InventoryTradingManager Class
-- *
-- ****************************************************************************

InventoryTradingManager = inherit(Singleton)
addRemoteEvents{"onClientReceiveTradingInfo", "onClientStartTrading", "onClientStopTrading", "onClientPlayerReadyTrading"}

function InventoryTradingManager:constructor()
    addEventHandler("onClientReceiveTradingInfo", resourceRoot, bind(self.onClientReceiveTradingInfo, self))
    addEventHandler("onClientStartTrading", resourceRoot, bind(self.startTrade, self))
    addEventHandler("onClientStopTrading", resourceRoot, bind(self.forceStopTrade, self))
    addEventHandler("onClientPlayerReadyTrading", resourceRoot, bind(self.onTradePartnerReady, self))
end

function InventoryTradingManager:startTrade(tradingPartner)
    self.m_TradingInfo = {["money"] = 0}
    InventoryTradingGUI:new(tradingPartner)
end

function InventoryTradingManager:forceStopTrade()
    if InventoryTradingGUI:isInstantiated() then
        delete(InventoryTradingGUI:getSingleton())
    end
end

function InventoryTradingManager:stopTrade()
    triggerServerEvent("onServerStopTrading", localPlayer)
end

function InventoryTradingManager:setTradeReady()
    triggerServerEvent("onServerPlayerReadyTrading", localPlayer)
end

function InventoryTradingManager:onTradePartnerReady()
    InventoryTradingGUI:getSingleton():onPartnerReady()
end

function InventoryTradingManager:updateTradeInfo()
    triggerServerEvent("onServerReceiveTradingInfo", localPlayer, self.m_TradingInfo)
end

function InventoryTradingManager:onClientReceiveTradingInfo(tradingInfo)
    InventoryTradingGUI:getSingleton():setRemoteData(tradingInfo)
end

function InventoryTradingManager:addMoneyToTrade(money) self.m_TradingInfo["money"] = money self:updateTradeInfo() end
function InventoryTradingManager:addItemToTrade(inventoryId, item) self.m_TradingInfo[item.Id] = item self:updateTradeInfo() end
function InventoryTradingManager:removeItemFromTrade(inventoryId, item) self.m_TradingInfo[item.Id] = nil self:updateTradeInfo() end