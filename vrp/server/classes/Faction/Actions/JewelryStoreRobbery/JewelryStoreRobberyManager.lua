-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/JewelryStoreRobbery/JewelryStoreRobberyManager.lua
-- *  PURPOSE:     Jewelry store robbery manager class
-- *
-- ****************************************************************************

JewelryStoreRobberyManager = inherit(Singleton)

JewelryStoreRobberyManager.Shelves = {
	{Vector3(44, 106.9, 697.5), Vector3(0, 0, 0)},
	{Vector3(43.99, 108.354, 697.5), Vector3(0, 0, 270)},
	{Vector3(43.99, 109.97, 697.5), Vector3(0, 0, 270)},
	{Vector3(44.64, 107.718, 697.5), Vector3(0, 0, 90)},
	{Vector3(44.64, 109.335, 697.5), Vector3(0, 0, 90)},
	{Vector3(44.64, 110.95, 697.5), Vector3(0, 0, 90)},
	{Vector3(43.99, 111.586, 697.5), Vector3(0, 0, 270)},
	{Vector3(45.4, 101.664, 697.5), Vector3(0, 0, 90)},
	{Vector3(44.6, 102.298, 697.5), Vector3(0, 0, 180)},
	{Vector3(44, 101.669, 697.5), Vector3(0, 0, 0)},
	{Vector3(42.4, 101.669, 697.5), Vector3(0, 0, 0)},
	{Vector3(43, 102.298, 697.5), Vector3(0, 0, 180)},
	{Vector3(41.6, 102.3, 697.5), Vector3(0, 0, 270)},
	{Vector3(39.167, 112.17, 697.5), Vector3(0, 0, 0)},
	{Vector3(39.8, 112.989, 697.5), Vector3(0, 0, 90)},
	{Vector3(39.8, 114.6, 697.5), Vector3(0, 0, 90)},
	{Vector3(39.803, 116.035, 697.5), Vector3(0, 0, 180)},
	{Vector3(37.429, 116.035, 697.5), Vector3(0, 0, 180)},
	{Vector3(36.801, 115.215, 697.5), Vector3(0, 0, 270)},
	{Vector3(36.801, 113.6, 697.5), Vector3(0, 0, 270)},
	{Vector3(36.8, 112.17, 697.5), Vector3(0, 0, 0)},
	{Vector3(40.1, 107.22, 697.5), Vector3(0, 0, 90)},
	{Vector3(39.2822, 107.867, 697.5), Vector3(0, 0, 180)},
	{Vector3(37.668, 107.867, 697.5), Vector3(0, 0, 180)},
	{Vector3(36.212, 107.86, 697.5), Vector3(0, 0, 270)},
	{Vector3(37.03, 107.21, 697.5), Vector3(0, 0, 0)},
	{Vector3(38.6459, 107.21, 697.5), Vector3(0, 0, 0)}
}

JewelryStoreRobberyManager.ShelvesAngled = {
	{Vector3(48.3009, 109.422, 697.45), Vector3(0, 0, 270)},
	{Vector3(31.091, 111.552, 697.45), Vector3(0, 0, 90)},
	{Vector3(41.1634, 118.991, 697.45), Vector3(0, 0, 0)},
	{Vector3(31.091, 109.273, 697.45), Vector3(0, 0, 90)},
	{Vector3(46.4909, 99.3103, 697.45), Vector3(0, 0, 180)}
}

JewelryStoreRobberyManager.ShelveContent = {
	Top = {
		{{2680, Vector3(0.6, -0.202, 0.84), Vector3(110, 0, 180), Vector3(1, 1, 1)}}, -- cj_padlock
		{{1210, Vector3(-0.117, -0.023, 0.964), Vector3(90, 0, 0), Vector3(1, 1, 1)}}, -- briefcase
		{{359, Vector3(0.369, -0.07, 0.95), Vector3(270, 0, 0), Vector3(0.9, 0.9, 0.9)}}, -- rocketla
		{{321, Vector3(0.316, -0.033, 0.855), Vector3(90, 0, 90), Vector3(1, 1, 1)}}, -- gun_dildo1
		{{1301, Vector3(0.368, 0.018, 0.865), Vector3(0, 0, 270), Vector3(0.1, 0.1, 0.1)}} -- heli_magnet
	},
	Middle = {
		{{2915, Vector3(0.5093, -0.141, 0.68), Vector3(0, 0, 0), Vector3(1, 1, 1)}}, -- kmb_dumbbell2
		{{2976, Vector3(0.1, -0.002, 0.68), Vector3(90, 0, 270), Vector3(0.5, 0.5, 0.5)}}, -- green_gloop
		{{1654, Vector3(0.708, -0.07, 0.621), Vector3(0, 270, 0), Vector3(1, 1, 1)}}, -- dynamite
		{
			{2710, Vector3(0.6831, -0.123, 0.667), Vector3(0, 0, 320), Vector3(1, 1, 1)}, -- watch_pickup
			{2710, Vector3(-0.1178, -0.133, 0.667), Vector3(0, 0, 30), Vector3(1, 1, 1)}, -- watch_pickup
			{2710, Vector3(0.2953, -0.133, 0.667), Vector3(0, 0, 10), Vector3(1, 1, 1)} -- watch_pickup
		}
	},
	Bottom = {
		{{1369, Vector3(0.3503, -0.152, 0.388), Vector3(0, 0, 30), Vector3(0.25, 0.25, 0.25)}}, -- cj_wheelchair1
		{{3056, Vector3(0.2, 0.12, 0.3), Vector3(0, 270, 310), Vector3(0.75, 0.75, 0.75)}}, -- mini_magnet
		{{1636, Vector3(0.4287, -0.095, 0.334), Vector3(0, 0, 270), Vector3(1, 1, 1)}}, -- rcbomb
		{{339, Vector3(0.711, -0.164, 0.265), Vector3(85, 0, 270), Vector3(1, 1, 1)}} -- katana
	}
}

JewelryStoreRobberyManager.ShelveAngleContent = {
	Top = {
		{
			{2703, Vector3(-0.095, -0.040, 0.85), Vector3(270, 0, 180), Vector3(1, 1, 1)}, -- cj_burger_1
			{1718, Vector3(0.81, -0.090, 0.83), Vector3(0, 0, 0), Vector3(0.5, 0.5, 0.5)} -- snesish
		},
		{{2680, Vector3(0.109, -0.113, 0.878), Vector3(293.438, 3.3232, 244.125), Vector3(1, 1, 1)}} -- cj_padlock
	},
	Middle = {
		{{954, Vector3(0.386, -0.05, 0.6), Vector3(270, 0, 180), Vector3(0.5, 0.5, 0.5)}}, -- cj_horse_shoe
		{{368, Vector3(0.759, -0.152, 0.540), Vector3(0, 270, -90), Vector3(1, 1, 1)}} -- nvgoggles
	},
	Bottom = {
		{{1279, Vector3(-0.036, -0.15, 0.44), Vector3(0, 0, 180), Vector3(0.5, 0.5, 0.5)}}, -- craigpackage
		{
			{1247, Vector3(-0.109, -0.216, 0.470), Vector3(90, 0, 30), Vector3(1, 1, 1)}, -- bribe
			{2750, Vector3(0.609, -0.037, 0.450), Vector3(90, 0, 0), Vector3(1, 1, 1)} -- cj_hair_dryer
		}
	}
}

function JewelryStoreRobberyManager:constructor()
	self.m_Interior = 0
	self.m_Dimension = 60001

	self.m_ShopPed = TargetableNPC:new(57, Vector3(32.613, 101.731, 698.455), 0)
    self.m_ShopPed:setInterior(self.m_Interior)
    self.m_ShopPed:setDimension(self.m_Dimension)
    self.m_ShopPed:setImmortal(true)
	self.m_ShopPed:setFrozen(true)
    self.m_ShopPed.onTargetted = bind(self.Event_PedTargetted, self)

	self.m_MinJewelryRobberyStateMembers = 3

	self.m_Players = {}
	setmetatable(self.m_Players, { __mode = "v" })

	self.m_ShopPedSoundCooldown = 0

	self.m_RobberyInstance = nil
	self.m_ShelveCollisions = {}
	self.m_Shelves = {}
	self.m_ShelvesAngled = {}
	self.m_ShelveCount = 0

	self.m_PedColShape = createColSphere(Vector3(32.613, 102.031, 698.455), 5)
	addEventHandler("onColShapeHit", self.m_PedColShape, bind(self.Event_ShopPedColHit, self))

	self.m_ShopColShape = createColCuboid(Vector3(28.887, 97.147, 691.111), Vector3(25.277, 32.362, 13.684))
	addEventHandler("onColShapeHit", self.m_ShopColShape, bind(self.Event_ShopEnter, self))
	addEventHandler("onColShapeLeave", self.m_ShopColShape, bind(self.Event_ShopLeave, self))

	InteriorEnterExit:new(Vector3(561.292, -1506.786, 14.548), Vector3(48.057, 122.831, 698.455), 90, 90, self.m_Interior, self.m_Dimension, 0, 0)

	self:spawnShelves()
	self:spawnShelveGlassesAndContent()
end

function JewelryStoreRobberyManager:spawnShelves()
	self.m_ShelveCount = 0

	for _, object in pairs(self.m_Shelves) do
		object:destroy()
	end

	for _, object in pairs(self.m_ShelvesAngled) do
		object:destroy()
	end

	for _, shelveInfo in pairs(JewelryStoreRobberyManager.Shelves) do
		local shelve = createObject(2413, shelveInfo[1], shelveInfo[2])
		shelve:setInterior(self.m_Interior)
		shelve:setDimension(self.m_Dimension)
		table.insert(self.m_Shelves, shelve)

		local matrix = shelve.matrix
		shelve.m_ColShape = createColSphere(matrix:transformPosition(Vector3(0.3, -1, 0.7)), 1)
		shelve.m_ColShape.m_Shelve = shelve
		table.insert(self.m_ShelveCollisions, shelve.m_ColShape)
		self.m_ShelveCount = self.m_ShelveCount + 1
	end

	for _, shelveInfo in pairs(JewelryStoreRobberyManager.ShelvesAngled) do
		local shelve = createObject(2436, shelveInfo[1], shelveInfo[2])
		shelve:setInterior(self.m_Interior)
		shelve:setDimension(self.m_Dimension)
		table.insert(self.m_ShelvesAngled, shelve)

		local matrix = shelve.matrix
		shelve.m_ColShape = createColSphere(matrix:transformPosition(Vector3(0.4, -1, 0.7)), 1.2)
		shelve.m_ColShape.m_Shelve = shelve
		table.insert(self.m_ShelveCollisions, shelve.m_ColShape)
		self.m_ShelveCount = self.m_ShelveCount + 1
	end
end

function JewelryStoreRobberyManager:spawnShelveGlassesAndContent()
	self:clearShelveGlassesAndContent()

	for _, shelve in pairs(self.m_Shelves) do
		local matrix = shelve.matrix
		shelve.m_Content = {}
		shelve.m_Looted = false

		local topGlass = createObject(1649, matrix:transformPosition(Vector3(0.32, -0.077, 1.021)), shelve.rotation + Vector3(270, 0, 0))
		topGlass:setInterior(self.m_Interior)
		topGlass:setDimension(self.m_Dimension)
		topGlass:setScale(Vector3(0.36, 1, 0.24))
		topGlass:setCollisionsEnabled(false)
		shelve.m_TopGlass = topGlass

		local frontGlass = createObject(1649, matrix:transformPosition(Vector3(0.3212, -0.491, 0.6)), shelve.rotation)
		frontGlass:setInterior(self.m_Interior)
		frontGlass:setDimension(self.m_Dimension)
		frontGlass:setScale(Vector3(0.36, 1, 0.25))
		frontGlass:setCollisionsEnabled(false)
		shelve.m_FrontGlass = frontGlass

		self:spawnShelveItems(matrix, shelve, math.randomchoice(JewelryStoreRobberyManager.ShelveContent.Top))
		self:spawnShelveItems(matrix, shelve, math.randomchoice(JewelryStoreRobberyManager.ShelveContent.Middle))
		self:spawnShelveItems(matrix, shelve, math.randomchoice(JewelryStoreRobberyManager.ShelveContent.Bottom))
	end

	for _, shelve in pairs(self.m_ShelvesAngled) do
		local matrix = shelve.matrix
		shelve.m_Content = {}
		shelve.m_Looted = false

		local topGlass = createObject(1649, matrix:transformPosition(Vector3(0.331, 0.079, 1.161)), shelve.rotation + Vector3(270, 0, 0))
		topGlass:setInterior(self.m_Interior)
		topGlass:setDimension(self.m_Dimension)
		topGlass:setScale(Vector3(0.359, 0.4, 0.15))
		topGlass:setCollisionsEnabled(false)
		shelve.m_TopGlass = topGlass

		local frontGlass = createObject(1649, matrix:transformPosition(Vector3(0.329, -0.302, 0.775)), shelve.rotation + Vector3(-20, 0, 0))
		frontGlass:setInterior(self.m_Interior)
		frontGlass:setDimension(self.m_Dimension)
		frontGlass:setScale(Vector3(0.360001, 0, 0.26))
		frontGlass:setCollisionsEnabled(false)
		shelve.m_FrontGlass = frontGlass

		self:spawnShelveItems(matrix, shelve, math.randomchoice(JewelryStoreRobberyManager.ShelveAngleContent.Top))
		self:spawnShelveItems(matrix, shelve, math.randomchoice(JewelryStoreRobberyManager.ShelveAngleContent.Middle))
		self:spawnShelveItems(matrix, shelve, math.randomchoice(JewelryStoreRobberyManager.ShelveAngleContent.Bottom))
	end
end

function JewelryStoreRobberyManager:clearShelveGlassesAndContent()
	for _, shelve in pairs(self.m_Shelves) do
		self:clearShelve(shelve)
	end

	for _, shelve in pairs(self.m_ShelvesAngled) do
		self:clearShelve(shelve)
	end
end

function JewelryStoreRobberyManager:clearShelve(shelve)
	shelve.m_Looted = true

	if isElement(shelve.m_TopGlass) then
		shelve.m_TopGlass:destroy()
	end

	if isElement(shelve.m_FrontGlass) then
		shelve.m_FrontGlass:destroy()
	end
	local matrix = shelve.matrix
	if shelve.m_Content then
		for key, object in pairs(shelve.m_Content) do
			if isElement(object) then
				object:destroy()
			end
		end
	end

	shelve.m_TopGlass = nil
	shelve.m_FrontGlass = nil
	shelve.m_Content = {}
end

function JewelryStoreRobberyManager:spawnShelveItems(matrix, shelve, items)
	for k, objectInfo in ipairs(items) do
		local object = createObject(objectInfo[1], matrix:transformPosition(objectInfo[2]), shelve.rotation + objectInfo[3])
		object:setInterior(self.m_Interior)
		object:setDimension(self.m_Dimension)
		object:setScale(objectInfo[4])
		object:setCollisionsEnabled(false)
		table.insert(shelve.m_Content, object)
	end
end

function JewelryStoreRobberyManager:destructor()
end

function JewelryStoreRobberyManager:Event_ShopPedColHit(hitElement)
	if self.m_RobberyInstance or self.m_ShopPed.m_InTarget then
		return false
	end

	if hitElement:getType() == "player" and hitElement:getDimension() == self.m_Dimension and hitElement:getInterior() == self.m_Interior then
		if self.m_ShopPedSoundCooldown + 30 * 1000 < getTickCount() then
			self.m_ShopPedSoundCooldown = getTickCount()
			local reverse = chance(10)
			triggerClientEvent("jewelryStoreRobberySound", hitElement, reverse)
		end
	end
end

function JewelryStoreRobberyManager:Event_ShopEnter(hitElement)
	if hitElement:getType() == "player" and hitElement:getDimension() == self.m_Dimension and hitElement:getInterior() == self.m_Interior then
		if not table.find(self.m_Players, hitElement) then
			table.insert(self.m_Players, hitElement)
		end
		hitElement:setVirtualTime(12, 0)
		if self.m_RobberyInstance then
			self.m_RobberyInstance:onShopEnter(hitElement)
		end
	end
end

function JewelryStoreRobberyManager:Event_ShopLeave(hitElement)
	if hitElement:getType() == "player" then
		if table.removevalue(self.m_Players, hitElement) then
			hitElement:clearVirtualTime()
			if self.m_RobberyInstance then
				self.m_RobberyInstance:onShopLeave(hitElement)
			end
		end
	end
end

function JewelryStoreRobberyManager:Event_PedTargetted(ped, attacker)
	if not attacker then return end
	local faction = attacker:getFaction()
	if faction and faction:isEvilFaction() then
		if attacker:isFactionDuty() then
			if not ActionsCheck:getSingleton():isActionAllowed(attacker) then
				return false
			end

			if self.m_RobberyInstance then
				return false
			end

			if not PermissionsManager:getSingleton():isPlayerAllowedToStart(attacker, "faction", "JewelryStoreRobbery") then
				attacker:sendError(_("Du bist nicht berechtigt einen Juwelierraub zu starten!", attacker))
				return false
			end

			if FactionState:getSingleton():countPlayers() < self.m_MinJewelryRobberyStateMembers and not DEBUG then
				attacker:sendError(_("Es müssen mindestens %d Staatsfraktionisten online sein!", attacker, self.m_MinJewelryRobberyStateMembers))
				return false
			end

			self:startRobbery(attacker)

			for key, player in pairs(self.m_Players) do
				if player and isElement(player) then
					outputChatBox(_("Geschäftsbesitzer sagt: Bitte tun sie mir nichts!", player), player, 255, 255, 255)
				end
			end
		else
			attacker:sendError(_("Nur Mitglieder im Fraktionsdienst können die Juwelier ausrauben!", attacker))
		end
	else
		attacker:sendError(_("Nur Mitglieder einer bösen Fraktion können die Juwelier ausrauben!", attacker))
	end
end

function JewelryStoreRobberyManager:startRobbery(attacker)
	if self.m_RobberyInstance or not attacker then
		return false
	end

	self.m_ShopPed:setTargetAble(false)
	self.m_RobberyInstance = JewelryStoreRobbery:new(attacker, self.m_ShelveCount)
end

function JewelryStoreRobberyManager:stopRobbery(state)
	if not self.m_RobberyInstance then
		return false
	end

	delete(self.m_RobberyInstance)
	self.m_RobberyInstance = nil

	self:spawnShelveGlassesAndContent()
	self.m_ShopPed:setTargetAble(true)
	self.m_ShopPed:setAnimation()

	if state == "timeup" then
		PlayerManager:getSingleton():breakingNews("Die Täter konnten die Beute nicht rechtzeitig abgeben!")
	elseif state == "state" then
		PlayerManager:getSingleton():breakingNews("Der Raub wurde erfolgreich vereitelt! Die Beute konnte sichergestellt werden!")
	else
		PlayerManager:getSingleton():breakingNews("Der Raub wurde abgeschlossen! Die Täter sind mit der Beute entkommen!")
	end
end
