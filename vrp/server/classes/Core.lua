Core = inherit(Object)
addEvent("Core.onClientInternalError", true)

function Core:constructor()
	outputServerLog("Initializing core...")

	-- Small hack to get the global core immediately
	core = self

	if DEBUG then
		Debugging:new()
	end

	-- Update MySQL DB if this is not the testserver/releaseserver
	if not IS_TESTSERVER then
		MYSQL_DB = "vrp_local"
	end

	-- Establish database connection
	sql = MySQL:new(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PW, MYSQL_DB, MYSQL_UNIX_SOCKET)
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
	JailBreak:new()
	Nametag:new()
	ItemShops:new()
	Collectables:new()
	DrivingSchool:new()
	AmmuLadder:new()
	Achievement:new()
	SkinShops:new()
	Deathmatch:new()
	VehicleTuning:new()
	DimensionManager:new()
	ActorManager:new()
	InteriorManager:new()
	CompanyManager:new()
	FactionManager:new()
	
	VendingMachine.initializeAll()
	RobableShop.initalizeAll()
	VehicleGarages.initalizeAll()
	BankRobbery.initializeAll()
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

	addEventHandler("Core.onClientInternalError", root, bind(self.onClientInternalError, self))

	-- Prepare unit tests
	if DEBUG then
		addCommandHandler("runtests", bind(self.runTests, self))
	end
end

function Core:onClientInternalError (msg)
	outputDebug(("[%s] Internal Client Error occurred: %s"):format(getPlayerName(client), msg))
	kickPlayer(client, "Server - Error Handler", ("Internal Error occurred: %s"):format(msg))
end

function Core:destructor()
	delete(VehicleManager:getSingleton())
	delete(PlayerManager:getSingleton())
	delete(GroupManager:getSingleton())
	delete(HouseManager:getSingleton())

	delete(sql)
end

function Core:runTests()
	-- Add some space
	outputServerLog("")

	-- Instantiates tests here
	UtilsTest:new("UtilsTest")
	GroupTest:new("GroupTest")

	outputServerLog("")
end

function Core:getVersion()
	if self.m_Version == nil then
		local file = File.Open("version.txt")
		if file then
			self.m_Version = file:getContent()
			file:close()
		else
			self.m_Version = false
		end
	end
	return self.m_Version
end
