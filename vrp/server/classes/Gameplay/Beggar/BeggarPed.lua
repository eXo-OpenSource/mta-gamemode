BeggarPed = inherit(Object)

function BeggarPed:new(id, position, rotation, ...)
    local ped = Ped.create(Randomizer:getRandomTableValue(BeggarSkins), position, rotation.z)
    enew(ped, self, id, ...)
	addEventHandler("onPedWasted", ped, bind(self.Event_onPedWasted, ped))

    return ped
end

function BeggarPed:constructor(id, roles)
	self.m_Id = id
	self.m_Name = Randomizer:getRandomTableValue(BeggarNames)
	self.m_ColShape = createColSphere(self:getPosition(), 10)
	self.m_Type = #roles > 0 and Randomizer:getRandomTableValue(roles) or math.random(1, #BeggarTypeNames)
	self.m_RoleName = BeggarTypeNames[self.m_Type]

	self.m_LastRobTime = 0

	addEventHandler("onColShapeHit", self.m_ColShape, bind(self.Event_onColShapeHit, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.Event_onColShapeLeave, self))

	if chance(50) then
		local animation = Randomizer:getRandomTableValue(BeggarAnimations)
		self:setAnimation(unpack(animation))
	end

	-- Set ElementDatas
	self:setData("clickable", true, true)
	self:setData("BeggarName", self.m_Name, true)
	self:setData("BeggarId", self.m_Id, true)
	self:setData("BeggarType", self.m_Type, true)
end

function BeggarPed:destructor()
	if self.m_ColShape and isElement(self.m_ColShape) then destroyElement(self.m_ColShape) end

	-- Remove ref
	BeggarPedManager:getSingleton():removeRef(self)
end

function BeggarPed:getId()
	return self.m_Id
end

function BeggarPed:despawn()
	self.m_Despawning = true
    setTimer(function ()
		if self and isElement(self) and self:getAlpha() then
			local newAlpha = self:getAlpha() - 10
			if newAlpha < 10 then newAlpha = 0 end
			if newAlpha == 0 then
				self:destroy()
			else
				self:setAlpha(newAlpha)
			end
		else
			killTimer(sourceTimer)
		end
    end, 50, 255/10)
end

function BeggarPed:rob(player)
	if self.m_Despawning then return end
	if getTickCount() - self.m_LastRobTime < 10*60*1000 then
		player:sendMessage(_("#FE8A00%s: #FFFFFFIch wurde gerade erst ausgeraubt. Bei mir gibts nichts zu holen.", player, self.m_Name))
		return
	end
	if not player.vehicle then
		-- Give wage
		local money = math.random(1, 5)
		player:giveMoney(money, "Bettler-Raub")
		player:giveKarma(-math.ceil(money/2))
		player:sendShortMessage(_("-%s Karma", player, math.ceil(money/2)))
		self:sendMessage(player, BeggarPhraseTypes.Rob)
		player:meChat(true, ("packt %s und entreißt ihm %s"):format(self.m_Name, money == 1 and "einen Schein" or "ein paar Scheine"))
		-- give Achievement
		player:giveAchievement(50)

		-- Update rob time
		self.m_LastRobTime = getTickCount()
		self.m_Robber = player:getId()
	else
		self:sendMessage(player, BeggarPhraseTypes.InVehicle)
	end
end

function BeggarPed:giveMoney(player, money)
	if self.m_Despawning then return end
	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		if player:getMoney() >= money then
			-- give wage
			player:takeMoney(money, "Bettler")
			local karma = math.min(money, 5)
			player:giveKarma(karma)
			player:sendShortMessage(_("+%s Karma", player, math.floor(karma)))
			player:givePoints(1)
			player:meChat(true, ("übergibt %s %s"):format(self.m_Name, money == 1 and "einen Schein" or "ein paar Scheine"))
			self:sendMessage(player, BeggarPhraseTypes.Thanks)

			-- give Achievement
			player:giveAchievement(56)
			if self.m_Name == BeggarNames[19] then
				player:giveAchievement(80)
			elseif self.m_Name == BeggarNames[32] then
				player:giveAchievement(81)
			end

			-- Despawn the Beggar
			setTimer(
				function ()
					self:despawn()
				end, 50, 1
			)
		else
			player:sendError(_("Du hast nicht soviel Geld dabei!", player))
		end
	else
		self:sendMessage(player, BeggarPhraseTypes.InVehicle)
	end
end

function BeggarPed:sellWeed(player, amount)
	if self.m_Despawning then return end
	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		if player:getInventory():getItemAmount("Weed") >= amount then
			player:getInventory():removeItem("Weed", amount)
			player:giveKarma(- math.ceil(amount/50))
			player:sendShortMessage(_("-%s Karma", player, math.ceil(amount/50)))
			player:giveMoney(amount*15, "Bettler-Drogenhandel")
			player:givePoints(math.ceil(20 * amount/200))
			player:meChat(true, ("übergibt %s %s"):format(self.m_Name, amount > 100 and "eine große Tüte" or "eine Tüte"))
			self:sendMessage(player, BeggarPhraseTypes.Thanks)
			-- Despawn the Beggar
			setTimer(
				function ()
					self:despawn()
				end, 50, 1
			)
		else
			player:sendError(_("Du hast nicht so viel Weed dabei!", player))
		end
	else
		self:sendMessage(player, BeggarPhraseTypes.InVehicle)
	end
end


function BeggarPed:giveItem(player, item)
	if self.m_Despawning then return end
	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		if player:getInventory():getItemAmount(item) >= 1 then
			player:getInventory():removeItem(item, 1)
			local karma = 5
			player:giveKarma(karma)
			player:sendShortMessage(_("+%s Karma", player, math.floor(karma)))
			player:givePoints(5)
			self:sendMessage(player, BeggarPhraseTypes.Thanks)
			player:meChat(true, ("übergibt %s eine Tüte"):format(self.m_Name))
			setTimer(
				function ()
					self:despawn()
				end, 50, 1
			)
		else
			player:sendError(_("Du hast kein/en %s dabei!", player, item))
		end
	else
		client:sendError(_("Steige zuerst aus deinem Fahrzeug aus!", client))
	end
end

function BeggarPed:acceptTransport(player)
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

				player.beggarTransportBlip = Blip:new("Waypoint.png", pos.x, pos.y, player, 9999)
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
							local karma = math.ceil(5*distance)
							player:giveKarma(karma)
							player:sendShortMessage(_("+%s Karma", player, karma))
							player:givePoints(math.ceil(7*distance))
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

function BeggarPed:onTransportExit(exitPlayer)
	if exitPlayer.beggarTransportMarker or exitPlayer == self then
		exitPlayer:sendError(_("Bettler-Transport fehlgeschlagen", exitPlayer))
		self:deleteTransport(exitPlayer)
	end
end

function BeggarPed:onTransportDestroy()
	local player = vehicle:getOccupant()
	player:sendError(_("Bettler-Transport fehlgeschlagen", player))
	self:deleteTransport(player)
end

function BeggarPed:sendMessage(player, type, arg)
    player:sendMessage(_("#FE8A00%s: #FFFFFF%s", player, self.m_Name, BeggarPedManager:getSingleton():getPhrase(self.m_Type, type, arg)))
end

function BeggarPed:deleteTransport(player)
	local veh = player.beggarTransportVehicle
	removeEventHandler("onVehicleExit", veh, self.m_onTransportExitBind)
	removeEventHandler("onVehicleDestroy", veh, self.m_onTransportExitBind)

	player.beggarTransportMarker:destroy()
	delete(player.beggarTransportBlip)

	self:removeFromVehicle()
	setTimer(function() self:despawn() end, 50, 1)
end

function BeggarPed:Event_onPedWasted(totalAmmo, killer, killerWeapon, bodypart, stealth)
	if killer and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		--killer:reportCrime(Crime.Kill)

		-- Take karma
		killer:giveKarma(-3)

		-- Destory the Ped
		self:despawn()

		-- Give Wanteds
		killer:giveWantedLevel(3)
		killer:sendMessage("Verbrechen begangen: Mord, 3 Wanteds", 255, 255, 0)
	end
end

function BeggarPed:Event_onColShapeHit(hitElement, dim)
    if dim then
        if hitElement:getType() ~= "player" then return end
        self:sendMessage(hitElement, BeggarPhraseTypes.Help)
        hitElement:triggerEvent("setManualHelpBarText", "HelpTextTitles.Gameplay.Beggar", "HelpTexts.Gameplay.Beggar", true)
    end
end

function BeggarPed:Event_onColShapeLeave(hitElement, dim)
    if dim then
        if hitElement:getType() ~= "player" then return end
        self:sendMessage(hitElement, BeggarPhraseTypes.NoHelp)
        hitElement:triggerEvent("resetManualHelpBarText")
    end
end
