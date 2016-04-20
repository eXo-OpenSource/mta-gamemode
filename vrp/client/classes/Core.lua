Core = inherit(Object)

function Core:constructor()
	-- Small hack to get the global core immediately
	core = self

	-- Instantiate the localPlayer instance right now
	enew(localPlayer, LocalPlayer)

	self.m_Config = ConfigXML:new("config.xml")
	Version:new()
	Provider:new()

	Cursor = GUICursor:new()

	DownloadGUI:new()
	local dgi = DownloadGUI:getSingleton()
	Provider:getSingleton():requestFile("vrp.data", bind(DownloadGUI.onComplete, dgi), bind(DownloadGUI.onProgress, dgi))
	setAmbientSoundEnabled( "gunfire", false )
	showChat(true)
end

function Core:ready()
	-- Tell the server that we're ready to accept additional data
	triggerServerEvent("playerReady", root)

	TranslationManager:new()
	HelpTextManager:new()
	MTAFixes:new()
	ClickHandler:new()
	HoverHandler:new()
	CustomModelManager:new()
	--GangAreaManager:new()
	HelpBar:new()
	JobManager:new()
	AmmuLadder:new()
	HouseGUI:new()
	Housing:new()
	Achievement:new()
	TippManager:new()
	JailBreak:new()
	DimensionManager:new()
	Inventory:new()
	Guns:new()
	Casino:new()
	TrainManager:new()
	Fire:new()
	PublicTransport:new()
	VehicleInteraction:new()
	-- Events
	EventManager:new()
	DMRaceEvent:new()
	DeathmatchEvent:new()
	StreetRaceEvent:new()

	VehicleShop.initializeAll()
	VehicleGarages:new()
	ELSSystem:new()
	GasStationGUI:new()
	SkinShopGUI.initializeAll()
	ItemManager:new();
	--// Gangwar
	GangwarClient:new()
	KeyBinds:new()
	MostWanted:new()
	NoDm:new()

end

function Core:afterLogin()
	-- Request Browser Domains
	Browser.requestDomains{"exo-reallife.de", "maxcdn.bootstrapcdn.com"}

	RadioGUI:new()
	KarmaBar:new()
	HUDSpeedo:new()
	Nametag:new()
	HUDRadar:getSingleton():show()
	HUDUI:getSingleton():show()
	Collectables:new()

	if DEBUG then
		Debugging:new()
	end

	SelfGUI:new()
	SelfGUI:getSingleton():close()
	addCommandHandler("self", function() SelfGUI:getSingleton():open() end)

	FactionGUI:new()
	FactionGUI:getSingleton():close()
	addCommandHandler("fraktion", function() FactionGUI:getSingleton():open() end)

	ScoreboardGUI:new()
	ScoreboardGUI:getSingleton():close()

	Phone:new()
	Phone:getSingleton():close()

	WebPanel:getSingleton():close()

	-- Pre-Instantiate important GUIS
	-- TODO: I think we have to improve this block, currently i don't have an idea. (In my tests this takes ~32ms, relevant?)
	GroupGUI:new()
	GroupGUI:getSingleton():close()
	TicketGUI:new()
	TicketGUI:getSingleton():close()
	CompanyGUI:new()
	CompanyGUI:getSingleton():close()
	FactionGUI:new()
	FactionGUI:getSingleton():close()
	AdminGUI:new()
	AdminGUI:getSingleton():close()
	MigratorPanel:new()
	MigratorPanel:getSingleton():close()
	KeyBindings:new()
	KeyBindings:getSingleton():close()
	NoDm:getSingleton():checkNoDm()

	if not localPlayer:getJob() then
		-- Change text in help menu (to the main text)
		HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
	end

	self:createBlips()
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

function Core:createBlips()
	Blip:new("Bank.png", 1660.4, -1272.8)
end

function Core:throwInternalError(message)
	triggerServerEvent("Core.onClientInternalError", root, message)
end
