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

addEvent("characterInitialized")
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
	self.m_CurrentAFKTime = 0
	self.m_AFKTime = 0
	self.m_AFKStartTime = 0
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
	HouseManager:getSingleton():destroyPlayerHouseBlip(self) -- Todo: do not on stop, cause of an error (annoying :P)
	PhoneNumber.unload(1, self.m_Id)

	--// gangwar
	triggerEvent("onDeloadCharacter",self)
end

function Player:connect()
	if not Ban.checkBan(self) then
		if not Warn.checkWarn(self) then
			return
		end
	end
end

function Player:join()
	setCameraMatrix(self,445.12222, -1886.34387, 22.368610,369.74289, -2036.1087, 7.67188) -- Untill new Login Scenes
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

function Player:setJailBail( bail )
	self.m_Bail = bail
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
	Premium.constructor(self)
	triggerEvent("characterInitialized", self)
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
	VehicleManager:getSingleton():sendTexturesToClient(self)
	HouseManager:getSingleton():createPlayerHouseBlip(self)
	
	-- Group blips
	local props = GroupPropertyManager:getSingleton():getPropsForPlayer( self )
	local x,y,z
	for k,v in ipairs( props ) do 
		x,y,z= getElementPosition( v.m_Pickup )
		createMarker(x,y,z,"checkpoint",1,0,200,200,200,self)
		createBlip(x,y,z,0,2,0,200,200,255,0,500,self)
	end
	--if self.m_Inventory then
	--	self.m_Inventory:setInteractingPlayer(self)
	--	self.m_Inventory:sendFullSync()
	--else
	--	outputDebugString("Inventory has not been instantiated successfully!")
	--end
end

function Player:initialiseBinds()
	if self:getFaction() then
 		bindKey(self, "y", "down", "chatbox", "Fraktion")
 	end
	--[[ Spieler werden sich folgende Binds lieber selbst zu recht legen
 	if self:getCompany() then
 		bindKey(self, "u", "down", "chatbox", "Unternehmen")
 	end
 	if self:getGroup() then
 		bindKey(self, "3", "down", "chatbox", "Firma/Gang")
 	end
	--]]
	bindKey(self, "l", "down", function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle then vehicle:toggleLight(player) end end)
	bindKey(self, "x", "down", function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle and getPedOccupiedVehicleSeat(player) == 0 then vehicle:toggleEngine(player) end end)
	bindKey(self, "g", "down",  function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle and getPedOccupiedVehicleSeat(player) == 0 then vehicle:toggleHandBrake( player ) end end)
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
	local dimension = 0

	if interior > 0 then dimension = self:getDimension() end

	sql:queryExec("UPDATE ??_character SET PosX = ?, PosY = ?, PosZ = ?, Interior = ?, Dimension = ?, UniqueInterior = ?, Health = ?, Armor = ?, Weapons = ?, PlayTime = ? WHERE Id = ?;", sql:getPrefix(),
		x, y, z, interior, dimension, self.m_UniqueInterior, math.floor(self:getHealth()), math.floor(self:getArmor()), toJSON(weapons, true), self:getPlayTime(), self.m_Id)

	--if self:getInventory() then
	--	self:getInventory():save()
	--end
	DatabasePlayer.save(self)
end

function Player:spawn( )
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
		spawnPlayer(self, NOOB_SPAWN, self.m_Skin, self.m_SavedInterior, self.m_SavedDimension) -- Todo: change position
		self:setRotation(0, 0, 180)
	else
		if self.m_SpawnLocation == SPAWN_LOCATION_DEFAULT then
			spawnPlayer(self, self.m_SavedPosition.x, self.m_SavedPosition.y, self.m_SavedPosition.z, 0, self.m_Skin, self.m_SavedInterior, self.m_SavedDimension)
		elseif self.m_SpawnLocation == SPAWN_LOCATION_GARAGE and self.m_LastGarageEntrance ~= 0 then
			VehicleGarages:getSingleton():spawnPlayerInGarage(self, self.m_LastGarageEntrance)
		else
			outputServerLog("Invalid spawn location ("..self:getName()..")")
		end

		-- Update Skin
		self:setDefaultSkin()

		-- Teleport player into a "unique interior"
		if self.m_UniqueInterior ~= 0 then
			InteriorManager:getSingleton():teleportPlayerToInterior(self, self.m_UniqueInterior)
			self.m_UniqueInterior = 0
		end

		-- Apply and delete health data
		self:setHealth(self.m_Health)
		self:setArmor(self.m_Armor)
		--self.m_Health, self.m_Armor = nil, nil -- this leads to errors as Player:spawn is called twice atm (--> introFinished event at the top)

		self:setPublicSync("Faction:Duty",false)

		if self:getFaction() and self:getFaction():isEvilFaction() then
			self:getFaction():changeSkin(self)
		end

		if self.m_JailTime then
			if self.m_JailTime > 0 then
				self:moveToJail(false)
			end
		end

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

	if not position then -- Search for nearest Spawnpoint
		--[[local currentPos = self.position
		local nearestDist = math.huge
		local nearestPoint = nil
		for i, v in ipairs(HOSPITAL_POSITIONS) do
			if (v-currentPos).length < nearestDist then
				nearestDist = (currentPos-v).length
				nearestPoint = i
			end
		end

		position, rotation = HOSPITAL_POSITIONS[nearestPoint], HOSPITAL_ROTATIONS[nearestPoint]
		--]]
		position, rotation = Vector3(1739.09, -1747.98, 18.81), Vector3(0, 0, 180)
	else
		position, rotation = position, rotation
	end

	self:setHeadless(false)
	spawnPlayer(self, position, rotation, self.m_Skin)

	if self:getFaction() and self:getFaction():isEvilFaction() then
		self:getFaction():changeSkin(self)
	end

	setCameraTarget(self, self)
end


-- Message Boxes
function Player:sendError(text) 	self:triggerEvent("errorBox", text) 	end
function Player:sendWarning(text)	self:triggerEvent("warningBox", text) 	end
function Player:sendInfo(text)		self:triggerEvent("infoBox", text)		end
function Player:sendInfoTimeout(text, timeout) self:triggerEvent("infoBox", text, timeout) end
function Player:sendSuccess(text)	self:triggerEvent("successBox", text)	end

function Player:sendShortMessage(text, ...) self:triggerEvent("shortMessageBox", text, ...)	end

function Player:sendTrayNotification(text, icon, sound)	self:triggerEvent("sendTrayNotification", text, icon, sound)	end

function Player:isActive() return true end

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
				self:getFaction():changeSkin(self)
				return
			end
		end
	self:setModel(self.m_Skin)
end

function Player:setKarma(karma)
	if karma < 0 and self.m_Karma >= 0 then
		self:giveAchievement(1)
	end
	if karma >= 0 and self.m_Karma < 0 then
		self:giveAchievement(2)
	end

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

function Player:setAFKTime()
	if self.m_AFKStartTime > 0 then
		self.m_CurrentAFKTime = (getTickCount() - self.m_AFKStartTime)
	else
		self.m_AFKTime = self.m_AFKTime + self.m_CurrentAFKTime
		self.m_CurrentAFKTime = 0
	end
end

function Player:startAFK()
	self.m_AFKStartTime = getTickCount()
end

function Player:endAFK()
	self:setAFKTime() -- Set CurrentAFKTime
	self.m_AFKStartTime = 0
	self:setAFKTime() -- Add CurrentAFKTime to AFKTime + Reset CurrentAFKTime
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

	if self:getWantedLevel() > 0 then
		self:sendShortMessage(_("Dir wurde ein Wanted erlassen!", self))
		self:takeWantedLevel(1)
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

function Player:giveMoney(money, reason) -- Overriden
	DatabasePlayer.giveMoney(self, money, reason)

	if money ~= 0 then
		self:sendShortMessage(("%s$%s"):format(money >= 0 and "+"..money or money, reason ~= nil and " - "..reason or ""), "SA National Bank (Cash)", {0, 94, 255}, 3000)
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
		else
			self:sendError(_("Du hast bereits ein Objekt dabei!", self))
		end
	else
		self:sendError("Internal Error: attachPlayerObject: Wrong Object")
	end
end

function Player:refreshAttachedObject()
	setTimer(function()
		self:getPlayerAttachedObject():setInterior(self:getInterior())
		self:getPlayerAttachedObject():setDimension(self:getDimension())
	end, 2000 ,1)
end

function Player:detachPlayerObjectBind(presser, key, state, object)
	self:detachPlayerObject(object)
end

function Player:setRegistrationDate(timestamp)
	self.m_RegistrationTimestamp = timestamp
end

function Player:getRegistrationDate()
	return self.m_RegistrationTimestamp
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

function Player:endPrison()
	self:setPosition(Vector3(1478.87, -1726.17, 13.55))
	self:setDimension(0)
	self:setInterior(0)
	toggleControl(self, "fire", true)
	toggleControl(self, "jump", true)
	toggleControl(self, "aim_weapon", true)
	self:triggerEvent("CountdownStop")
	self:sendInfo(_("Du wurdest aus dem Prison entlassen! Benimm dich nun besser!", self))
	if self.m_PrisonTimer then killTimer(self.m_PrisonTimer) end
	self.m_PrisonTime = 0
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
	if system == true then systemText = " ** " end

	for index = 1,#playersToSend do
		outputChatBox(("%s %s %s"):format(systemText, message, systemText), playersToSend[index], 100, 0, 255)
		if playersToSend[index] ~= self then
            receivedPlayers[#receivedPlayers+1] = playersToSend[index]:getName()
        end

	end
	if not system then
		StatisticsLogger:getSingleton():addChatLog(self, "me", text, toJSON(receivedPlayers))
	end
end

function Player:moveToJail(CUTSCENE)
	if self.m_JailTime > 0 then
		local rnd = math.random(1, #Jail.Cells)
		self:respawn()
		self:setPosition(Jail.Cells[rnd])
		self:setInterior(0)
		self:setDimension(0)
		self:setRotation(0, 0, 90)
		self:toggleControl("fire", false)
		self:toggleControl("jump", false)
		self:toggleControl("aim_weapon ", false)

		self.m_JailStart = getRealTime().timestamp
		self:setData("inJail",true, true)
		self.m_JailTimer = setTimer(
			function()
				if isElement(self) then
					self:setPosition(1539.7, -1659.5 + math.random(-3, 3), 13.6)
					self:setRotation(0, 0, 90)
					self:setWantedLevel(0)
					self:toggleControl("fire", true)
					self:toggleControl("jump", true)
					self:toggleControl("aim_weapon ", true)
					self.m_JailStart = nil
					self.m_JailTimer = nil
					self:setJailTime(0)
					self:triggerEvent("playerLeftJail")
					self:setData("inJail",false, true)
				end
			end, self.m_JailTime * 60000, 1
		)

		self:triggerEvent("playerJailed", self.m_JailTime, CUTSCENE)
	end
end
