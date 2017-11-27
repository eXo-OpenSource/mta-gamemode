Core = inherit(Object)

function Core:constructor()
	-- Small hack to get the global core immediately
	core = self

	-- Instantiate the localPlayer instance right now
	enew(localPlayer, LocalPlayer)

	self.m_Config = ConfigXML:new("@config.xml")
	Version:new()
	Provider:new()

	Cursor = GUICursor:new()

	if HTTP_DOWNLOAD then -- In debug mode use old Provider
		showChat(false)

		Async.create( -- HTTPProvider needs asynchronous "context"
			function()
				fadeCamera(true)

				local dgi = HTTPDownloadGUI:getSingleton()
				local provider = HTTPProvider:new(FILE_HTTP_SERVER_URL, dgi)
				if provider:start() then -- did the download succeed
					delete(dgi)
					self:onDownloadComplete()
				else
					outputConsole("retrying download from different mirror")
					delete(dgi)
					local dgi = HTTPDownloadGUI:getSingleton()
					local provider = HTTPProvider:new(FILE_HTTP_FALLBACK_URL, dgi)
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
					bind(DownloadGUI.onProgress, dgi)
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

function Core:ready()
	-- Tell the server that we're ready to accept additional data
	triggerServerEvent("playerReady", root)

	-- Request Browser Domains
	Browser.requestDomains{"exo-reallife.de"}

	DxHelper:new()
	TranslationManager:new()
	HelpTextManager:new()
	MTAFixes:new()
	ClickHandler:new()
	HoverHandler:new()
	CustomModelManager:new()
	--GangAreaManager:new()
	HelpBar:new()
	JobManager:new()
	TippManager:new()
	--JailBreak:new()
	DimensionManager:new()
	Inventory:new()
	Guns:new()
	Casino:new()
	TrainManager:new()
	Fire:new()
	VehicleInteraction:new()
	EventManager:new()
	DMRaceEvent:new()
	StreetRaceEvent:new()
	VehicleGarages:new()
	SkinShopGUI.initializeAll()
	ItemManager:new()
	--// Gangwar
	GangwarClient:new()
	GangwarStatistics:new()

	MostWanted:new()
	NoDm:new()
	FactionManager:new()
	CompanyManager:new()
	DeathmatchManager:new()
	HorseRace:new()
	Townhall:new()
	PremiumArea:new()

	Plant.initalize()
	ItemSellContract:new()
	Neon.initalize()
	CoronaEffect.initalize()
	GroupSaleVehicles.initalize()
	AccessoireClothes:new()
	AccessoireClothes:triggerMode()
	EasterEgg:new()

	Shaders.load()

	GroupProperty:new()
	GUIWindowsFocus:new()
	--SprayWallManager:new()
	AntiClickSpam:new()
	GasStation:new()

	ChessSession:new()

	GroupRob:new()
	DrivingSchool:new()
	Help:new()
	ClientStatistics:new()
	Nametag:new()

	if EVENT_HALLOWEEN then
		Halloween:new()
	end

	if EVENT_CHRISTMAS then
		Christmas:new()
	end

end

function Core:afterLogin()
	RadioGUI:new()
	KarmaBar:new()
	HUDSpeedo:new()
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

	if DEBUG then
		Debugging:new()
		DebugGUI.initalize()
	end

	-- Pre-Instantiate important GUIS
	SelfGUI:new()
	SelfGUI:getSingleton():close()
	ScoreboardGUI:new()
	ScoreboardGUI:getSingleton():close()

	Phone:new()
	Phone:getSingleton():close()

	if not localPlayer:getJob() then
		-- Change text in help menu (to the main text)
		HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
	end

	localPlayer:setPlayTime()

	setTimer(function()	NoDm:getSingleton():checkNoDm() end, 2500, 1)

	PlantGUI.load()
	Fishing.load()
	TurtleRace.load()
	GUIForm3D.load()
	NonCollidingSphere.load()
	TextureReplacer.loadBacklog()

	showChat(true)
	setCameraTarget(localPlayer)
	setElementFrozen(localPlayer,false)

	addCommandHandler("self", function() KeyBinds:getSingleton():selfMenu() end)
	addCommandHandler("fraktion", function() FactionGUI:getSingleton():open() end)
	addCommandHandler("report", function() TicketGUI:getSingleton():open() end)
	addCommandHandler("tickets", function() TicketGUI:getSingleton():open() end)
	addCommandHandler("bug", function() TicketGUI:getSingleton():open() end)
	--addCommandHandler("paintjob", function() PaintjobPreviewGUI:getSingleton():open() end)

	for index, object in pairs(getElementsByType("object")) do -- Make ATM´s unbreakable
		if object:getModel() == 2942 then
			object:setBreakable(false)
		end
	end

end

function Core:destructor()
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
			if v:isAttached() and getElementType(v:getAttachedTo()) == "player" then
				table.insert(attachedBlips, v)
			end
		end

		if #attachedBlips > 1 then
			triggerServerEvent("AntiCheat:ReportBlip", localPlayer, #attachedBlips)
		end
	end, 600000, 0
)
