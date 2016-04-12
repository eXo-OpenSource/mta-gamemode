-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/AmmuNationManager.lua
-- *  PURPOSE:     Weapon shop manager class
-- *
-- ****************************************************************************
AmmuNationManager = inherit(Singleton)
addRemoteEvents{"onPlayerWeaponBuy", "onPlayerMagazineBuy", "onAmmunationAppOrder"}

AmmuNationManager.DATA = {
	[1] = {
		NAME = "Los Santos Main",
		ENTER =
		{
			{1368.23376,-1279.83606,13.54688}
		},
		DIMENSION = Interiors.AmmuNation1
	},
	[2] = {
		NAME = "Los Santos East",
		ENTER = {
			{2400.59106,-1981.68750,13.54688}
		},
		DIMENSION = Interiors.AmmuNation2
	},
}

function AmmuNationManager:constructor()
	self.m_AmmuNations = {}

	for k, info in pairs(AmmuNationManager.DATA) do
		local ammuNation = AmmuNation:new(info.NAME)
		table.insert(self.m_AmmuNations, ammuNation)

		for k, coords in pairs(info.ENTER) do
			ammuNation:addEnter(coords[1], coords[2], coords[3], info.DIMENSION)
		end

		-- Register interiors (so that the player respawns here after reconnecting)
		InteriorManager:getSingleton():registerInterior(info.DIMENSION, AmmuNation.INTERIORID, Vector3(info.ENTER[1]))
	end
	addEventHandler("onAmmunationAppOrder",root, bind(self.onAmmunationAppOrder, self))

end

function AmmuNationManager:getPlayerWeapons(player)
	local playerWeapons = {}
	for i=1, 12 do
		if getPedWeapon(player,i) > 0 then
			playerWeapons[getPedWeapon(player,i)] = true
		end
	end
	return playerWeapons
end

function AmmuNationManager:onAmmunationAppOrder(weaponTable)
	local totalAmount = 0
	local canBuyWeapons = true
	for weaponID,v in pairs(weaponTable) do
		for typ,amount in pairs(weaponTable[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					totalAmount = totalAmount + AmmuNationInfo[weaponID].Weapon * amount
				elseif typ == "Munition" then
					totalAmount = totalAmount + AmmuNationInfo[weaponID].Magazine.price * amount
				end
				if client:getWeaponLevel() < AmmuNationInfo[weaponID].MinLevel then
					canBuyWeapons = false
				end
			end
		end
	end
	if canBuyWeapons then
		if client:getMoney() >= totalAmount then
			if totalAmount > 0 then
				client:takeMoney(totalAmount)
				self:createOrder(client, weaponTable)
			else
				client:sendError(_("Du hast keine Artikel im Warenkorb!",client))
			end
		else
			client:sendError(_("Du hast nicht ausreichend Geld dabei! (%d$)",client, totalAmount))
		end
	else
		-- Possible Cheat attempt?
		client:sendError(_("An Internal Error occured!", client))
	end
end

function AmmuNationManager:createOrder(player, weaponTable)
	local x, y, z = getElementPosition ( player )
	y = y - 2
	x = x - 2
	local dropObject = createObject ( 2903, x, y, z+6.3+15 )
	moveObject(dropObject, 9000, x, y, z+6.3 )
	setTimer(destroyElement, 10000, 1, dropObject )
	setTimer(function(x, y, z, weaponTable)
		local pickup = createPickup(x, y, z, 3, 1210)
		addEventHandler("onPickupHit", pickup, function(hitElement)
			if hitElement:getType() == "player" and not hitElement:getOccupiedVehicle() then
				self:giveWeaponsFromOrder(hitElement, weaponTable)
				source:destroy()
			end
		end)
	end, 10000, 1, x, y, z, weaponTable)

end

function AmmuNationManager:giveWeaponsFromOrder(player, weaponTable)
	local playerWeapons = self:getPlayerWeapons(player)
	outputChatBox("Du hast folgende Waffen und Magazine erhalten:",player,255,255,255)
	for weaponID,v in pairs(weaponTable) do
		for typ,amount in pairs(weaponTable[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					if weaponID > 0 then
						outputChatBox(amount.." "..getWeaponNameFromID(weaponID),player,255,125,0)
						giveWeapon(player,weaponID,amount)
					else
						outputChatBox("1 Schutzweste",player,255,125,0)
						player:setArmor(100)
					end
				elseif typ == "Munition" then
					playerWeapons = self:getPlayerWeapons(player)
					if playerWeapons[weaponID] then
						giveWeapon(player,weaponID,amount*getWeaponProperty(weaponID, "poor", "maximum_clip_ammo"))
						outputChatBox(amount.." "..getWeaponNameFromID(weaponID).." Magazin/e",player,255,125,0)
					else
						outputChatBox("Du hast keine "..getWeaponNameFromID(weaponID).." für ein Magazin!",player,255,0,0)
					end
				end
			end
		end
	end
end
