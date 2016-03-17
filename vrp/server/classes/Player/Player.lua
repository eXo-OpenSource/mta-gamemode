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
	self.m_Achievements = {}
	self.m_LastGotWantedLevelTime = 0
	self.m_JoinTime = getTickCount()
	self.m_Crimes = {}
	self.m_LastPlayTime = 0
	self:destroyChatColShapes( )
	self:createChatColshapes( )

	self.m_detachPlayerObjectBindFunc = bind(self.detachPlayerObjectBind, self)
	self:toggleControlsWhileObjectAttached(true)
end

function Player:destructor()
	if not self:isLoggedIn() then
		return
	end
	if self.m_JobVehicle and isElement(self.m_JobVehicle) then -- TODO: Move this to an appropriate position to be able to use the quit hook
		destroyElement(self.m_JobVehicle)
	end

	if self.m_Inventory then
		delete(self.m_Inventory)
	end
	-- Collect all world items
--	local worldItems = WorldItem.getItemsByOwner(self)
--	for k, worldItem in pairs(worldItems) do
--		worldItem:collect(self)
--	end

	-- Call the quit hook (to clean up various things before saving)
	Player.ms_QuitHook:call(self)

	if self:getRank() > 0 then
		Admin:getSingleton():removeAdmin(self,self:getRank())
	end

	self:save()

	-- Unload stuff
	--if self.m_Inventory then
	--	delete(self.m_Inventory)
	--end

	--// gangwar
	triggerEvent("onDeloadCharacter",self)
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

function Player:startNavigationTo(pos)
	self:triggerEvent("navigationStart", pos.x, pos.y, pos.z)
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


	-- Send initial sync
	self:sendInitialSync()

	-- Add binds
	self:initialiseBinds()

	-- Add command and event handler
	addCommandHandler("Fraktion", Player.staticFactionChatHandler)
	addCommandHandler("Group", Player.staticGroupChatHandler)
	self:setPublicSync("Rank", self:getRank())

	if self:getRank() > 0 then
		Admin:getSingleton():addAdmin(self,self:getRank())
	end

	-- Add Payday
	self:setNextPayday()
	self.m_Inventory = InventoryManager:getSingleton():loadInventory(self)

	--// Gangwar
	triggerEvent("onLoadCharacter",self)
end

function Player:createCharacter()
	sql:queryExec("INSERT INTO ??_character(Id,PosX,PosY,PosZ) VALUES(?,?,?,?);", sql:getPrefix(), self.m_Id, NOOB_SPAWN.x, NOOB_SPAWN.y, NOOB_SPAWN.z)
	--self.m_Inventory = Inventory.create()
end

function Player:loadCharacterInfo()
	if self:isGuest() then
		Blip.sendAllToClient(self)
		RadarArea.sendAllToClient(self)
		return
	end

	local row = sql:asyncQueryFetchSingle("SELECT Health, Armor, Weapons, UniqueInterior FROM ??_character WHERE Id = ?", sql:getPrefix(), self.m_Id)
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

	-- Sync server objects to client
	Blip.sendAllToClient(self)
	RadarArea.sendAllToClient(self)
	FactionManager:getSingleton():sendAllToClient(self)
	--if self.m_Inventory then
	--	self.m_Inventory:setInteractingPlayer(self)
	--	self.m_Inventory:sendFullSync()
	--else
	--	outputDebugString("Inventory has not been instantiated successfully!")
	--end
end

function Player:initialiseBinds()
	bindKey(self, "c", "down", "chatbox", "Group")
	bindKey(self, "y", "down", "chatbox", "Fraktion")
	bindKey(self, "l", "down", function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle then vehicle:toggleLight(player) end end)
	bindKey(self, "x", "down", function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle and getPedOccupiedVehicleSeat(player) == 0 then vehicle:toggleEngine(player) end end)
end

function Player:save()
	if not self.m_Account or self:isGuest() then
		return
	end
	local x, y, z = getElementPosition(self)
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

	sql:queryExec("UPDATE ??_character SET PosX = ?, PosY = ?, PosZ = ?, Interior = ?, UniqueInterior = ?, Health = ?, Armor = ?, Weapons = ?, PlayTime = ? WHERE Id = ?;", sql:getPrefix(),
		x, y, z, interior, self.m_UniqueInterior, math.floor(self:getHealth()), math.floor(self:getArmor()), toJSON(weapons, true), self:getPlayTime(), self.m_Id)

	--if self:getInventory() then
	--	self:getInventory():save()
	--end
	DatabasePlayer.save(self)
end

function Player:spawn()
	if self:isGuest() then
		-- set default data (fallback / guest)
		self:setMoney(0)
		self:setXP(0)
		self:setKarma(0)
		self:setWantedLevel(0)
		self:setJobLevel(0)
		self:setWeaponLevel(0)
		self:setVehicleLevel(0)
		self:setSkinLevel(0)

		-- spawn the player
		spawnPlayer(self, NOOB_SPAWN, self.m_Skin, self.m_SavedInterior, 0) -- Todo: change position
		self:setRotation(0, 0, 180)
	else
		if self.m_SpawnLocation == SPAWN_LOCATION_DEFAULT then
			spawnPlayer(self, self.m_SavedPosition.x, self.m_SavedPosition.y, self.m_SavedPosition.z, 0, self.m_Skin, self.m_SavedInterior, 0)
		elseif self.m_SpawnLocation == SPAWN_LOCATION_GARAGE and self.m_LastGarageEntrance ~= 0 then
			VehicleGarages:getSingleton():spawnPlayerInGarage(self, self.m_LastGarageEntrance)
		else
			outputServerLog("Invalid spawn location ("..self:getName()..")")
		end

		-- Teleport player into a "unique interior"
		if self.m_UniqueInterior ~= 0 then
			InteriorManager:getSingleton():teleportPlayerToInterior(self, self.m_UniqueInterior)
			self.m_UniqueInterior = 0
		end

		-- Apply and delete health data
		self:setHealth(self.m_Health)
		self:setArmor(self.m_Armor)
		--self.m_Health, self.m_Armor = nil, nil -- this leads to errors as Player:spawn is called twice atm (--> introFinished event at the top)

		-- Give weapons
		for k, info in pairs(self.m_Weapons) do
			giveWeapon(self, info[1], info[2])
		end
	end

	self:setFrozen(false)
	setCameraTarget(self, self)
	fadeCamera(self, true)

	-- reAttach ChatCols
	attachElements(self.chatCol_whisper, self)
	attachElements(self.chatCol_talk, self)
	attachElements(self.chatCol_scream, self)
end

function Player:respawn(position, rotation)
	if not self:isLoggedIn() then
		return
	end

	position = position or Vector3(2028, -1405, 18)
	rotation = rotation or 0

	spawnPlayer(self, position, rotation, self.m_Skin)
	setCameraTarget(self, self)
end


-- Message Boxes
function Player:sendError(text) 	self:triggerEvent("errorBox", text) 	end
function Player:sendWarning(text)	self:triggerEvent("warningBox", text) 	end
function Player:sendInfo(text)		self:triggerEvent("infoBox", text)		end
function Player:sendInfoTimeout(text, timeout) self:triggerEvent("infoBox", text, timeout) end
function Player:sendSuccess(text)	self:triggerEvent("successBox", text)	end
function Player:sendShortMessage(text, ...) self:triggerEvent("shortMessageBox", text, ...)	end
function Player:isActive() return true end

function Player:setPhonePartner(partner) self.m_PhonePartner = partner end
function DatabasePlayer:setSessionId(hash) self.m_SessionId = string.upper(hash) if self:isActive() then self:setPrivateSync("SessionID", self.m_SessionId) end end

function Player:getInventory()
	return self.m_Inventory
end

function Player.staticGroupChatHandler(self, command, ...)
	if self.m_Group then
		self.m_Group:sendMessage(("[GROUP] %s: %s"):format(getPlayerName(self), table.concat({...}, " ")))
	end
end

function Player.staticFactionChatHandler(self, command, ...)
	if self.m_Faction then
		self.m_Faction:sendChatMessage(self,table.concat({...}, " "))
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

function Player:setJobDutySkin(skin)
	if skin ~= nil then
		self.m_JobDutySkin = skin
		self:setModel(skin)
	else
		self:setModel(self.m_Skin)
	end
end

function Player:setDefaultSkin()
	self:setModel(self.m_Skin)
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

function Player:getPlayTime()
	return math.floor(self.m_LastPlayTime + (getTickCount() - self.m_JoinTime)/1000/60)
end

function Player:setNextPayday()
	local payday = (math.floor(self:getPlayTime()/60)+1)*60
	self.m_NextPayday = payday
end

function Player:payDay()
	local time = getRealTime()
	outputChatBox ( "PAYDAY: "..time.hour..":"..time.minute,self,255,0,0 )
	self.m_paydayTexts = {}

	local income, outgoing, total = 0, 0, 0
	local income_faction, income_company, income_group, income_interest = 0, 0, 0, 0
	local outgoing_vehicles = 0
	--Income:
	if self:getFaction() then
		income_faction = self:getFaction():paydayPlayer(self)
		income = income + income_faction
		self:addPaydayText("faction","Fraktion: "..income_faction.."$",255,255,255)
	end
	if self:getCompany() then
		income_company = self:getCompany():paydayPlayer(self)
		income = income + income_company
		self:addPaydayText("company","Unternehmen: "..income_company.."$",255,255,255)
	end
	if self:getGroup() then
		income_group = self:getGroup():paydayPlayer(self)
		income = income + income_group
		self:addPaydayText("group","Gang/Firma: "..income_group.."$",255,255,255)
	end

	income_interest = math.floor(self:getBankMoney()*0.01)
	if income_interest > 1500 then income_interest = 1500 end
	income = income + income_interest
	self:addPaydayText("interest","Bank-Zinsen: "..income_interest.."$",255,255,255)

	--Outgoing
	outgoing_vehicles = #self:getVehicles()*75
	outgoing = outgoing + outgoing_vehicles
	self:addPaydayText("vehicleTax","Fahrzeugsteuer: "..outgoing_vehicles.."$",255,255,255)

	total = income - outgoing
	self:addPaydayText("totalIncome","Gesamteinkommen: "..income.." $",255,255,255)
	self:addPaydayText("totalOutgoing","Gesamtausgaben: "..outgoing.." $",255,255,255)
	self:addPaydayText("payday","Der Payday über "..total.."$ wurde auf dein Konto überwiesen!",255,150,0)

	self:addBankMoney(total, "Payday")

	triggerClientEvent ( self, "paydayBox", self, self.m_paydayTexts)
	-- Add Payday again
	self:setNextPayday()
end

function Player:addPaydayText(typ,text,r,g,b)
	self.m_paydayTexts[typ] = {}
	self.m_paydayTexts[typ]["text"] = text
	self.m_paydayTexts[typ]["r"] = r
	self.m_paydayTexts[typ]["g"] = g
	self.m_paydayTexts[typ]["b"] = b
end

function Player:togglePhone(status)
	self.m_PhoneOn = status
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

function Player:giveMoney(money) -- Overriden
	DatabasePlayer.giveMoney(self, money)

	if money ~= 0 then
		self:sendShortMessage((money >= 0 and "+"..money or money).."$")
	end
	self:triggerEvent("playerCashChange")
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

function Player:givePoints(p) -- Overriden
	DatabasePlayer.givePoints(self, p)

	if p ~= 0 then
		self:sendShortMessage((p >= 0 and "+"..p or p).._(" Punkte", self))
	end
end

function Player:setUniqueInterior(uniqueInteriorId)
	self.m_UniqueInterior = uniqueInteriorId
end

function Player:createChatColshapes( )
	local x,y,z = getElementPosition( self )
	self.chatCol_whisper = createColSphere ( x,y,z, CHAT_WHISPER_RANGE )
	attachElements(self.chatCol_whisper, self)
	self.chatCol_talk = createColSphere ( x,y,z, CHAT_TALK_RANGE )
	attachElements(self.chatCol_talk, self)
	self.chatCol_scream = createColSphere ( x,y,z, CHAT_SCREAM_RANGE )
	attachElements(self.chatCol_scream, self)
end

function Player:destroyChatColShapes( )
	if self.chatCol_scream then destroyElement(self.chatCol_scream) end
	if self.chatCol_talk then destroyElement(self.chatCol_talk) end
	if self.chatCol_whisper then destroyElement(self.chatCol_whisper) end
end

function Player:getPlayersInChatRange( irange)
	local colShape
	if irange == 0 then
		colShape = self.chatCol_whisper
	elseif irange == 1 then
		colShape = self.chatCol_talk
	elseif irange == 2 then
		colShape = self.chatCol_scream
	end
	local playersInRange = {	}
	local elementTable = getElementsWithinColShape( colShape,"player")
	local player,dimension,interior,check
	for index = 1,#elementTable do
		player = elementTable[index]
		dimension = player.dimension
		interior = player.interior
		if interior == self.interior then
			if dimension == self.dimension then
				playersInRange[#playersInRange+1] = player
			end
		end
	end
	return playersInRange
end

function Player:toggleControlsWhileObjectAttached(bool)
	toggleControl(self, "jump", bool )
	toggleControl(self, "fire", bool )
	toggleControl(self, "sprint", bool )
	toggleControl(self, "next_weapon", bool )
	toggleControl(self, "previous_weapon", bool )
	toggleControl(self, "enter_exit", bool )
end

function Player:attachPlayerObject(object, allowWeapons)
	local model = object.model
	if PlayerAttachObjects[model] then
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

	else
		self:sendError("Internal Error: attachPlayerObject: Wrong Object")
	end
end

function Player:refreshAttachedObject()
	self:getPlayerAttachedObject():setInterior(self:getInterior())
	self:getPlayerAttachedObject():setDimension(self:getDimension())
end

function Player:detachPlayerObjectBind(presser, key, state, object)
	self:detachPlayerObject(object)
end

function Player:detachPlayerObject(object)
	local model = object.model
	if PlayerAttachObjects[model] then
		object:detach(self)
		object:setCollisionsEnabled(true)
		unbindKey(self, "n", "down", self.m_detachPlayerObjectBindFunc)
		self:setAnimation(false)
		self:toggleControlsWhileObjectAttached(true)
		removeEventHandler("onElementDimensionChange", self, self.m_RefreshAttachedObject)
		removeEventHandler("onElementInteriorChange", self, self.m_RefreshAttachedObject)
	end
end

function Player:getPlayerAttachedObject()
	local model
	for key, value in pairs (getAttachedElements(self)) do
		model = value:getModel()
		if PlayerAttachObjects[model] then
			return value
		end
	end
	return false
end

function Player:setModel( skin )
	setElementModel( self, skin )
end
