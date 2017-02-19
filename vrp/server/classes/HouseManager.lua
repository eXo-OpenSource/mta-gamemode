-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HouseManager.lua
-- *  PURPOSE:     House manager class
-- *
-- ****************************************************************************
HouseManager = inherit(Singleton)
addRemoteEvents{"enterHouse", "leaveHouse", "buyHouse", "sellHouse", "rentHouse", "unrentHouse", "breakHouse","lockHouse", "houseSetRent", "houseDeposit", "houseWithdraw", "houseRemoveTenant"}

local ROB_DELAY = 1000*60*15

function HouseManager:constructor()

	self.m_RobPlayers = {}
	self.m_Houses = {}

	outputServerLog("Loading houses...")
	--local query = sql:queryFetch("SELECT * FROM ??_houses", sql:getPrefix())

	--for key, value in pairs(query) do
	--	self.m_Houses[value["Id"]] = House:new(value["Id"], Vector3(value["x"], value["y"], value["z"]), value["interiorID"], value["keys"], value["owner"], value["price"], value["lockStatus"], value["rentPrice"], value["elements"], value["money"])
	--end

	addEventHandler("breakHouse",root,bind(self.breakHouse,self))
	addEventHandler("rentHouse",root,bind(self.rentHouse,self))
	addEventHandler("unrentHouse",root,bind(self.unrentHouse,self))
	addEventHandler("buyHouse",root,bind(self.buyHouse,self))
	addEventHandler("sellHouse",root,bind(self.sellHouse,self))
	addEventHandler("enterHouse",root,bind(self.enterHouse,self))
	addEventHandler("leaveHouse",root,bind(self.leaveHouse,self))
	addEventHandler("lockHouse",root,bind(self.lockHouse,self))
	addEventHandler("houseSetRent",root,bind(self.setRent,self))
	addEventHandler("houseDeposit",root,bind(self.deposit,self))
	addEventHandler("houseWithdraw",root,bind(self.withdraw,self))
	addEventHandler("houseRemoveTenant",root,bind(self.removeTenant,self))



	addCommandHandler("createhouse", bind(self.createNewHouse,self))

end

function HouseManager:createNewHouse(player,cmd,...)
	if select("#",...) < 2 then player:sendMessage("Syntax: interior, price",255,0,0) return false end
	if player:getRank() >= RANK.Administrator then
		local interior, price = ...
		interior, price = tonumber(interior), tonumber(price)
		if interior and price and House.interiorTable[interior] then
			local pos = player:getPosition()
			self:newHouse(pos, interior, price)
			player:sendMessage(("house created @ %f, %f, %f"):format(x,y,z), 255, 255, 255)
		end
	end
end

function HouseManager:addCharacterToRoblist(player)
	self.m_RobPlayers[player:getId()] = true
	setTimer ( function (id) self.m_RobPlayers[id] = nil end, ROB_DELAY, 1, player:getId() )
end

function HouseManager:isCharacterAllowedToRob (player)
	return self.m_RobPlayers[player:getId()] == nil and true or false
end

function HouseManager:lockHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:toggleLockState(client)
end

function HouseManager:setRent(rent)
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:setRent(client, rent)
end

function HouseManager:deposit(amount)
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:deposit(client, amount)
end

function HouseManager:withdraw(amount)
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:withdraw(client, amount)
end

function HouseManager:removeTenant(id)
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:removeTenant(client, id)
end

function HouseManager:breakHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:breakHouse(client)
end

function HouseManager:enterHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:enterHouseTry(client)
end

function HouseManager:leaveHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:leaveHouse(client)
end

function HouseManager:buyHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:buyHouse(client)
	StatisticsLogger:getSingleton():addHouse( client, "BUY", client.visitingHouse)
end

function HouseManager:sellHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:sellHouse(client)
	StatisticsLogger:getSingleton():addHouse( client, "SELL", client.visitingHouse)
end

function HouseManager:rentHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:rentHouse(client)
end

function HouseManager:unrentHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:unrentHouse(client)
end

function HouseManager:newHouse(pos, interiorID, price)
	sql:queryExec("INSERT INTO ??_houses (x,y,z,interiorID,`keys`,owner,price,lockStatus,rentPrice,elements) VALUES (?,?,?,?,?,?,?,?,?,?)",
		sql:getPrefix(), pos.x, pos.y, pos.z, interiorID, toJSON({}), 0, price, 0, 25, toJSON({}))

	local Id = sql:lastInsertId()

	self.m_Houses[Id] = House:new(Id, pos, interiorID, toJSON({}), 0, price, 0, 25, toJSON({}))
end

function HouseManager:getPlayerHouse(player)
	local playerId = player:getId()
	for key, house in pairs(self.m_Houses) do
		if house:getOwner() == playerId then
			return house
		end
	end
	return false
end

function HouseManager:getPlayerRentedHouses(player)
	local houses = {}
	local playerId = player:getId()
	for key, house in pairs(self.m_Houses) do
		if house:isTenant(playerId) then
			houses[#houses+1] = house
		end
	end
	return houses
end

function HouseManager:loadBlips(player)
	local house = self:getPlayerHouse(player)
	if house then
		player:triggerEvent("addHouseBlip", house.m_Id, house.m_Pos.x, house.m_Pos.y)
	end
	for index, rentHouse in pairs(self:getPlayerRentedHouses(player)) do
		if rentHouse then
			player:triggerEvent("addHouseBlip", rentHouse.m_Id, rentHouse.m_Pos.x, rentHouse.m_Pos.y)
		end
	end
end

function HouseManager:destructor ()
	for key, house in pairs(self.m_Houses) do
		house:save()
	end
end
