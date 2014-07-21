HouseManager = inherit(Singleton)

addEvent("enterHouse",true)
addEvent("leaveHouse",true)
addEvent("buyHouse",true)
addEvent("rentHouse",true)
addEvent("unrentHouse",true)

function HouseManager:constructor()
	self.m_Houses = {}
	
	outputServerLog("Loading houses...")
	local query = sql:queryFetch("SELECT * FROM ??_houses", sql:getPrefix())
	
	for key, value in ipairs(query) do
		self.m_Houses[value["Id"]] = House:new(value["Id"], value["x"], value["y"], value["z"], value["interiorID"], value["keys"], value["owner"], value["price"], value["lockStatus"], value["rentPrice"])
	end
	
	addEventHandler("rentHouse",root,bind(self.rentHouse,self))
	addEventHandler("unrentHouse",root,bind(self.unrentHouse,self))
	addEventHandler("buyHouse",root,bind(self.buyHouse,self))
	addEventHandler("enterHouse",root,bind(self.enterHouse,self))
	addEventHandler("leaveHouse",root,bind(self.leaveHouse,self))
	
end

function HouseManager:enterHouse()
	if not client then return end
	self.m_Houses[client.visitingHouse]:enterHouse(client)
end

function HouseManager:leaveHouse()
	if not client then return end
	self.m_Houses[client.visitingHouse]:leaveHouse(client)
end

function HouseManager:buyHouse()
	if not client then return end
	self.m_Houses[client.visitingHouse]:buyHouse(client)
end

function HouseManager:rentHouse()
	if not client then return end
	self.m_Houses[client.visitingHouse]:rentHouse(client)
end

function HouseManager:unrentHouse()
	if not client then return end
	self.m_Houses[client.visitingHouse]:unrentHouse(getPlayerName(client))
end

function HouseManager:newHouse(x, y, z, interiorID, price)
	--[[
		Aenderungen:
		- Wenn moeglich, unsigned Typen in MySQL benutzt
		- Fuer Id: AUTO_INCREMENT (um sql:lastInsertId benutzen zu koennen)
	]]

	sql:queryExec("INSERT INTO ??_houses VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
		sql:getPrefix(), x, y, z, interiorID, toJSON({}), 0, price, 0, 25)
	
	local Id = sql:lastInsertId()
	self.m_Houses[Id] = House:new(Id, x, y, z, interiorID, {}, 0, price, 0, 25) -- Jusonex: Schluessel-Wert Table benutzen, um spaeter leichter von der Id zum eigentlichen Haus Objekt zu kommen
end

function HouseManager:destructor ()
	for key, house in pairs(self.m_Houses) do
		house:save()
	end
end
