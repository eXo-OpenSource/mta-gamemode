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
    PlayerManager:getSingleton():getQuitHook():register(bind(self.Event_PlayerQuit, self))
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

function SlotGameManager:Event_PlayerQuit(player) 
	for element, slotclass in pairs(SlotGameManager.Map) do 
        if slotclass.m_Player and not isElement(slotclass.m_Player) then 
            slotclass.m_Player = nil 
            slotclass.m_Pay = 0
            slotclass.m_LastPay = 0
        end
        if slotclass.m_Player == player then 
            slotclass.m_Player = nil 
            slotclass.m_Pay = 0
            slotclass.m_LastPay = 0
        end
    end
end

function SlotGameManager:destructor() 

end

function SlotGameManager:add(element)
    if not SlotGameManager.Map[element] then 
        SlotGameManager.Map[element] = SlotGame:new(element)
    end
end
