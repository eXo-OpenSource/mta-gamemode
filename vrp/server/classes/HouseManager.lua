HouseManager = inherit(Singleton)

function HouseManager:constructor()

	self.m_Houses = {}

	local query = sql:queryFetch("SELECT * FROM ??_houses", sql:getPrefix())
	
	outputServerLog(string.format("Loading %d houses", table.getn(query)))
	
	for key, value in ipairs(query) do
		self.m_Houses[value["Id"]] = House:new(value["Id"], value["x"], value["y"], value["z"], value["interiorID"], value["keys"], value["owner"], value["price"], value["lockStatus"], value["rentPrice"])
	end
	
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
