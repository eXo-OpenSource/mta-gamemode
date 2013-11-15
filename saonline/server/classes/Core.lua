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
	
end

function Core:destructor()
	delete(sql)
	delete(VehicleManager)
	delete(PlayerManager)
end
