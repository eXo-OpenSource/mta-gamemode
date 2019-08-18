-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/BlackJack/BlackJackManager.lua
-- *  PURPOSE:     BlackJackManager
-- *
-- ****************************************************************************

BlackJackManager = inherit(Singleton)
addRemoteEvents{"BlackJackManager:onReady", "BlackJackManager:onHit", "BlackJackManager:onStand", "BlackJackManager:onCancel", 
				"BlackJackManager:onReset", "BlackJackManager:onInsurance", "BlackJackManager:requestTables"}

function BlackJackManager:constructor() 
	self.m_Players = {}
	
	self.m_Tables = {}
	
	self.m_OccupiedTables = {}
	addEventHandler("BlackJackManager:onReady", root, bind(self.Event_onPlayerReady, self))

	addEventHandler("BlackJackManager:onHit", root, bind(self.Event_onPlayerHit, self))

	addEventHandler("BlackJackManager:onStand", root, bind(self.Event_onPlayerStand, self))

	addEventHandler("BlackJackManager:onCancel", root, bind(self.Event_onPlayerCancel, self))

	addEventHandler("BlackJackManager:onReset", root, bind(self.Event_onPlayerReset, self))

	addEventHandler("BlackJackManager:onInsurance", root, bind(self.Event_onPlayerInsurance, self))

	addEventHandler("BlackJackManager:requestTables", root, bind(self.Event_onPlayerRequestTables, self))

	PlayerManager:getSingleton():getQuitHook():register(bind(self.Event_PlayerQuit, self))

	self:load() 
	setTimer(bind(self.pulse, self), 2000, 1)
end

function BlackJackManager:load() 
	sql:queryExec(
	"CREATE TABLE IF NOT EXISTS ??_blackjack_tables (" ..
	"`Id` INT NOT NULL AUTO_INCREMENT," ..
	"`X` FLOAT NOT NULL DEFAULT '0'," ..
	"`Y` FLOAT NOT NULL DEFAULT '0'," ..
	"`Z` FLOAT NOT NULL DEFAULT '0'," ..
	"`Rx` FLOAT NOT NULL DEFAULT '0'," ..
	"`Bets` JSON NULL," ..
	"`Date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," ..
	"PRIMARY KEY (`Id`)" ..
	")	COLLATE='latin1_swedish_ci' ENGINE=InnoDB;", sql:getPrefix())

	local result = sql:queryFetch("SELECT * FROM ??_blackjack_tables", sql:getPrefix())
	if result then 
		for k, row in pairs(result) do
			self:createTable(Vector3(row.X, row.Y, row.Z), Vector3(0, 0, row.Rz), row.Bets, row.Id)
		end
	end
end

function BlackJackManager:destructor() 
	for obj, bool in pairs(self.m_Tables) do 
		if isValidElement(obj, "object") then 
			if not obj.Id or obj.Id == 0 then 
				sql:queryExec("INSERT INTO ??_blackjack_tables (X, Y, Z, Rx, Bets) VALUES (?, ?, ?, ?, ?)", sql:getPrefix(), obj.position.x, obj.position.y, obj.position.z, obj.rotation.z, toJSON(obj.bets))
			else 
				sql:queryExec("UPDATE ??_blackjack_tables SET Bets =? WHERE Id =?", sql:getPrefix(), obj.bets and toJSON(obj.bets), obj.Id)
			end
		end
	end
end

function BlackJackManager:pulse() 
	for table, bool in pairs(self.m_Tables) do 
		if table.ped and isValidElement(table.ped, "ped") then 
			if self.m_OccupiedTables[table] and isValidElement(self.m_OccupiedTables[table], "player") then 
				table.ped:setAnimation("casino", "slot_wait", -1, false, false, false, true)
			else 
				table.ped:setAnimation("casino", "cards_loop", -1, false, false, false, true)
			end
		end
	end
	setTimer(bind(self.pulse, self), math.random(5000, 10000), 1)
end

function BlackJackManager:Event_onPlayerReady(bet)
	if client and self.m_Players[client] then 
		self.m_Players[client]:start(bet)
	end
end

function BlackJackManager:Event_onPlayerHit() 
	if self.m_Players[client] then 
		self.m_Players[client]:hit()
	end
end

function BlackJackManager:Event_onPlayerStand() 
	if self.m_Players[client] then 
		self.m_Players[client]:stand()
	end
end

function BlackJackManager:Event_onPlayerCancel(spectating) 
	if not spectating and self.m_Players[client] then 
		self.m_OccupiedTables[self.m_Players[client].m_Object] = nil
		self.m_Players[client]:delete()
		self.m_Players[client] = nil
	else 
		if self.m_Players[spectating] then 
			self.m_Players[spectating]:stopSpectate(client)
		end
	end
end

function BlackJackManager:Event_onPlayerInsurance() 
	if self.m_Players[client] then 
		self.m_Players[client]:insurance()
	end
end

function BlackJackManager:Event_onPlayerReset(bet) 
	if self.m_Players[client] then 
		self.m_Players[client]:reset(bet)
	end
end

function BlackJackManager:Event_onPlayerSpectate(spectator, player) 
	if self.m_Players[player] then
		if spectator.m_BlackJackSpectate then
			spectator.m_BlackJackSpectate:stopSpectate()
		end
		self.m_Players[player]:spectate(spectator)
	end
end

function BlackJackManager:Event_onStart(player, object) 
	if not self.m_Players[player] then
		self.m_Players[player] = BlackJack:new(player, object)
		self.m_OccupiedTables[object] = player
		object.ped:setAnimation("casino", "slot_wait", -1, false, false, false, true)
	end
end

function BlackJackManager:Event_PlayerQuit(player)
	if self.m_Players[player] then 
		self.m_Players[player]:delete()
		self.m_Players[player] = nil
	end
	if player.m_BlackJackSpectate then 
		player.m_BlackJackSpectate:stopSpectate(player) 
	end
end

function BlackJackManager:Event_onPlayerRequestTables()
	client:triggerEvent("BlackJack:sendTableObjects", self.m_Tables)
end

function BlackJackManager:getTablePlayer(object)
	if self.m_OccupiedTables[object] then 
		return isValidElement(self.m_OccupiedTables[object], "player") and self.m_OccupiedTables[object]
	end
end

function BlackJackManager:createTable(pos, rot, bets, id) 
	
	local obj = createObject(2188, pos, Vector3(rot.x, rot.y, rot.z+180))
	obj.Id = id -- Id
	obj.bets = bets and fromJSON(bets) or bets
	if not obj.bets then
		obj.bets = BlackJack.DEFAULT_BETS
	end
	obj.ped = NPC:new(142, pos.x, pos.y, pos.z, rot.z)
	obj.ped:setPosition(obj.ped.position + obj.ped.matrix:getForward()*(-0.45))
	obj.ped:setFrozen(true)
	obj.ped.obj = obj
	obj.ped:setImmortal(true)
	obj:setData("clickable", true, true)
	obj.ped:setData("clickable", true, true)
	obj.ped:setAnimation("casino", "cards_loop", -1, false, false, false, true)
	obj.infoObj = createObject(1858, (obj.position + obj.matrix:getForward()*-1)+ obj.matrix:getUp()*0.2)
	obj.infoObj:setCollisionsEnabled(false)
	obj.infoObj:setAlpha(0)
    addEventHandler("onElementClicked", obj, function(button, state, player)
		if self.m_Players[player] then return end
        if Vector3(source:getPosition()-player:getPosition()):getLength() > 5 then return end
		if button == "left" and state == "up" then
			if self:getTablePlayer(source) then return player:sendShortMessage(_("Der Tisch ist schon besetzt! Rechtsklick zum Zuschauen!", player)) end
			self:Event_onStart(player, source)
		elseif button == "right" and state == "up" then
			if self:getTablePlayer(source) then
				self:Event_onPlayerSpectate(player, self:getTablePlayer(source) )
			end
		end
	end)
    addEventHandler("onElementClicked", obj.ped, function(button, state, player)
		if self.m_Players[player] then return end
        if Vector3(source.obj:getPosition()-player:getPosition()):getLength() > 5 then return end
		if button == "left" and state == "up" then
			if self:getTablePlayer(source.obj) then return player:sendShortMessage(_("Der Tisch ist schon besetzt! Rechtsklick zum Zuschauen!", player)) end
			self:Event_onStart(player, source.obj)
		elseif button == "right" and state == "up" then
			if self:getTablePlayer(source.obj) then
				self:Event_onPlayerSpectate(player, self:getTablePlayer(source.obj) )
			end
		end
	end)
	self.m_Tables[obj] = true
	obj:setData("BlackJackTable:ped", obj.ped, true)
	obj.ped.pone = createObject(1238, obj.ped:getPosition())
	obj.ped.pone:setScale(0.5)
	obj.ped:setData("BlackJackPed:cone", obj.ped.pone, true)
	exports.bone_attach:attachElementToBone(obj.ped.pone, obj.ped, 1, 0.02, 0.01, 0.26, 10, 0)

	for k, p in ipairs(getElementsByType("player")) do 
		p:triggerEvent("BlackJack:sendTableObject", obj)
	end
	obj.m_Info = ElementInfo:new(obj.infoObj, "Casino", .4, "DoubleDown", true)

	
	return obj
end

function BlackJackManager:destroyTable(obj) 
	if obj and isValidElement(obj, "object") then 
		if self.m_Tables[obj] then 
			local player = self:getTablePlayer(obj)
			if player then 
				if self.m_Players[player] then 
					self.m_Players[player]:delete()
					self.m_Players[player] = nil
				end
			end
			self.m_Tables[obj] = nil 
			self.m_OccupiedTables[obj] = nil 
			if obj.m_Info then 
				obj.m_Info:delete() 
				obj.m_Info = nil
			end
			if isValidElement(obj.ped, "ped") then 
				obj.ped:destroy()
				if obj.ped.pone and isValidElement(obj.ped.pone, "object") then 
					obj.ped.pone:destroy()
				end
			end
			if isValidElement(obj.infoObj, "object") then 
				obj.infoObj:destroy()
			end
			if obj.Id and obj.Id > 0 then 
				sql:queryExec("DELETE FROM ??_blackjack_tables WHERE Id=?", sql:getPrefix(), obj.Id)
			end 
			obj:destroy()
		end
	end
end

function BlackJackManager:setBets(obj, bets)
	if obj and isValidElement(obj, "object") then 
		obj.bets = bets
		if not obj.bets then
			obj.bets = BlackJack.DEFAULT_BETS
		end
	end
end