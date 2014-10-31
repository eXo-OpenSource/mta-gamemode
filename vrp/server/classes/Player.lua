-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
inherit(DatabasePlayer, Player)
registerElementClass("player", Player)

addEvent("introFinished", true)
addEventHandler("introFinished", root, function()
	client.m_TutorialStage = 3 -- todo: character creation and tutorial mission
	client:spawn() 
end)

function Player:constructor()		
	setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	setElementFrozen(self, true)
	
	self.m_PrivateSync = {}
	self.m_PrivateSyncUpdate = {}
	self.m_PublicSync = {}
	self.m_PublicSyncUpdate = {}
	self.m_SyncListener = {}
end

function Player:destructor()
	if self.m_JobVehicle and isElement(self.m_JobVehicle) then
		destroyElement(self.m_JobVehicle)
	end
	
	self:save()
	
	-- Unload stuff
	if self.m_Inventory then
		delete(self.m_Inventory)
	end
end

function Player:connect()
	if not Ban.checkBan(self) then return end
end

function Player:join()

end

function Player:sendNews()
	self:triggerEvent("ingamenews", Forum:getSingleton():getNews())
end

function Player:triggerEvent(ev, ...)
	triggerClientEvent(self, ev, self, ...)
end

function Player:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), self, r, g, b, true)
end

function Player:startNavigationTo(x, y, z)
	self:triggerEvent("navigationStart", x, y, z)
end

function Player:stopNavigation()
	self:triggerEvent("navigationStop")
end

function Player:loadCharacter()
	DatabasePlayer.Map[self.m_Id] = self
	self:loadCharacterInfo()
	
	-- Send infos to client
	local info = {
		Rank = self:getRank();
	}
	self:triggerEvent("retrieveInfo", info)
	
	-- Add binds
	self:initialiseBinds()
	
	-- Add command and event handler
	addCommandHandler("Group", Player.staticGroupChatHandler)
end

function Player:createCharacter()
	sql:queryExec("INSERT INTO ??_character(Id) VALUES(?);", sql:getPrefix(), self.m_Id)
	
	self.m_Inventory = Inventory.create()
end

function Player:loadCharacterInfo()
	local row = sql:asyncQueryFetchSingle("SELECT Weapons FROM ??_character WHERE Id = ?", sql:getPrefix(), self.m_Id)
	if not row then
		return false
	end

	-- Load non-element related data
	self:load()
	
	-- Load weapons
	if row.Weapons and row.Weapons ~= "" then
		local weaponID = 0
		for i = 1, 26 do
			local value = gettok(row.Weapons, i, '|')
			if tonumber(value) ~= 0 then
				if math.mod(i, 2) == 1 then
					weaponID = value
				else
					giveWeapon(self, weaponID, value)
				end
			end
		end
	end
	
	-- Sync server objects to client
	Blip.sendAllToClient()
	RadarArea.sendAllToClient()
end

function Player:initialiseBinds()
	bindKey(self, "u", "down", "chatbox", "Group")
	bindKey(self, "l", "down", function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle then vehicle:toggleLight(player) end end)
	bindKey(self, "x", "down", function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle and getPedOccupiedVehicleSeat(player) == 0 then vehicle:toggleEngine(player) end end)
	bindKey(self, "i", "down", function(player) if player:getInventory():getInteractingPlayer() then player:getInventory():closeFor(player) else player:getInventory():openFor(player) end end)
end

function Player:save()
	if not self.m_Account or self:isGuest() then	
		return 
	end
	local x, y, z = getElementPosition(self)
	local interior = getElementInterior(self)
	local weapons = ""
	for i = 0, 12 do
		if i == 0 then weapons = getPedWeapon(self, i).."|"..getPedTotalAmmo(self, i)
		else weapons = weapons.."|"..getPedWeapon(self, i).."|"..getPedTotalAmmo(self, i) end
	end
	
	sql:queryExec("UPDATE ??_character SET PosX = ?, PosY = ?, PosZ = ?, Interior = ?, Weapons = ?, InventoryId = ? WHERE Id = ?;", sql:getPrefix(), x, y, z, interior, weapons, self.m_Inventory:getId(), self.m_Id)

	if self:getInventory() then
		self:getInventory():save()
	end
	DatabasePlayer.save(self)
end

function Player:spawn()
	if self.m_SpawnLocation == SPAWN_LOCATION_DEFAULT then
		spawnPlayer(self, self.m_SavedPosition.X, self.m_SavedPosition.Y, self.m_SavedPosition.Z, 0, self.m_Skin, self.m_SavedInterior, 0)
	elseif self.m_SpawnLocation == SPAWN_LOCATION_GARAGE and self.m_LastGarageEntrance ~= 0 then
		VehicleGarages:getSingleton():spawnPlayerInGarage(self, self.m_LastGarageEntrance)
	else
		self:sendMessage("An error occurred", 255, 0, 0)
	end
	
	setElementFrozen(self, false)
	setCameraTarget(self, self)
	fadeCamera(self, true)
end

function Player:respawnAfterDeath()
	spawnPlayer(self, 2028--[[+math.random(-4, 4)--]], -1405--[[+math.random(-2, 2)]], 18)
end

-- Message Boxes
function Player:sendError(text, ...) 	self:triggerEvent("errorBox", text:format(...)) 	end
function Player:sendWarning(text, ...)	self:triggerEvent("warningBox", text:format(...)) 	end
function Player:sendInfo(text, ...)		self:triggerEvent("infoBox", text:format(...))		end
function Player:sendSuccess(text, ...)	self:triggerEvent("successBox", text:format(...))	end
function Player:sendShortMessage(text, ...) self:triggerEvent("shortMessageBox", text:format(...))	end
function Player:isActive() return true end

function Player:setPhonePartner(partner) self.m_PhonePartner = partner end

function Player.staticGroupChatHandler(self, command, ...)
	if self.m_Group then
		self.m_Group:sendMessage(("[GROUP] %s: %s"):format(getPlayerName(self), table.concat({...}, " ")))
	end
end

function Player:reportCrime(crimeType)
	JobPolice:getSingleton():reportCrime(self, crimeType)
end

function Player:setSkin(skin)
	self.m_Skin = skin
	setElementModel(self, skin)
end

function Player:setJobDutySkin(skin)
	if skin ~= nil then
		self.m_JobDutySkin = skin
		setElementModel(self, skin)
	else
		setElementModel(self, self.m_Skin)
	end
end

function Player:setKarma(karma)
	DatabasePlayer.setKarma(self, karma)
	self:setPublicSync("Karma", self.m_Karma)
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

function Player:sendInitialSyncTo(target)
	if target == self then
		triggerClientEvent(self, "PlayerPrivateSync", self, self.m_PrivateSync)
	end
	
	triggerClientEvent(target, "PlayerPublicSync", self, self.m_PublicSyncUpdate)
end
