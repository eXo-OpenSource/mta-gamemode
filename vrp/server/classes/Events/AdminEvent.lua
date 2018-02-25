AdminEvent = inherit(Object)

function AdminEvent:constructor()
	self.m_Players = {}
    self.m_Vehicles = {}
    self.m_AuctionsPerEvent = {}
    self.m_VehiclesAmount = 0
end

function AdminEvent:setTeleportPoint(eventManager)
	self.m_TeleportPoint = {eventManager:getPosition(), eventManager:getInterior(), eventManager:getDimension()}
	eventManager:sendInfo(_("Du hast den Event-Teleport Punkt an deine Position gesetzt!", eventManager))
end

function AdminEvent:sendGUIData(player)
	player:triggerEvent("adminEventReceiveData", true, self.m_Players, self.m_Vehicles, self.m_CurrentAuction)
end

function AdminEvent:joinEvent(player)
	table.insert(self.m_Players, player)
    player:sendInfo(_("Du nimmst am Admin-Event teil! Bitte warte auf weitere Anweisungen!", player))
    player:triggerEvent("adminEventPrepareClient")
    if self.m_CurrentAuction then
        triggerClientEvent(player, "adminEventSendAuctionData", resourceRoot, self.m_CurrentAuction)
    end
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

function AdminEvent:startAuction(player, name)
    if not self.m_CurrentAuction then
        self.m_CurrentAuction = {
            name = name,
            bids = {},
        }
        triggerClientEvent(self.m_Players, "adminEventSendAuctionData", resourceRoot, self.m_CurrentAuction)
        triggerClientEvent(self.m_Players, "infoBox", resourceRoot, "Eine neue Auktions-Runde wurde gestartet.")
        Admin:getSingleton():sendShortMessage(_("%s hat eine Auktions-Runde für %s gestartet!", player, player:getName(), name))
    else
        player:sendError(_("Es läuft bereits eine Auktion!", player))
    end
end

function AdminEvent:registerBid(player, bid)
    if self.m_CurrentAuction then
        if not self.m_CurrentAuction.bids[1] or bid > self.m_CurrentAuction.bids[1][2] then
            QuestionBox:new(player, player, ("Achtung bindend! Willst du wirklich %s auf %s bieten? (Es folgen administrative Strafen, wenn du nach der Auktion nicht bezahlen kannst)"):format(toMoneyString(bid), self.m_CurrentAuction.name), function(player, bid)
                if self.m_CurrentAuction then
                    if not self.m_CurrentAuction.bids[1] or bid > self.m_CurrentAuction.bids[1][2] then
                        local updated = false
                        for i,v in ipairs(self.m_CurrentAuction.bids) do
                            if v[1] == player:getName() then
                                self.m_CurrentAuction.bids[i] = {player:getName(), bid}
                                updated = true
                                break;
                            end
                        end
                        if not updated then
                            table.insert(self.m_CurrentAuction.bids, {player:getName(), bid})
                        end
                
                        table.sort(self.m_CurrentAuction.bids, function(a,b)
                            return a[2] > b[2]
                        end)
                        
                        player:sendSuccess(_("Du hast %s auf %s geboten und bist somit Höchstbietender!", player, toMoneyString(bid), self.m_CurrentAuction.name))
                        triggerClientEvent(self.m_Players, "adminEventSendAuctionData", resourceRoot, self.m_CurrentAuction)
                    else
                        player:sendError(_("Dein Gebot ist zu tief, das Höchstgebot für %s liegt bei %s!", player, self.m_CurrentAuction.name, toMoneyString(bid)))
                    end
                else
                    player:sendError(_("Es läuft keine Auktion!", player))
                end
            end, false, player, bid)
        else
            player:sendError(_("Dein Gebot ist zu tief, das Höchstgebot für %s liegt bei %s!", player, self.m_CurrentAuction.name, toMoneyString(bid)))
        end
    else
        player:sendError(_("Es läuft keine Auktion!", player))
    end
end

function AdminEvent:removeHighestBid(admin)
    if self.m_CurrentAuction then
        if self.m_CurrentAuction.bids[1] then
            table.remove(self.m_CurrentAuction.bids, 1)
            triggerClientEvent(self.m_Players, "adminEventSendAuctionData", resourceRoot, self.m_CurrentAuction)
            Admin:getSingleton():sendShortMessage(_("%s hat das höchste Gebot entfernt!", admin, admin:getName()))
        else
            admin:sendError(_("Es gibt noch keine Gebote!", admin))
        end
    else
        admin:sendError(_("Es läuft keine Auktion!", admin))
    end
end

function AdminEvent:stopAuction(admin)
    if self.m_CurrentAuction then
        local msg = ""
        local name, bid = "niemand", 0
        if self.m_CurrentAuction.bids[1] then
            name, bid = self.m_CurrentAuction.bids[1][1], self.m_CurrentAuction.bids[1][2]
            msg = ("Der Aufruf für %s ist beendet, Höchstbietender ist %s mit %s!"):format(self.m_CurrentAuction.name, name, toMoneyString(bid))
        else
            msg = ("Der Aufruf für %s ist beendet, das Gut wurde nicht versteigert!"):format(self.m_CurrentAuction.name)
        end
        for index, player in pairs(self.m_Players) do
			player:sendInfo(msg)
		end
        Admin:getSingleton():sendShortMessage(_("%s hat den Aufruf für %s beendet!", admin, admin:getName(), self.m_CurrentAuction.name))
        table.insert(self.m_AuctionsPerEvent, {self.m_CurrentAuction.name, name, bid})
        self.m_CurrentAuction = nil
        triggerClientEvent(self.m_Players, "adminEventSendAuctionData", resourceRoot, self.m_CurrentAuction)
    else
        admin:sendError(_("Es läuft keine Auktion!", admin))
    end
end


function AdminEvent:outputAuctionDataToPlayer(player)
    if isElement(player) and getElementType(player) == "player" then
        for i,v in ipairs(self.m_AuctionsPerEvent) do
            outputConsole(inspect(v), player)
        end
    end

end