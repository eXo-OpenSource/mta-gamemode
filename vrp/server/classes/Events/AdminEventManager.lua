AdminEventManager = inherit(Singleton)

function AdminEventManager:constructor()
	self.m_EventRunning = false

	self.m_EventPartic = {}

	addCommandHandler("teilnehmen", bind(self.joinEventList, self),false,false)
	addCommandHandler("eventTP", bind(self.teleportJoinList, self),false, false )
	addCommandHandler("stopEventTP", bind(self.clearTPList, self), false, false )

	addRemoteEvents{"adminEventRequestData", "adminEventToggle"}
	addEventHandler("adminEventRequestData", root, bind(self.requestData, self))
	addEventHandler("adminEventToggle", root, bind(self.toggle, self))

end

function AdminEventManager:joinEventList( source )
	if not self.m_EventPartic[source] then
		self.m_EventPartic[source] = true
		outputChatBox("Du nimmst am Event teil, warte bis du teleportiert wirst!", source, 0, 200, 0)
	else
		self.m_EventPartic[source] = true
		outputChatBox("Du nimmst nicht mehr am Event teil!", source, 200, 0 ,0)
	end
end

function AdminEventManager:clearTPList( source )
	if source:getRank() <= RANK.Supporter then return end
	self.m_EventPartic = {}
	outputChatBox("Du hast die Teleport-Liste geleert!",source, 200,200,0)
end

function AdminEventManager:toggle()
	self.m_EventRunning = not self.m_EventRunning
	self:sendData(client)
end

function AdminEventManager:requestData()
	self:sendData(client)
end

function AdminEventManager:sendData(player)
	player:triggerEvent("adminEventReceiveData", self.m_EventRunning)

end

function AdminEventManager:teleportJoinList( source )
	if source:getRank() <= RANK.Supporter then return end
	local veh
	local x,y,z = getElementPosition(source)
	local count = 0
	local int = getElementInterior(source)
	local dim = getElementDimension(source)
	for player, bool in pairs( self.m_EventPartic ) do
		if bool then
			veh = getPedOccupiedVehicle(player)
			if veh then
				removePedFromVehicle(player)
			end
			setElementDimension(player, dim)
			setElementInterior(player, int)
			setElementPosition(player, x+math.random(1,3), y+math.random(1,3),z)
			count = count + 1
		end
	end
	outputChatBox("Es wurden "..count.." teleportiert!", source, 200, 200, 200)
	self.m_EventPartic = {}
end
