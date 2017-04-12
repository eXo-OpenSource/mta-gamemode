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
		Provider:getSingleton():requestFile("vrp.data", bind(DownloadGUI.onComplete, dgi), bind(DownloadGUI.onProgress, dgi))
		setAmbientSoundEnabled( "gunfire", false )
		showChat(true)
	end
end

function Core:onDownloadComplete()
	-- Instantiate all classes
	self:ready()

	-- create login gui
	lgi = LoginGUI:new()
	lgi:setVisible(false)
	lgi:fadeIn(750)

	local pwhash = core:get("Login", "password", "")
	local username = core:get("Login", "username", "")
	lgi.m_LoginEditUser:setText(username)
	lgi.m_LoginEditPass:setText(pwhash)
	lgi.usePasswordHash = pwhash
	lgi.m_LoginCheckbox:setChecked(pwhash ~= "")
	lgi:anyChange()

	-- other
	setAmbientSoundEnabled( "gunfire", false )
	showChat(true)
end

function Core:ready()
	-- Tell the server that we're ready to accept additional data
	triggerServerEvent("playerReady", root)

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
	DeathmatchEvent:new()
	StreetRaceEvent:new()
	VehicleGarages:new()
	ELSSystem:new()
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

	PlantWeed.initalize()
	ItemSellContract:new()
	Neon.initalize()
	AccessoireClothes:new()
	AccessoireClothes:triggerMode()
	EasterEgg:new()
	--MiamiSpawnGUI:new() -- Miami Spawn deactivated


	Shaders.load()

	GroupProperty:new()
	GUIWindowsFocus:new()
	--SprayWallManager:new()
	AntiClickSpam:new()
	GasStation:new()

	ChessSession:new()
	
	GroupRob:new() 
	
	WareClient:new()
	triggerServerEvent("drivingSchoolRequestSpeechBubble",localPlayer)

end

function Core:afterLogin()
	-- Request Browser Domains
	Browser.requestDomains{"exo-reallife.de"}

	RadioGUI:new()
	KarmaBar:new()
	HUDSpeedo:new()
	Nametag:new()
	HUDRadar:getSingleton():show()
	HUDUI:getSingleton():show()
	Collectables:new()
	KeyBinds:new()
	Indicator:new()
	Tour:new()
	Achievement:new()

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
	GUIForm3D.load()
	NonCollidingSphere.load()

	-- Miami Spawn deactivated:
	HUDRadar:getSingleton():setEnabled(true)
	showChat(true)
	setCameraTarget(localPlayer)
	setElementFrozen(localPlayer,false)
	triggerServerEvent("remoteClientSpawn", localPlayer)
	-- //Miami Spawn deactivated:

	--addCommandHandler("self", function() SelfGUI:getSingleton():open() end)
	addCommandHandler("self", function() KeyBinds:getSingleton():selfMenu() end)
	addCommandHandler("fraktion", function() FactionGUI:getSingleton():open() end)
	addCommandHandler("report", function() TicketGUI:getSingleton():open() end)
	addCommandHandler("tickets", function() TicketGUI:getSingleton():open() end)
	addCommandHandler("bug", function() TicketGUI:getSingleton():open() end)
	addCommandHandler("paintjob", function() PaintjobPreviewGUI:getSingleton():open() end)
	triggerServerEvent("requestVehicleTextures", localPlayer)

	for index, object in pairs(getElementsByType("object")) do -- Make ATM´s unbreakable
		if object:getModel() == 2942 then
			object:setBreakable(false)
		end
	end
end

function Core:destructor()
	delete(Cursor)
	delete(self.m_Config)
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


-- AntiCheat for blips // Workaround
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
