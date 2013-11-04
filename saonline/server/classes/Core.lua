Core = inherit(Object)

function Core:constructor()
	outputServerLog("Initializing core...")

	-- Small hack to get the global core immediately
	core = self
	
	-- Establish database connection
	sql = SQLite:new("database.db")
	sql:setPrefix("base")
	
	-- Instantiate classes (Create objects)
	WhiteList:new()
	
end

function Core:destructor()

end
