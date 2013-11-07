Core = inherit(Object)

function Core:constructor()
	outputServerLog("Initializing core...")

	-- Small hack to get the global core immediately
	core = self
	
	-- Establish database connection
	sql = MySQL:new(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PW, MYSQL_DB, "")
	sql:setPrefix("saonline")
	
	-- Instantiate classes (Create objects)
	WhiteList:new()
	
end

function Core:destructor()

end
