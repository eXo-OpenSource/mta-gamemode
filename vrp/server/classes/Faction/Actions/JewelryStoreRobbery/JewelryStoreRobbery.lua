JewelryStoreRobbery = inherit(Object)

function JewelryStoreRobbery:constructor(maxBags)
	triggerClientEvent("jewelryStoreRobberyAlarmStart", root)
	triggerClientEvent("jewelryStoreRobberyPedAnimation", JewelryStoreRobberyManager:getSingleton().m_ShopPed, "VRP.OTHER", "cowerHandsBehindHead", -1, true, false, false, true)

	PlayerManager:getSingleton():breakingNews("Die Alarmanlage des Juweliers wurde ausgelöst!")

	self.m_MaxBags = maxBags
	self.m_PendingBags = maxBags
	self.m_BagsGivenOut = 0

	self.m_MaxMoney = 50000

	self.m_Players = {}
	self.m_Bags = {}

	self.m_BreakGlass = bind(self.Event_BreakGlass, self)
	self.m_BagClick = bind(self.Event_BagClick, self)

	self.m_EvilDeliveryPed = NPC:new(132, -1438.823, 1491.225, 1.867, 270)
    self.m_EvilDeliveryPed:setImmortal(true)
	self.m_EvilDeliveryPed:setFrozen(true)
	self.m_EvilDeliveryPed:setData("clickable", true, true)

	self.m_StateDeliveryPed = NPC:new(281, 1578.373, -1620.275, 13.547, 270)
    self.m_StateDeliveryPed:setImmortal(true)
	self.m_StateDeliveryPed:setFrozen(true)
	self.m_StateDeliveryPed:setData("clickable", true, true)

	self.m_BankAccountServer = BankServer.get("action.jewelry_store_robbery")
	self.m_BreakingNewsTimer = setTimer(bind(self.updateBreakingNews, self), 20000, 0)
	self.m_TimeUpTimer = setTimer(bind(self.timeUp, self), 15*60*1000, 1)

	addEventHandler("onElementClicked", self.m_EvilDeliveryPed, bind(self.Event_EvilDeliveryFaction, self))
	addEventHandler("onElementClicked", self.m_StateDeliveryPed, bind(self.Event_StateDeliveryFaction, self))

	for index, player in pairs(JewelryStoreRobberyManager:getSingleton().m_Players) do
		if isElement(player) then
			bindKey(player, "f", "down", self.m_BreakGlass)
		end
	end
	ActionsCheck:getSingleton():setAction("Juwelier-Raub")
end

function JewelryStoreRobbery:destructor()
	triggerClientEvent("jewelryStoreRobberyAlarmEnd", root)
	for index, player in pairs(JewelryStoreRobberyManager:getSingleton().m_Players) do
		if isElement(player) then
			unbindKey(player, "f", "down", self.m_BreakGlass)
		end
	end

	for index, object in pairs(self.m_Bags) do
		if isElement(object) then
			object:destroy()
		end
	end

	self.m_EvilDeliveryPed:destroy()
	self.m_StateDeliveryPed:destroy()
	killTimer(self.m_BreakingNewsTimer)
	killTimer(self.m_TimeUpTimer)
	ActionsCheck:getSingleton():endAction()
end

function JewelryStoreRobbery:Event_BreakGlass(player)
	local nearestShelve = nil
	local nearestShelveDistance = -1

	if player.m_IsGlassBreaking then
		return
	end

	if not (player:getFaction():isEvilFaction() and player:isFactionDuty()) then
		return
	end

	if player.m_PlayerAttachedObject and not player.m_PlayerAttachedObject.m_Jewelry then
		player:sendError(_("Du trägst bereits ein Objekt!", player))
		return
	end

	for key, collision in ipairs(JewelryStoreRobberyManager:getSingleton().m_ShelveCollisions) do
		if not collision.m_Shelve.m_Looted then
			local distance = getDistanceBetweenPoints3D(player.position, collision.position)
			if nearestShelveDistance == -1 or nearestShelveDistance > distance then
				nearestShelve = collision
				nearestShelveDistance = distance
			end
		end
	end

	if nearestShelveDistance == -1 then
		return
	end

	if nearestShelveDistance < 0.7 then
		local shelve = nearestShelve.m_Shelve
		local rotation = findRotation(player.position.x, player.position.y, shelve.position.x, shelve.position.y)
		player:setRotation(0, 0, rotation)
		toggleAllControls(player, false)

		player:setAnimation("sword", "sword_4", 2000, true, false, false, false)
		player.m_IsGlassBreaking = true

		local timer = setTimer(function()
			toggleAllControls(player, true)
			player.m_IsGlassBreaking = false
			if not shelve.m_Looted then
				if player.m_PlayerAttachedObject and not player.m_PlayerAttachedObject.m_Jewelry then
					player:sendError(_("Du hast bereits ein Objekt dabei!", self))
					return
				end

				JewelryStoreRobberyManager:getSingleton():clearShelve(shelve)
				triggerClientEvent("jewelryStoreRobberyBreakGlass", player, shelve.position.x, shelve.position.y, shelve.position.z)

				self.m_BagsGivenOut = self.m_BagsGivenOut + 1
				if player.m_PlayerAttachedObject then
					player.m_PlayerAttachedObject:setData("Value", player.m_PlayerAttachedObject:getData("Value") + 1)
				else
					local bag = createObject(1550, player.position)
					bag:setData("Value", 1)
					bag:setInterior(player:getInterior())
					bag:setDimension(player:getDimension())
					bag.m_Jewelry = true
					table.insert(self.m_Bags, bag)
					addEventHandler("onElementClicked", bag, self.m_BagClick)

					player:attachPlayerObject(bag, {blockJump = false, blockFlyingVehicles = true})
				end
			end
		end, 2000, 1)
	end
end

function JewelryStoreRobbery:Event_BagClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			if (player:getFaction():isStateFaction() or player:getFaction():isEvilFaction()) and player:isFactionDuty() then
				if getElementData(player, "heligrab.vehicle") or player.vehicle then
					player:sendError(_("Du kannst die Beute nicht aufeben solange du in einem Fahrzeug bist!", player))
					return
				end

				if player.m_PlayerAttachedObject and player.m_PlayerAttachedObject.m_Jewelry then
					player.m_PlayerAttachedObject:setData("Value", player.m_PlayerAttachedObject:getData("Value") + source:getData("Value"))
					player:sendShortMessage(_("Die Beute wurde zu deinem Beutel hinzugefügt!", player))
					source:destroy()
					return
				end
				player:attachPlayerObject(source, {blockJump = false, blockFlyingVehicles = true})
			else
				player:sendError(_("Du bist nicht an diesem Raub beteiligt!", player))
			end
		else
			player:sendError(_("Du bist zu weit von der Beute entfernt!", player))
		end
	end
end

function JewelryStoreRobbery:Event_EvilDeliveryFaction(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			if player:getFaction():isEvilFaction() and player:isFactionDuty() then
				if player.m_PlayerAttachedObject and player.m_PlayerAttachedObject.m_Jewelry then
					local bag = player.m_PlayerAttachedObject
					local value = bag:getData("Value")
					local money = math.round(value * (self.m_MaxMoney / self.m_MaxBags), 0)
					player:detachPlayerObject(bag)
					player:sendShortMessage(_("Du hast die Beute abgegeben!", player))
					bag:destroy()

					self.m_PendingBags = self.m_PendingBags - value
					self.m_BankAccountServer:transferMoney({"faction", player:getFaction():getId(), true}, money, "Juwelier-Diebstahl", "Action", "JewelryRobbery", {silent = true})

					if self.m_PendingBags == 0 or self.m_MaxBags - self.m_BagsGivenOut == self.m_PendingBags then
						JewelryStoreRobberyManager:getSingleton():stopRobbery("evil")
					end
				else
					player:sendError(_("Du hast keine Beute dabei!", player))
				end
			else
				player:sendError(_("Du kannst nicht mit diesem NPC interagieren!", player))
			end
		else
			player:sendError(_("Du bist zu weit von dem NPC entfernt!", player))
		end
	end
end

function JewelryStoreRobbery:Event_StateDeliveryFaction(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			if player:getFaction():isStateFaction() and player:isFactionDuty() then
				if player.m_PlayerAttachedObject and player.m_PlayerAttachedObject.m_Jewelry then
					local bag = player.m_PlayerAttachedObject
					local value = bag:getData("Value")
					local money = math.round(value * (self.m_MaxMoney / self.m_MaxBags), 0)
					player:detachPlayerObject(bag)
					player:sendShortMessage(_("Du hast die Beute abgegeben!", player))
					bag:destroy()

					self.m_PendingBags = self.m_PendingBags - value
					self.m_BankAccountServer:transferMoney({"faction", player:getFaction():getId(), true}, money, "Juwelier-Diebstahl", "Action", "JewelryRobbery", {silent = true})

					if self.m_PendingBags == 0 or self.m_MaxBags - self.m_BagsGivenOut == self.m_PendingBags then
						JewelryStoreRobberyManager:getSingleton():stopRobbery("state")
					end
				else
					player:sendError(_("Du hast keine Beute dabei!", player))
				end
			else
				player:sendError(_("Du kannst nicht mit diesem NPC interagieren!", player))
			end
		else
			player:sendError(_("Du bist zu weit von dem NPC entfernt!", player))
		end
	end
end

function JewelryStoreRobbery:onShopEnter(player)
	bindKey(player, "f", "down", self.m_BreakGlass)
	triggerClientEvent("jewelryStoreRobberyAlarmStart", root)
	triggerClientEvent("jewelryStoreRobberyPedAnimation", JewelryStoreRobberyManager:getSingleton().m_ShopPed, "VRP.OTHER", "cowerHandsBehindHead", -1, true, false, false, true)
end

function JewelryStoreRobbery:onShopLeave(player)
	unbindKey(player, "f", "down", self.m_BreakGlass)
end

function JewelryStoreRobbery:timeUp()
	JewelryStoreRobberyManager:getSingleton():stopRobbery("timeup")
end

function JewelryStoreRobbery:updateBreakingNews()
	local stateCount = 0
	local evilCount = 0

	for index, player in pairs(JewelryStoreRobberyManager:getSingleton().m_Players) do
		if isElement(player) and player:isFactionDuty() then
			if player:getFaction():isStateFaction() then
				stateCount = stateCount + 1
			elseif player:getFaction():isEvilFaction() then
				evilCount = evilCount + 1
			end
		end
	end

	if evilCount > 0 then
		if evilCount > stateCount then
			PlayerManager:getSingleton():breakingNews(("Es befinden sich derzeit %d Räuber im Juwelier!"):format(evilCount))
		else
			PlayerManager:getSingleton():breakingNews(("Es befinden sich derzeit %d Beamte im Juwelier!"):format(stateCount))
		end
	else
		PlayerManager:getSingleton():breakingNews(("Die Räuber befinden sind mit der Beute auf der Flucht!"))
	end
end
