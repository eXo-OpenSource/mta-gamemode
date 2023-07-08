Core = inherit(Object)

function Core:constructor()
	-- Small hack to get the global core immediately
	core = self

	-- Instantiate the localPlayer instance right now
	enew(localPlayer, LocalPlayer)

	self.m_Config = ConfigXML:new("@config.xml")
	Version:new()
	TinyInfoLabel:new()
	Provider:new()
	if not DISABLE_INFLUX then
		influx = InfluxDB:new("", "", "")
		InfluxLogging:new()
	end
	Cursor = GUICursor:new()
	self.m_WhitelistChecker = setTimer(bind(self.checkDomainsWhitelist, self), 1000, 0)

	if HTTP_DOWNLOAD then -- In debug mode use old Provider
		showChat(false)

		Async.create( -- HTTPProvider needs asynchronous "context"
			function()
				fadeCamera(true)

				local dgi = HTTPDownloadGUI:getSingleton()
				local provider = HTTPProvider:new(FILE_HTTP_FALLBACK_URL, dgi)
				if provider:start() then -- did the download succeed
					delete(dgi)
					self:onDownloadComplete()
				else
					outputConsole("retrying download from different mirror")
					delete(dgi)
					local dgi = HTTPDownloadGUI:getSingleton()
					local provider = HTTPProvider:new(FILE_HTTP_SERVER_URL, dgi)
					if provider:start(true) then -- did the download succeed
						delete(dgi)
						self:onDownloadComplete()
					end
				end
			end
		)()
	else
		local dgi = DownloadGUI:getSingleton()
		Provider:getSingleton():addFileToRequest("vrp.list")
		Provider:getSingleton():requestFiles(
			function()
				local fh = fileOpen("vrp.list")
				local json = fileRead(fh, fileGetSize(fh))
				fileClose(fh)
				local tbl = fromJSON(json)

				for _, v in pairs(tbl) do
					Provider:getSingleton():addFileToRequest(v)
				end

				Provider:getSingleton():requestFiles(
					bind(DownloadGUI.onComplete, dgi),
					bind(DownloadGUI.onProgress, dgi),
					bind(DownloadGUI.onWrite, dgi)
				)
			end
		)

		setAmbientSoundEnabled( "gunfire", false )
		showChat(true)
	end
end

function Core:onDownloadComplete()
	-- Instantiate all classes
	self:ready()

	-- create login gui
	local pwhash = core:get("Login", "password", "")
	local username = core:get("Login", "username", "")
	lgi = LoginGUI:new(username, pwhash)

	-- other
	setAmbientSoundEnabled( "gunfire", false )
	showChat(true)
end

function Core:ready() --onClientResourceStart
	-- Tell the server that we're ready to accept additional data
	triggerServerEvent("playerReady", root, { -- trigger some client settings
		["LastFactionSkin"] = core:get("Cache", "LastFactionSkin", 0),
		["LastCompanySkin"] = core:get("Cache", "LastCompanySkin", 0),
	})

	localPlayer:setLocale(core:get("HUD", "locale", getLocalization()["code"] == "de" and "de" or "en"))
	triggerServerEvent("playerLocale", localPlayer, localPlayer:getLocale())

	-- Request Browser Domains
	Admin:new()
	Browser.requestDomains(DOMAINS, false, self.m_BrowserWhitelistResponse)
	DxHelper:new()
	TranslationManager:new()
	MTAFixes:new()
	ClickHandler:new()
	HoverHandler:new()
	CustomModelManager:new()
	--GangAreaManager:new()
	HelpBar:new()
	JobManager:new()
	RadioStationManager:new()
	DimensionManager:new()
	Inventory:new()
	Guns:new()
	Guns:getSingleton():toggleHitMark(core:get("HUD","Hitmark", false))
	Guns:getSingleton():toggleTracer(core:get("HUD","Tracers", false))
	Guns:getSingleton():toggleMonochromeShader(core:get("HUD", "KillFeedbackShader", false))
	localPlayer:setChatSettings()
	ThrowObject:new()
	Casino:new()
	TrainManager:new()
	FireManager:new()
	VehicleInteraction:new()
	EventManager:new()
	DMRaceEvent:new()
	StreetRaceEvent:new()
	VehicleGarages:new()
	SkinShopGUI.initializeAll()
	ItemManager:new()
	CinemaManager:new()
	CustomAnimationManager:new()
	ColorCarsManager:new()
	--// Gangwar
	GangwarClient:new()
	GangwarStatistics:new()
	Damage:new()
	if core:get("World", "MostWantedEnabled", true) then MostWanted:new() end
	if core:get("Other", "Movehead", true) then
		localPlayer:startLookAt()
	end
	if core:get("Other","RenderDistance", false) then
		setFarClipDistance(math.floor(core:get("Other","RenderDistance",992)) )
	else
		setFarClipDistance(992)
	end
	if not core:get("Sounds", "Interiors", true) then
		setInteriorSoundsEnabled(false)
	end

	localPlayer.m_DisplayMode = core:get("HUD", "ToggleQuickDisplay", true)
	--Light = DynamicLightingBind:getSingleton() | disabled needs to be rewritten for mutliple pass

	NoDm:new()
	FactionManager:new()
	CompanyManager:new()
	VehicleImportManager:new()
	DeathmatchManager:new()
	HorseRace:new()
	Townhall:new()
	Sewers:new()
	PlayHouse:new()
	PremiumArea:new()

	ColshapeStreamer:new()
	Plant.initalize()
	ItemSellContract:new()
	Neon.initalize()
	CoronaEffect.initalize()
	GroupSaleVehicles.initalize()
	GroupRentVehicles.initalize()
	EasterEgg:new()
	EasterEggArcade.Game:new()
	Shaders.load()

	GroupProperty:new()
	GUIWindowsFocus:new()
	--SprayWallManager:new()
	AntiClickSpam:new()
	GasStation:new()

	ChessSession:new()

	GroupRob:new()
	DrivingSchool:new()
	ClientStatistics:new()
	Nametag:new()
	VehicleMark:new()
	PickupWeaponManager:new()

	if EVENT_HALLOWEEN then
		Halloween:new()
	end
	if EVENT_CHRISTMAS then
		Christmas:new()
	end
	if SNOW_SHADERS_ENABLED then
		triggerEvent("switchSnowFlakes", root, core:get("Event", "SnowFlakes", EVENT_CHRISTMAS))
		triggerEvent("switchSnowGround", root, core:get("Event", "SnowGround", EVENT_CHRISTMAS), core:get("Event", "SnowGround_Extra", EVENT_CHRISTMAS))
	end
	if EVENT_EASTER_SLOTMACHINES_ACTIVE then --these are only slot machine textures
		Easter.updateTextures()
	end

	ItemSmokeGrenade:new() -- this is loaded here instead of beeing loaded in ItemManager.lua due to a shader-bug
	ExplosiveTruckManager:new()
	JewelryStoreRobberyManager:new()
	VehicleTurbo:new()
	PlaneManager:new()
	FileModdingHelper:new()
	PoliceAnnouncements:new()
	BlackJackTable:new()
	CasinoWheel:new()
	PedScale:new()
	VehicleGuns:new()
	HelicopterDrivebyManager:new()
	RcVanExtension:new()
end

function Core:afterLogin()
	Time:new()
	RadioGUI:new()
	HUDSpeedo:new()
	HUDAviation:new()
	HUDRadar:getSingleton():setEnabled(core:get("HUD", "showRadar", true))
	HUDUI:getSingleton():show()
	CustomF11Map:getSingleton():enable()
	GPS:new()
	Collectables:new()
	KeyBinds:new()
	Indicator:new()
	Tour:new()
	Achievement:new()
	BindManager:new()
	WheelOfFortune:new()
	Atrium:new()
	ElementInfoManager:new()
	AtmManager:new()
	PermissionsManager:new()
	if EVENT_HALLOWEEN then
		HalloweenEasterEggs:new()
	end
	if EVENT_EASTER then
		Easter:new()
	end

	for i = 1,#GUNBOX_CRATES do
		ElementInfo:new(GUNBOX_CRATES[i], "Waffenbox", 2)
	end
	if DEBUG then
		Debugging:new()
		DebugGUI.initalize()
	end

	-- Pre-Instantiate important GUIS

	ScoreboardGUI:new()
	ScoreboardGUI:getSingleton():close()


	localPlayer:setPlayTime()
	localPlayer:deactivateBlur(core:get("Shaders", "BlurLevel", false))

	setTimer(function()	NoDm:getSingleton():checkNoDm() end, 2500, 1)

	Fishing.load()
	TurtleRace.load()
	GUIForm3D.load()
	NonCollisionArea.load()
	TextureReplacer.loadBacklog()

	addCommandHandler("self", function() KeyBinds:getSingleton():selfMenu() end)
	addCommandHandler("fraktion", function() if localPlayer:getFaction() then FactionGUI:getSingleton():open() end end)
	addCommandHandler("unternehmen", function() if localPlayer:getCompany() then CompanyGUI:getSingleton():open() end end)
	addCommandHandler("report", function() TicketGUI:getSingleton():open() end)
	addCommandHandler("tickets", function() TicketGUI:getSingleton():open() end)
	addCommandHandler("bug", function() TicketGUI:getSingleton():open() end)
	--addCommandHandler("paintjob", function() PaintjobPreviewGUI:getSingleton():open() end)

	for index, object in pairs(getElementsByType("object")) do -- Make ATM´s unbreakable
		if object:getModel() == 2942 then
			object:setBreakable(false)
			table.insert(AppBank.ATMs, object)
		end
	end

	setElementData(localPlayer, "isEquipmentGUIOpen", false, true)

	setTimer(
		function()
			if localPlayer:isWorldLoaded() then
				triggerServerEvent("unfreezePlayer", localPlayer) -- do not unfreeze player on client cause of sync issues
				if isTimer(sourceTimer) then killTimer(sourceTimer) end
			end
		end, 1000, 0
	)
end

function Core:onWebSessionCreated() -- this gets called from LocalPlayer when the client recieves it's web session ID
	SelfGUI:new()
	SelfGUI:getSingleton():close()
	Phone:new()
	Phone:getSingleton():close()
	showChat(true)
end

function Core:checkDomainsWhitelist()
	for k, v in pairs(DOMAINS) do
		if Browser.isDomainBlocked(v) then
			Browser.requestDomains(DOMAINS, false, checkRequest)
			return
		end
	end
	killTimer(self.m_WhitelistChecker)
end

function Core:destructor()
	if HUDAviation:isInstantiated() then
		delete(HUDAviation:getSingleton())
	end
	delete(Cursor)
	delete(self.m_Config)
	delete(BindManager:getSingleton())
	if CustomModelManager:isInstantiated() then
		delete(CustomModelManager:getSingleton())
	end
end

function Core:getConfig()
	return self.m_Config
end

function Core:get(...)
	return self.m_Config:get(...)
end

function Core:set(...)
	return self.m_Config:set(...)
end

function Core:throwInternalError(message)
	triggerServerEvent("Core.onClientInternalError", root, message)
end


-- AntiCheat for blips // Workaround // this wont detect cheated blips
setTimer(
	function()
		local attachedBlips = {}
		for _, v in pairs(getElementsByType("blip")) do
			if v:isAttached() and getElementType(v:getAttachedTo()) == "player" and not v:getData("isGangwarBlip") then
				table.insert(attachedBlips, v)
			end
		end

		if #attachedBlips > 1 then
			triggerServerEvent("AntiCheat:ReportBlip", localPlayer, #attachedBlips)
		end
	end, 600000, 0
)
