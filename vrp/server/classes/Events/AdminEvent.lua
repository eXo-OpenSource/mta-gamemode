AdminEvent = inherit(Object)

function AdminEvent:constructor()
	self.m_Players = {}
	self.m_Vehicles = {}
	self.m_VehiclesAmount = 0
end

function AdminEvent:setTeleportPoint(eventManager)
	self.m_TeleportPoint = {eventManager:getPosition(), eventManager:getInterior(), eventManager:getDimension()}
	eventManager:sendInfo(_("Du hast den Event-Teleport Punkt an deine Position gesetzt!", eventManager))
end

function AdminEvent:sendGUIData(player)
	player:triggerEvent("adminEventReceiveData", true, self.m_Players, self.m_Vehicles)
end

function AdminEvent:joinEvent(player)
	table.insert(self.m_Players, player)
	player:sendInfo(_("Du nimmst am Admin-Event teil! Bitte warte auf weitere Anweisungen!", player))
end

function AdminEvent:isPlayerInEvent(player)
    return table.find(self.m_Players, player)
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

function AdminEvent:createVehiclesInRow(player, amount, direction)
    local allowedDirections = {"V", "H", "L", "R"}

    if not table.find(allowedDirections, direction) then
        player:sendError(_("Ungültige Richtung! Erlaubt sind %s", player, table.concat(allowedDirections, ", ")))
        return
    end

    if not amount or not tonumber(amount) or tonumber(amount) > 20 then
        player:sendError(_("Du kannst maximal 20 Fahrzeuge estellen!", player))
        return
    end

    if not player.vehicle then
        player:sendError(_("Du musst in einem Fahrzeug sitzen!", player))
        return
    end

    local veh
    local model = player.vehicle:getModel()
    local pos = player.vehicle:getPosition()
    local rot = player.vehicle:getRotation()
    local matrix = player.vehicle:getMatrix()
    amount = tonumber(amount)

    for i=0, amount do
            if direction == "V" then pos = pos + matrix.forward*3
        elseif direction == "H" then pos = pos - matrix.forward*3
        elseif direction == "R" then pos = pos + matrix.right*3
        elseif direction == "L" then pos = pos - matrix.right*3
        end

        veh = TemporaryVehicle.create(model, pos, rot)
        veh:setFrozen(true)
        veh.m_DisableToggleHandbrake = true
        self.m_Vehicles[self.m_VehiclesAmount] = veh
        self.m_VehiclesAmount = self.m_VehiclesAmount + 1
    end
end

function AdminEvent:freezeEventVehicles(player)
    local count = 0
    for index, veh in pairs(self.m_Vehicles) do
        if veh and isElement(veh) then
            veh:setFrozen(true)
            count = count+1
        else
            self.m_Vehicles[index] = nil
        end
    end
    player:sendInfo(_("Du hast %d Event-Fahrzege gefreezt!", player, count))
end

function AdminEvent:unfreezeEventVehicles(player)
    local count = 0
    for index, veh in pairs(self.m_Vehicles) do
        if veh and isElement(veh) then
            veh:setFrozen(false)
            count = count+1
        else
            self.m_Vehicles[index] = nil
        end
    end
    player:sendInfo(_("Du hast %d Event-Fahrzege entfreezt!", player, count))
end

function AdminEvent:deleteEventVehicles(player)
    local count = 0
    for index, veh in pairs(self.m_Vehicles) do
        if veh and isElement(veh) then
            veh:destroy()
            count = count+1
        else
            self.m_Vehicles[index] = nil
        end
    end
	self.m_Vehicles = {}
	self.m_VehiclesAmount = 0
    player:sendInfo(_("Du hast %d Event-Fahrzege gelöscht!", player, count))
end
