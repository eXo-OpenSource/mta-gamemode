AdminEvent = inherit(Singleton)
addRemoteEvents{"adminEventPrepareClient", "adminEventSendAuctionData"}

function AdminEvent:constructor()
    addEventHandler("adminEventSendAuctionData", resourceRoot, bind(AdminEvent.sendAuctionData, self))
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


