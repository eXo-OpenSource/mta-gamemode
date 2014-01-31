HouseManager = inherit(Singleton)

function HouseManager:constructor ()

	self.m_Houses = {}

	self.m_OnResourceStop = function () self:destructor () end
	
	local query = sql:queryFetch (dbConnection,'SELECT * FROM ??_houses', sql:getPrefix())
	
	outputServerLog (string.format("Loading %d houses",table.getn(query)))
	
	for key, value in next, query do
		table.insert ( self.m_Houses, new (House,value['id'],value['x'],value['y'],value['z'],value['interiorID'],value['keys'],value['owner'],value['price'],value['lockStatus'],value['rentPrice']))
	end
	
	addEventHandler ('onResourceStop',resourceRoot,self.m_OnResourceStop)
end

function HouseManager:newHouse ( x,y,z, interiorID, price )
	local id = sql:queryFetch (dbConnection, 'SELECT * FROM ??_houses', sql:getPrefix())
	local query = sql:queryFetch (dbConnection, 'INSERT INTO _houses VALUES (?,?,?,?,?,?,?,?,?,?)',
	sql:getPrefix(),
	#id + 1,
	x,
	y,
	z,
	interiorID,
	toJSON({}),
	0,
	price,
	0,
	25
	)
	table.insert (self.m_Houses,House:new ( #id+1,x,y,z,interiorID,{},0,price,0,25))
end

function HouseManager:destructor ()
	for key, value in next, self.m_Houses do
		value:save ()
	end
end