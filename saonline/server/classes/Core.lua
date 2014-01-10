Core = inherit(Object)

function Core:constructor()
	outputServerLog("Initializing core...")

	-- Small hack to get the global core immediately
	core = self
	
	if DEBUG then
		Debugging:new()
	end
	
	-- Establish database connection
	sql = MySQL:new(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PW, MYSQL_DB, "")
	sql:setPrefix("vrp")
	
	-- Instantiate classes (Create objects)
	TranslationManager:new()
	WhiteList:new()
	PhoneInteraction:new()
	PlayerManager:new()
	JobManager:new()
	VehicleManager:new()
	BankManager:new()
	Async.create(function() Forum:new() end)()
	WantedSystem:new()
	
	-- Refresh all players
	for k, v in pairs(getElementsByType("player")) do
		Async.create(Player.connect)(v)
	end	
	for k, v in pairs(getElementsByType("player")) do
		Async.create(Player.join)(v)
	end
end

function Core:destructor()
	delete(VehicleManager:getSingleton())
	delete(PlayerManager:getSingleton())
	
	delete(sql)
end
