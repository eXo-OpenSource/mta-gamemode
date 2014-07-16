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
	VehicleManager:new()
	PhoneInteraction:new()
	PlayerManager:new()
	JobManager:new()
	BankManager:new()
	Async.create(function() Forum:new() end)()
	WantedSystem:new()
	Provider:new()
	GroupManager:new()
	HouseManager:new()
	AmmuNationManager:new()
	Police:new()
	EventManager:new()
	GangAreaManager:new()
	Weather:new()
	
	VendingMachine.initializeAll()
	RobableShop.initalizeAll()
	VehicleGarages.initalizeAll()
	BankRobbery.initializeAll()
	InteriorEnterExit.initializeAll()
	VehicleSpawner.initializeAll()
	PayNSpray.initializeAll()
	GasStation.initializeAll()
	
	-- Generate Package
	local xml = xmlLoadFile("meta.xml")
	local files = {}
	for k, v in pairs(xmlNodeGetChildren(xml)) do
		if xmlNodeGetName(v) == "vrpfile" then
			files[#files+1] = xmlNodeGetAttribute(v, "src")
		end
	end
	
	Package.save("vrp.data", files)
	
	Provider:getSingleton():offerFile("vrp.data")
	
	-- Refresh all players
	for k, v in pairs(getElementsByType("player")) do
		Async.create(Player.connect)(v)
	end	
	for k, v in pairs(getElementsByType("player")) do
		Async.create(Player.join)(v)
	end
	
	setOcclusionsEnabled(false)
end

function Core:destructor()
	delete(VehicleManager:getSingleton())
	delete(PlayerManager:getSingleton())
	delete(GroupManager:getSingleton())
	delete(HouseManager:getSingleton())
	
	delete(sql)
end
