AdminEvent = inherit(Singleton)
addRemoteEvents{"adminEventPrepareClient", "adminEventSendAuctionData", "adminEventCreateBattleRoyaleTextures", "adminEventDeleteBattleRoyaleTextures", "adminEventBattleRoyaleDeath"}

function AdminEvent:constructor()
    addEventHandler("adminEventSendAuctionData", resourceRoot, bind(AdminEvent.sendAuctionData, self))
    addEventHandler("adminEventCreateBattleRoyaleTextures", root, bind(self.createTexturesForBattleRoyale, self))
    addEventHandler("adminEventDeleteBattleRoyaleTextures", root, bind(self.deleteTexturesFromBattleRoyale, self))
    addEventHandler("adminEventBattleRoyaleDeath", root, bind(self.createDeathSign, self))
end

function AdminEvent:sendAuctionData(data)
    self.m_AuctionData = data
    if data then
        if not self.m_AuctionMessage then
            self.m_AuctionMessage = ShortMessage:new("", "Auktionsübersicht", Color.Accent, -1)
        end
        local bids = ""
        for i = 1, (math.min(#data.bids, 5)) do
            local v = data.bids[i]
            bids = bids .. "\n" .. toMoneyString(v[2]) .. " von " .. v[1]
        end
        self.m_AuctionMessage:setText(("Es wird %s versteigert, du kannst mit /bieten [Betrag] ein Gebot abgeben.\nAktuelle Gebote:%s"):format(data.name, bids))
        self.m_AuctionMessage.onLeftClick = function ()
            if not self.m_AuctionData then
                self.m_AuctionMessage:delete()
                self.m_AuctionMessage = nil
            end
        end
    else
        if self.m_AuctionMessage then
            self.m_AuctionMessage:delete()
            self.m_AuctionMessage = nil
        end
    end

end

function AdminEvent.start()
    AdminEvent:new()
end
addEventHandler("adminEventPrepareClient", root, AdminEvent.start)

--EASTEREVENT: BATTLE ROYALE--

function AdminEvent:createTexturesForBattleRoyale()
    local texture = dxCreateTexture("files/images/Events/BattleRoyaleBorder.png")
    local shader = dxCreateShader("files/shader/texreplace.fx")
    dxSetShaderValue(shader, "gTexture", texture)

    engineApplyShaderToWorldTexture(shader, "sl_plazatile01")
    engineApplyShaderToWorldTexture(shader, "man_cellarfloor128")
    engineApplyShaderToWorldTexture(shader, "concretemanky")
    engineApplyShaderToWorldTexture(shader, "sl_labedingsoil")
    engineApplyShaderToWorldTexture(shader, "citywall1")
    engineSetModelLODDistance(3997, 170)
end

function AdminEvent:deleteTexturesFromBattleRoyale()
    engineRemoveShaderFromWorldTexture(shader, "sl_plazatile01")
    engineRemoveShaderFromWorldTexture(shader, "man_cellarfloor128")
    engineRemoveShaderFromWorldTexture(shader, "concretemanky")
    engineRemoveShaderFromWorldTexture(shader, "sl_labedingsoil")
    engineRemoveShaderFromWorldTexture(shader, "citywall1")
end

function AdminEvent:createDeathSign(player)
    playSound("files/audio/battleroyaledeath.ogg")
    ItemFireworkRocket:new(player:getPosition())
end