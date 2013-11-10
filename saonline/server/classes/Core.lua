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
	sql:setPrefix("saonline")
	
	-- Instantiate classes (Create objects)
	TranslationManager:new()
	WhiteList:new()
	PhoneInteraction:new()
	PlayerManager:new()
	
	-- Create jobs
	JobLogistician:new()
	
end

function Core:destructor()
	delete(sql)
end
