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

	addEventHandler("onPlayerWeaponBuy",root, bind(self.buyWeapon, self))
	addEventHandler("onPlayerMagazineBuy",root, bind(self.buyMagazine, self))
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
	if client:getInterior() > 0 or client:getDimension() > 0 or client.m_JailTime > 0 then
		client:sendError(_("Du kannst hier nicht bestellen!",client))
		return
	end

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
				if client:getWeaponLevel() < MIN_WEAPON_LEVELS[weaponID] then
					canBuyWeapons = false
				end
			end
		end
	end
	if canBuyWeapons then
		if client:getBankMoney() >= totalAmount then
			if totalAmount > 0 then
				client:takeBankMoney(totalAmount, "AmmuNation Bestellung")
				StatisticsLogger:getSingleton():addAmmunationLog(client, "Bestellung", toJSON(weaponTable), totalAmount)
				self:createOrder(client, weaponTable)
			else
				client:sendError(_("Du hast keine Artikel im Warenkorb!",client))
			end
		else
			client:sendError(_("Du hast nicht ausreichend Geld auf deinem Bankkonto! (%d$)",client, totalAmount))
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
				StatisticsLogger:getSingleton():addAmmunationLog(hitElement, "Pickup", toJSON(weaponTable), 0)
				if source then
					if isElement(source) then 
						destroyElement(source)
					end
				end
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
				local mag = getWeaponProperty(weaponID, "pro", "maximum_clip_ammo") or 1
				if typ == "Waffe" then
					if weaponID > 0 then
						outputChatBox(amount.." "..WEAPON_NAMES[weaponID],player,255,125,0)
						giveWeapon(player, weaponID, mag)
					else
						outputChatBox("1 Schutzweste",player,255,125,0)
						player:setArmor(100)
					end
				elseif typ == "Munition" then
					playerWeapons = self:getPlayerWeapons(player)
					if playerWeapons[weaponID] then
						giveWeapon(player,weaponID,amount*mag)
						outputChatBox(amount.." "..WEAPON_NAMES[weaponID].." Magazin/e",player,255,125,0)
					else
						outputChatBox("Du hast keine "..WEAPON_NAMES[weaponID].." für ein Magazin!",player,255,0,0)
					end
				end
			end
		end
	end
end

function AmmuNationManager:buyWeapon(id)
	if MIN_WEAPON_LEVELS[id] <= client:getWeaponLevel() then
		if client:getMoney() >= AmmuNationInfo[id].Weapon then
			if AmmuNationInfo[id].Magazine then
				giveWeapon(client,id,AmmuNationInfo[id].Magazine.amount)
				client:takeMoney(AmmuNationInfo[id].Weapon, "Ammunation")
				client:sendShortMessage(_("Waffe erhalten.",client))
				local weaponTable = toJSON({[id] = AmmuNationInfo[id].Magazine.amount})
				StatisticsLogger:addAmmunationLog(client, "Shop", weaponTable, AmmuNationInfo[id].Weapon)
				return
			else
				if id == 0 then
					client:takeMoney(AmmuNationInfo[id].Weapon, "Ammunation")
					client:setArmor(100)
					client:sendShortMessage(_("Schutzweste erhalten.",client))
					return
				else
					client:takeMoney(AmmuNationInfo[id].Weapon, "Ammunation")
					giveWeapon(client,id,1)
					reloadPedWeapon(client)
					client:sendShortMessage(_("Schlagwaffe erhalten.",client))
					return
				end
			end
		else
			client:sendError(_("Du hast nicht genuegend Geld.",client))
		end
	else
		client:sendError(_("Dein Waffenlevel ist zu niedrig!",client))
	end
end

function AmmuNationManager:buyMagazine(id)
	if MIN_WEAPON_LEVELS[id] <= client:getWeaponLevel() then
		if not hasPedThisWeaponInSlots (client,id) then return false end
		if client:getMoney() >= AmmuNationInfo[id].Magazine.price then
			giveWeapon(client,id,AmmuNationInfo[id].Magazine.amount)
			client:takeMoney(AmmuNationInfo[id].Magazine.price, "Ammunation")
			client:sendShortMessage(_("Munition erhalten.",client))
			local weaponTable = toJSON({[id] = AmmuNationInfo[id].Magazine.amount})
			StatisticsLogger:addAmmunationLog(client, "Shop", weaponTable, AmmuNationInfo[id].Magazine.price)
			reloadPedWeapon(client)
			return
		else
			client:sendError(_("Du hast nicht genuegend Geld.",client))
		end
	else
		client:sendError(_("Dein Waffenlevel ist zu niedrig!",client))
	end
end
