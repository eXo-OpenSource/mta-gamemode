-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/ExplosiveTruck/ExplosiveTruckManager.lua
-- *  PURPOSE:     C4 Truck Class
-- *
-- ****************************************************************************

ExplosiveTruck = inherit(Object)
ExplosiveTruck.Price = 5000
ExplosiveTruck.Item = "Sprengstoff"
ExplosiveTruck.ItemAmount = 1

function ExplosiveTruck:constructor(faction, player)
	self.m_Faction = faction
	self.m_FactionDepot = faction:getDepot()
	self.m_FactionDepotObject = FactionEvil:getSingleton().m_ItemDepot[faction:getId()]

	local color = faction:getColor()
	self.m_FactionDepotObjectMarker = Marker(self.m_FactionDepotObject:getPosition(), "corona", 1, color.r, color.g, color.b)
	self.m_FactionDepotObjectMarker:setDimension(self.m_FactionDepotObject:getDimension())
	self.m_FactionDepotObjectMarker:setInterior(self.m_FactionDepotObject:getInterior())

	for k, faction in pairs(FactionEvil:getSingleton():getFactions()) do
		if faction:isEvilFaction() then
			addEventHandler("onElementClicked", FactionEvil:getSingleton().m_ItemDepot[faction:getId()], bind(self.deliverBox, self))
		end
	end

	addEventHandler("onPickupUse", FactionState:getSingleton().m_EvidenePickup, bind(self.impoundBox, self))

	self.m_Box = createObject(2912, player:getPosition())
	self.m_Box.m_Faction = faction
	setElementData(self.m_Box, "explosiveBox", true)
	addEventHandler("onElementClicked", self.m_Box, bind(self.dragBox, self))
	addEventHandler("onElementDestroy", self.m_Box, bind(self.cancel, self))
	player:attachPlayerObject(self.m_Box)

	faction:transferMoney(BankServer.get("action.trucks"), ExplosiveTruck.Price, "Sprengstoff", "Action", "ExplosiveTruck")
end

function ExplosiveTruck:destructor()
	ExplosiveTruckManager.Active[self.m_Faction:getId()] = nil
	self.m_FactionDepotObjectMarker:destroy()

	for k, faction in pairs(FactionEvil:getSingleton():getFactions()) do
		if faction:isEvilFaction() then
			removeEventHandler("onElementClicked", FactionEvil:getSingleton().m_ItemDepot[faction:getId()], bind(self.deliverBox, self))
		end
	end

	removeEventHandler("onPickupUse", FactionState:getSingleton().m_EvidenePickup, bind(self.impoundBox, self))
end

function ExplosiveTruck:dragBox(button, state, player)
	if
		button ~= "left"
		or state ~= "down"
		or player:isInVehicle()
		or player:isDead()
	then
		return
	end

	if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) > 3 then
		player:sendError("Du bist zu weit von der Kiste entfernt!")

		return
	end

	local faction = player:getFaction()

	if
		not faction
		or not faction:isStateFaction() and not faction:isEvilFaction()
	then
		player:sendError("Du kannst diese Kiste nicht aufheben!")

		return
	end

	player:setAnimation("carry", "crry_prtial", 1, true, true, false, true)
	player:attachPlayerObject(source)
end

function ExplosiveTruck:removeBox(player)
	local box = player:getPlayerAttachedObject()
	if not box then
		return
	end

	player:detachPlayerObject(box)
	box:destroy()
end

function ExplosiveTruck:deliverBox(button, state, player)
	local faction = player:getFaction()

	if
		button ~= "left"
		or state ~= "down"
		or not faction
		or not faction:isEvilFaction()
		or not player:getPlayerAttachedObject()
	then
		return
	end

	self:removeBox(player)

	faction:getDepot():addItem(player, ExplosiveTruck.Item, ExplosiveTruck.ItemAmount, true)
	faction:sendSuccess("Es ist Sprengstoff ins Depot eingelagert worden!")

	delete(self)
end

function ExplosiveTruck:impoundBox(player)
	if not player or player:getFaction() or player:getFaction():isStateFaction() then
		return
	end

	self:removeBox(player)

	FactionState:getSingleton():sendShortMessage(player:getName() .. " hat Sprengstoff konfesziert!")

	delete(self)
end

function ExplosiveTruck:cancel()
	delete(self)
end
