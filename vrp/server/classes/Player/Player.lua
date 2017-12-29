-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
inherit(DatabasePlayer, Player)
registerElementClass("player", Player)

-- Create Hooks
Player.ms_QuitHook = Hook:new()
Player.ms_ChatHook = Hook:new()
Player.ms_ScreamHook = Hook:new()

addEvent("characterInitialized")

function Player:constructor()

	self:setVoiceBroadcastTo(nil)

	self.m_PrivateSync = {}
	self.m_PrivateSyncUpdate = {}
	self.m_PublicSync = {}
	self.m_PublicSyncUpdate = {}
	self.m_SyncListener = {}
	self.m_Achievements = {}
	self.m_LastGotWantedLevelTime = 0
	self.m_JoinTime = getTickCount()
	self.m_CurrentAFKTime = 0
	self.m_AFKTime = 0
	self.m_AFKStartTime = 0
	self.m_Crimes = {}
	self.m_LastPlayTime = 0
	self.m_LastJobAction = 0

	self.m_detachPlayerObjectBindFunc = bind(self.detachPlayerObjectBind, self)
end

function Player:destructor()
	if not self:isLoggedIn() then
		return
	end
	self.m_Disconnecting = true -- use this variable e.g. to prevent the server from sending events to this player
	if self.m_SpawnerVehicle and isElement(self.m_SpawnerVehicle) then -- TODO: Move this to an appropriate position to be able to use the quit hook
		destroyElement(self.m_SpawnerVehicle)
	end

	WorldItem.collectAllFromOwner(self)

	if self.m_Inventory then
		delete(self.m_Inventory)
	end

	-- Call the quit hook (to clean up various things before saving)

	Player.ms_QuitHook:call(self)

	if self:getRank() > 0 then
		Admin:getSingleton():removeAdmin(self,self:getRank())
	end

	if self:isFactionDuty() then
		takeAllWeapons(self)
	end

	self:setJailNewTime()

	if self:hasTemporaryStorage() then
		self:restoreStorage()
	end

	self:save()

	if self.m_BankAccount then
		delete(self.m_BankAccount)
	end

	-- Unload stuff
	PhoneNumber.unload(1, self.m_Id)

	if self:getGroup() then
		self:getGroup():checkDespawnVehicle()
	end

	--// gangwar
	triggerEvent("onDeloadCharacter",self)
end

function Player:connect()

end


function Player:Event_requestTime()
	self:triggerEvent("setClientTime",getRealTime())
end

function Player:join()
	--setElementDimension(self, PRIVATE_DIMENSION_SERVER) --don't do this as it ruins the view in login panel (desyncs of other players) // (maybe add it again if it bugs for some reason)
	setElementFrozen(self, true)
	--[[setTimer(function()

	end, 500, 1)]]

	--setCameraMatrix(self,445.12222, -1886.34387, 22.368610,369.74289, -2036.1087, 7.67188) -- Untill new Login Scenes
end


function Player:sendNews()
	self:triggerEvent("ingamenews", Forum:getSingleton():getNews())
end

function Player:triggerEvent(ev, ...)
	if self then
		triggerClientEvent(self, ev, self, ...)
	end
end

function Player:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), self, r, g, b, true)
end

function Player:startNavigationTo(pos)
	self:triggerEvent("navigationStart", pos.x, pos.y, pos.z)
end

function Player:stopNavigation()
	self:triggerEvent("navigationStop")
end

function Player:setJailBail( bail )
	if bail > 0 then
		self:sendMessage(_("Knast: Du kannst dich mit /bail für %d$ freikaufen!", self, bail), 255, 0, 0)
	end
	self.m_Bail = bail
end

function Player:loadCharacter()
	if self.m_DoNotSave then
		return
	end

	DatabasePlayer.Map[self.m_Id] = self
	self:loadCharacterInfo()
	self:setPrivateSync("Id", self.m_Id)

	-- Send infos to client
	local info = {
		Rank = self:getRank();
	}
	self:triggerEvent("retrieveInfo", info)


	-- Send initial sync
	self:sendInitialSync()

	self:setPublicSync("DeathTime", DEATH_TIME)
	self:setPublicSync("Rank", self:getRank())

	if self:getRank() > 0 then
		Admin:getSingleton():addAdmin(self,self:getRank())
	end

	if self:getGroup() then
		self:getGroup():onPlayerJoin(self)
	end

	self.m_PhoneNumber = (PhoneNumber.load(1, self.m_Id) or PhoneNumber.generateNumber(1, self.m_Id))

	-- Add Payday
	self:setNextPayday()
	self.m_Inventory = InventoryManager:getSingleton():loadInventory(self)

	-- Add binds
	self:initialiseBinds()

	-- Gangwar
	triggerEvent("onLoadCharacter",self)

	-- Premium
	self.m_Premium = PremiumPlayer:new(self)

	-- CJ Skin
	if self.m_Skin == 0 then
		for i = 0, #CJ_CLOTHE_TYPES, 1 do
			self:removeClothes(i)
			local data = self.m_CJData[tostring(i)]
			if data then
				self:addClothes(data.texture, data.model, i)
			end
		end
	end

	VehicleManager:getSingleton():createVehiclesForPlayer(self)

	if self:getGroup() then
		self:getGroup():spawnVehicles()
	end
	self:toggleControlsWhileObjectAttached(true)
	triggerEvent("characterInitialized", self)
end

function Player:createCharacter()
	sql:queryExec("INSERT INTO ??_character(Id, Skin, PosX, PosY, PosZ, Money, Health) VALUES(?, ?, ?, ?, ?, ?, 100)", sql:getPrefix(), self.m_Id, NOOB_SKIN, NOOB_SPAWN.x, NOOB_SPAWN.y, NOOB_SPAWN.z, START_MONEY_BAR)
	--self.m_Inventory = Inventory.create()
end

function Player:loadCharacterInfo()
	if self:isGuest() then
		Blip.sendAllToClient(self)
		RadarArea.sendAllToClient(self)
		VehicleELS.sendAllToClient(self)
		return
	end

	local row = sql:asyncQueryFetchSingle("SELECT Health, Armor, Weapons, UniqueInterior, IsDead, BetaPlayer FROM ??_character WHERE Id = ?", sql:getPrefix(), self.m_Id)
	if not row then
		return false
	end

	-- Reset Name
	self:setName(self:getAccount():getName())

	-- Load non-element related data
	self:load()

	self.m_UniqueInterior = row.UniqueInterior

	-- Load health data
	self.m_Health = row.Health
	self.m_Armor = row.Armor

	-- Load weapons
	self.m_Weapons = fromJSON(row.Weapons or "") or {}

	-- Give beta Achievement
	if toboolean(row.BetaPlayer) then
		self:giveAchievement(83)
	end

	-- Sync server objects to client
	Blip.sendAllToClient(self)
	RadarArea.sendAllToClient(self)
	VehicleELS.sendAllToClient(self)

	if HouseManager:isInstantiated() then
		HouseManager:getSingleton():loadBlips(self)
	end
	VehicleCategory:getSingleton():syncWithClient(self)

	self.m_IsDead = row.IsDead or 0

	-- Group blips
	local props = GroupPropertyManager:getSingleton():getPropsForPlayer( self )
	local x,y,z
	for k,v in ipairs( props ) do
		self:triggerEvent("addPickupToGroupStream",v.m_ExitMarker, v.m_Id)
		x,y,z = getElementPosition( v.m_Pickup )
		self:triggerEvent("createGroupBlip",x,y,z,v.m_Id, self:getGroup():getType())
	end
	--if self.m_Inventory then
	--	self.m_Inventory:setInteractingPlayer(self)
	--	self.m_Inventory:sendFullSync()
	--else
	--	outputDebugString("Inventory has not been instantiated successfully!")
	--end
	self:getOfflineMessages()
	if self.m_OfflineMessages then
		for key, msg in ipairs( self.m_OfflineMessages ) do
			self:sendShortMessage(msg[1], "Offlinenachricht" )
		end
	end
end


function Player:initialiseBinds()
	if self:getFaction() then
 		bindKey(self, "y", "down", "chatbox", "Fraktion")
 	end
end

function Player:buckleSeatBelt(vehicle)
	if self.m_SeatBelt then
		self.m_SeatBelt = false
		setElementData(self,"isBuckeled", false)
		triggerClientEvent(self, "playSeatbeltAlarm", self, true)
	elseif vehicle == getPedOccupiedVehicle(self) then
		self.m_SeatBelt = vehicle
		setElementData(self,"isBuckeled", true)
		triggerClientEvent(self, "playSeatbeltAlarm", self, false)
		self:playSound("files/audio/car_seatbelt_click.wav")
	else
		self.m_SeatBelt = false
		setElementData(self,"isBuckeled", false)
	end

	if self.vehicle then
		self:sendShortMessage(_("Du hast dich %sgeschnallt!", self, self.m_SeatBelt and "an" or "ab"))
	end
end

function Player:playSound(path)
	triggerClientEvent(self, "playSound", self, path)
end

function Player:save()
	if not self.m_Account or self:isGuest() then
		return
	end
	if self.m_DoNotSave then
		return
	end
	if self:isLoggedIn() then
		local x, y, z = getElementPosition(self)
		if getPedOccupiedVehicle(self) then
			z = z + 2
		end
		local interior = self:getInterior()

		-- Reset unique interior if interior or dimension doesn't match (ATTENTION: Dimensions must be unique as well)
		if interior == 0 or self:getDimension() ~= self.m_UniqueInterior then
			self.m_UniqueInterior = 0
		end

		local weapons = {}
		for slot = 0, 11 do -- exclude satchel detonator (slot 12)
			local weapon, ammo = getPedWeapon(self, slot), getPedTotalAmmo(self, slot)
			if ammo > 0 then
				weapons[#weapons + 1] = {weapon, ammo}
			end
		end

		local dimension = 0
		local sHealth = self:getHealth()
		local sArmor = self:getArmor()
		local sSkin = self:getModel()
		if interior > 0 then dimension = self:getDimension() end
		local spawnWithFac = self.m_SpawnWithFactionSkin and 1 or 0

		sql:queryExec("UPDATE ??_character SET PosX = ?, PosY = ?, PosZ = ?, Interior = ?, Dimension = ?, UniqueInterior = ?,Skin = ?, Health = ?, Armor = ?, Weapons = ?, PlayTime = ?, SpawnWithFacSkin = ?, AltSkin = ?, IsDead =? WHERE Id = ?", sql:getPrefix(),
			x, y, z, interior, dimension, self.m_UniqueInterior, sSkin, math.floor(sHealth), math.floor(sArmor), toJSON(weapons, true), self:getPlayTime(), spawnWithFac, self.m_AltSkin or 0, self.m_IsDead or 0, self.m_Id)

		VehicleManager:getSingleton():savePlayerVehicles(self)
		DatabasePlayer.save(self)
		outputServerLog("Saved Data for Player "..self:getName())
		outputDebugString("Saved Data for Player "..self:getName())
	end
end

function Player:spawn()
	if self:isGuest() then
		-- set default data (fallback / guest)
		self:setMoney(0)
		self:setXP(0)
		self:setKarma(0)
		self:setWanteds(0)
		self:setJobLevel(0)
		self:setWeaponLevel(0)
		self:setVehicleLevel(0)
		self:setSkinLevel(0)

		-- spawn the player
		spawnPlayer(self, NOOB_SPAWN, self.m_Skin, self.m_SavedInterior, self.m_SavedDimension) -- Todo: change position
		self:setRotation(0, 0, 180)
	else
		local quitTick = PlayerManager:getSingleton().m_QuitPlayers[self:getId()]
		local spawnSuccess = false
		local SpawnLocationProperty = self:getSpawnLocationProperty()

		if not quitTick or (getTickCount() - quitTick > 300000) then
			if self.m_SpawnLocation == SPAWN_LOCATIONS.DEFAULT then
				spawnSuccess = spawnPlayer(self, self.m_SavedPosition.x, self.m_SavedPosition.y, self.m_SavedPosition.z, 0, self.m_Skin or 0, self.m_SavedInterior, self.m_SavedDimension)
			elseif self.m_SpawnLocation == SPAWN_LOCATIONS.NOOBSPAWN then
				spawnSuccess = spawnPlayer(self, Vector3(1480.54, -1778.65, 13.55), 0, self.m_Skin or 0, 0, 0)
			elseif self.m_SpawnLocation == SPAWN_LOCATIONS.VEHICLE then
				if SpawnLocationProperty then
					local vehicle = VehicleManager:getSingleton():getPlayerVehicleById(self:getId(), SpawnLocationProperty)

					if vehicle and vehicle:getPositionType() == VehiclePositionType.World then
						if vehicle:getSpeed() == 0 then
							spawnSuccess = spawnPlayer(self, vehicle.matrix:transformPosition(VEHICLE_SPAWN_OFFSETS[vehicle:getModel()]), 0, self.m_Skin or 0, 0, 0)
						else
							self:sendWarning("Spawnen am Fahrzeug nicht möglich, Fahrzeug wird gerade benutzt")
						end
					else
						self:sendWarning("Spawnen am Fahrzeug nicht möglich, dass Fahrzeug ist am Abschlepphof oder ist nicht mehr vorhanden")
					end
				end
			elseif self.m_SpawnLocation == SPAWN_LOCATIONS.HOUSE then
				if SpawnLocationProperty then
					local house = HouseManager:getSingleton().m_Houses[SpawnLocationProperty]
					if house and house:isValidToEnter(self) then
						if spawnPlayer(self, Vector3(house.m_Pos), 0, self.m_Skin or 0, 0, 0) and house:enterHouse(self) then
							spawnSuccess = true
						end
					else
						self:sendWarning("Spawnen im Haus nicht möglich, du hast kein Zugriff mehr auf das Haus")
					end
				end
			elseif self.m_SpawnLocation == SPAWN_LOCATIONS.FACTION_BASE then
				if self:getFaction() then
					local position = factionSpawnpoint[self:getFaction():getId()]
					spawnSuccess = spawnPlayer(self, position[1], 0, self.m_Skin or 0, position[2], position[3])
				end
			elseif self.m_SpawnLocation == SPAWN_LOCATIONS.COMPANY_BASE then
				if self:getCompany() then
					local position = companySpawnpoint[self:getCompany():getId()]
					spawnSuccess = spawnPlayer(self, position[1], 0, self.m_Skin or 0, position[2], position[3])
				end
			--elseif self.m_SpawnLocation == SPAWN_LOCATIONS.GARAGE and self.m_LastGarageEntrance ~= 0 then
			--	VehicleGarages:getSingleton():spawnPlayerInGarage(self, self.m_LastGarageEntrance)
			end
		end

		-- if not able to spawn, spawn at last known location
		if not spawnSuccess then
			spawnPlayer(self, self.m_SavedPosition.x, self.m_SavedPosition.y, self.m_SavedPosition.z, 0, self.m_Skin or 0, self.m_SavedInterior, self.m_SavedDimension)
		end

		-- Update Skin
		self:setDefaultSkin()

		-- Teleport player into a "unique interior"
		if self.m_UniqueInterior ~= 0 then
			InteriorManager:getSingleton():teleportPlayerToInterior(self, self.m_UniqueInterior)
			self.m_UniqueInterior = 0
		end

		-- Apply and delete health data
		self:setHealth(math.max(self.m_Health, 1))
		self:setArmor(self.m_Armor)
		--self.m_Health, self.m_Armor = nil, nil -- this leads to errors as Player:spawn is called twice atm (--> introFinished event at the top)

		self:setPublicSync("Faction:Duty",false)

		if self:getFaction() and self:getFaction():isEvilFaction() then
			if self.m_SpawnWithFactionSkin then
				self:getFaction():changeSkin(self)
			else
				setElementModel( self, self.m_AltSkin or self.m_Skin)
			end
			setPedArmor(self, 100)
		end
		if self.m_PrisonTime > 0 then
			self:setPrison(self.m_PrisonTime, true)
		end
		if self.m_JailTime then
			if self.m_JailTime > 0 then
				self:moveToJail(false, true)
			end
		end

		-- Give weapons
		for k, info in pairs(self.m_Weapons) do
			giveWeapon(self, info[1], info[2])
		end
	end

	if self:isPremium() then
		self:setArmor(100)
		giveWeapon(self, 24, 35)
	end

	self:setFrozen(false)
	setCameraTarget(self, self)
	fadeCamera(self, true)

	if self.m_IsDead == 1 then
		if not self:getData("isInDeathMatch") then
			self:setReviveWeapons()
		end
		killPed(self)
	end

	WearableManager:getSingleton():removeAllWearables(self)

	if self.m_DeathInJail then
		FactionState:getSingleton():Event_JailPlayer(self, false, true, false, true)
	end

	self:triggerEvent("checkNoDm")
	triggerEvent("WeaponAttach:removeAllWeapons", self)
	triggerEvent("WeaponAttach:onInititate", self)

	VehicleTexture.requestTextures(self)
end

function Player:respawn(position, rotation, bJailSpawn)
	if not self:isLoggedIn() then
		return
	end

	if not position then
		position, rotation = HOSPITAL_POSITION, HOSPITAL_ROTATION
	else
		position, rotation = position, rotation
	end
	if self.m_PrisonTime > 0 then
		self:setPrison(self.m_PrisonTime, true)
	end
	if self.m_JailTime == 0 or not self.m_JailTime then

		self:setHeadless(false)
		spawnPlayer(self, position, rotation, self.m_Skin or 0)

	else
		spawnPlayer(self, position, rotation, self.m_Skin or 0)
		self:setHeadless(false)
		if not bJailSpawn then
			self:moveToJail(false,true)
		end
	end

	if self:getFaction() and self:getFaction():isEvilFaction() then
		if self.m_SpawnWithFactionSkin then
			self:getFaction():changeSkin(self)
		else
			setElementModel( self, self.m_AltSkin or self.m_Skin)
		end
		setPedArmor(self, 100)
	end

	if self:isPremium() then
		self:setArmor(100)
		giveWeapon(self, 24, 35)
	end
	self:setOnFire(false)
	setCameraTarget(self, self)
	self:triggerEvent("checkNoDm")
	self.m_IsDead = 0
	FactionState:getSingleton():uncuffPlayer( self )
	setPedAnimation(self,false)
	setElementAlpha(self,255)

	if isElement(self.ped_deadDouble) then
		destroyElement(self.ped_deadDouble)
	end
	WearableManager:getSingleton():removeAllWearables(self)
	if self.m_DeathInJail then
		FactionState:getSingleton():Event_JailPlayer(self, false, true, false, true)
	end
	triggerEvent("WeaponAttach:removeAllWeapons", self)
	triggerEvent("WeaponAttach:onInititate", self)
end

function Player:clearReviveWeapons()
	self.m_ReviveWeapons = false
end

function Player:dropReviveWeapons()
	self:destroyDropWeapons()
	if self.m_ReviveWeapons then
		self.m_WorldObjectWeapons =  {}
		local obj, weapon, ammo, model, x, y, z, dim, int, playerFaction
		for i = 1, 12 do
			if self.m_ReviveWeapons[i] then
				x,y,z = getElementPosition(self)
				int = getElementInterior(self)
				dim = getElementDimension(self)
				weapon =  self.m_ReviveWeapons[i][1]
				ammo = self.m_ReviveWeapons[i][2]
				model = WEAPON_MODELS_WORLD[weapon]
				playerFaction = self:getFaction()
				if not playerFaction then
					playerFaction = "Keine"
				else
					playerFaction:getShortName()
				end
				local x,y = getPointFromDistanceRotation(x, y, 3, 360*(i/12))
				if model then
					if weapon ~= 23 and weapon ~= 38 and weapon ~= 37 and weapon ~= 39 and  weapon ~= 16 and weapon ~= 17 then
						obj = createPickup(x,y,z-0.5, 3, model, 1 )
						if obj then
							setElementDoubleSided(obj,true)
							setElementDimension(obj, dim)
							setElementInterior(obj, int)
							obj:setData("weaponId", weapon)
							obj:setData("ammoInWeapon", ammo)
							obj:setData("weaponOwner", self)
							obj:setData("factionName", playerFaction)
							addEventHandler("onPickupHit", obj, bind(self.Event_onPlayerReviveWeaponHit, self))
							self.m_WorldObjectWeapons[#self.m_WorldObjectWeapons+1] = obj
						end
					end
				end
			end
		end
		triggerEvent("WeaponAttach:removeAllWeapons", self)
	end
end

function Player:destroyDropWeapons()
	if self.m_WorldObjectWeapons then
		for i = 1, #self.m_WorldObjectWeapons do
			if self.m_WorldObjectWeapons[i] and isElement(self.m_WorldObjectWeapons[i]) then
				destroyElement(self.m_WorldObjectWeapons[i])
			end
		end
	end
end

function Player:Event_onPlayerReviveWeaponHit( player )
	if player then
		if source then
			local weapon = source:getData("weaponId")
			local ammo = source:getData("ammoInWeapon")
			if weapon and ammo then
				player:sendShortMessage("Drücke Links-Alt + M um die Waffe aufzuheben!")
				player:triggerEvent("onTryPickupWeapon", source)
			end
		end
	end
end

function Player:setReviveWeapons()
	self.m_ReviveWeapons = {}
	local weaponInSlot, ammoInSlot
	for i = 1, 12 do
		weaponInSlot = getPedWeapon(self, i)
		ammoInSlot = getPedTotalAmmo(self, i )
		self.m_ReviveWeapons[i] = {weaponInSlot, ammoInSlot}
	end
end

function Player:giveReviveWeapons()
	if self.m_ReviveWeapons then
		for i = 1, 12 do
			if self.m_ReviveWeapons[i] then
				giveWeapon( self, self.m_ReviveWeapons[i][1], self.m_ReviveWeapons[i][2], true)
			end
		end
		return true
	else
		return false
	end
end


-- Message Boxes
function Player:sendError(text, timeout, title) 	self:triggerEvent("errorBox", text, timeout, title) 	end
function Player:sendWarning(text, timeout, title)	self:triggerEvent("warningBox", text, timeout, title) 	end
function Player:sendInfo(text, timeout, title)		self:triggerEvent("infoBox", text, timeout, title)		end
function Player:sendSuccess(text, timeout, title)	self:triggerEvent("successBox", text)	end

function Player:sendShortMessage(text, ...) self:triggerEvent("shortMessageBox", text, ...)	end

function Player:sendTrayNotification(text, icon, sound)	self:triggerEvent("sendTrayNotification", text, icon, sound)	end

function Player:isActive() return true end
function Player:isPremium() return self.m_Premium:isPremium() end

function Player:setPhonePartner(partner) self.m_PhonePartner = partner end
function DatabasePlayer:setSessionId(hash) self.m_SessionId = string.upper(hash) if self:isActive() then self:setPrivateSync("SessionID", self.m_SessionId) end end

function Player:getInventory()
	return self.m_Inventory
end

function Player.staticGroupChatHandler(self, command, ...)
	if self.m_Group then
		self.m_Group:sendChatMessage(self,table.concat({...}, " "))
	end
end

function Player.staticFactionChatHandler(self, command, ...)
	if self.m_Faction then
		self.m_Faction:sendChatMessage(self,table.concat({...}, " "))
	end
end

function Player.staticFactionAllianceChatHandler(self, command, ...)
	if self.m_Faction then
		local bndFaction = self.m_Faction:getAllianceFaction()
		if bndFaction then
			self.m_Faction:sendBndChatMessage(self, table.concat({...}, " "), bndFaction)
			bndFaction:sendBndChatMessage(self, table.concat({...}, " "), bndFaction)
		else
			self:sendError(_("Eure Allianz hat kein Bündnis!", self))
		end
	end
end

function Player.staticCompanyChatHandler(self, command, ...)
	if self.m_Company then
		self.m_Company:sendChatMessage(self,table.concat({...}, " "))
	end
end

function Player.staticStateFactionChatHandler(self, command, ...)
	if self.m_Faction and self.m_Faction:isStateFaction() then
		FactionState:getSingleton():sendStateChatMessage(self,table.concat({...}, " "))
	end
end


function Player:reportCrime(crimeType)
	--JobPolice:getSingleton():reportCrime(self, crimeType)
end

function Player:setSkin(skin)
	self.m_Skin = skin
	self:setModel(skin)
end

function Player:isFactionDuty()
  return self.m_FactionDuty
end

function Player:isCompanyDuty()
  return self.m_CompanyDuty
end

function Player:setFactionDuty(state)
	self.m_FactionDuty = state
	self:reloadBlips()
end

function Player:setCompanyDuty(state)
	self.m_CompanyDuty = state
	self:reloadBlips()
end

function Player:setJobDutySkin(skin)
	if skin ~= nil then
		self.m_JobDutySkin = skin
		self:setModel(skin)
	else
		self:setModel(self.m_Skin)
	end
end

function Player:setDefaultSkin()
	if self:getFaction() then
			if self:getFaction():isEvilFaction() then
				if self.m_SpawnWithFactionSkin then
					self:getFaction():changeSkin(self)
				else
					setElementModel( self, self.m_AltSkin or self.m_Skin)
				end
				return
			end
		end
	if self.m_SpawnWithFactionSkin then
		self:setModel(self.m_Skin or self.m_AltSkin or 0)
	else
		setElementModel( self, self.m_AltSkin or self.m_Skin or 0)
	end
end

function Player:setXP(xp)
	DatabasePlayer.setXP(self, xp)
	self:setPublicSync("XP", xp)

	-- Check if the player needs a level up
	local oldLevel = self:getLevel()
	if self:getLevel() > oldLevel then
		--self:triggerEvent("levelUp", self:getLevel())
		self:sendInfo(_("Du bist zu Level %d aufgestiegen", self, self:getLevel()))
	end
end

function Player:addBuff(buff,amount)
	Nametag:getSingleton():addBuff(self,buff,amount)
end

function Player:removeBuff(buff)
	Nametag:getSingleton():removeBuff(self,buff)
end

function Player:setPrivateSync(key, value)
	if self.m_PrivateSync[key] ~= value then
		self.m_PrivateSync[key] = value
		self.m_PrivateSyncUpdate[key] = key
	end
end

function Player:setPublicSync(key, value)
	if self.m_PublicSync[key] ~= value then
		self.m_PublicSync[key] = value
		self.m_PublicSyncUpdate[key] = true
	end
end

function Player:getPublicSync(key)
	return self.m_PublicSync[key]
end

function Player:getPrivateSync(key)
	return self.m_PrivateSync[key]
end

function Player:addSyncListener(player)
	self.m_SyncListener[player] = player
end

function Player:removeSyncListener(player)
	self.m_SyncListener[player] = nil
end

function Player:updateSync()
	local publicSync = {}
	for k, v in pairs(self.m_PublicSyncUpdate) do
		publicSync[k] = self.m_PublicSync[k]
	end
	self.m_PublicSyncUpdate = {}

	local privateSync = {}
	for k, v in pairs(self.m_PrivateSyncUpdate) do
		privateSync[k] = self.m_PrivateSync[k]
	end
	self.m_PrivateSyncUpdate = {}

	if table.size(privateSync) ~= 0 then
		triggerClientEvent(self, "PlayerPrivateSync", self, privateSync)
		for k, v in pairs(self.m_SyncListener) do
			triggerClientEvent(v, "PlayerPrivateSync", self, privateSync)
		end
	end

	if table.size(publicSync) ~= 0 then
		triggerClientEvent(root, "PlayerPublicSync", self, publicSync)
	end
end

function Player:sendInitialSync()
	triggerClientEvent(self, "PlayerPrivateSync", self, self.m_PrivateSync)

	-- Todo: Pack data and send only 1 event
	for k, player in pairs(getElementsByType("player")) do
		triggerClientEvent(self, "PlayerPublicSync", player, player.m_PublicSync)
	end
end

function Player:getLastGotWantedLevelTime()
	return self.m_LastGotWantedLevelTime
end

function Player:getJoinTime()
	return self.m_JoinTime
end

function Player:setAFKTime()
	if self.m_AFKStartTime > 0 then
		self.m_CurrentAFKTime = (getTickCount() - self.m_AFKStartTime)
	else
		self.m_AFKTime = self.m_AFKTime + self.m_CurrentAFKTime
		self:increaseStatistics("AFK", self.m_CurrentAFKTime)
		self.m_CurrentAFKTime = 0
	end
end

function Player:startAFK()
	self.m_AFKStartTime = getTickCount()
	self.m_isAFK = true
end

function Player:endAFK()
	self:setAFKTime() -- Set CurrentAFKTime
	self.m_AFKStartTime = 0
	self:setAFKTime() -- Add CurrentAFKTime to AFKTime + Reset CurrentAFKTime
	self.m_isAFK = false
end

function Player:getPlayTime()
	self:setAFKTime() -- Refresh AFK Time
	return math.floor(self.m_LastPlayTime + (getTickCount() - self.m_JoinTime - self.m_CurrentAFKTime-self.m_AFKTime)/1000/60)
end

function Player:setNextPayday()
	local payday = (math.floor(self:getPlayTime()/60)+1)*60
	self.m_NextPayday = payday
end

function Player:payDay()
	local time = getRealTime()
	self.m_paydayTexts = {}

	local income, outgoing, total = 0, 0, 0
	local income_faction, income_company, income_group, income_interest = 0, 0, 0, 0
	local outgoing_vehicles, outgoing_house = 0, 0
	local points_total = 0
	--Income:
	if self:getFaction() then
		income_faction = self:getFaction():paydayPlayer(self)
		points_total = points_total + self:getFaction():getPlayerRank(self)
		if income_faction > 0 then
			self:getFaction():transferMoney({self, true, true}, income_faction, ("Lohn für %s"):format(self:getName()), "Faction", "Loan", {silent = true})
			income = income + income_faction
			self:addPaydayText("income", _("%s-Lohn", self, self:getFaction():getShortName()), income_faction)
		end
	end
	if self:getCompany() then
		income_company = self:getCompany():paydayPlayer(self)
		points_total = points_total + self:getCompany():getPlayerRank(self)
		if income_company > 0 then
			income = income + income_company
			self:getCompany():transferMoney({self, true, true}, income_company, ("Lohn für %s"):format(self:getName()), "Company", "Loan", {silent = true})
			self:addPaydayText("income", _("%s-Lohn", self, self:getCompany():getShortName()), income_company)
		end
	end
	if self:getGroup() then
		income_group = self:getGroup():paydayPlayer(self)
		points_total = points_total + self:getGroup():getPlayerRank(self)
		if income_group > 0 then
			income = income + income_group
			self:getGroup():transferMoney({self, true, true}, income_group, ("Lohn für %s"):format(self:getName()), "Group", "Loan", {silent = true})
			self:addPaydayText("income", _("%s-Lohn", self, self:getGroup():getName()), income_group)
		end
	end

	if EVENT_HALLOWEEN and self.m_HalloweenPaydayBonus then
		income = income + self.m_HalloweenPaydayBonus
		BankServer.get("event.halloween"):transferMoney({self, true, true}, self.m_HalloweenPaydayBonus, "Halloween-Bonus", "Event", "HalloweenBonus", {silent = true})
		self:addPaydayText("income", _("Halloween-Bonus", self), self.m_HalloweenPaydayBonus)
	end

	income_interest = math.floor(self:getBankMoney()*0.01)
	if income_interest > 1500 then income_interest = 1500 end
	if income_interest > 0 then
		income = income + income_interest
		BankServer.get("server.bank"):transferMoney({self, true, true}, income_interest, "Bankzinsen", "Bank", "Interest", {silent = true})
		self:addPaydayText("income", _("Bankzinsen", self), income_interest)
		points_total = points_total + math.floor(income_interest/500)
	end

	--noob bonus
	if self:getPlayTime() <= PAYDAY_NOOB_BONUS_MAX_PLAYTIME * 60 then
		income = income + PAYDAY_NOOB_BONUS
		BankServer.get("server.bank"):transferMoney({self, true, true}, PAYDAY_NOOB_BONUS, "Willkommens-Bonus", "Gameplay", "NoobBonus", {silent = true})
		self:addPaydayText("income", _("Willkommens-Bonus", self), PAYDAY_NOOB_BONUS)
	end

	--Outgoing
	local temp_bank_money = self:getBankMoney() + income

	outgoing_vehicles, vehiclesTaxAmount = self:calcVehiclesTax()
	if outgoing_vehicles > 0 then
		self:addPaydayText("outgoing", _("Fahrzeugsteuer", self), outgoing_vehicles)
		self:transferBankMoney({BankServer.get("server.vehicle_tax"), nil, nil, true}, outgoing_vehicles, _("Fahrzeugsteuer", self), "Vehicle", "Tax", {silent = true, allowNegative = true})
		temp_bank_money = temp_bank_money - outgoing_vehicles
		points_total = points_total + vehiclesTaxAmount*2
	end

	if HouseManager:isInstantiated() then
		local houses = HouseManager:getSingleton():getPlayerRentedHouses(self)
		for index, house in pairs(houses) do
			local rent = house:getRent()
			if self:getBankMoney() - rent >= 0 then
				outgoing_house = outgoing_house + rent
				temp_bank_money = temp_bank_money - rent
				points_total = points_total + 1
				self:transferBankMoney({house.m_BankAccount, nil, nil, true}, outgoing_house, _("Miete an %s von %s", self, Account.getNameFromId(house:getOwner()), self:getName()), "House", "Rent", {silent = true})
				self:addPaydayText("outgoing", _("Miete an %s", self, Account.getNameFromId(house:getOwner())), rent)
			else
				self:addPaydayText("info", _("Du konntest die Miete von %s's Haus nicht bezahlen.", self, Account.getNameFromId(house:getOwner())))
				house:unrentHouse(self, true)
			end
		end
		--give points if the player owns a house
		if HouseManager:getSingleton():getPlayerHouse(self) then
			points_total = points_total + 10
		end
	end

	outgoing = outgoing_vehicles + outgoing_house

	total = income - outgoing
	self:addPaydayText("totalIncome", "", income)
	self:addPaydayText("totalOutgoing", "", outgoing)
	self:addPaydayText("total", "Total", total)


	if self:getWanteds() > 0 then
		self:addPaydayText("info", _("Dir wurde ein Wanted erlassen!", self))
		self:takeWanteds(1)
	end

	if self:getSTVO() > 0 then
		self:addPaydayText("info", _("Dir wurde ein StVO Punkt erlassen!", self))
		self:setSTVO(self:getSTVO() - 1)
	end

	self:givePoints(points_total, "Payday", true, true)
	self:addPaydayText("info", _("Du hast %s Punkte bekommen.", self, points_total))

	if EVENT_EASTER then
		self:addPaydayText("info", _("Du hast 5 Ostereier bekommen!", self))
		self:getInventory():giveItem("Osterei", 5)
	end

	if EVENT_CHRISTMAS then
		self:addPaydayText("info", _("Du hast 3 Zuckerstangen bekommen!", self))
		self:getInventory():giveItem("Zuckerstange", 3)
	end


	triggerClientEvent ( self, "paydayBox", self, self.m_paydayTexts)
	-- Add Payday again
	self:setNextPayday()
	self:save()
end

function Player:calcVehiclesTax()
	local tax = 0
	local amount = 0
	for key, vehicle in pairs(self:getVehicles()) do
		if vehicle:getTax() > 0 then
			tax = tax + vehicle:getTax()
			amount = amount + 1
		end
	end
	return tax, amount
end

function Player:addPaydayText(type, text, amount)
	if not self.m_paydayTexts[type] then self.m_paydayTexts[type] = {} end
	table.insert(self.m_paydayTexts[type], {text, amount})
	--self.m_paydayTexts[typ]["r"] = r
	--self.m_paydayTexts[typ]["g"] = g
	--self.m_paydayTexts[typ]["b"] = b
end

function Player:togglePhone(status)
	self.m_PhoneOn = status
	self:setPublicSync("Phone", status)
end

function Player:isPhoneEnabled()
	return self.m_PhoneOn
end

function Player:getCrimes()
	return self.m_Crimes
end

function Player:clearCrimes()
	self.m_Crimes = {}
end

function Player:addCrime(crimeType)
	self.m_Crimes[#self.m_Crimes + 1] = crimeType
end

function Player:__giveMoney(money, reason, silent) -- Overriden
	if not money or money < 1 then return false end
	local success = DatabasePlayer.__giveMoney(self, money, reason)
	if success then
		if money ~= 0 and not silent then
			self:sendShortMessage(("%s%s"):format("+"..toMoneyString(money), reason ~= nil and " - "..reason or ""), "SA National Bank (Bar)", {0, 94, 255}, 3000)
		end
		self:triggerEvent("playerCashChange", silent)
	end
	return success
end

function Player:__takeMoney(money, reason, silent) -- Overriden
	if not money or money < 1 then return false end
	local success = DatabasePlayer.__takeMoney(self, money, reason)
	if success then
		local money = math.abs(money)
		if money ~= 0 and not silent then
			self:sendShortMessage(("%s%s"):format("-"..toMoneyString(money), reason ~= nil and " - "..reason or ""), "SA National Bank (Bar)", {0, 94, 255}, 3000)
		end
		self:triggerEvent("playerCashChange", silent)
	end
	return success
end

function Player:__giveBankMoney(money, reason, silent) -- Overriden
	if not money or money < 1 then return false end
	local success = DatabasePlayer.__giveBankMoney(self, money, reason, silent)
	if success then
		if money ~= 0 and not silent then
			self:sendShortMessage(("%s$%s"):format("+"..money, reason ~= nil and " - "..reason or ""), "SA National Bank (Konto)", {0, 94, 255}, 3000)
		end
		self:triggerEvent("playerCashChange", bNoSound)
	end
	return success
end

function Player:__takeBankMoney(money, reason, silent) -- Overriden
	if not money or money < 1 then return false end
	local success = DatabasePlayer.__takeBankMoney(self, money, reason, silent)
	if success then
		if money ~= 0 and not silent then
			self:sendShortMessage(("%s$%s"):format("-"..money, reason ~= nil and " - "..reason or ""), "SA National Bank (Konto)", {0, 94, 255}, 3000)
		end
		self:triggerEvent("playerCashChange", bNoSound)
	end
	return success
end

function Player:startTrading(tradingPartner)
	if self == tradingPartner then
		return
	end

	self.m_TradingPartner = tradingPartner
	self.m_TradeItems = {}
	self.m_TradingStatus = false

	tradingPartner.m_TradingPartner = self
	tradingPartner.m_TradeItems = {}
	tradingPartner.m_TradingStatus = false

	--self:triggerEvent("tradingStart", self:getInventory():getId())
	--tradingPartner:triggerEvent("tradingStart", tradingPartner:getInventory():getId())
end

function Player:getTradingPartner()
	return self.m_TradingPartner
end

function Player.getQuitHook()
	return Player.ms_QuitHook
end

function Player.getChatHook()
	return Player.ms_ChatHook
end

function Player.getScreamHook()
	return Player.ms_ScreamHook
end

function Player:setKarma(karma)
	if karma < 0 and self.m_Karma >= 0 then
		self:giveAchievement(1)
	end
	if karma >= 0 and self.m_Karma < 0 then
		self:giveAchievement(2)
	end

	DatabasePlayer.setKarma(self, karma)
end

function Player:giveKarma(karma, reason, bNoSound, silent)
	if not karma then return false end
	local oldKarma = self.m_Karma
	local success = DatabasePlayer.giveKarma(self, karma, reason)
	if success then
		if karma < 0 and self.m_Karma >= 0 then
			self:giveAchievement(1)
		end
		if karma ~= 0 and not silent then
			self:sendShortMessage(("%s Karma%s"):format("+"..karma, reason ~= nil and " - "..reason or ""), "Spielfortschritt", {0, 94, 255}, 3000)
		end
	end
	return success
end

function Player:takeKarma(karma, reason, bNoSound, silent)
	if not karma or karma < 1 then return false end
	local oldKarma = self.m_Karma
	local success = DatabasePlayer.takeKarma(self, karma, reason)
	if success then
		if oldKarma >= 0 and self.m_Karma < 0 then
			self:giveAchievement(2)
		end
		if karma ~= 0 and not silent then
			self:sendShortMessage(("%s Karma%s"):format("-"..karma, reason ~= nil and " - "..reason or ""), "Spielfortschritt", {0, 94, 255}, 3000)
		end
	end
	return success
end

function Player:givePoints(p, reason, bNoSound, silent) -- Overriden
	DatabasePlayer.givePoints(self, p, reason)
	if p ~= 0 and not silent then
		self:sendShortMessage(("%s Punkte%s"):format("+"..p, reason ~= nil and " - "..reason or ""), "Spielfortschritt", {0, 94, 255}, 3000)
	end
end

function Player:takePoints(p, reason, bNoSound, silent) -- Overriden
	DatabasePlayer.takePoints(self, p, reason)
	if p ~= 0 and not silent then
		self:sendShortMessage(("%s Punkte%s"):format("-"..p , reason ~= nil and " - "..reason or ""), "Spielfortschritt", {0, 94, 255}, 3000)
	end
end

function Player:giveCombinedReward(reason, tblReward)
	local smText = ""
	for name, amount in pairs(tblReward) do
		if amount then
		    if type(amount) ~= "table" then amount = tonumber(amount) end
			if name == "money" then
			    if type(amount) ~= "table" then amount.amount = math.floor(amount.amount) end
				local prefix = amount.mode == "give" and "+" or ""
				local bank = amount.bank and " (Konto)" or ""

				if amount.mode == "give" then
					amount.toOrFrom:transferMoney({self, amount.bank, true}, amount.amount, reason, amount.category, amount.subcategory)
				else
					if amount.bank then
						self:transferBankMoney(amount.toOrFrom, amount.amount, reason, amount.category, amount.subcategory, {silent = true})
					else
						self:transferMoney(amount.toOrFrom, amount.amount, reason, amount.category, amount.subcategory, {silent = true})
					end
				end

				smText = smText .. ("%s%s%s\n"):format(prefix, toMoneyString(amount.amount), bank)
			elseif name == "points" then
				if amount > 0 then
					self:givePoints(amount, reason, false, true)
					smText = smText .. ("+%s Punkte\n"):format(amount)
				elseif amount < 0 then
					self:takePoints(math.abs(amount), reason, false, true)
					smText = smText .. ("%s Punkte\n"):format(amount)
				end
			elseif name == "karma" then
				if amount > 0 then
					self:giveKarma(amount, reason, false, true)
					smText = smText .. ("+%s Karma\n"):format(amount)
				elseif amount < 0 then
					self:takeKarma(math.abs(amount), reason, false, true)
					smText = smText .. ("%s Karma\n"):format(amount)
				end
			end
		end
	end
	self:sendShortMessage(smText:sub(0, #smText-1), reason, {0, 94, 255}, 10000)
end

function Player:setUniqueInterior(uniqueInteriorId)
	self.m_UniqueInterior = uniqueInteriorId
end

function Player:getLastChatMessage()
	if not self.m_LastChatMsg then
		self.m_LastChatMsg = {"", 0}
	end
	return unpack(self.m_LastChatMsg) -- message, timeSent
end

function Player:setLastChatMessage(msg)
	self.m_LastChatMsg = {msg, getTickCount()}
end


function Player:getPlayersInChatRange( irange)
	local range
	if irange == 0 then
		range = CHAT_WHISPER_RANGE
	elseif irange == 1 then
		range = CHAT_TALK_RANGE
	elseif irange == 2 then
		range = CHAT_SCREAM_RANGE
	elseif irange == 3 then
		range = CHAT_DISTRICT_RANGE
	end
	local pos = self:getPosition()
	local playersInRange = {}
	local elementTable = getElementsByType("player")
	local player,dimension,interior,check
	for index = 1,#elementTable do
	    if (pos - elementTable[index]:getPosition()).length <= range then
			player = elementTable[index]
			dimension = player.dimension
			interior = player.interior
			if interior == self.interior then
				if dimension == self.dimension then
					playersInRange[#playersInRange+1] = player
				end
			end
		end
	end
	return playersInRange
end

function Player:toggleControlsWhileObjectAttached(bool)
	if bool then
		if not getElementData(self,"schutzzone") then
			toggleControl(self, "jump", bool )
			toggleControl(self, "fire", bool )
			toggleControl(self, "sprint", bool )
			toggleControl(self, "next_weapon", bool )
			toggleControl(self, "previous_weapon", bool )
			toggleControl(self, "enter_exit", bool )
			toggleControl(self, "enter_passenger", bool )
		end
	else
		toggleControl(self, "jump", bool )
		toggleControl(self, "fire", bool )
		toggleControl(self, "sprint", bool )
		toggleControl(self, "next_weapon", bool )
		toggleControl(self, "previous_weapon", bool )
		toggleControl(self, "enter_exit", bool )
		toggleControl(self, "enter_passenger", bool )
	end
end

function Player:attachPlayerObject(object, allowWeapons)
	local model = object.model
	if PlayerAttachObjects[model] then
		if not self:getPlayerAttachedObject() then
			local settings = PlayerAttachObjects[model]
			object:setCollisionsEnabled(false)
			object:attach(self, settings["pos"], settings["rot"])
			if not allowWeapons then
				self:toggleControlsWhileObjectAttached(false)
			end
			self:sendShortMessage(_("Drücke 'n' um den/die %s abzulegen!", self, settings["name"]))
			bindKey(self, "n", "down", self.m_detachPlayerObjectBindFunc, object)
			self.m_RefreshAttachedObject = bind(self.refreshAttachedObject, self)
			addEventHandler("onElementDimensionChange", self, self.m_RefreshAttachedObject)
			addEventHandler("onElementInteriorChange", self, self.m_RefreshAttachedObject)
			addEventHandler("onPlayerWasted", self, self.m_RefreshAttachedObject)
		else
			self:sendError(_("Du hast bereits ein Objekt dabei!", self))
		end
	else
		--self:sendError("Internal Error: attachPlayerObject: Wrong Object")
	end
end

function Player:refreshAttachedObject(instant)
	local func = function()
		if self:getPlayerAttachedObject() then
			local object = self:getPlayerAttachedObject()
			if self:isDead() then
				self:detachPlayerObject(object)
			end
			object:setInterior(self:getInterior())
			object:setDimension(self:getDimension())

		end
	end
	if instant then	func() else	setTimer(func, 2000 ,1) end
end

function Player:detachPlayerObjectBind(presser, key, state, object)
	self:detachPlayerObject(object)
end

function Player:detachPlayerObject(object, collisionNextFrame)
	if not self:isLoggedIn() then return end
	local model = object.model
	if PlayerAttachObjects[model] then
		object:detach(self)
		object:setPosition(self.position + self.matrix.forward)
		if collisionNextFrame then
			nextframe(function() --to "prevent" it from spawning in another player / vehicle (added for RTS)
				object:setCollisionsEnabled(true)
			end)
		else
			object:setCollisionsEnabled(true)
		end
		unbindKey(self, "n", "down", self.m_detachPlayerObjectBindFunc)
		self:setAnimation("carry", "crry_prtial", 1, false, true, true, false) -- Stop Animation Work Arround
		self:toggleControlsWhileObjectAttached(true)
		removeEventHandler("onElementDimensionChange", self, self.m_RefreshAttachedObject)
		removeEventHandler("onElementInteriorChange", self, self.m_RefreshAttachedObject)
		removeEventHandler("onPlayerWasted", self, self.m_RefreshAttachedObject)
	end
end

function Player:getPlayerAttachedObject()
	local model
	for key, value in pairs (getAttachedElements(self)) do
		if value and isElement(value) then
			model = value:getModel()
			if PlayerAttachObjects[model] then
				return value
			end
		end
	end
	return false
end

function Player:attachToVehicle(forceDetach)
	if self:getPrivateSync("isAttachedToVehicle") then
		self:setPrivateSync("isAttachedToVehicle", false)
		self:detach()
		return
	end

	if forceDetach or not self.contactElement or self.contactElement:getType() ~= "vehicle" then return end
	if self.contactElement:getVehicleType() == VehicleType.Boat or VEHICLE_PICKUP[self.contactElement:getModel()] then
		if self.contactElement:getSpeed() < 20 then
			local px, py, pz = getElementPosition(self)
			local vx, vy, vz = getElementPosition(self.contactElement)
			local sx = px - vx
			local sy = py - vy
			local sz = pz - vz

			local rotpX = 0
			local rotpY = 0
			local rotpZ = getPlayerRotation(self)

			local rotvX, rotvY, rotvZ = getVehicleRotation(self.contactElement)

			local t, p, f = math.rad(self.contactElement.rotation.x), math.rad(self.contactElement.rotation.y), math.rad(self.contactElement.rotation.z)
			local ct, st, cp, sp, cf, sf = math.cos(t), math.sin(t), math.cos(p), math.sin(p), math.cos(f), math.sin(f)

			local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
			local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
			local y = st*sz - sf*ct*sx + cf*ct*sy

			local rotX = rotpX - rotvX
			local rotY = rotpY - rotvY
			local rotZ = rotpZ - rotvZ

			self:attach(self.contactElement, x, y, z, rotX, rotY, rotZ)
			self:setPrivateSync("isAttachedToVehicle", self.contactElement)
			self:sendShortMessage(_("Drücke 'X' um dich nicht mehr am Fahrzeug festzuhalten.", self))
		else
			self:sendWarning(_("Dieses Fahrzeug ist zu schnell, um sich daran festzuhalten!", self))
		end
	end
end

function Player:setModel( skin )
	setElementModel( self, skin or 0)
end

function Player:reloadBlips()
	return Blip.sendAllToClient(self)
end

function Player:endPrison()
	if isElement(self) then
		self:setPosition(Vector3(1478.87, -1726.17, 13.55))
		setElementDimension(self,0)
		setElementInterior(self, 0)
		toggleControl(self, "fire", true)
		toggleControl(self, "jump", true)
		toggleControl(self, "aim_weapon", true)
		self:triggerEvent("playerLeftPrison")
		self:triggerEvent("checkNoDm")
		self:setData("inAdminPrison",false,true)
		self:sendInfo(_("Du wurdest aus dem Prison entlassen! Benimm dich nun besser!", self))
	end
	if self.m_PrisonTimer then killTimer(self.m_PrisonTimer) end
	self.m_PrisonTime = 0
	if self.m_JailTime > 0 then
		self:moveToJail(false,false)
	end
end

function Player:meChat(system, ...)
	if self:isDead() then
		return
	end

	local argTable = { ... }
	local text = table.concat ( argTable , " " )
	local playersToSend = self:getPlayersInChatRange( 1 )
	local systemText = ""
	local receivedPlayers = {}
	local message = ("%s %s"):format(self:getName(), text)
	if system == true then systemText = "★" end
	for index = 1,#playersToSend do
		outputChatBox(("%s %s"):format(systemText, message), playersToSend[index], 255,105,180)
		if playersToSend[index] ~= self then
            receivedPlayers[#receivedPlayers+1] = playersToSend[index]:getName()
        end

	end
end

function Player:sendPedChatMessage( name, ...)
	if self:isDead() then
		return
	end
	local argTable = { ... }
	local text = table.concat ( argTable , " " )
	local playersToSend = self:getPlayersInChatRange( 1 )
	local systemText = name.." sagt:"
	local receivedPlayers = {}
	local message = text
	for index = 1,#playersToSend do
		outputChatBox(("%s %s"):format(systemText, message), playersToSend[index], 220,220,220)
		if playersToSend[index] ~= self then
            receivedPlayers[#receivedPlayers+1] = playersToSend[index]:getName()
        end

	end
end

function Player:districtChat(...)
	if self:isDead() then
		return
	end
	local argTable = { ... }
	local text = table.concat ( argTable , " " )
	local playersToSend = self:getPlayersInChatRange( 3 )
	local receivedPlayers = {}
	local message = ("%s"):format(text)
	local systemText = "✪"
	for index = 1,#playersToSend do
		outputChatBox(("%s %s"):format(systemText, message), playersToSend[index],192, 196, 194)
		if playersToSend[index] ~= self then
            receivedPlayers[#receivedPlayers+1] = playersToSend[index]:getName()
        end
	end
end

function Player:moveToJail(CUTSCENE, alreadySpawned)
	if self.m_JailTime > 0 then
		local rnd = math.random(1, #Jail.Cells)
		if not alreadySpawned and not self.m_DeathInJail then
			self:respawn(false, false, true)
		end
		self:setPosition(Jail.Cells[rnd])
		setElementInterior(self, 0)
		setElementDimension(self, 0)
		self:setRotation(0, 0, 90)
		self:setSkin(self.m_Skin)
		self:toggleControl("fire", false)
		self:toggleControl("jump", false)
		self:toggleControl("aim_weapon ", false)

		self.m_JailStart = getRealTime().timestamp
		self:setData("inJail",true, true)
		self.m_JailTimer = setTimer(
			function()
				if isElement(self) then
					if self:getData("inJail") then
						FactionState:getSingleton():freePlayer(self)
					end
				end
			end, self.m_JailTime * 60000, 1
		)

		self:triggerEvent("playerJailed", self.m_JailTime, CUTSCENE)
	end
end

function Player:isInGangwar()
	return Gangwar:getSingleton():isPlayerInGangwar(self)
end

-- Override mta function
function Player:removeClothes(typeId)
	if self:getSkin() ~= 0 then return false end
	removePedClothes(self, typeId)

	self.m_SkinData[typeId] = nil
end

-- Override mta function
function Player:addClothes(texture, model, typeId)
	if self:getSkin() ~= 0 then return false end
	addPedClothes(self, texture, model, typeId)

	self.m_SkinData[typeId] = {texture = texture, model = model}
end

-- Temporary player storage
local stats = {69, 70, 71, 72, 74, 76, 77, 78, 160, 229, 230}
function Player:createStorage(storeSkills)
	self.m_Storage = {
		weapons = {},
		stats = {},
		health = self:getHealth(),
		armor = self:getArmor(),
	}

	for slot = 0, 11 do
		local weapon, ammo = getPedWeapon(self, slot), getPedTotalAmmo(self, slot)
		if ammo > 0 then
			self.m_Storage.weapons[weapon] = ammo
		end
	end

	takeAllWeapons(self)

	if storeSkills then
		for _, stat in pairs(stats) do
			self.m_Storage.stats[stat] = self:getStat(stat)
			setPedStat(self, stat, 0)
		end
	end
end

function Player:restoreStorage()
	if not self.m_Storage then return false end

	takeAllWeapons(self)
	for weapon, ammo in pairs(self.m_Storage.weapons) do
		giveWeapon(self, weapon, ammo)
	end

	for stat, value in pairs(self.m_Storage.stats) do
		setPedStat(self, stat, value)
	end

	self:setHealth(self.m_Storage.health)
	self:setArmor(self.m_Storage.armor)

	self.m_Storage = nil
end

function Player:hasTemporaryStorage()
	return type(self.m_Storage) == "table"
end
