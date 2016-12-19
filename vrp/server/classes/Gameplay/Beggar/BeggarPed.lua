BeggarPed = inherit(Object)

function BeggarPed:new(position, rotation, ...)
    local ped = Ped.create(Randomizer:getRandomTableValue(BeggarSkins), position, rotation.z)
    enew(ped, self, ...)
	addEventHandler("onPedWasted", ped, bind(self.Event_onPedWasted, ped))

    return ped
end

function BeggarPed:constructor(Id)
	self.m_Id = Id
	self.m_Name = Randomizer:getRandomTableValue(BeggarNames)
	self.m_ColShape = ColShape.Sphere(self:getPosition(), 10)
	self.m_Type = math.random(1, 3)
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
	if self.m_ColShape and isElement(self.m_Colshape) then
		self.m_ColShape:destroy()
	end

	-- Remove ref
	BeggarPedManager:getSingleton():removeRef(self)
end

function BeggarPed:getId()
	return self.m_Id
end

function BeggarPed:despawn()
    setTimer(function ()
        local newAlpha = self:getAlpha() - 10
        if newAlpha < 10 then newAlpha = 0 end
        if newAlpha == 0 then
            self:destroy()
        else
            self:setAlpha(newAlpha)
        end
    end, 50, 255/10)
end

function BeggarPed:rob(player)
	if getTickCount() - self.m_LastRobTime < 10*60*1000 then
		return
	end

	-- Give wage
	client:giveMoney(math.random(1, 5), "Bettler-Raub")
	client:giveKarma(-1/math.random(1, 5))
	client:sendShortMessage(_("Well done. Du hast einen Bettler ausgeraubt!", player))
    self:sendMessage(client, BeggarPhraseTypes.Rob)

	-- give Achievement
	client:giveAchievement(50)

	-- Update rob time
	self.m_LastRobTime = getTickCount()
end

function BeggarPed:giveMoney(player, money)
	if player:getMoney() >= money then
		-- give wage
		player:takeMoney(money, "Bettler")
		local karma = math.random(1, 5)
		player:giveKarma(karma)
		player:sendShortMessage(_("+%s Karma", player, math.floor(karma)))
		player:givePoints(1)
		self:sendMessage(player, BeggarPhraseTypes.Thanks)

		-- give Achievement
		player:giveAchievement(56)

		-- Despawn the Beggar
		setTimer(
			function ()
				self:despawn()
			end, 50, 1
		)
	else
		player:sendError(_("Du hast nicht soviel Geld dabei!", player))
	end
end

function BeggarPed:giveItem(player, item)
	if player:getInventory():getItemAmount(item) >= 1 then
		player:getInventory():removeItem(item, 1)
		local karma = 5
		player:giveKarma(karma)
		player:sendShortMessage(_("+%s Karma", player, math.floor(karma)))
		player:givePoints(1)
		self:sendMessage(player, BeggarPhraseTypes.Thanks)
		setTimer(
			function ()
				self:despawn()
			end, 50, 1
		)
	else
		player:sendError(_("Du hast kein/en %s dabei!", player, item))
	end
end

function BeggarPed:acceptTransport(player)
	if player.vehicle and player.vehicleSeat == 0 then
		local veh = player.vehicle
		for seat = 1, veh.maxPassengers do
			if not veh:getOccupant(seat) then
				local pos = Randomizer:getRandomTableValue(BeggarTransportPositions)
				self:warpIntoVehicle(veh, seat)
				player.beggarTransportMarker = createMarker(pos, "cylinder", 2)
				player.beggarTransportMarker.player = player
				setElementVisibleTo(player.beggarTransportMarker, root, false)
				setElementVisibleTo(player.beggarTransportMarker, player, true)

				player.beggarTransportBlip = Blip:new("Waypoint.png", pos.x, pos.y, player, 9999)
				if self.m_ColShape then self.m_ColShape:destroy() end

				local function deleteBeggarTransport(player, ped)
					player.beggarTransportMarker:destroy()
					delete(player.beggarTransportBlip)

					ped:removeFromVehicle()
					setTimer(function() ped:despawn() end, 50, 1)
				end

				addEventHandler("onVehicleExit", veh, function(exitPlayer)
					if exitPlayer == player or exitPlayer == self then
						player:sendError(_("Bettler-Transport fehlgeschlagen", player))
						deleteBeggarTransport(player, self)
					end
				end)

				addEventHandler("onVehicleDestroy", veh, function()
					player:sendError(_("Bettler-Transport fehlgeschlagen", player))
					deleteBeggarTransport(player, self)
				end)

				addEventHandler("onMarkerHit", player.beggarTransportMarker, function(hitElement, dim)
					if hitElement:getType() == "player" and dim and source.player == hitElement then
						local player = hitElement
						if player.vehicle and veh:getOccupant(seat) == self then
							local karma = 15
							player:giveKarma(karma)
							player:sendShortMessage(_("+%s Karma", player, math.floor(karma)))
							player:givePoints(1)
							self:sendMessage(player, BeggarPhraseTypes.Thanks)
							deleteBeggarTransport(player, self)
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

function BeggarPed:sendMessage(player, type)
    player:sendMessage(_("#FE8A00%s: #FFFFFF%s", player, self.m_Name, BeggarPedManager:getSingleton():getPhrase(self.m_Type, type)))
end


function BeggarPed:Event_onPedWasted(totalAmmo, killer, killerWeapon, bodypart, stealth)
	if killer and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		--killer:reportCrime(Crime.Kill)

		-- Take karma
		killer:giveKarma(-1/math.random(1, 5))

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

		-- Take karma
		hitElement:giveKarma(-1/math.random(1, 5))
    end
end
