SlotGameManager = inherit(Singleton)

addRemoteEvents{"onOnlineSlotmachineUse", "onOnlineSlotmachineRequestPay", "onOnlineSlotMachineForceOut"}
SlotGameManager.Map = {}
function SlotGameManager:constructor() 
    self.m_UseBind = bind(self.Event_onUse, self)    
    self.m_RequestBind = bind(self.Event_onClientRequestPay, self)
    self.m_End = bind(self.Event_onClientRequestEnd, self)
    addEventHandler("onOnlineSlotmachineUse", root, self.m_UseBind)
    addEventHandler("onOnlineSlotmachineRequestPay", root, self.m_RequestBind)
    addEventHandler("onOnlineSlotMachineForceOut", root, self.m_End)
end

function SlotGameManager:Event_onUse(data, bet)
    if client.m_OnlineSlotMachine then 
        client.m_OnlineSlotMachine:use(data, bet)
    end
end

function SlotGameManager:Event_onClientRequestPay()
    if client.m_OnlineSlotMachine then 
        client.m_OnlineSlotMachine:requestPay( )
    end
end

function SlotGameManager:Event_onClientRequestEnd() 
    if client.m_OnlineSlotMachine then 
        client.m_OnlineSlotMachine:endPlayer(client)
    end
end

function SlotGameManager:destructor() 

end

function SlotGameManager:add(element)
    if not SlotGameManager.Map[element] then 
        SlotGame:new(element)
    end
end
