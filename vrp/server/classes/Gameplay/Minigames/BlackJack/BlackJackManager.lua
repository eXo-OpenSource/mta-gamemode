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

	setTimer(bind(self.pulse, self), 3000, 0)
end

function BlackJackManager:destructor() 

end

function BlackJackManager:pulse() 
	for table, player in pairs(self.m_Tables) do 
		if table.ped and isValidElement(table.ped, "ped") then 
			if self.m_OccupiedTables[table] and isValidElement(self.m_OccupiedTables[table], "player") then 
				table.ped:setAnimation("casino", "slot_wait", -1, true, false, false, true)
			else 
				table.ped:setAnimation("casino", "cards_loop", -1, true)
			end
		end
	end
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
	end
end

function BlackJackManager:Event_PlayerQuit(player)
	if self.m_Players[player] then 
		self.m_Players[player]:delete()
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

function BlackJackManager:createTable(pos, rot) 
	
	local obj = createObject(2188, pos, Vector3(rot.x, rot.y, rot.z+180))
	obj.ped = NPC:new(220, pos.x, pos.y, pos.z, rot.z)
	obj.ped:setPosition(obj.ped.position + obj.ped.matrix:getForward()*(-0.32))
	obj.ped:setFrozen(true)
	obj.ped.obj = obj
	obj.ped:setImmortal(true)
	obj:setData("clickable", true, true)
	obj.ped:setData("clickable", true, true)
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
	for k, p in ipairs(getElementsByType("player")) do 
		p:triggerEvent("BlackJack:sendTableObject", obj)
	end
	obj.m_Info = ElementInfo:new(obj.infoObj, "Casino", .4, "DoubleDown", true)
end