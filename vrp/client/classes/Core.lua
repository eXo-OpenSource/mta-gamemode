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

	-- Events
	EventManager:new()
	DMRaceEvent:new()
	DeathmatchEvent:new()
	StreetRaceEvent:new()

	VehicleShop.initializeAll()
	VehicleGarages:new()
	GasStationGUI:new()
	SkinShopGUI.initializeAll()

	--// Gangwar
	GangwarClient:new()

	-- Init Binds
	bindKey(core:get("KeyBindings", "KeyToggleHelpGUI", "f9"), "down",
		function()
			if not HelpGUI:isInstantiated() then
				HelpGUI:new()
			else
				delete(HelpGUI:getSingleton())
			end
		end
	)
end

function Core:afterLogin()
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

	-- Phone
	Phone:new()
	Phone:getSingleton():close()
	bindKey(core:get("KeyBindings", "KeyTogglePhone", "u"), "down",
		function()
			Phone:getSingleton():toggle()
		end
	)

	bindKey(core:get("KeyBindings", "KeyTogglePolicePanel", "f4"), "down",
		function()
			if localPlayer:getJob() == JobPolice:getSingleton() then
				if PolicePanel:isInstantiated() then
					delete(PolicePanel:getSingleton())
				else
					PolicePanel:new()
				end
			end
		end
	)

	SelfGUI:new()
	SelfGUI:getSingleton():close()
	addCommandHandler("self", function() SelfGUI:getSingleton():open() end)


	FactionGUI:new()
	FactionGUI:getSingleton():close()
	addCommandHandler("fraktion", function() FactionGUI:getSingleton():open() end)

	ScoreboardGUI:getSingleton():close()
	bindKey(core:get("KeyBindings", "KeyToggleScoreboard", "tab"), "down", function() ScoreboardGUI:getSingleton():setVisible(true):bringToFront() end)
	bindKey(core:get("KeyBindings", "KeyToggleScoreboard", "tab"), "up", function() ScoreboardGUI:getSingleton():setVisible(false) end)

	WebPanel:getSingleton():close()
	bindKey(core:get("KeyBindings", "KeyToggleWebPanel", "f1"), "down", function() WebPanel:getSingleton():toggle() end)

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

	bindKey(core:get("KeyBindings", "KeyToggleSelfGUI", "f2"), "down",
		function ()
			if SelfGUI:getSingleton():isVisible() then
				SelfGUI:getSingleton():close()
			elseif CompanyGUI:getSingleton():isVisible() then
				CompanyGUI:getSingleton():close()
			elseif FactionGUI:getSingleton():isVisible() then
				FactionGUI:getSingleton():close()
			elseif GroupGUI:getSingleton():isVisible() then
				GroupGUI:getSingleton():close()
			elseif TicketGUI:getSingleton():isVisible() then
				TicketGUI:getSingleton():close()
			elseif AdminGUI:getSingleton():isVisible() then
				AdminGUI:getSingleton():close()
			elseif MigratorPanel:getSingleton():isVisible() then
				MigratorPanel:getSingleton():close()
			else
				SelfGUI:getSingleton():open()
			end
		end
	)
	-- TODO: Block end

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
