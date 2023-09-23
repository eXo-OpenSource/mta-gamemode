Core = inherit(Object)
addEvent("Core.onClientInternalError", true)

Config.register("MYSQL_MAIN_HOST", "string", "127.0.0.1")
Config.register("MYSQL_MAIN_PORT", "number", "3306")
Config.register("MYSQL_MAIN_USERNAME", "string", "root")
Config.register("MYSQL_MAIN_PASSWORD", "string", "")
Config.register("MYSQL_MAIN_DATABASE", "string", "vrp")

Config.register("MYSQL_LOGS_HOST", "string", "127.0.0.1")
Config.register("MYSQL_LOGS_PORT", "number", "3306")
Config.register("MYSQL_LOGS_USERNAME", "string", "root")
Config.register("MYSQL_LOGS_PASSWORD", "string", "")
Config.register("MYSQL_LOGS_DATABASE", "string", "vrp")

Config.register("MYSQL_PREMIUM_HOST", "string", "127.0.0.1")
Config.register("MYSQL_PREMIUM_PORT", "number", "3306")
Config.register("MYSQL_PREMIUM_USERNAME", "string", "root")
Config.register("MYSQL_PREMIUM_PASSWORD", "string", "")
Config.register("MYSQL_PREMIUM_DATABASE", "string", "vrp")

Config.register("WEB_ACCOUNT_USERNAME", "string", "")
Config.register("WEB_ACCOUNT_PASSWORD", "string", "")

function Core:constructor()
	outputServerLog("Initializing core...")
	nextframe(function() --small hack to override the name meta-name
		if DEBUG then
			setGameType(("%s @ %s"):format(PROJECT_NAME, getOpticalTimestamp()))
		else
			setGameType(("%s %s"):format(PROJECT_NAME, PROJECT_VERSION))
		end
	end)

	-- Small hack to get the global core immediately
	core = self
	self.m_Failed = false
	self.ms_StopHook = Hook:new()

	if DEBUG then
		Debugging:new()
	end

	Config:new()

	-- Update MySQL DB if this is not the testserver/releaseserver
	if not IS_TESTSERVER then
		--MYSQL_DB = "vrp_local"
	end

	-- Create file logger for sql performance
	FileLogger:new()
	if not DISABLE_INFLUX then
		influx = InfluxDB:new("", "", "")
		influxPlayer = InfluxDB:new("", "", "")
		InfluxLogging:new()
	end

	-- Establish database connection
	sql = MySQL:new(Config.get("MYSQL_MAIN_HOST"), Config.get("MYSQL_MAIN_PORT"), Config.get("MYSQL_MAIN_USERNAME"), Config.get("MYSQL_MAIN_PASSWORD"), Config.get("MYSQL_MAIN_DATABASE"), nil)
	sql:setPrefix("vrp")
	sqlPremium = MySQL:new(Config.get("MYSQL_PREMIUM_HOST"), Config.get("MYSQL_PREMIUM_PORT"), Config.get("MYSQL_PREMIUM_USERNAME"), Config.get("MYSQL_PREMIUM_PASSWORD"), Config.get("MYSQL_PREMIUM_DATABASE"), nil)
	sqlLogs = MySQL:new(Config.get("MYSQL_LOGS_HOST"), Config.get("MYSQL_LOGS_PORT"), Config.get("MYSQL_LOGS_USERNAME"), Config.get("MYSQL_LOGS_PASSWORD"), Config.get("MYSQL_LOGS_DATABASE"), nil)
	sqlLogs:setPrefix("vrpLogs")

	if not DISABLE_MIGRATION then
		MigrationManager:new()
	end

	if Config.get("WEB_ACCOUNT_USERNAME") ~= "" and Config.get("WEB_ACCOUNT_PASSWORD") ~= "" then
		self.m_ACLAccount = Account.add(Config.get("WEB_ACCOUNT_USERNAME"), Config.get("WEB_ACCOUNT_PASSWORD"))

		local aclGroup = aclGetGroup("web")
		if not aclGroup then aclGroup = aclCreateGroup("web") end
	
		local acl = aclGet("web")
		if not acl then acl = aclCreate("web") end
	
		aclGroupAddACL(aclGroup, acl)
		acl:setRight("general.http", true)
		acl:setRight("function.callRemote", true)
		acl:setRight("function.fetchRemote", true)
	
		aclGroup:addObject(("user.%s"):format(Config.get("WEB_ACCOUNT_USERNAME")))
	end

	ACLGroup.get("Admin"):addObject("resource.admin_exo")

	if GIT_BRANCH == "release/production" then
		setServerPassword()
	end

	addCommandHandler("servertime", function(p)
		local time = getRealTime()
		outputChatBox(("* Es ist %02d:%02d:%02d Uhr Serverzeit"):format(time.hour, time.minute, time.second), p, 255, 100, 100)
	end)

	-- Instantiate classes (Create objects)
	if not self.m_Failed then
		Time:new()
		ServerSettings:new()
		AntiCheat:new()
		ModdingCheck:new()
		TranslationManager:new()
		GlobalTimer:new()
		MTAFixes:new()
		VehicleManager:new()
		VehicleScrapper:new()
		Admin:new()
		StatisticsLogger:new()
		--WhiteList:new()
		PhoneInteraction:new()
		PlayerManager:new()
		JobManager:new()
		BankManager:new()
		BankServer:new()
		BankRobberyManager:new()
		JewelryStoreRobberyManager:new()
		PrisonBreakManager:new()
		--WantedSystem:new()
		Provider:new()
		PermissionsManager:new()
		GroupManager:new()
		GroupPropertyManager:new()
		HouseManager:new()
		SkyscraperManager:new()
		EventManager:new()
		AdminEventManager:new()
		--AuctionEvent:new()
		--GangAreaManager:new()
		Weather:new()
		Nametag:new()
		Collectables:new()
		Achievement:new()
		SkinShops:new()
		VehicleTuningShop:new()
		VehicleCustomTextureShop:new()
		DimensionManager:new()
		ActorManager:new()
		InteriorManager:new()
		FactionManager:new()
		StateEvidence:new()
		CompanyManager:new()
		VehicleImportManager:new()
		Guns:new()
		ThrowObjectManager:new()
		InventoryManager:new()
		ItemManager:new()
		StaticWorldItems:new()
		WorldItemManager:new()
		Casino:new()
		FerrisWheelManager:new()
		ActionsCheck:new()
		TrainManager:new()
		FireManager:new()
		GasStationManager:new()
		ShopManager:new()
		Jail:new()
		VehicleInteraction:new()
		VehicleHarbor:new()
		Tour:new()
		GrowableManager:new()
		MinigameManager:new()
		Townhall:new()
		BeggarPedManager:new()
		ShootingRanch:new()
		DeathmatchManager:new()
		SkydivingManager:new()
		Kart:new()
		HorseRace:new()
		TurtleRace:new()
		BoxManager:new()
		Fishing:new()
		InactivityManager:new()
		HistoryPlayer:new()
		ForumPermissions:new()
		VehicleCategory:new()
		ClientStatistics:new()
		SkribbleManager:new()
		TSConnect:new()
		PickupWeaponManager:new()
		InteriorEnterExitManager:new()
		ElevatorManager:new()
		CinemaManager:new()
		CustomAnimationManager:new()
		PricePoolManager:new()
		ColorCarsManager:new()
		LeaderCheck:new()
		VehicleRcUpgradeShop:new()

		if EVENT_EASTER then
			Easter:new()
		end

		if EVENT_HALLOWEEN then
			Halloween:new()
		end

		if EVENT_CHRISTMAS then
			Christmas:new()
			BotManager:new()
			CookieClickerManager:new()
			ChristmasTruckManager:new()
		end

		GPS:new()
		Chair:new()
		Atrium:new()


		VehicleManager.loadVehicles()
		VendingMachine.initializeAll()
		VehicleGarages.initalizeAll()
		VehicleSpawner.initializeAll()
		PayNSpray.initializeAll()
		TollStation.initializeAll()
		Depot.initalize()
		QuestionBox.initalize()
		ShortMessageQuestion.initalize()

		ChessSessionManager:new()
		-- Generate Missions
		--MStealWeaponTruck:new()

		-- Missions
		MWeaponTruck:new()
		MWeedTruck:new()
		ExplosiveTruckManager:new()

		--// Gangwar
		Gangwar:new()
		GangwarStatistics:new()
		--SprayWallManager:new()
		GroupHouseRob:new()

		BindManager:new()
		Forum:new()
		ServiceSync:new()
		Discord:new()
		TeleportManager:new()
		Sewers:new()
		PlayHouse:new()
		ArmsDealer:new()
		PlaneManager:new()
		PoliceAnnouncements:new()
		RadioCommunication:new()
		MapLoader:new()
		MapEditor:new()
		DamageManager:new()
		PedScale:new()
		HelicopterDrivebyManager:new()
		AtmManager:new()
		ShopVehicleRobManager:new()
		--AmmunationEvaluation:new()
		-- Disable Heathaze-Effect (causes unsightly effects on 3D-GUIs e.g. SpeakBubble3D)
		setHeatHaze(0)

		setWaveHeight(1)
		setWaterColor(0, 65, 75, 250)
		resetSkyGradient()
		resetFogDistance()
		-- Generate Package
		if not HTTP_DOWNLOAD then -- not required in HTTP-Download mode
			local xml = xmlLoadFile("meta.xml")
			local files = {}
			local st = getTickCount()
			for k, v in pairs(xmlNodeGetChildren(xml)) do
				if xmlNodeGetName(v) == "vrpfile" then
					files[#files+1] = xmlNodeGetAttribute(v, "src")
					Provider:getSingleton():offerFile(xmlNodeGetAttribute(v, "src"))
				end
			end
			outputDebug("offered files in ", getTickCount()-st, "ms")
			Package.save("vrp.list", files, true)
			Provider:getSingleton():offerFile("vrp.list")
		end

		-- Refresh all players
		for k, v in pairs(getElementsByType("player")) do
			Async.create(Player.connect)(v)
		end
		for k, v in pairs(getElementsByType("player")) do
			Async.create(Player.join)(v)
		end

		local realtime = getRealTime()
		setTime(realtime.hour, realtime.minute)
		setMinuteDuration(60000)

		setOcclusionsEnabled(true)

		addEventHandler("Core.onClientInternalError", root, bind(self.onClientInternalError, self))

		-- Prepare unit tests
		if DEBUG then
			addCommandHandler("runtests", bind(self.runTests, self))
		end

		if GIT_BRANCH == "release/production" then
			GlobalTimer:getSingleton():registerEvent(function()
				outputChatBox("Achtung: Der Server wird in 10 Minuten neu gestartet!", root, 255, 0, 0)
			end, "Server Restart Message 1", nil, 04, 50)
			GlobalTimer:getSingleton():registerEvent(function()
				outputChatBox("Achtung: Der Server wird in 5 Minuten neu gestartet!", root, 255, 0, 0)
			end, "Server Restart Message 2", nil, 04, 55)
		end
	end
end

function Core:onClientInternalError (msg)
	outputDebug(("[%s] Internal Client Error occurred: %s"):format(getPlayerName(client), msg))
	kickPlayer(client, "Server - Error Handler", ("Internal Error occurred: %s"):format(msg))
end

function Core:destructor()
	if not self.m_Failed then
		ACLGroup.get("Admin"):removeObject("user.exo_web")
		if self.m_ACLAccount then
			removeAccount(self.m_ACLAccount)
		end

		delete(PlayerManager:getSingleton())
		delete(VehicleManager:getSingleton())
		delete(GroupManager:getSingleton())
		if HouseManager:isInstantiated() then
			delete(HouseManager:getSingleton())
		end
		delete(Guns:getSingleton())
		delete(FactionManager:getSingleton())
		delete(CompanyManager:getSingleton())
		delete(WorldItemManager:getSingleton())
		delete(InventoryManager:getSingleton())
		delete(ShopManager:getSingleton())
		delete(GrowableManager:getSingleton())
		delete(GangwarStatistics:getSingleton())
		delete(GroupPropertyManager:getSingleton())
		delete(Admin:getSingleton())
		delete(GPS:getSingleton())
		delete(StatisticsLogger:getSingleton())
		delete(BankServer:getSingleton())
		ItemManager:updateOnQuit()
		delete(BlackJackManager:getSingleton())
		delete(CasinoWheelManager:getSingleton())
		delete(PricePoolManager:getSingleton())
		delete(SkyscraperManager:getSingleton())
		if EVENT_EASTER then
			delete(Easter:getSingleton())
		end
		if EVENT_CHRISTMAS then
			delete(CookieClickerManager:getSingleton())
			delete(ChristmasTruckManager:getSingleton())
		end
		delete(sql) -- Very slow
	end
end

function Core:runTests()
	-- Instantiates tests here
	UtilsTest:new("UtilsTest")
	--GroupTest:new("GroupTest") // Throws an Erorr
	PromiseTest:new("PromiseTest")
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

function Core:getStopHook()
	return self.ms_StopHook
end
