Core = inherit(Object)
addEvent("Core.onClientInternalError", true)
local RUN_UNIT_TESTS = DEBUG and true

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
	JailBreak:new()
	Nametag:new()
	ItemShops:new()
	Collectables:new()
	DrivingSchool:new()
	AmmuLadder:new()
	Achievement:new()
	SkinShops:new()
	Deathmatch:new()

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

	addEventHandler("Core.onClientInternalError", root, bind(self.onClientInternalError, self))

	-- Execute tests
	if RUN_UNIT_TESTS then
		self:runTests()
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

	outputServerLog("")
end
