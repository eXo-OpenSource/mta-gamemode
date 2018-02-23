AdminEvent = inherit(Singleton)
addRemoteEvents{"adminEventPrepareClient", "adminEventSendAuctionData"}

function AdminEvent:constructor()
    addEventHandler("adminEventSendAuctionData", resourceRoot, bind(AdminEvent.sendAuctionData, self))
end

function AdminEvent:sendAuctionData(data)
    if data then
        if not self.m_AuctionMessage then
            self.m_AuctionMessage = ShortMessage:new("", "Auktionsüberseicht", Color.Accent, -1)
        end
        local bids = ""
        for i = 1, (math.min(#data.bids, 5)) do
            local v = data.bids[i]
            bids = bids .. "\n" .. toMoneyString(v[2]) .. " von " .. v[1]
        end
        self.m_AuctionMessage:setText(("Es wird %s versteigert.\nAktuelle Gebote:%s"):format(data.name, bids))
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


