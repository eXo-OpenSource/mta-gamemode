-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareButtons.lua
-- *  PURPOSE:     WareButtons class
-- *
-- ****************************************************************************
WareButtons = inherit(Object)
WareButtons.modeDesc = "Klicke der Reihe nach auf die Buttons!"
WareButtons.timeScale = 0.4

addRemoteEvents{"Ware:clientButtonPress"}

function WareButtons:constructor( super )
	self.m_Super = super
	self.m_Amount = math.random(2,4)
	self.m_LastButton = {}
	for key, player in ipairs(self.m_Super.m_Players) do
		player:triggerEvent("setWareButtonsListenerOn", self.m_Amount)
	end
	self.Event_onButtonPress = bind(self.Event_onButtonPress, self)
	addEventHandler("Ware:clientButtonPress", root, self.Event_onButtonPress)
end

function WareButtons:Event_onButtonPress(button)
	if client.bInWare then
		if client.bInWare == self.m_Super then
			if not self.m_LastButton[client] then self.m_LastButton[client] = 0 end
			if self.m_LastButton[client]+1 == button then
				self.m_LastButton[client] = button
			else
				client:triggerEvent("onClientWareFail")
				client:triggerEvent("setWareButtonsListenerOff")
				return
			end
			if self.m_LastButton[client] == self.m_Amount then
				self.m_Super:addPlayerToWinners(client)
			end
		end
	end
end

function WareButtons:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do
		p:triggerEvent("setWareButtonsListenerOff")
	end
	removeEventHandler("Ware:clientButtonPress", root, self.Event_onButtonPress)
end
