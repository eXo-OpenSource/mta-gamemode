TransportBeggar = inherit(BeggarPed)

function TransportBeggar:constructor()
end

function TransportBeggar:acceptTransport(player)
	if self.m_Despawning then return end
	if player.vehicle and player.vehicleSeat == 0 then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		local veh = player.vehicle

		if not instanceof(veh, PermanentVehicle, true) then
			self:sendMessage(player, BeggarPhraseTypes.Decline)
			return
		end

		for seat = 1, veh.maxPassengers do
			if not veh:getOccupant(seat) then
				local pos = Randomizer:getRandomTableValue(BeggarTransportPositions)
				self:warpIntoVehicle(veh, seat)

				player:meChat(true, ("bittet %s in sein Fahrzeug"):format(self.m_Name))
				self:sendMessage(player, BeggarPhraseTypes.Destination, getZoneName(pos.x, pos.y, pos.z))
				player.beggarTransportVehicle = veh
				player.beggarTransportStartPos = player.position
				player.beggarTransportMarker = createMarker(pos, "cylinder", 2)
				player.beggarTransportMarker.player = player
				setElementVisibleTo(player.beggarTransportMarker, root, false)
				setElementVisibleTo(player.beggarTransportMarker, player, true)

				player.beggarTransportBlip = Blip:new("Marker.png", pos.x, pos.y, player, 9999, BLIP_COLOR_CONSTANTS.Red)
				player.beggarTransportBlip:setDisplayText(("Ziel von %s"):format(self.m_Name))
				if self.m_ColShape then self.m_ColShape:destroy() end

				self.m_onTransportExitBind = bind(self.onTransportExit, self)
				self.m_onTransportDestroyBind = bind(self.onTransportDestroy, self)

				addEventHandler("onVehicleExit", veh, self.m_onTransportExitBind)
				addEventHandler("onVehicleDestroy", veh, self.m_onTransportDestroyBind)

				addEventHandler("onMarkerHit", player.beggarTransportMarker, function(hitElement, dim)
					if hitElement:getType() == "player" and dim and source.player == hitElement then
						local player = hitElement
						if player.vehicle and veh:getOccupant(seat) == self then
							local distance = getDistanceBetweenPoints3D(player.beggarTransportStartPos, player.position)/1000
							player:giveCombinedReward("Bettler-Transport", {
								karma = math.ceil(5*distance),
								points = math.ceil(7*distance),
							})
							player:meChat(true, ("lässt %s aus seinem Fahrzeug"):format(self.m_Name))
							self:sendMessage(player, BeggarPhraseTypes.Thanks)
							self:deleteTransport(player)
							return
						else
							player:sendError(_("Du hast den Bettler nicht dabei", player))

						end
					end
				end)

				return
			end
		end

		player:sendError(_("Dein Fahrzeug hat keinen freien Sitzplatz!", player))
		return

	else
		player:sendError(_("Du sitzt in keinem Fahrzeug!", player))
	end
end

function TransportBeggar:onTransportExit(exitPlayer)
	if exitPlayer.beggarTransportMarker or exitPlayer == self then
		exitPlayer:sendError(_("Bettler-Transport fehlgeschlagen", exitPlayer))
		self:deleteTransport(exitPlayer)
	end
end

function TransportBeggar:onTransportDestroy()
	local player = vehicle:getOccupant()
	player:sendError(_("Bettler-Transport fehlgeschlagen", player))
	self:deleteTransport(player)
end

function TransportBeggar:deleteTransport(player)
	local veh = player.beggarTransportVehicle
	removeEventHandler("onVehicleExit", veh, self.m_onTransportExitBind)
	removeEventHandler("onVehicleDestroy", veh, self.m_onTransportExitBind)

	player.beggarTransportMarker:destroy()
	delete(player.beggarTransportBlip)

	self:removeFromVehicle()
	setTimer(function() self:despawn() end, 50, 1)
end
