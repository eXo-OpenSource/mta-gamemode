AdminEvent = inherit(Object)

function AdminEvent:constructor()
	self.m_Players = {}
	self.m_Vehicles = {}
end

function AdminEvent:setTeleportPoint(eventManager)
	self.m_TeleportPoint = {eventManager:getPosition(), eventManager:getInterior(), eventManager:getDimension()}
	eventManager:sendInfo(_("Du hast den Event-Teleport Punkt an deine Position gesetzt!", eventManager))
end

function AdminEvent:sendGUIData(player)
	player:triggerEvent("adminEventReceiveData", true, self.m_Players)
end

function AdminEvent:joinEvent(player)
	table.insert(self.m_Players, player)
	player:sendInfo(_("Du nimmst am Admin-Event teil! Bitte warte auf weitere Anweisungen!", player))
end

function AdminEvent:teleportPlayers(eventManager)
	if not self.m_TeleportPoint then
		eventManager:sendError(_("Du hast keinen Event-Teleport Punkt gesetzt!", eventManager))
	end

	local pos, int, dim = unpack(self.m_TeleportPoint)
	local count = 0

	for index, player in pairs(self.m_Players) do
		if not player.adminEventPortet then
			if player.vehicle then removePedFromVehicle(player)	end
			player:setDimension(dim)
			player:setInterior(dim)
			player:setPosition(pos.x + math.random(1,3), pos.y + math.random(1,3), pos.z)
			count = count + 1
			player.adminEventPortet = true
		end
	end
	eventManager:sendInfo(_("Es wurden %d Spieler teleportiert!", eventManager, count))
end
